# Patch: Simple 4-field workflow

This patch changes each requirement line to the exact workflow:

1. Our need
2. Supplier answer
3. Final decision
4. Status

Allowed statuses:
- Waiting Supplier
- Supplier Answered
- Discussion
- Validated

## Install

1. Copy the files from this ZIP into your GitHub repo and replace existing files.
2. Commit and push.
3. In Supabase SQL Editor, run:
   `supabase/updates/002_simple_fields_statuses.sql`
4. In Vercel, redeploy.

## Notes

- Admin/Internal can edit Our need, Supplier answer, Final decision and Status.
- Supplier can edit Supplier answer only. When Supplier saves, status becomes Supplier Answered.
- The SQL update also replaces generic needs with the detailed guidelines from Bruno's workbook notes.
