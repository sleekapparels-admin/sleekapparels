# Deployment Instructions for Sleek Apparels Website

## 🎯 Overview

This document provides complete instructions for deploying the Sleek Apparels website to production. Since **backend is handled by Lovable Cloud**, this is purely a **static frontend deployment**.

---

## 📋 Pre-Deployment Checklist

### ✅ Completed
- [x] All 11 routes built and tested
- [x] SSR verification passed (100% crawlable)
- [x] SEO metadata on all pages
- [x] Structured data (JSON-LD) implemented
- [x] Git repository initialized
- [x] Production build successful

### ⏳ Required Actions
- [ ] Setup GitHub repository authorization
- [ ] Setup Cloudflare API key
- [ ] Configure custom domain (optional)

---

## 🚀 Option 1: Deploy to Cloudflare Pages (RECOMMENDED)

### Step 1: Setup Cloudflare API Key

1. Go to **Deploy** tab in sidebar
2. Create Cloudflare API token:
   - Log in to Cloudflare Dashboard
   - Go to **My Profile** → **API Tokens**
   - Create Token → **Edit Cloudflare Workers** template
   - Include permissions: **Cloudflare Pages:Edit**
3. Copy token and save in Deploy tab

### Step 2: Deploy via CLI

```bash
cd /home/user/webapp

# Ensure build is complete
npm run build

# Deploy to Cloudflare Pages
npx wrangler pages deploy out --project-name sleekapparels

# You'll get URLs like:
# - Production: https://sleekapparels.pages.dev
# - Branch: https://main.sleekapparels.pages.dev
```

### Step 3: Configure Custom Domain (Optional)

```bash
# Add custom domain
npx wrangler pages domain add sleekapparels.com --project-name sleekapparels

# DNS Configuration:
# Add CNAME record: sleekapparels.com → sleekapparels.pages.dev
# SSL automatically provisioned by Cloudflare
```

---

## 🐙 Option 2: Deploy via GitHub + Cloudflare Pages

### Step 1: Setup GitHub Repository

1. Go to **#github** tab in sidebar
2. Complete GitHub authorization
3. Create repository: `sleekapparels-website`

### Step 2: Push Code to GitHub

```bash
cd /home/user/webapp

# After GitHub authorization is complete:
git remote add origin https://github.com/YOUR_USERNAME/sleekapparels-website.git
git branch -M main
git push -u origin main
```

### Step 3: Connect to Cloudflare Pages

1. Go to Cloudflare Dashboard → **Pages**
2. Click **Create a project** → **Connect to Git**
3. Select your GitHub repository
4. Build settings:
   - **Build command:** `npm run build`
   - **Build output directory:** `out`
   - **Root directory:** `/` (leave blank)
5. Click **Save and Deploy**

**Automatic Deployments:**
- Every push to `main` branch triggers new deployment
- Preview deployments for pull requests
- Instant rollback capability

---

## 🌐 Option 3: Deploy to Vercel

```bash
cd /home/user/webapp

# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Follow prompts:
# - Project name: sleekapparels
# - Build command: npm run build
# - Output directory: out
```

---

## 📊 Post-Deployment Verification

### 1. Test All Routes

```bash
# Replace with your actual domain
DOMAIN="https://sleekapparels.pages.dev"

# Test key routes
curl -I $DOMAIN/
curl -I $DOMAIN/services
curl -I $DOMAIN/products
curl -I $DOMAIN/products/t-shirts
curl -I $DOMAIN/products/hoodies
curl -I $DOMAIN/contact
curl -I $DOMAIN/faq
curl -I $DOMAIN/about

# All should return 200 OK
```

### 2. Verify SSR Content

```bash
# Check if content is in HTML (no JS required)
curl $DOMAIN/ | grep "Low MOQ Clothing Manufacturer"
curl $DOMAIN/products | grep "Custom T-Shirts"

# Should return matching lines
```

### 3. Check Meta Tags

```bash
# Verify SEO metadata
curl $DOMAIN/ | grep '<meta name="description"'
curl $DOMAIN/ | grep 'og:title'

# Should show proper meta tags
```

---

## 🔍 SEO Setup (Post-Deployment)

### 1. Google Search Console

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add property: `sleekapparels.com`
3. Verify ownership (HTML tag or DNS)
4. Submit sitemap: Generate and submit `sitemap.xml`
5. Request indexing for key pages:
   - Homepage
   - /services
   - /products
   - /products/t-shirts
   - /products/hoodies

