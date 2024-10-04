# Semantic Image Search App

## Features

- **Next.js App Router**
- **React Server Components (RSCs)**, Suspense, and Server Actions
- **Vercel AI SDK** for multimodal prompting, generating & embedding image metadata, and streaming images from Server to Client
- Support for **OpenAI** (default), **Gemini**, or custom AI chat models
- **shadcn/ui**
- Styling with **Tailwind CSS**
- **Radix UI** for headless component primitives
- Query caching with **Vercel KV**
- Embeddings powered by **Vercel Postgres**, **pgvector**, and **Drizzle ORM**
- File (image) storage with **Vercel Blob**

### Environment Variables

**Note:** Do not commit your `.env` file to version control.

### Install Dependencies

```bash
npm install
```

### Add OpenAI API Key

Add your OpenAI API Key to the `.env` file:

```
OPENAI_API_KEY=your-openai-api-key
```

### Database Setup

#### Vercel KV

```
KV_URL=
KV_REST_API_URL=
KV_REST_API_TOKEN=
KV_REST_API_READ_ONLY_TOKEN=
```

#### Vercel Postgres

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
npm run db:generate
npm run db:push
```

#### Vercel Blob

```
BLOB_READ_WRITE_TOKEN=
```

### Prepare Your Images (Indexing Step)

1. **Upload Images**

   Place `.jpg` images in the `images-to-index` directory. Run:

   ```bash
   npm run upload
   ```

2. **Generate Metadata**

   Run:

   ```bash
   npm run generate-metadata
   ```

3. **Embed Metadata and Save to Database**

   Run:

   ```bash
   npm run embed-and-save
   ```

### Running the Application

Start the development server:

```bash
npm run dev
```

The app should now be running at [http://localhost:3000](http://localhost:3000).
