/// <reference types="vite/client" />

// Extend Vite's ImportMetaEnv with our custom environment variables
interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL: string
  readonly VITE_SUPABASE_PUBLISHABLE_KEY: string
  readonly VITE_SUPABASE_PROJECT_ID: string
  readonly VITE_STRIPE_PUBLISHABLE_KEY: string
}
