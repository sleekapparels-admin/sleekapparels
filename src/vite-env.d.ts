declare global {
  interface ImportMetaEnv {
    readonly VITE_SUPABASE_URL: string
    readonly VITE_SUPABASE_PUBLISHABLE_KEY: string
    readonly VITE_SUPABASE_PROJECT_ID: string
    readonly VITE_STRIPE_PUBLISHABLE_KEY: string
    readonly DEV: boolean
    readonly MODE: string
    readonly PROD: boolean
  }

  interface ImportMeta {
    readonly env: ImportMetaEnv
    glob(
      pattern: string,
      options?: {
        eager?: boolean
        as?: 'raw' | 'url'
        import?: string
      }
    ): Record<string, any>
  }
}

declare module '*.svg' {
  const content: string
  export default content
}

declare module '*.webp' {
  const content: string
  export default content
}

declare module '*.png' {
  const content: string
  export default content
}

declare module '*.jpg' {
  const content: string
  export default content
}

declare module '*.jpeg' {
  const content: string
  export default content
}

declare module '*.gif' {
  const content: string
  export default content
}

declare module '@/assets/*' {
  const content: string
  export default content
}

export {}
