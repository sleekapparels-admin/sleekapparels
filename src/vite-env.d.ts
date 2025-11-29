/// <reference types="vite/client" />

// Explicitly extend ImportMetaEnv
interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL: string
  readonly VITE_SUPABASE_PUBLISHABLE_KEY: string
  readonly VITE_SUPABASE_PROJECT_ID: string
  readonly VITE_STRIPE_PUBLISHABLE_KEY: string
  // Vite defaults
  readonly BASE_URL: string
  readonly MODE: string
  readonly DEV: boolean
  readonly PROD: boolean
  readonly SSR: boolean
}

// Explicitly extend ImportMeta
interface ImportMeta {
  readonly env: ImportMetaEnv
  readonly hot?: any
  url: string
}