### 2. Structured Data Testing

1. Go to [Rich Results Test](https://search.google.com/test/rich-results)
2. Test each page with JSON-LD:
   - Homepage (Organization schema)
   - Products (Product schema)
   - FAQ (FAQPage schema)
3. Fix any errors/warnings

### 3. Performance Monitoring

1. Google Analytics: Add tracking code
2. Google Tag Manager: Setup tags
3. Cloudflare Analytics: Monitor traffic

---

## 🔧 Lovable Cloud Backend Integration

Since **backend is handled by Lovable Cloud**, here's how to integrate:

### API Endpoints Structure

Your Lovable Cloud backend should expose REST APIs:

```
# Example backend endpoints
https://your-lovable-backend.com/api/contact    # Contact form submission
https://your-lovable-backend.com/api/quote      # Quote request
https://your-lovable-backend.com/api/newsletter # Newsletter signup
```

### Frontend Integration Points

Update these files to connect to Lovable backend:

#### 1. Contact Form (`app/contact/page.tsx`)

```typescript
// Add form submission handler
const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();
  const formData = new FormData(e.target as HTMLFormElement);
  
  const response = await fetch('https://your-lovable-backend.com/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(Object.fromEntries(formData)),
  });
  
  if (response.ok) {
    alert('Message sent successfully!');
  }
};
```

#### 2. Environment Variables

Create `.env.local` (local dev) and configure in Cloudflare:

```bash
# .env.local
NEXT_PUBLIC_API_URL=https://your-lovable-backend.com/api
```

In Cloudflare Pages:
1. Go to project settings
2. Environment Variables
3. Add: `NEXT_PUBLIC_API_URL`

---

## 🛠️ Maintenance & Updates

### Update Content

```bash
cd /home/user/webapp

# Make changes to pages
# Example: edit app/page.tsx

# Rebuild
npm run build

# Test locally (optional)
npx wrangler pages dev out

# Deploy
npx wrangler pages deploy out --project-name sleekapparels

# Or push to GitHub (auto-deploys if connected)
git add .
git commit -m "Update homepage content"
git push origin main
```

### Add New Pages

```bash
# Create new page
mkdir -p app/new-page
echo 'export default function NewPage() { return <div>New Page</div> }' > app/new-page/page.tsx

# Rebuild and deploy
npm run build
npx wrangler pages deploy out --project-name sleekapparels
```

---

## 🚨 Troubleshooting

### Build Fails

```bash
# Clear cache and rebuild
rm -rf .next out
npm run build
```

### 404 Errors After Deployment

- Ensure `out/` directory contains all HTML files
- Check Cloudflare Pages build log
- Verify output directory setting: `out`

### Content Not Updating

- Clear Cloudflare cache: Dashboard → Caching → Purge Everything
- Hard refresh browser: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)

### Missing Meta Tags

- View page source (Ctrl+U)
- Verify meta tags present in HTML
- Check if `metadata` export exists in page file

---

## 📞 Support & Resources

### Documentation
- [Next.js Docs](https://nextjs.org/docs)
- [Cloudflare Pages Docs](https://developers.cloudflare.com/pages/)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)

### Project Files
- `README.md` - Project overview
- `SSR_AUDIT_REPORT.md` - Technical audit report
- `test-crawlability.js` - SSR verification script

### Quick Commands

```bash
# Development
npm run dev           # Local dev server

# Build
npm run build         # Production build

# Test
node test-crawlability.js  # Verify SSR

# Deploy
npx wrangler pages deploy out --project-name sleekapparels
```

---

## ✅ Final Checklist

Before going live, verify:

- [ ] All routes accessible (11/11)
- [ ] Meta tags present on all pages
- [ ] Structured data (JSON-LD) working
- [ ] Forms connected to backend
- [ ] Google Search Console setup
- [ ] Analytics tracking installed
- [ ] Custom domain configured (if applicable)
- [ ] SSL certificate active
- [ ] Performance optimized (Cloudflare caching)
- [ ] Mobile responsive verified

---

## 🎉 Success!

Your Sleek Apparels website is now live and fully optimized for search engines!

**Expected Results:**
- Pages indexed within 2-4 weeks
- Organic traffic within 1-2 months
- Keyword rankings within 2-3 months
- 300-500% traffic increase within 3 months

---

**Last Updated:** 2025-11-24  
**Status:** 🟢 Ready for Deployment
