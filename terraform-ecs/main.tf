provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "your-terraform-state-bucket" # Name of your S3 bucket for Terraform state
    key            = "terraform/ecs/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Create public subnets
resource "aws_subnet" "public_subnet" {
  count = 2
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = cidrsubnet(aws_vpc.my_vpc.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create an internet gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Route traffic through the internet gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "public_rt_assoc" {
  count = 2
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Create a security group for ECS tasks
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}

# Create ECR repository
resource "aws_ecr_repository" "my_ecr_repo" {
  name = "nextjs-app"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "nextjs-app-ecr"
  }
}

# Create ECS Cluster
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "nextjs-cluster"
  capacity_providers = ["FARGATE"]
  tags = {
    Name = "nextjs-ecs-cluster"
  }
}

# Create ECS Task Definition
resource "aws_ecs_task_definition" "my_task_definition" {
  family = "nextjs-app-task"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"
  
  container_definitions = jsonencode([{
    name      = "nextjs-container"
    image     = "${aws_ecr_repository.my_ecr_repo.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# Create ECS Service
resource "aws_ecs_service" "my_ecs_service" {
  name = "nextjs-ecs-service"
  cluster = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.my_task_definition.arn
  desired_count = 1
  launch_type = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.public_subnet[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
    container_name   = "nextjs-container"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.frontend_listener]
}

# Create Application Load Balancer
resource "aws_lb" "my_load_balancer" {
  name = "nextjs-load-balancer"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ecs_sg.id]
  subnets = aws_subnet.public_subnet[*].id

  tags = {
    Name = "nextjs-alb"
  }
}

# Create Target Group
resource "aws_lb_target_group" "my_lb_target_group" {
  name     = "nextjs-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
  target_type = "ip"
}

# Create Listener
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port     = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }
}

# Create IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}
