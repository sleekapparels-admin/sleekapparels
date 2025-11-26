# External IDE Development Workflow

This guide explains how to develop the Sleek Apparels platform using external IDEs (Project IDX, Cursor, VSCode, etc.) while maintaining Lovable Cloud as the backend provider.

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture Overview](#architecture-overview)
- [What Lives Where](#what-lives-where)
- [Development Workflows](#development-workflows)
- [Multi-Agent Coordination](#multi-agent-coordination)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/sleek-apparels.git
cd sleek-apparels
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Set Up Environment Variables

```bash
cp .env.local.example .env.local
```

The `.env.local` file contains pre-configured credentials for Lovable Cloud backend. **Do not modify these values.**

### 4. Start Development Server

```bash
npm run dev
```

Your app will be available at `http://localhost:8080`

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL IDE (Your Local)                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Frontend Code (React, Components, Pages, Hooks)      │  │
│  │  • Modify freely                                      │  │
│  │  • Test locally with npm run dev                      │  │
│  │  • Push to GitHub when ready                          │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↓                                  │
│                      git push                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                         GITHUB                               │
│                   (Source of Truth)                          │
│           • Bidirectional sync with Lovable                  │
│           • All agents push/pull from here                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      LOVABLE CLOUD                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Backend Services (Managed by Lovable)               │  │
│  │  • Supabase Database + RLS Policies                   │  │
│  │  • Edge Functions Deployment                          │  │
│  │  • Storage Buckets                                    │  │
│  │  • Authentication                                      │  │
│  │  • Secrets Management                                 │  │
│  │  • Production Deployment                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## What Lives Where

| Component | External IDE | Lovable | Notes |
|-----------|--------------|---------|-------|
| **Frontend Code** | ✅ Edit freely | ✅ Auto-syncs from GitHub | Push to GitHub, Lovable pulls automatically |
| **Database Schema** | ❌ Cannot modify | ✅ Only here | Create `.sql` files, execute in Lovable |
| **Edge Functions Code** | ✅ Can edit | ✅ Deploys | Edit locally, push to GitHub, deploy in Lovable |
| **RLS Policies** | ❌ Cannot modify | ✅ Only here | Must use Lovable's migration tool |
| **Secrets (API Keys)** | ❌ Cannot access | ✅ Only here | Managed via Lovable secrets tool |
| **Storage Buckets** | ❌ Cannot create | ✅ Only here | Can upload files via Supabase client |
| **Production Deploy** | ❌ Cannot deploy | ✅ Only here | Click "Update" in Lovable publish dialog |
| **Environment Variables** | ✅ `.env.local` | ✅ Auto-provided | Use provided credentials, don't modify |

---

## Development Workflows

### Workflow 1: Frontend-Only Changes

**Best for:** UI updates, new components, styling, client-side logic

```bash
# In your external IDE
1. Edit React components, pages, hooks
2. Test locally: npm run dev
3. Commit changes: git add . && git commit -m "Updated hero section"
4. Push to GitHub: git push origin main
5. Lovable automatically syncs changes
6. Click "Update" in Lovable to deploy to production
```

**What AI agents can do:**
- ✅ Modify components, pages, hooks
- ✅ Add new routes
- ✅ Update styling with Tailwind
- ✅ Install npm packages
- ✅ Test changes locally

**What AI agents cannot do:**
- ❌ Deploy to production (requires Lovable)
- ❌ Modify database schema
- ❌ Change RLS policies

---

### Workflow 2: Edge Function Changes

**Best for:** Backend API logic, integrations, business logic

```bash
# In your external IDE
1. Edit edge function code in supabase/functions/
2. Test locally by calling via Supabase client
3. Commit: git add supabase/functions/ && git commit -m "Updated payment logic"
4. Push to GitHub: git push origin main
5. In Lovable: Deploy edge function using deployment tool
6. Verify deployment in Lovable Cloud tab
```

**What AI agents can do:**
- ✅ Edit edge function TypeScript code
- ✅ Add new edge functions
- ✅ Update function logic
- ✅ Test functions via curl or Supabase client

**What AI agents cannot do:**
- ❌ Deploy functions (requires Lovable)
- ❌ Add secrets (requires Lovable secrets tool)
- ❌ Modify `config.toml` function settings

---

### Workflow 3: Database Schema Changes

**Best for:** New tables, columns, RLS policies, triggers

```bash
# In your external IDE
1. Create migration file: supabase/migrations/YYYYMMDD_description.sql
2. Write SQL for schema changes, RLS policies, triggers
3. Commit: git add supabase/migrations/ && git commit -m "Added orders table"
4. Push to GitHub: git push origin main
5. In Lovable: Open Cloud tab → Database → Run migration
6. Verify migration executed successfully
7. Updated types appear in src/integrations/supabase/types.ts
```

**What AI agents can do:**
- ✅ Write SQL migration files
- ✅ Design database schema
- ✅ Write RLS policies
- ✅ Create triggers and functions

**What AI agents cannot do:**
- ❌ Execute migrations (requires Lovable)
- ❌ Directly modify `types.ts` (auto-generated)
- ❌ Access Supabase dashboard

---

## Multi-Agent Coordination

### Working with Multiple AI Agents

When coordinating multiple AI agents (Lovable, Claude Code, Gemini, etc.) on the same repository:

#### 1. **Use Feature Branches**

```bash
# Create feature branch for major changes
git checkout -b feature/supplier-dashboard
# Work on feature
git push origin feature/supplier-dashboard
# Merge via pull request when ready
```

#### 2. **Always Pull Before Starting**

```bash
git pull origin main
```

Before asking any AI agent to make changes, ensure you have the latest code.

#### 3. **Clear Communication**

When instructing AI agents, be explicit:

❌ Bad: "Update the dashboard"
✅ Good: "Update ModernBuyerDashboard.tsx to add a new 'Orders' tab with a table showing order_number, status, and created_at from the orders table"

#### 4. **One Agent Per Feature**

Avoid having multiple agents editing the same file simultaneously. Assign features to specific agents:

- **Lovable Agent**: Backend migrations, edge function deployment, production deploy
- **Claude Code**: Complex React component refactoring
- **Gemini 2.0 Flash Thinking**: Architecture planning and code review
- **Cursor**: Quick UI fixes and styling

#### 5. **Document in Commits**

```bash
git commit -m "feat(auth): Add supplier registration flow - Agent: Claude Code"
```

Tag which agent made the change for accountability.

---

## Bidirectional Sync

### How Lovable ↔ GitHub ↔ External IDE Works

```
External IDE → GitHub → Lovable
   (push)       (auto)    (auto-sync)

Lovable → GitHub → External IDE
 (commit)   (auto)    (git pull)
```

#### From External IDE to Lovable

1. You make changes in external IDE
2. `git push origin main`
3. GitHub receives commits
4. Lovable automatically syncs within seconds
5. Changes appear in Lovable editor

#### From Lovable to External IDE

1. Changes made in Lovable (e.g., migration executed)
2. Lovable commits to GitHub automatically
3. In external IDE: `git pull origin main`
4. You receive latest changes

---

## Critical Rules for AI Agents

### ✅ ALWAYS Safe to Do

- Edit `.tsx`, `.ts`, `.css` files in `src/`
- Add new components in `src/components/`
- Create new pages in `src/pages/`
- Update routing in `src/App.tsx`
- Install npm packages
- Create edge function code files
- Write SQL migration files
- Update documentation

### ❌ NEVER Do Without Lovable

- Execute SQL migrations
- Deploy edge functions
- Modify `src/integrations/supabase/types.ts` (auto-generated)
- Modify `src/integrations/supabase/client.ts` (auto-generated)
- Modify `.env` (managed by Lovable)
- Deploy to production
- Add/modify secrets
- Create storage buckets

### ⚠️ Coordination Required

- Modifying `supabase/config.toml` (coordinate with Lovable agent)
- Large refactoring affecting many files (use feature branch)
- Database schema changes (create migration, execute in Lovable)

---

## Troubleshooting

### Issue: Changes not appearing in Lovable

**Solution:**
1. Verify push succeeded: `git log origin/main`
2. Wait 10-30 seconds for sync
3. Refresh Lovable editor

### Issue: Local dev server not connecting to backend

**Solution:**
1. Check `.env.local` exists and has correct values
2. Verify Supabase URL: `https://eqpftggctumujhutomom.supabase.co`
3. Restart dev server: `npm run dev`

### Issue: Edge function not working locally

**Solution:**
Edge functions cannot run locally. Test by:
1. Deploying in Lovable
2. Calling via Supabase client in frontend
3. Checking edge function logs in Lovable Cloud tab

### Issue: Migration file created but schema not updated

**Solution:**
1. Migration files must be executed in Lovable, not locally
2. Push migration file to GitHub
3. In Lovable: Cloud → Database → Run migration
4. Types will auto-update in `types.ts`

### Issue: Multiple agents making conflicting changes

**Solution:**
1. Use feature branches
2. Merge one agent's changes at a time
3. Pull before starting new work
4. Resolve conflicts manually if needed

---

## Best Practices

### 1. **Start Small, Test Often**

- Make incremental changes
- Test locally after each change
- Commit frequently with clear messages

### 2. **Keep Lovable as Source of Truth for Backend**

- All database changes go through Lovable
- All production deploys happen in Lovable
- All secrets managed in Lovable

### 3. **Use TypeScript Strictly**

- Enable strict mode
- Leverage auto-generated Supabase types
- Let AI agents infer types from database schema

### 4. **Follow Existing Patterns**

- Study existing components before creating new ones
- Use established hooks (`useToast`, `useSupabase`)
- Follow Tailwind semantic tokens from `index.css`

### 5. **Document Complex Logic**

- Add comments for non-obvious code
- Update this workflow doc when discovering new patterns
- Create memory entries in Lovable for important decisions

---

## Quick Reference

| Task | Where to Do It | Command |
|------|----------------|---------|
| Edit React components | External IDE | `npm run dev` |
| Install npm package | External IDE | `npm install <package>` |
| Create migration file | External IDE | Create `.sql` file |
| Execute migration | Lovable | Cloud → Database |
| Deploy edge function | Lovable | Deploy tool |
| Add secret | Lovable | Secrets tool |
| Deploy to production | Lovable | Publish → Update |
| Pull latest changes | External IDE | `git pull origin main` |
| Push your changes | External IDE | `git push origin main` |

---

## Support

- **Lovable Documentation**: https://docs.lovable.dev
- **Supabase Documentation**: https://supabase.com/docs
- **Project Repository**: https://github.com/YOUR_USERNAME/sleek-apparels

---

**Last Updated**: 2024-11-26  
**Lovable Project ID**: eqpftggctumujhutomom
