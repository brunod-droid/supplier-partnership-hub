import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import RequirementResponseForm from '../../../components/RequirementResponseForm';
import SignOutButton from '../../../components/SignOutButton';

export default async function RequirementPage({ params }: { params: Promise<{ requirementId: string }> }) {
  const { requirementId } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single();
  const { data: requirement } = await supabase
    .from('requirements')
    .select('*, categories(name), workspaces(id, name)')
    .eq('id', requirementId)
    .single();

  if (!requirement) redirect('/dashboard');

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

      <div className="grid" style={{ gridTemplateColumns: '1fr 1fr' }}>
        <section className="card">
          <span className="badge">Our need</span>
          <p>{requirement.our_need}</p>
          <h3>Document expected</h3>
          <p className="small">{requirement.expected_document || 'No mandatory document.'}</p>
          <h3>Status</h3>
          <span className="badge">{requirement.status}</span>
          {profile?.role !== 'supplier' && (
            <>
              <h3>Internal notes</h3>
              <p className="small">{requirement.internal_notes || 'No internal notes yet.'}</p>
            </>
          )}
        </section>

        <section className="card">
          <span className="badge">Supplier answer</span>
          <RequirementResponseForm
            requirementId={requirement.id}
            initialResponse={requirement.supplier_response}
            initialStatus={requirement.status}
            canEditStatus={profile?.role !== 'supplier'}
          />
        </section>
      </div>
    </main>
  );
}
