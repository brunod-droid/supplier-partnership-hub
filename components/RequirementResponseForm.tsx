'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

type Props = {
  requirementId: string;
  initialResponse: string | null;
  initialStatus: string;
  canEditStatus: boolean;
};

const statuses = [
  'Waiting Supplier',
  'Supplier Replied',
  'Internal Review',
  'Need Clarification',
  'Approved',
  'Rejected',
  'Blocked'
];

export default function RequirementResponseForm({ requirementId, initialResponse, initialStatus, canEditStatus }: Props) {
  const supabase = createClient();
  const router = useRouter();
  const [supplierResponse, setSupplierResponse] = useState(initialResponse || '');
  const [status, setStatus] = useState(initialStatus || 'Waiting Supplier');
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  async function save() {
    setSaving(true);
    setMessage('');
    const payload: any = {
      supplier_response: supplierResponse,
      status: canEditStatus ? status : 'Supplier Replied',
      updated_at: new Date().toISOString()
    };
    const { error } = await supabase.from('requirements').update(payload).eq('id', requirementId);
    setSaving(false);
    if (error) {
      setMessage(error.message);
      return;
    }
    setMessage('Saved.');
    router.refresh();
  }

  return (
    <div className="grid">
      <label>
        Supplier response
        <textarea rows={9} value={supplierResponse} onChange={e => setSupplierResponse(e.target.value)} placeholder="Write the supplier answer here..." />
      </label>
      {canEditStatus && (
        <label>
          Status
          <select value={status} onChange={e => setStatus(e.target.value)}>
            {statuses.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        </label>
      )}
      <button className="btn" type="button" onClick={save} disabled={saving}>{saving ? 'Saving...' : 'Save response'}</button>
      {message && <p className="small">{message}</p>}
    </div>
  );
}
