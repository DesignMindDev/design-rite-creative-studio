# Creative Studio - Quick Reference

**Microservice Location:** `C:\Users\dkozi\Projects\Design-Rite\v3\design-rite-v3.1\design-rite-creative-studio`
**Server URL:** http://localhost:3030
**Status:** ✅ Running

---

## 🚀 Start Server
```bash
cd C:\Users\dkozi\Projects\Design-Rite\v3\design-rite-v3.1\design-rite-creative-studio
npm run dev
```

## 🛑 Stop Server
```bash
# If running in foreground: Ctrl + C
# If running in background:
npx kill-port 3030
```

---

## 🗄️ Database Setup

**SQL File:** `supabase/creative_studio_tables.sql`

1. Open Supabase SQL Editor: https://supabase.com/dashboard/project/aeorianxnxpxveoxzhov/sql/new
2. Paste contents of `creative_studio_tables.sql`
3. Click "Run"
4. Verify 4 tables created: `creative_projects`, `creative_assets`, `creative_templates`, `creative_generations`

---

## 📂 Key Files

| File | Purpose |
|------|---------|
| `app/page.tsx` | Main Creative Studio UI (113KB) |
| `app/api/*` | 7 API routes (assets, chat, designs, generate, projects, publish, upload) |
| `lib/supabase.ts` | Supabase client helpers |
| `lib/creative-studio-api.ts` | API helper functions |
| `middleware.ts` | Auth middleware (manager+ required) |
| `.env.local` | Environment variables |
| `supabase/creative_studio_tables.sql` | Database schema |

---

## 🔧 Environment Variables

**File:** `.env.local`

```bash
# Supabase (SHARED with Design-Rite v3)
NEXT_PUBLIC_SUPABASE_URL=https://aeorianxnxpxveoxzhov.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGci...
SUPABASE_SERVICE_KEY=eyJhbGci...

# OpenAI
OPENAI_API_KEY=sk-proj-eNFCtLC6...

# Creative Studio
CREATIVE_ASSISTANT_ID=asst_ybxoe2JxhEOobS84D7VnCGJj

# Service Config
NEXT_PUBLIC_SERVICE_NAME=creative-studio
NEXT_PUBLIC_MAIN_APP_URL=http://localhost:3010
```

---

## 🎯 What is Creative Studio?

AI-powered content generation platform for security marketing:
- **Blog Posts** - Industry-specific articles
- **Case Studies** - Customer success stories
- **Product Descriptions** - Technical marketing content
- **Social Media** - Optimized posts
- **Email Campaigns** - Professional emails

**Target Users:** Marketing teams, content creators, sales enablement

---

## 🔒 Authentication

- **Shared Auth:** Uses same Supabase instance as Design-Rite v3
- **Required Role:** Manager or higher (super_admin, admin, manager)
- **Protected Routes:** `/api/*`, `/projects/*`
- **Redirect:** Unauthenticated users sent to homepage

---

## 📊 Database Tables

1. **creative_projects** - Content generation projects
2. **creative_assets** - Uploaded/generated assets (images, videos, docs)
3. **creative_templates** - Reusable content templates
4. **creative_generations** - AI generation tracking and cost analytics

**Storage Bucket:** `creative-assets` (public, 10MB limit)

---

## 🐛 Troubleshooting

### Server Won't Start
```bash
# Check if port 3030 is in use
npx kill-port 3030

# Reinstall dependencies
npm install --legacy-peer-deps
```

### Import Errors
All imports should use `@/*` alias:
```typescript
// ✅ Correct
import { getSupabaseAdmin } from '@/lib/supabase'

// ❌ Wrong
import { getSupabaseAdmin } from '../../../../lib/supabase'
```

### Authentication Issues
1. Verify `.env.local` has correct Supabase credentials
2. Check user role in `user_roles` table (needs manager+)
3. Ensure middleware is not blocking routes

---

## 🔗 Related Services

| Service | Port | Purpose |
|---------|------|---------|
| Design-Rite v3 | 3010 | Main app + admin dashboard |
| Spatial Studio | 3020 | 3D floor plan analysis |
| Creative Studio | 3030 | Content generation |

All services share Supabase authentication.

---

## 📝 Commands Cheat Sheet

```bash
# Development
npm run dev          # Start dev server (port 3030)
npm run build        # Build for production
npm start            # Start production server

# Utilities
npx kill-port 3030   # Kill server
npm install          # Install dependencies

# Database
# Run supabase/creative_studio_tables.sql in Supabase SQL Editor
```

---

## 📚 Documentation

- **SESSION_SUMMARY.md** - Complete extraction details
- **AI_CREATIVE_STUDIO.md** - Product documentation
- **QUICK_REFERENCE.md** - This file

---

**Last Updated:** October 3, 2025
**Status:** Microservice extraction completed successfully ✅
