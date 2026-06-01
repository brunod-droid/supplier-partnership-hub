# Editable requirements patch

Replace/add these files in your GitHub repo:

- `app/requirements/[requirementId]/page.tsx`
- `app/workspaces/[workspaceId]/page.tsx`
- `components/RequirementEditor.tsx`
- `components/CommentsPanel.tsx`
- `supabase/updates/003_editable_requirements_comments.sql`

Then:

1. Commit and push to GitHub.
2. In Supabase SQL Editor, run `supabase/updates/003_editable_requirements_comments.sql`.
3. Redeploy Vercel.

The requirement page will have:

- Our need: editable by admin/internal, read-only for supplier.
- Supplier answer: editable by supplier and admin/internal.
- Final decision: editable by admin/internal, read-only for supplier.
- Status dropdown: admin/internal only.
- Comments: everyone can comment; internal-only comments are hidden from suppliers.
