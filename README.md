# Supplier Partnership Hub

One private portal for supplier onboarding and operational governance.

This version uses one codebase, one Vercel deployment, and one Supabase project with two separated workspaces:

- Lime&Lou x Jondo
- Tenengroup x ShineOn

Users log in with email/password. Access is controlled by role and workspace.

## Roles

- `admin`: Bruno, full access to all workspaces
- `internal`: Tenengroup team, access to all workspaces
- `supplier`: supplier user, access only to assigned workspace

## Main folders

```text
app/                     Next.js pages
components/              UI and forms
lib/                     Supabase clients
supabase/schema.sql      Tables, enums, RLS policies
supabase/seed.sql        Jondo + ShineOn workspaces and checklist content
supabase/setup_users.sql User profile/access setup after creating Auth users
.env.example             Environment variable template
```

## Local setup

```bash
npm install
cp .env.example .env.local
npm run dev
```

Add your Supabase values in `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

## Supabase setup order

1. Create one Supabase project, for example `supplier-hub`.
2. SQL Editor: run `supabase/schema.sql`.
3. SQL Editor: run `supabase/seed.sql`.
4. Authentication > Users: create your users.
5. Edit `supabase/setup_users.sql` and replace the example emails.
6. SQL Editor: run `supabase/setup_users.sql`.
7. Test login.

## Vercel setup

1. Push this project to one GitHub repo, for example `supplier-partnership-hub`.
2. Vercel > Add New Project > Import GitHub repo.
3. Add environment variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
4. Deploy.

## Important

Do not commit `.env.local`. It is excluded by `.gitignore`.
