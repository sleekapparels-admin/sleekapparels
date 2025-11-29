# Environment Setup Guide

This guide will help you configure your local development environment for Sleek Apparels.

## Quick Start

1. **Copy the environment template:**
   ```bash
   cp .env.example .env.local
   ```

2. **Configure required variables** (see sections below)

3. **Start development server:**
   ```bash
   npm run dev
   ```

## Required Environment Variables

### Supabase Configuration

Sleek Apparels uses Supabase as the primary backend. You **must** configure these variables:

```
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-public-key-here
```

**How to obtain:**
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project (or create one)
3. Navigate to **Settings** → **API**
4. Copy:
   - **Project URL** → `VITE_SUPABASE_URL`
   - **anon public** key → `VITE_SUPABASE_PUBLISHABLE_KEY`

⚠️ **Important:** Use the **anon/public** key, NOT the service_role key. The service role key should only be used server-side.

## Optional Environment Variables

### Stripe Payment Configuration

If you're working on payment features:

```
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

**How to obtain:**
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Switch to **Test mode** (toggle in top right)
3. Navigate to **Developers** → **API keys**
4. Copy the **Publishable key**

### Application Configuration

```
VITE_APP_URL=http://localhost:5173
VITE_ENVIRONMENT=development
```

- `VITE_APP_URL`: Base URL for the application (default: `http://localhost:5173`)
- `VITE_ENVIRONMENT`: Current environment (development/staging/production)

### Analytics

```
VITE_GA_MEASUREMENT_ID=G-XXXXXXXXXX
```

Google Analytics measurement ID (optional for local development).

### Feature Flags

Enable/disable specific features:

```
VITE_ENABLE_AI_FEATURES=true
VITE_ENABLE_PRODUCTION_TRACKING=true
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG_MODE=true
```

## Automatic Vite Variables

These variables are automatically provided by Vite and **should NOT** be added to your `.env` file:

- `import.meta.env.DEV` - `true` in development mode
- `import.meta.env.PROD` - `true` in production mode
- `import.meta.env.MODE` - Current mode (development/production)
- `import.meta.env.BASE_URL` - Base URL path

## Environment-Specific Configuration

### Development

```
VITE_APP_URL=http://localhost:5173
VITE_ENVIRONMENT=development
VITE_ENABLE_DEBUG_MODE=true
```

### Staging

```
VITE_APP_URL=https://staging.sleekapparels.com
VITE_ENVIRONMENT=staging
VITE_ENABLE_DEBUG_MODE=false
```

### Production

```
VITE_APP_URL=https://sleekapparels.com
VITE_ENVIRONMENT=production
VITE_ENABLE_DEBUG_MODE=false
VITE_ENABLE_ANALYTICS=true
```

## Security Best Practices

### DO:
✅ Store `.env.local` locally (never commit to git)
✅ Use `.env.example` as a template (safe to commit)
✅ Use different Supabase projects for dev/staging/production
✅ Use Stripe test keys for development
✅ Rotate keys periodically

### DON'T:
❌ Commit `.env` or `.env.local` files to git
❌ Share your Supabase keys publicly
❌ Use production keys in development
❌ Use service_role keys in client-side code
❌ Hard-code sensitive values in source code

## Troubleshooting

### Missing Environment Variables

**Error:** `Missing required Supabase configuration`

**Solution:** Ensure `VITE_SUPABASE_URL` and `VITE_SUPABASE_PUBLISHABLE_KEY` are set in `.env.local`

### Invalid Supabase URL

**Error:** `Invalid Supabase URL format`

**Solution:** URL should be in format `https://[project-id].supabase.co`

### Build Fails with Environment Errors

**Solution:**
1. Verify all required variables are set
2. Check for typos in variable names (must start with `VITE_`)
3. Restart the development server after changing `.env.local`

### Variables Not Updating

**Solution:**
1. Stop the development server (Ctrl+C)
2. Clear Vite cache: `rm -rf .vite`
3. Restart: `npm run dev`

## Deployment Configuration

When deploying to Vercel, Netlify, or other platforms:

1. **Add environment variables** in the platform's dashboard
2. **Mark sensitive variables** as secret/encrypted
3. **Set different values** for staging and production environments
4. **Test configuration** in preview/staging deployments first

### Vercel

1. Go to Project Settings → Environment Variables
2. Add each variable
3. Select environment (Production/Preview/Development)
4. Deploy

### Netlify

1. Go to Site Settings → Build & deploy → Environment
2. Add environment variables
3. Trigger redeploy

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Stripe API Keys](https://stripe.com/docs/keys)
- [Security Best Practices](../SECURITY.md)

## Need Help?

- Check [Quick Start Guide](./quick-start.md)
- Review [Architecture Documentation](../architecture/)
- Contact the development team

---

*Last Updated: November 29, 2025*
