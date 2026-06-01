import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import SignOutButton from '../../../components/SignOutButton';

export const dynamic = 'force-dynamic';

type Requirement = {
  id: string;
  title: string;
  status: string;
  supplier_response: string | null;
  final_decision: string | null;
  sort_order: number | null;
  is_hidden?: boolean | null;
  categories?: { id?: string; name: string; sort_order: number | null } | null;
};

const statusOrder = ['Waiting Supplier', 'Supplier Answered', 'Discussion', 'Validated'];

function statusClass(status: string) {
  if (status === 'Validated') return 'status status-validated';
  if (status === 'Discussion') return 'status status-discussion';
  if (status === 'Supplier Answered') return 'status status-answered';
  return 'status status-waiting';
}

function categoryHealth(reqs: Requirement[]) {
  if (!reqs.length) return 'Not started';
  const validated = reqs.filter((r) => r.status === 'Validated').length;
  if (validated === reqs.length) return 'Validated';
  if (reqs.some((r) => r.status === 'Discussion')) return 'Discussion';
  if (reqs.some((r) => r.status === 'Supplier Answered')) return 'Supplier answered';
  return 'Waiting supplier';
}

export default async function WorkspacePage({
  params,
  searchParams
}: {
  params: Promise<{ workspaceId: string }>;
  searchParams?: Promise<{ showHidden?: string }>;
}) {
  const { workspaceId } = await params;
  const sp = searchParams ? await searchParams : {};
  const showHidden = sp?.showHidden === '1';

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single();

  if (!profile) redirect('/login');

  const { data: access } = await supabase
    .from('workspace_access')
    .select('*')
    .eq('user_id', user.id)
    .eq('workspace_id', workspaceId)
    .single();

  if (!access) redirect('/dashboard');

  const { data: workspace } = await supabase
    .from('workspaces')
    .select('*')
    .eq('id', workspaceId)
    .single();

  let query = supabase
    .from('requirements')
    .select('id, title, status, supplier_response, final_decision, sort_order, is_hidden, categories(id, name, sort_order)')
    .eq('workspace_id', workspaceId)
    .order('sort_order', { referencedTable: 'categories' })
    .order('sort_order');

  if (!showHidden) {
    query = query.eq('is_hidden', false);
  }

  const { data: items } = await query;
  const requirements = (items || []).map((item: any) => ({
  ...item,
  categories: Array.isArray(item.categories)
    ? item.categories[0] || null
    : item.categories
})) as Requirement[];

  const grouped = requirements.reduce((acc: Record<string, Requirement[]>, item) => {
    const key = item.categories?.name || 'Other';
    acc[key] = acc[key] || [];
    acc[key].push(item);
    return acc;
  }, {});

  const total = requirements.length;
  const counts = statusOrder.reduce((acc: Record<string, number>, status) => {
    acc[status] = requirements.filter((r) => r.status === status).length;
    return acc;
  }, {});
  const completion = total ? Math.round(((counts.Validated || 0) / total) * 100) : 0;
  const canManage = profile.role !== 'supplier';

  return (
    <main className="handbook-shell">
      <aside className="sidebar">
        <div className="sidebar-title">Supplier Handbook</div>
        <Link href="/dashboard" className="sidebar-link">← Dashboard</Link>
        <div className="sidebar-section-title">Categories</div>
        {Object.entries(grouped).map(([category, reqs]) => (
          <a key={category} href={`#${category.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}`} className="sidebar-link">
            <span>{category}</span>
            <span className="sidebar-count">{reqs.length}</span>
          </a>
        ))}
      </aside>

      <section className="handbook-main">
        <div className="handbook-topbar">
          <div>
            <h1>{workspace?.name}</h1>
            <p className="muted">A shared operational reference between Tenengroup and the supplier.</p>
          </div>
          <SignOutButton />
        </div>

        <section className="hero-card">
          <div>
            <p className="eyebrow">Partnership readiness</p>
            <h2>{completion}% validated</h2>
            <div className="progress"><span style={{ width: `${completion}%` }} /></div>
          </div>
          <div className="metric-grid">
            <div className="metric"><b>{total}</b><span>Total lines</span></div>
            <div className="metric"><b>{counts['Waiting Supplier'] || 0}</b><span>Waiting supplier</span></div>
            <div className="metric"><b>{counts['Supplier Answered'] || 0}</b><span>Supplier answered</span></div>
            <div className="metric"><b>{counts.Discussion || 0}</b><span>Discussion</span></div>
            <div className="metric"><b>{counts.Validated || 0}</b><span>Validated</span></div>
          </div>
        </section>

        {canManage && (
          <div className="toolbar-card">
            <span className="muted">Admin tools</span>
            {showHidden ? (
              <Link className="btn secondary" href={`/workspaces/${workspaceId}`}>Hide archived lines</Link>
            ) : (
              <Link className="btn secondary" href={`/workspaces/${workspaceId}?showHidden=1`}>Show hidden lines</Link>
            )}
          </div>
        )}

        <div className="category-stack">
          {Object.entries(grouped).map(([category, reqs]) => (
            <section className="category-panel" key={category} id={category.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}>
              <div className="category-header">
                <div>
                  <p className="eyebrow">Category</p>
                  <h2>{category}</h2>
                </div>
                <span className="status">{categoryHealth(reqs)}</span>
              </div>

              <div className="requirement-list">
                {reqs.map((item) => (
                  <Link className="requirement-card" key={item.id} href={`/requirements/${item.id}`}>
                    <div>
                      <h3>{item.title}</h3>
                      <p className="muted">
                        {item.supplier_response ? 'Supplier answer received.' : 'Waiting for supplier input.'}
                        {item.final_decision ? ' Final decision recorded.' : ''}
                      </p>
                    </div>
                    <div className="requirement-card-side">
                      {item.is_hidden && <span className="badge">Hidden</span>}
                      <span className={statusClass(item.status)}>{item.status}</span>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          ))}
        </div>
      </section>
    </main>
  );
}
