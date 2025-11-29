/// <reference types="vite/client" />

/**
 * Global type declarations for Vite environment variables
 * This file serves as a supplementary type declaration to ensure
 * import.meta.env is properly typed throughout the application.
 */

declare global {
  interface ImportMetaEnv {
    // Required Supabase variables
    readonly VITE_SUPABASE_URL: string
    readonly VITE_SUPABASE_PUBLISHABLE_KEY: string
    
    // Optional configuration variables
    readonly VITE_SUPABASE_PROJECT_ID?: string
    readonly VITE_STRIPE_PUBLISHABLE_KEY?: string
    readonly VITE_GA_MEASUREMENT_ID?: string
    readonly VITE_APP_URL?: string
    readonly VITE_ENVIRONMENT?: string
    readonly VITE_ENABLE_AI_FEATURES?: string
    readonly VITE_ENABLE_PRODUCTION_TRACKING?: string
    readonly VITE_ENABLE_ANALYTICS?: string
    readonly VITE_ENABLE_DEBUG_MODE?: string
    
    // Vite built-in variables
    readonly DEV: boolean
    readonly PROD: boolean
    readonly MODE: string
    readonly BASE_URL: string
  }

  interface ImportMeta {
    readonly env: ImportMetaEnv
  }
}

export {}
