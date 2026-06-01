create extension if not exists "uuid-ossp";

create type user_role as enum ('admin','internal','supplier');
create type requirement_status as enum ('Waiting Supplier','Supplier Answered','Discussion','Validated');

create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  full_name text,
  role user_role not null default 'supplier',
  created_at timestamptz default now()
);

create table workspaces (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  slug text not null unique,
  supplier_name text not null,
  brand_name text not null,
  created_at timestamptz default now()
);

create table workspace_access (
  user_id uuid references profiles(id) on delete cascade,
  workspace_id uuid references workspaces(id) on delete cascade,
  primary key (user_id, workspace_id)
);

create table categories (
  id uuid primary key default uuid_generate_v4(),
  name text not null,
  sort_order int not null
);

create table requirements (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid references workspaces(id) on delete cascade,
  category_id uuid references categories(id) on delete cascade,
  title text not null,
  our_need text not null,
  supplier_response text,
  final_decision text,
  internal_notes text,
  expected_document text,
  status requirement_status not null default 'Waiting Supplier',
  sort_order int not null default 0,
  updated_at timestamptz default now()
);

create table comments (
  id uuid primary key default uuid_generate_v4(),
  requirement_id uuid references requirements(id) on delete cascade,
  author_id uuid references profiles(id) on delete set null,
  body text not null,
  is_internal boolean default false,
  created_at timestamptz default now()
);

create table documents (
  id uuid primary key default uuid_generate_v4(),
  workspace_id uuid references workspaces(id) on delete cascade,
  requirement_id uuid references requirements(id) on delete set null,
  uploaded_by uuid references profiles(id) on delete set null,
  file_name text not null,
  storage_path text not null,
  created_at timestamptz default now()
);

alter table profiles enable row level security;
alter table workspaces enable row level security;
alter table workspace_access enable row level security;
alter table categories enable row level security;
alter table requirements enable row level security;
alter table comments enable row level security;
alter table documents enable row level security;

create or replace function current_user_role() returns user_role language sql security definer as $$
  select role from profiles where id = auth.uid();
$$;

create policy "Profiles see self" on profiles for select using (id = auth.uid() or current_user_role() in ('admin','internal'));
create policy "Workspace access" on workspaces for select using (current_user_role() in ('admin','internal') or exists (select 1 from workspace_access wa where wa.workspace_id = id and wa.user_id = auth.uid()));
create policy "Access rows" on workspace_access for select using (user_id = auth.uid() or current_user_role() in ('admin','internal'));
create policy "Categories readable" on categories for select using (auth.uid() is not null);
create policy "Requirements readable by workspace" on requirements for select using (current_user_role() in ('admin','internal') or exists (select 1 from workspace_access wa where wa.workspace_id = workspace_id and wa.user_id = auth.uid()));
create policy "Requirements update by workspace" on requirements for update using (current_user_role() in ('admin','internal') or exists (select 1 from workspace_access wa where wa.workspace_id = workspace_id and wa.user_id = auth.uid())) with check (current_user_role() in ('admin','internal') or exists (select 1 from workspace_access wa where wa.workspace_id = workspace_id and wa.user_id = auth.uid()));
create policy "Comments readable" on comments for select using ((current_user_role() in ('admin','internal') or exists (select 1 from requirements r join workspace_access wa on wa.workspace_id = r.workspace_id where r.id = requirement_id and wa.user_id = auth.uid())) and (is_internal = false or current_user_role() in ('admin','internal')));
create policy "Comments insert" on comments for insert with check (auth.uid() = author_id);
create policy "Documents readable" on documents for select using (current_user_role() in ('admin','internal') or exists (select 1 from workspace_access wa where wa.workspace_id = workspace_id and wa.user_id = auth.uid()));
create policy "Documents insert" on documents for insert with check (auth.uid() = uploaded_by);

-- Run seed.sql after this schema.
