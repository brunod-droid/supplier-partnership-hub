-- Editable requirements patch
-- Run this once in Supabase SQL Editor.

-- 1) Add final_decision field used by the new UI.
alter table public.requirements
add column if not exists final_decision text;

-- 2) Add the simplified statuses requested for the supplier hub.
alter type requirement_status add value if not exists 'Supplier Answered';
alter type requirement_status add value if not exists 'Discussion';
alter type requirement_status add value if not exists 'Validated';

-- 3) Normalize old statuses into the simplified workflow.
update public.requirements set status = 'Supplier Answered' where status::text = 'Supplier Replied';
update public.requirements set status = 'Discussion' where status::text in ('Internal Review', 'Need Clarification', 'Blocked', 'Rejected');
update public.requirements set status = 'Validated' where status::text = 'Approved';
update public.requirements set status = 'Waiting Supplier' where status::text = 'Draft';

-- 4) Ensure RLS stays enabled.
alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_access enable row level security;
alter table public.categories enable row level security;
alter table public.requirements enable row level security;
alter table public.comments enable row level security;
alter table public.documents enable row level security;

-- 5) Make sure comments can be inserted by logged-in users.
drop policy if exists "Comments insert" on public.comments;
create policy "Comments insert" on public.comments
for insert
with check (auth.uid() = author_id);

-- 6) Make sure requirements are updateable for users with workspace access.
drop policy if exists "Requirements update by workspace" on public.requirements;
create policy "Requirements update by workspace" on public.requirements
for update
using (
  current_user_role() in ('admin','internal')
  or exists (
    select 1 from public.workspace_access wa
    where wa.workspace_id = requirements.workspace_id
    and wa.user_id = auth.uid()
  )
)
with check (
  current_user_role() in ('admin','internal')
  or exists (
    select 1 from public.workspace_access wa
    where wa.workspace_id = requirements.workspace_id
    and wa.user_id = auth.uid()
  )
);
