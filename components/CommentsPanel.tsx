'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

type Comment = {
  id: string;
  body: string;
  is_internal: boolean;
  created_at: string;
  profiles?: {
    full_name: string | null;
    email: string | null;
    role: string | null;
  } | null;
};

type Props = {
  requirementId: string;
  userId: string;
  role: 'admin' | 'internal' | 'supplier';
  comments: Comment[];
};

export default function CommentsPanel({ requirementId, userId, role, comments }: Props) {
  const supabase = createClient();
  const router = useRouter();
  const canInternal = role !== 'supplier';
  const [body, setBody] = useState('');
  const [isInternal, setIsInternal] = useState(false);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  async function addComment() {
    if (!body.trim()) return;
    setSaving(true);
    setMessage('');

    const { error } = await supabase.from('comments').insert({
      requirement_id: requirementId,
      author_id: userId,
      body: body.trim(),
      is_internal: canInternal ? isInternal : false
    });

    setSaving(false);

    if (error) {
      setMessage(error.message);
      return;
    }

    setBody('');
    setIsInternal(false);
    router.refresh();
  }

  return (
    <section className="card">
      <h2>Comments</h2>

      <div className="grid" style={{ marginBottom: 16 }}>
        {comments.length === 0 && <p className="small">No comments yet.</p>}
        {comments.map((comment) => (
          <div key={comment.id} style={{ border: '1px solid #ececf0', borderRadius: 14, padding: 12 }}>
            <div className="nav" style={{ justifyContent: 'space-between' }}>
              <b>{comment.profiles?.full_name || comment.profiles?.email || 'User'}</b>
              <span className="small">{new Date(comment.created_at).toLocaleString()}</span>
            </div>
            {comment.is_internal && <span className="badge">Internal only</span>}
            <p style={{ whiteSpace: 'pre-wrap' }}>{comment.body}</p>
          </div>
        ))}
      </div>

      <label>
        <b>Add comment</b>
        <textarea rows={4} value={body} onChange={(e) => setBody(e.target.value)} placeholder="Write a comment..." />
      </label>

      {canInternal && (
        <label className="nav" style={{ marginTop: 10, justifyContent: 'flex-start' }}>
          <input type="checkbox" checked={isInternal} onChange={(e) => setIsInternal(e.target.checked)} style={{ width: 'auto' }} />
          <span className="small">Internal note only - hidden from supplier</span>
        </label>
      )}

      <div className="nav" style={{ marginTop: 12 }}>
        <button className="btn" type="button" onClick={addComment} disabled={saving || !body.trim()}>
          {saving ? 'Adding...' : 'Add comment'}
        </button>
        {message && <p className="small">{message}</p>}
      </div>
    </section>
  );
}
