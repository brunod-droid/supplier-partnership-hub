# Supplier Hub V2 Content Patch

This patch adds:

- clearer supplier-facing `Our need` text for all requirement lines
- a new `Example / expected format` field
- a Supabase trigger that automatically creates a row in `profiles` when a user is created in Supabase Auth

## Install

1. Copy the files into your repo.
2. Commit and push to GitHub.
3. In Supabase SQL Editor, run:

```sql
supabase/updates/004_profiles_trigger_and_requirement_examples.sql
```

4. Redeploy Vercel.

## Notes

New Auth users will default to `supplier`. After creating a Tenengroup user, change `role` to `internal` in `public.profiles`.

The CSV in `data/requirements_our_needs_examples_v2.csv` is included as a review/import file. The SQL file is the easiest and safest way to update the existing Supabase rows.
