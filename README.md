# Semantic Image Search App

## Features

- **Next.js App Router**
- **React Server Components (RSCs)**, Suspense, and Server Actions
- **Vercel AI SDK** for multimodal prompting, generating & embedding image metadata, and streaming images from Server to Client
- Support for **OpenAI** (default), **Gemini**, **Anthropic**, **Cohere**, or custom AI chat models
- **shadcn/ui**
- Styling with **Tailwind CSS**
- **Radix UI** for headless component primitives
- Query caching with **Vercel KV**
- Embeddings powered by **Vercel Postgres**, **pgvector**, and **Drizzle ORM**
- File (image) storage with **Vercel Blob**

## Model Providers

This template ships with **OpenAI GPT-4** as the default. Thanks to the **Vercel AI SDK**, you can switch LLM providers to Gemini, Anthropic, Cohere, and more with just a few lines of code.

## Deploy Your Own

You can deploy your own version of the Semantic Image Search App to Vercel with one click:

[![Deploy with Vercel](https://vercel.com/button)](#)

## Setup

### Prerequisites

- [Vercel CLI](https://vercel.com/docs/cli)
- [pnpm](https://pnpm.io/)

### Environment Variables

Copy `.env.example` to `.env` and fill in the required variables. It's recommended to use Vercel Environment Variables, but a local `.env` file is sufficient.

**Note:** Do not commit your `.env` file to version control.

### Install Dependencies

```bash
pnpm install
```

### Add OpenAI API Key

Add your OpenAI API Key to the `.env` file:

```
OPENAI_API_KEY=your-openai-api-key
```

### Database Setup

#### Vercel KV

Follow the [Vercel KV Quick Start Guide](https://vercel.com/docs/storage/vercel-kv/quickstart) to create a KV database instance. Update the following environment variables in your `.env` file:

```
KV_URL=
KV_REST_API_URL=
KV_REST_API_TOKEN=
KV_REST_API_READ_ONLY_TOKEN=
```

#### Vercel Postgres

Follow the [Vercel Postgres Quick Start Guide](https://vercel.com/docs/storage/vercel-postgres/quickstart) to create a Postgres database instance. Enable `pgvector` by running:

```sql
CREATE EXTENSION vector;
```

Update the following environment variables in your `.env` file:

```
POSTGRES_URL=
POSTGRES_PRISMA_URL=
POSTGRES_URL_NON_POOLING=
POSTGRES_USER=
POSTGRES_HOST=
POSTGRES_PASSWORD=
POSTGRES_DATABASE=
```

Push your schema changes:

```bash
pnpm run db:generate
pnpm run db:push
```

#### Vercel Blob

Follow the [Vercel Blob Quick Start Guide](https://vercel.com/docs/storage/vercel-blob/quickstart) to create a Blob storage instance. Update the following environment variable in your `.env` file:

```
BLOB_READ_WRITE_TOKEN=
```

### Prepare Your Images (Indexing Step)

1. **Upload Images**

   Place `.jpg` images in the `images-to-index` directory. Run:

   ```bash
   pnpm run upload
   ```

2. **Generate Metadata**

   Run:

   ```bash
   pnpm run generate-metadata
   ```

3. **Embed Metadata and Save to Database**

   Run:

   ```bash
   pnpm run embed-and-save
   ```

### Running the Application

Start the development server:

```bash
pnpm run dev
```

Your app should now be running at [http://localhost:3000](http://localhost:3000).