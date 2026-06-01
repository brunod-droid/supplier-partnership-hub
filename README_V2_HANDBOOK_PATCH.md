# Supplier Partnership Hub - V2 Handbook UX Patch

This patch removes the Excel-like table UX and turns the supplier workspace into a handbook-style portal.

## Files to replace / add

- `app/workspaces/[workspaceId]/page.tsx`
- `app/requirements/[requirementId]/page.tsx`
- `components/RequirementEditor.tsx`
- `components/CommentsPanel.tsx`
- `app/globals.css`
- `supabase/updates/005_v2_handbook_ui.sql`

## Supabase

Run this file in Supabase SQL Editor before deploying:

```sql
supabase/updates/005_v2_handbook_ui.sql
```

It adds:

- `requirements.example_response`
- `requirements.is_hidden`
- `requirements.updated_at`
- simplified statuses if missing
- update/comment policies

## Deploy

1. Copy the files into your GitHub repo.
2. Commit and push.
3. Vercel will redeploy automatically.

## Result

Workspace page:

- left sidebar with categories
- progress dashboard
- category panels
- requirement cards instead of tables

Requirement page:

- readable handbook layout
- Our need split into sections
- Example / expected format
- Supplier answer textarea
- Final decision textarea
- Status dropdown
- Hide/unhide checkbox for internal users
- Comments side panel
