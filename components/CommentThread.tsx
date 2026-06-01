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
  comments: Comment[];
  canUseInternalComments: boolean;
};

export default function CommentThread({ requirementId, userId, comments, canUseInternalComments }: Props) {
  const supabase = createClient();
  const router = useRouter();
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
      is_internal: canUseInternalComments ? isInternal : false
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
      <div className="section-title">
        <span className="badge">Discussion</span>
        <span className="small">Supplier comments and Tenengroup follow-up</span>
      </div>

      <div className="comment-list">
        {comments.length === 0 && <p className="small">No comments yet.</p>}
        {comments.map(comment => (
          <div key={comment.id} className="comment">
            <div className="comment-header">
              <b>{comment.profiles?.full_name || comment.profiles?.email || 'User'}</b>
              {comment.is_internal && <span className="badge">Internal</span>}
              <span className="small">{new Date(comment.created_at).toLocaleString()}</span>
            </div>
            <p>{comment.body}</p>
          </div>
        ))}
      </div>

      <div className="grid" style={{ marginTop: 16 }}>
        <textarea
          rows={4}
          value={body}
          onChange={e => setBody(e.target.value)}
          placeholder="Add a comment or ask a question..."
        />
        {canUseInternalComments && (
          <label className="checkbox-row">
            <input type="checkbox" checked={isInternal} onChange={e => setIsInternal(e.target.checked)} />
            Internal comment only visible to Bruno / Tenengroup
          </label>
        )}
        <button className="btn secondary" type="button" onClick={addComment} disabled={saving}>
          {saving ? 'Adding...' : 'Add comment'}
        </button>
        {message && <p className="small">{message}</p>}
      </div>
    </section>
  );
}
