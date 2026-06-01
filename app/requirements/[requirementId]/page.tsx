import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import SignOutButton from '../../../components/SignOutButton';
import RequirementEditor from '../../../components/RequirementEditor';
import CommentsPanel from '../../../components/CommentsPanel';

export const dynamic = 'force-dynamic';

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

  const normalizedComments = (comments || [])
    .map((comment: any) => ({
      ...comment,
      profiles: Array.isArray(comment.profiles)
        ? comment.profiles[0] || null
        : comment.profiles
    }))
    .filter((comment: any) => profile.role !== 'supplier' || !comment.is_internal);

  return (
    <main className="requirement-page">
      <div className="requirement-topbar">
        <div>
          <Link className="small" href={`/workspaces/${requirement.workspaces.id}`}>
            ← Back to {requirement.workspaces.name}
          </Link>
          <h1>{requirement.title}</h1>
          <p className="muted">
            {requirement.workspaces.name} · {requirement.categories?.name} · Role: {profile.role}
          </p>
        </div>
        <SignOutButton />
      </div>

      <div className="requirement-layout">
        <section className="requirement-content">
          <RequirementEditor
            requirementId={requirement.id}
            role={profile.role}
            initialTitle={requirement.title}
            initialOurNeed={requirement.our_need}
            initialExampleResponse={requirement.example_response}
            initialSupplierResponse={requirement.supplier_response}
            initialFinalDecision={requirement.final_decision}
            initialStatus={requirement.status}
            initialIsHidden={Boolean(requirement.is_hidden)}
          />
        </section>

        <aside className="requirement-side-panel">
          <CommentsPanel
            requirementId={requirement.id}
            userId={user.id}
            role={profile.role}
            comments={normalizedComments}
          />
        </aside>
      </div>
    </main>
  );
}
