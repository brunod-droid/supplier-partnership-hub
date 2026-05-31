-- Run this AFTER you create the users in Supabase Auth.
-- Replace the emails below with the exact emails you created.

insert into profiles (id, email, full_name, role)
select id, email, 'Bruno', 'admin'
from auth.users
where email = 'bruno@example.com'
on conflict (id) do update set role = 'admin', full_name = 'Bruno';

insert into profiles (id, email, full_name, role)
select id, email, 'Tenengroup Team', 'internal'
from auth.users
where email = 'team@example.com'
on conflict (id) do update set role = 'internal', full_name = 'Tenengroup Team';

insert into profiles (id, email, full_name, role)
select id, email, 'Jondo Supplier', 'supplier'
from auth.users
where email = 'jondo@example.com'
on conflict (id) do update set role = 'supplier', full_name = 'Jondo Supplier';

insert into profiles (id, email, full_name, role)
select id, email, 'ShineOn Supplier', 'supplier'
from auth.users
where email = 'shineon@example.com'
on conflict (id) do update set role = 'supplier', full_name = 'ShineOn Supplier';

-- Give access.
-- Bruno and Tenengroup see both workspaces.
insert into workspace_access (user_id, workspace_id)
select u.id, w.id
from auth.users u
cross join workspaces w
where u.email in ('bruno@example.com','team@example.com')
on conflict do nothing;

-- Jondo supplier sees only Jondo.
insert into workspace_access (user_id, workspace_id)
select u.id, w.id
from auth.users u
join workspaces w on w.slug = 'jondo'
where u.email = 'jondo@example.com'
on conflict do nothing;

-- ShineOn supplier sees only ShineOn.
insert into workspace_access (user_id, workspace_id)
select u.id, w.id
from auth.users u
join workspaces w on w.slug = 'shineon'
where u.email = 'shineon@example.com'
on conflict do nothing;
