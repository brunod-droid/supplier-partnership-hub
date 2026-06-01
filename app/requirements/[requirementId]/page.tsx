import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import RequirementFieldsForm from '../../../components/RequirementFieldsForm';
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

      <section className="card">
        <RequirementFieldsForm
          requirementId={requirement.id}
          initialOurNeed={requirement.our_need}
          initialSupplierResponse={requirement.supplier_response}
          initialFinalDecision={requirement.final_decision}
          initialStatus={requirement.status}
          role={profile?.role || 'supplier'}
        />
      </section>
    </main>
  );
}
