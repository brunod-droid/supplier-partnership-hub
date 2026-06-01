import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import RequirementResponseForm from '../../../components/RequirementResponseForm';
import CommentThread from '../../../components/CommentThread';
import SignOutButton from '../../../components/SignOutButton';

export default async function RequirementPage({ params }: { params: Promise<{ requirementId: string }> }) {
  const { requirementId } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single();
  const isInternalUser = profile?.role === 'admin' || profile?.role === 'internal';

  const { data: requirement } = await supabase
    .from('requirements')
    .select('*, categories(name), workspaces(id, name)')
    .eq('id', requirementId)
    .single();

  if (!requirement) redirect('/dashboard');

  const { data: comments } = await supabase
    .from('comments')
    .select('*, profiles(full_name, email, role)')
    .eq('requirement_id', requirementId)
    .order('created_at', { ascending: true });

  return (
    <main className="container">
      <div className="header">
        <div>
          <Link className="small" href={`/workspaces/${requirement.workspaces.id}`}>← Back to workspace</Link>
          <h1>{requirement.title}</h1>
          <p className="small">{requirement.workspaces.name} · {requirement.categories?.name}</p>
        </div>
        <SignOutButton />
      </div>

      <div className="grid requirement-grid">
        <section className="card">
          <span className="badge">Our guidelines / expectation</span>
          <div className="guidelines">{requirement.our_need}</div>

          <h3>Document expected</h3>
          <p className="small">{requirement.expected_document || 'No mandatory document.'}</p>

          <h3>Status</h3>
          <span className="badge">{requirement.status}</span>

          {isInternalUser && (
            <>
              <h3>Tenengroup internal notes</h3>
              <p className="small pre-wrap">{requirement.internal_notes || 'No internal notes yet.'}</p>
            </>
          )}
        </section>

        <section className="card">
          <span className="badge">Response & status</span>
          <RequirementResponseForm
            requirementId={requirement.id}
            initialResponse={requirement.supplier_response}
            initialStatus={requirement.status}
            initialInternalNotes={requirement.internal_notes}
            canEditStatus={isInternalUser}
            canEditInternalNotes={isInternalUser}
          />
        </section>
      </div>

      <div style={{ marginTop: 18 }}>
        <CommentThread
          requirementId={requirement.id}
          userId={user.id}
          comments={(comments || []) as any}
          canUseInternalComments={isInternalUser}
        />
      </div>
    </main>
  );
}
