# # Stage 1: Install dependencies and build the application
# FROM node:18-alpine AS builder

# # Install build dependencies (for node-gyp)
# RUN apk add --no-cache python3 make g++ 

# # Set working directory inside the container
# WORKDIR /app

# # Install dependencies
# COPY package.json package-lock.json ./
# RUN npm ci

# # Copy all files
# COPY . .

# # Build the Next.js project
# RUN npm run build

# # Stage 2: Production image to serve the Next.js app
# FROM node:18-alpine AS runner

# # Set working directory inside the container
# WORKDIR /app

# # Copy the built files from the builder stage
# COPY --from=builder /app/ ./

# # Install only production dependencies
# RUN npm ci

# # Expose the port where the app will run
# EXPOSE 3000

# # Command to start the Next.js application in production mode
# CMD ["npm", "start"]


# Stage 1: Install dependencies and build the application
FROM node:18-alpine AS builder

# Install build dependencies (for node-gyp)
RUN apk add --no-cache python3 make g++

# Set working directory inside the container
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy all files
COPY . .

# Build the Next.js project
RUN npm run build

# Stage 2: Production image to serve the Next.js app
FROM node:18-alpine AS runner

# Set working directory inside the container
WORKDIR /app

# Copy only necessary files from the build stage
COPY --from=builder /app/.next/ .next/
COPY --from=builder /app/public/ public/
COPY --from=builder /app/package.json ./

# Install only production dependencies (from the build stage)
COPY --from=builder /app/node_modules/ ./node_modules/

# Expose the port where the app will run
EXPOSE 3000

# Command to start the Next.js application in production mode
CMD ["npm", "start"]
