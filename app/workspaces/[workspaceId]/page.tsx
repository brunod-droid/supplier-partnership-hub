import { redirect } from 'next/navigation';
import { createClient } from '../../../lib/supabase-server';
import SignOutButton from '../../../components/SignOutButton';

export default async function WorkspacePage({ params }: { params: Promise<{ workspaceId: string }> }) {
  const { workspaceId } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: access } = await supabase.from('workspace_access').select('*').eq('user_id', user.id).eq('workspace_id', workspaceId).single();
  if (!access) redirect('/dashboard');

  const { data: workspace } = await supabase.from('workspaces').select('*').eq('id', workspaceId).single();
  const { data: items } = await supabase
    .from('requirements')
    .select('*, categories(name, sort_order)')
    .eq('workspace_id', workspaceId)
    .order('sort_order', { referencedTable: 'categories' })
    .order('sort_order');

  const grouped = (items || []).reduce((acc: any, item: any) => {
    const key = item.categories?.name || 'Other';
    acc[key] = acc[key] || [];
    acc[key].push(item);
    return acc;
  }, {});

  return (
    <main className="container">
      <div className="header">
        <div>
          <h1>{workspace?.name}</h1>
          <p className="small">Supplier-friendly checklist: Our need → Supplier response → Attachments → Approval.</p>
        </div>
        <SignOutButton />
      </div>

      {Object.entries(grouped).map(([category, reqs]: any) => (
        <section className="card" key={category} style={{ marginBottom: 18 }}>
          <h2>{category}</h2>
          <table className="table">
            <thead><tr><th>Requirement</th><th>Our need</th><th>Supplier response</th><th>Status</th></tr></thead>
            <tbody>
              {reqs.map((item: any) => (
                <tr key={item.id}>
                  <td><a href={`/requirements/${item.id}`}><b>{item.title}</b></a><div className="small">{item.expected_document || 'No mandatory document'}</div></td>
                  <td>{item.our_need}</td>
                  <td>{item.supplier_response || <span className="small">Waiting supplier response</span>}</td>
                  <td><span className="badge">{item.status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      ))}
    </main>
  );
}
