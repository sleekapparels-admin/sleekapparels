# AI Agent Development Guide

**Project**: Sleek Apparels - LoopTrace™ Platform  
**Backend**: Lovable Cloud (Supabase)  
**Architecture**: React + Vite + TypeScript + Supabase

This guide provides AI coding agents with comprehensive project context for effective collaboration.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Edge Functions Reference](#edge-functions-reference)
- [Key Components](#key-components)
- [Code Patterns](#code-patterns)
- [What You Can Do](#what-you-can-do)
- [What Requires Lovable](#what-requires-lovable)
- [Security Rules](#security-rules)

---

## Project Overview

**Sleek Apparels** is a B2B apparel manufacturing platform offering the **LoopTrace™** SaaS product - an AI-powered quality verification and real-time production tracking system.

### Business Model

- **Two-sided marketplace**: Buyers (brands) + Suppliers (manufacturers)
- **Sleek Apparels acts as intermediary** in both directions
- **Beta launch strategy**: Free until Dec 31, 2025 → Paid tiers (Growth/Scale)

### Core Value Propositions

1. **Low MOQ**: 50 pieces minimum (industry standard: 500+)
2. **AI-Powered Quotes**: Real-time market research + instant pricing
3. **LoopTrace™ Tracking**: Real-time production visibility
4. **Quality Assurance**: AI-powered risk prediction

---

## Tech Stack

### Frontend

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **React Router v6** - Client-side routing
- **Tailwind CSS** - Styling (semantic tokens in `index.css`)
- **shadcn/ui** - Component library
- **Framer Motion** - Animations
- **Lucide React** - Icons
- **React Query** - Server state management
- **Zustand** - Client state management

### Backend (Lovable Cloud)

- **Supabase** - PostgreSQL database
- **Edge Functions** - Deno-based serverless functions
- **Row Level Security (RLS)** - Database access control
- **Supabase Auth** - Authentication system
- **Supabase Storage** - File storage
- **Supabase Realtime** - WebSocket subscriptions

### Integrations

- **Stripe** - Payment processing
- **Resend** - Transactional emails
- **Lovable AI Gateway** - AI model access (Gemini, GPT)
- **Perplexity AI** - Real-time web search for market research
- **Google reCAPTCHA v2** - Bot protection

---

## Project Structure

```text
sleek-apparels/
├── src/
│   ├── components/          # React components
│   │   ├── admin/           # Admin dashboard components
│   │   ├── buyer/           # Buyer dashboard components  
│   │   ├── supplier/        # Supplier dashboard components
│   │   ├── marketing/       # Homepage, landing pages
│   │   └── ui/              # shadcn/ui components
│   ├── pages/               # Route pages
│   │   ├── Index.tsx        # Homepage
│   │   ├── Auth.tsx         # Login/signup
│   │   ├── Dashboard.tsx    # Buyer dashboard
│   │   ├── SupplierDashboard.tsx
│   │   ├── AdminDashboard.tsx
│   │   └── ...
│   ├── hooks/               # Custom React hooks
│   ├── lib/                 # Utility functions
│   ├── integrations/        # External integrations
│   │   └── supabase/        # Supabase client & types
│   ├── App.tsx              # Root component + routing
│   ├── main.tsx             # Entry point
│   └── index.css            # Global styles + design tokens
├── supabase/
│   ├── functions/           # Edge functions (Deno)
│   │   ├── ai-conversational-quote/
│   │   ├── ai-market-research/
│   │   ├── create-payment-intent/
│   │   ├── send-otp/
│   │   └── ...
│   ├── migrations/          # SQL migration files
│   └── config.toml          # Edge function config
├── docs/                    # Documentation
├── public/                  # Static assets
└── .env.local              # Local environment variables
```

---

## Database Schema

### Key Tables

#### `profiles`

User profile data (linked to `auth.users` via `id`)

```typescript
{
  id: string (uuid, primary key)
  email: string
  full_name: string
  phone: string
  company_name: string
  role: 'buyer' | 'supplier' | 'admin'
  address: string
  bio: string
  phone_verified: boolean
  created_at: timestamp
  updated_at: timestamp
}
```

**RLS**: Users can only view/update their own profile; admins see all.

#### `orders`

Production orders from buyers

```typescript
{
  id: string (uuid, primary key)
  order_number: string (unique, e.g., "SLK-2024-001")
  buyer_id: string (references profiles.id)
  supplier_id: string (references suppliers.id, nullable)
  product_type: string
  quantity: number
  buyer_price: number
  supplier_price: number
  admin_margin: number
  status: string ('pending' | 'in_production' | 'completed')
  workflow_status: enum (order_workflow_status)
  payment_status: string
  created_at: timestamp
  updated_at: timestamp
  expected_delivery_date: timestamp
  tracking_token: string (unique, for public tracking)
}
```

**RLS**: Buyers see only their orders; suppliers see assigned orders; admins see all.

#### `ai_quotes`

AI-generated instant quotes

```typescript
{
  id: string (uuid, primary key)
  session_id: string (for anonymous quote tracking)
  user_id: string (nullable, if authenticated)
  product_type: string
  quantity: number
  total_price: number
  estimated_delivery_days: number
  quote_data: json (detailed breakdown)
  confidence_score: number (0-100)
  price_justification: text
  research_sources: json[]
  status: string ('pending' | 'approved' | 'converted')
  created_at: timestamp
}
```

**RLS**: 5-minute session window + IP binding for anonymous quotes.

#### `suppliers`

Registered manufacturing suppliers

```typescript
{
  id: string (uuid, primary key)
  company_name: string
  contact_person: string
  email: string
  phone: string
  business_registration_number: string
  specialization: string[]
  factory_location: string
  capacity_units_per_month: number
  certifications: string[]
  rating: number (0-5)
  status: string ('pending' | 'verified' | 'active')
  created_at: timestamp
}
```

**RLS**: Public view (restricted fields); full access for admins.

#### `production_stages`

Granular production tracking

```typescript
{
  id: string (uuid, primary key)
  supplier_order_id: string (references supplier_orders.id)
  stage_name: string
  stage_number: number
  status: string ('pending' | 'in_progress' | 'completed')
  completion_percentage: number
  photos: string[]
  notes: text
  started_at: timestamp
  completed_at: timestamp
  updated_by: string
}
```

**RLS**: Buyers see stages for their orders; suppliers can update assigned stages.

---

## Edge Functions Reference

All edge functions are deployed at:  
`https://eqpftggctumujhutomom.supabase.co/functions/v1/{function-name}`

### Public Functions (No Auth Required)

#### `ai-market-research`

**Purpose**: Real-time market research via Perplexity AI  
**Method**: POST  
**Request**:

```json
{
  "productType": "t-shirts",
  "quantity": 500,
  "specifications": "100% cotton, custom print"
}
```

**Response**:

```json
{
  "research": {
    "averageMarketPrice": 8.50,
    "priceRange": { "min": 6.00, "max": 12.00 },
    "materialCosts": { "fabric": 3.20, "labor": 2.50 },
    "sources": ["alibaba.com", "thomasnet.com"]
  }
}
```

**Rate Limit**: 10 requests/hour per IP

#### `ai-conversational-quote`

**Purpose**: Generate AI-powered instant quotes  
**Method**: POST  
**Request**:

```json
{
  "message": "I need 1000 custom hoodies with logo embroidery",
  "conversationHistory": []
}
```

**Response**:

```json
{
  "reply": "Based on market research...",
  "quote": {
    "totalPrice": 15000,
    "pricePerUnit": 15.00,
    "estimatedDeliveryDays": 45,
    "confidenceScore": 87
  }
}
```

**Rate Limit**: 5 requests/hour per IP, 10/day per email

#### `send-otp`

**Purpose**: Send email OTP for registration  
**Method**: POST  
**Request**:

```json
{
  "email": "user@example.com",
  "sessionId": "uuid-session-id",
  "recaptchaToken": "google-recaptcha-token"
}
```

**Response**:

```json
{
  "success": true,
  "message": "OTP sent to email"
}
```

### Authenticated Functions (JWT Required)

#### `create-payment-intent`

**Purpose**: Create Stripe payment intent for orders  
**Method**: POST  
**Headers**: `Authorization: Bearer {JWT}`  
**Request**:

```json
{
  "quoteId": "uuid-quote-id",
  "amount": 5000
}
```

**Response**:

```json
{
  "clientSecret": "pi_xxx_secret_xxx",
  "paymentIntentId": "pi_xxx"
}
```

#### `generate-invoice`

**Purpose**: Auto-generate invoice PDF when order completes  
**Method**: POST (triggered automatically)  
**Request**:

```json
{
  "orderId": "uuid-order-id"
}
```

**Response**:

```json
{
  "invoiceUrl": "https://storage.supabase.co/...",
  "invoiceNumber": "INV-2024-001"
}
```

#### `ai-supplier-assignment`

**Purpose**: Smart supplier matching using AI  
**Method**: POST  
**Headers**: `Authorization: Bearer {JWT}`  
**Request**:

```json
{
  "orderId": "uuid-order-id"
}
```

**Response**:

```json
{
  "recommendations": [
    {
      "supplierId": "uuid",
      "supplierName": "ABC Garments",
      "confidenceScore": 92,
      "reasoning": "Specializes in hoodies, high capacity..."
    }
  ]
}
```

---

## Key Components

### Authentication

**File**: `src/pages/Auth.tsx`

```tsx
import { supabase } from "@/integrations/supabase/client";

// Signup
const { data, error } = await supabase.auth.signUp({
  email: "user@example.com",
  password: "secure-password",
  options: {
    data: {
      full_name: "John Doe",
      role: "buyer"
    }
  }
});

// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: "user@example.com",
  password: "secure-password"
});

// Get current user
const { data: { user } } = await supabase.auth.getUser();
```

### Database Queries

**Pattern**: Use Supabase client with automatic RLS enforcement

```tsx
import { supabase } from "@/integrations/supabase/client";

// Query with RLS
const { data: orders, error } = await supabase
  .from('orders')
  .select('*')
  .eq('buyer_id', userId)
  .order('created_at', { ascending: false });

// Insert with RLS
const { data, error } = await supabase
  .from('ai_quotes')
  .insert({
    product_type: 't-shirts',
    quantity: 500,
    total_price: 5000,
    user_id: userId
  });
```

### Realtime Subscriptions

**Pattern**: Subscribe to table changes for live updates

```tsx
import { supabase } from "@/integrations/supabase/client";
import { useEffect } from "react";

useEffect(() => {
  const channel = supabase
    .channel('orders-changes')
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'orders',
        filter: `buyer_id=eq.${userId}`
      },
      (payload) => {
        console.log('Order updated:', payload.new);
        // Update UI state
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}, [userId]);
```

### Edge Function Calls

**Pattern**: Use `supabase.functions.invoke()`

```tsx
import { supabase } from "@/integrations/supabase/client";

const { data, error } = await supabase.functions.invoke('ai-market-research', {
  body: {
    productType: 't-shirts',
    quantity: 500
  }
});

if (error) {
  console.error('Function error:', error);
  return;
}

console.log('Research results:', data);
```

---

## Code Patterns

### 1. **Use Semantic Color Tokens**

❌ **Bad**:

```tsx
<div className="bg-white text-black">
```

✅ **Good**:

```tsx
<div className="bg-background text-foreground">
```

All colors defined in `src/index.css` using HSL values:

- `--background` - Main background color
- `--foreground` - Main text color
- `--primary` - Brand accent color
- `--secondary` - Secondary surfaces
- `--muted` - Muted text/backgrounds
- `--accent` - Accent highlights

### 2. **Always Use TypeScript Types from Supabase**

❌ **Bad**:

```tsx
const orders: any[] = data;
```

✅ **Good**:

```tsx
import { Database } from "@/integrations/supabase/types";

type Order = Database['public']['Tables']['orders']['Row'];
const orders: Order[] = data;
```

### 3. **Error Handling Pattern**

```tsx
const { data, error } = await supabase
  .from('orders')
  .select('*');

if (error) {
  console.error('Database error:', error);
  toast({
    title: "Error loading orders",
    description: error.message,
    variant: "destructive"
  });
  return;
}

// Use data safely
```

### 4. **Loading States**

```tsx
const [loading, setLoading] = useState(false);

const handleSubmit = async () => {
  setLoading(true);
  try {
    await someAsyncOperation();
    toast({ title: "Success!" });
  } catch (error) {
    toast({ title: "Error", variant: "destructive" });
  } finally {
    setLoading(false);
  }
};

<Button disabled={loading}>
  {loading ? "Processing..." : "Submit"}
</Button>
```

### 5. **React Query for Server State**

```tsx
import { useQuery } from "@tanstack/react-query";

const { data: orders, isLoading, error } = useQuery({
  queryKey: ['orders', userId],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('buyer_id', userId);
    
    if (error) throw error;
    return data;
  }
});
```

---

## What You Can Do

### ✅ Freely Edit

- **React Components**: Create, modify, delete `.tsx` files in `src/components/`
- **Pages**: Add routes in `src/pages/` and update `src/App.tsx`
- **Styling**: Update Tailwind classes, modify `src/index.css` semantic tokens
- **Hooks**: Create custom hooks in `src/hooks/`
- **Utils**: Add utility functions in `src/lib/`
- **Edge Function Code**: Write/edit code in `supabase/functions/` (deployment requires Lovable)
- **SQL Migrations**: Write `.sql` files in `supabase/migrations/` (execution requires Lovable)

### ✅ Test Locally

- Run dev server: `npm run dev`
- Test database queries via Supabase client
- Call edge functions (after deployed in Lovable)
- Test authentication flows
- Verify RLS policies

### ✅ Install Packages

```bash
npm install <package-name>
```

Example: `npm install recharts` for charts

---

## What Requires Lovable

### ❌ Cannot Do Externally

- **Execute SQL Migrations**: Must run in Lovable Cloud → Database
- **Deploy Edge Functions**: Must deploy via Lovable tools
- **Add Secrets**: API keys managed in Lovable Secrets tool
- **Modify RLS Policies**: Requires migration execution in Lovable
- **Create Storage Buckets**: Managed in Lovable Cloud UI
- **Production Deploy**: Click "Update" in Lovable Publish dialog
- **Modify Auto-Generated Files**:
  - `src/integrations/supabase/types.ts`
  - `src/integrations/supabase/client.ts`
  - `.env`

---

## Security Rules

### 🔒 Critical Security Requirements

#### 1. **Never Expose Secrets**

❌ **NEVER**:

```tsx
const API_KEY = "sk_live_xxx"; // NEVER hardcode secrets
```

✅ **ALWAYS**:

```typescript
// In edge function
const apiKey = Deno.env.get("STRIPE_SECRET_KEY");
```

Secrets are managed in Lovable Secrets tool, accessed via `Deno.env.get()` in edge functions.

#### 2. **Use RLS Policies**

All tables MUST have RLS enabled with appropriate policies.

**Example**: Users can only see their own orders

```sql
CREATE POLICY "Users view own orders"
ON orders FOR SELECT
USING (auth.uid() = buyer_id);
```

#### 3. **Validate User Input**

Always validate and sanitize user input:

```tsx
import { z } from "zod";

const quoteSchema = z.object({
  productType: z.string().min(1).max(100),
  quantity: z.number().min(50).max(100000)
});

const validated = quoteSchema.parse(userInput);
```

#### 4. **Prevent SQL Injection**

✅ Use Supabase client (parameterized queries):

```tsx
const { data } = await supabase
  .from('orders')
  .select('*')
  .eq('order_number', userInput); // Safe
```

❌ Never construct raw SQL with user input

#### 5. **Rate Limiting**

All public endpoints must implement rate limiting:

```typescript
// Check rate limit before expensive operations
const { count } = await supabase
  .from('ai_quote_rate_limits')
  .select('*', { count: 'exact' })
  .eq('identifier', ipAddress)
  .gte('window_start', new Date(Date.now() - 3600000));

if (count >= 10) {
  return new Response('Rate limit exceeded', { status: 429 });
}
```

#### 6. **Authentication for Sensitive Data**

Financial, PII, and admin operations require JWT authentication:

```typescript
// In edge function
const authHeader = req.headers.get('Authorization');
if (!authHeader) {
  return new Response('Unauthorized', { status: 401 });
}

const token = authHeader.replace('Bearer ', '');
const { data: { user }, error } = await supabaseClient.auth.getUser(token);

if (error || !user) {
  return new Response('Invalid token', { status: 401 });
}
```

#### 7. **SECURITY DEFINER Functions Must Set search_path**

All PostgreSQL SECURITY DEFINER functions MUST include:

```sql
CREATE OR REPLACE FUNCTION my_secure_function()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public -- CRITICAL: Prevents privilege escalation
AS $$
BEGIN
  -- Function logic
END;
$$;
```

---

## User Roles & Permissions

### Buyer

- Can create quotes
- View own orders
- Track order progress via LoopTrace™
- Make payments
- View own profile

### Supplier

- View assigned orders
- Update production stages
- Upload progress photos
- Communicate with buyers
- View own metrics

### Admin

- Full access to all data
- Approve quotes
- Assign suppliers to orders
- Manage CMS content
- View analytics
- Configure automation rules

---

## Testing Guidelines

### Before Committing Changes

1. **Run TypeScript check**: `npm run type-check` (if available)
2. **Test locally**: `npm run dev` and verify in browser
3. **Check console**: No errors in browser DevTools console
4. **Verify RLS**: Test with different user roles if modifying queries
5. **Test edge cases**: Empty states, loading states, error states

### Example Test Checklist

```markdown
- [ ] Component renders without errors
- [ ] Loading states display correctly
- [ ] Error states handled gracefully
- [ ] Success messages appear
- [ ] Data fetches correctly
- [ ] Mutations update UI optimistically
- [ ] Mobile responsive
- [ ] Accessibility (keyboard navigation, ARIA labels)
- [ ] No console errors
```

---

## Common Pitfalls to Avoid

### ❌ Don't Do This

1. **Modifying auto-generated files**
   - `src/integrations/supabase/types.ts`
   - `src/integrations/supabase/client.ts`

2. **Hardcoding environment variables**

   ```tsx
   const SUPABASE_URL = "https://xxx.supabase.co"; // ❌
   ```

   Use: `import.meta.env.VITE_SUPABASE_URL`

3. **Ignoring TypeScript errors**
   - Always fix type errors, don't use `any` or `@ts-ignore`

4. **Direct DOM manipulation**

   ```tsx
   document.getElementById('btn').innerHTML = 'Click'; // ❌
   ```

   Use React state and JSX

5. **Skipping RLS policies**
   - Every table with user data MUST have RLS enabled

6. **Exposing sensitive data in URLs**

---

## Remember

> "External IDEs handle frontend code and can write backend code. Lovable Cloud executes backend deployments, migrations, and manages secrets. GitHub is the source of truth connecting everything."

Happy coding! 🚀
