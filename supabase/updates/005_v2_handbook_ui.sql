-- 005 - V2 Handbook UI support
-- Run this in Supabase SQL Editor before deploying the V2 UI.

alter table public.requirements add column if not exists example_response text;
alter table public.requirements add column if not exists is_hidden boolean not null default false;
alter table public.requirements add column if not exists updated_at timestamptz default now();

-- Make sure the simplified statuses exist.
alter type requirement_status add value if not exists 'Supplier Answered';
alter type requirement_status add value if not exists 'Discussion';
alter type requirement_status add value if not exists 'Validated';

-- Optional normalization from earlier workflow names.
update public.requirements set status = 'Supplier Answered' where status::text = 'Supplier Replied';
update public.requirements set status = 'Discussion' where status::text in ('Internal Review', 'Need Clarification', 'Blocked', 'Rejected');
update public.requirements set status = 'Validated' where status::text = 'Approved';
update public.requirements set status = 'Waiting Supplier' where status::text = 'Draft';

-- Keep RLS enabled.
alter table public.profiles enable row level security;
alter table public.workspaces enable row level security;
alter table public.workspace_access enable row level security;
alter table public.categories enable row level security;
alter table public.requirements enable row level security;
alter table public.comments enable row level security;
alter table public.documents enable row level security;

-- Allow logged-in users with workspace access to update requirements.
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

-- Allow comments to be inserted by the author.
drop policy if exists "Comments insert" on public.comments;
create policy "Comments insert" on public.comments
for insert
with check (auth.uid() = author_id);
