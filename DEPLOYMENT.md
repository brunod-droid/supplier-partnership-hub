# Deployment checklist

## 1. GitHub

Create one repository:

```text
supplier-partnership-hub
```

Upload all files from this ZIP.

## 2. Supabase

Create one project:

```text
supplier-hub
```

Run in this exact order:

1. `supabase/schema.sql`
2. `supabase/seed.sql`
3. Create Auth users manually
4. Edit + run `supabase/setup_users.sql`

Suggested users:

```text
bruno@yourcompany.com       role admin      access all
team@yourcompany.com        role internal   access all
jondo@partner.com           role supplier   access Jondo only
shineon@partner.com         role supplier   access ShineOn only
```

In `setup_users.sql`, replace:

```text
bruno@example.com
team@example.com
jondo@example.com
shineon@example.com
```

with the exact emails created in Supabase Auth.

## 3. Vercel

Create one Vercel project from the GitHub repo.

Add these variables in Vercel > Settings > Environment Variables:

```env
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

Deploy.

## 4. Access logic

Bruno and Tenengroup see both workspaces.

Suppliers only see their own workspace:

- Jondo supplier: Lime&Lou x Jondo
- ShineOn supplier: Tenengroup x ShineOn

## 5. RLS verification

In Supabase SQL Editor, you can check RLS with:

```sql
select schemaname, tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;
```

All project tables should show `true`.
