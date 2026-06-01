import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import SignOutButton from '../../../components/SignOutButton';
import RequirementEditor from '../../../components/RequirementEditor';
import CommentsPanel from '../../../components/CommentsPanel';

export default async function RequirementPage({ params }: { params: Promise<{ requirementId: string }> }) {
  const { requirementId } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (!profile) redirect('/login');

  const { data: requirement } = await supabase
    .from('requirements')
    .select('*, categories(name), workspaces(id, name)')
    .eq('id', requirementId)
    .single();

  if (!requirement) redirect('/dashboard');

  const { data: comments } = await supabase
    .from('comments')
    .select('id, body, is_internal, created_at, profiles(full_name, email, role)')
    .eq('requirement_id', requirementId)
    .order('created_at', { ascending: true });

  return (
    <main className="container">
      <div className="header">
        <div>
          <Link className="small" href={`/workspaces/${requirement.workspaces.id}`}>← Back to workspace</Link>
          <h1>{requirement.title}</h1>
          <p className="small">{requirement.workspaces.name} · {requirement.categories?.name} · Role: {profile.role}</p>
        </div>
        <SignOutButton />
      </div>

      <div className="grid" style={{ gap: 18 }}>
        <RequirementEditor
          requirementId={requirement.id}
          role={profile.role}
          initialOurNeed={requirement.our_need}
          initialSupplierResponse={requirement.supplier_response}
          initialFinalDecision={requirement.final_decision}
          initialStatus={requirement.status}
        />

        <CommentsPanel
          requirementId={requirement.id}
          userId={user.id}
          role={profile.role}
          comments={comments || []}
        />
      </div>
    </main>
  );
}
