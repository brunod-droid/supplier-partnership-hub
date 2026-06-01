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
    <section className="discussion-card">
      <div className="section-heading compact">
        <p className="eyebrow">Discussion</p>
        <h2>Comments</h2>
      </div>

      <div className="comment-list">
        {comments.length === 0 && <p className="muted">No comments yet.</p>}
        {comments.map((comment) => (
          <article key={comment.id} className="comment-card">
            <div className="comment-meta">
              <b>{comment.profiles?.full_name || comment.profiles?.email || 'User'}</b>
              <span>{new Date(comment.created_at).toLocaleString()}</span>
            </div>
            {comment.is_internal && <span className="badge">Internal only</span>}
            <p>{comment.body}</p>
          </article>
        ))}
      </div>

      <label>
        <b>Add comment</b>
        <textarea rows={5} value={body} onChange={(e) => setBody(e.target.value)} placeholder="Write a comment or clarification..." />
      </label>

      {canInternal && (
        <label className="check-row" style={{ marginTop: 10 }}>
          <input type="checkbox" checked={isInternal} onChange={(e) => setIsInternal(e.target.checked)} />
          <span>Internal note only - hidden from supplier</span>
        </label>
      )}

      <div className="save-bar compact-save">
        <button className="btn" type="button" onClick={addComment} disabled={saving || !body.trim()}>
          {saving ? 'Adding...' : 'Add comment'}
        </button>
        {message && <p className="muted">{message}</p>}
      </div>
    </section>
  );
}
