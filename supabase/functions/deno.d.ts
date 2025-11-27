// Deno global type declarations for Supabase Edge Functions
// These functions run on Deno runtime, not Node.js

declare namespace Deno {
  export const env: {
    get(key: string): string | undefined;
    toObject(): Record<string, string>;
  };

  export interface ConnInfo {
    readonly remoteAddr: {
      transport: "tcp" | "udp";
      hostname: string;
      port: number;
    };
  }
}

// Deno standard library types
declare module "https://deno.land/std@*/http/server.ts" {
  export function serve(
    handler: (request: Request) => Response | Promise<Response>,
    options?: {
      port?: number;
      hostname?: string;
      signal?: AbortSignal;
      onError?: (error: unknown) => Response | Promise<Response>;
      onListen?: (params: { hostname: string; port: number }) => void;
    }
  ): void;
}

// ESM.sh Supabase types
declare module "https://esm.sh/@supabase/supabase-js@*" {
  export * from "@supabase/supabase-js";
  export { createClient } from "@supabase/supabase-js";
}

declare global {
  const Deno: typeof Deno;
}

export {};
