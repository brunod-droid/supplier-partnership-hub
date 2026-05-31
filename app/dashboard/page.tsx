import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../lib/supabase-server';
import SignOutButton from '../../components/SignOutButton';

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single();
  const { data: workspaces } = await supabase.from('workspace_access').select('workspaces(*)').eq('user_id', user.id);

  return (
    <main className="container">
      <div className="header">
        <div>
          <h1>Supplier Partnership Hub</h1>
          <p className="small">Role: <b>{profile?.role || 'not configured'}</b></p>
        </div>
        <SignOutButton />
      </div>
      <div className="grid grid-3">
        {(workspaces || []).map((row: any) => (
          <Link className="card" key={row.workspaces.id} href={`/workspaces/${row.workspaces.id}`}>
            <span className="badge">Workspace</span>
            <h2>{row.workspaces.name}</h2>
            <p className="small">Open the supplier onboarding checklist, responses, documents and approvals.</p>
          </Link>
        ))}
      </div>
    </main>
  );
}
