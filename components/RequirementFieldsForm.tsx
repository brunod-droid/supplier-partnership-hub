'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

type Props = {
  requirementId: string;
  initialOurNeed: string;
  initialSupplierResponse: string | null;
  initialFinalDecision: string | null;
  initialStatus: string;
  role: string;
};

const statuses = ['Waiting Supplier', 'Supplier Answered', 'Discussion', 'Validated'];

export default function RequirementFieldsForm({
  requirementId,
  initialOurNeed,
  initialSupplierResponse,
  initialFinalDecision,
  initialStatus,
  role
}: Props) {
  const supabase = createClient();
  const router = useRouter();
  const canEditInternal = role === 'admin' || role === 'internal';
  const [ourNeed, setOurNeed] = useState(initialOurNeed || '');
  const [supplierResponse, setSupplierResponse] = useState(initialSupplierResponse || '');
  const [finalDecision, setFinalDecision] = useState(initialFinalDecision || '');
  const [status, setStatus] = useState(initialStatus || 'Waiting Supplier');
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  async function save() {
    setSaving(true);
    setMessage('');

    const payload: any = {
      supplier_response: supplierResponse,
      updated_at: new Date().toISOString()
    };

    if (canEditInternal) {
      payload.our_need = ourNeed;
      payload.final_decision = finalDecision;
      payload.status = status;
    } else {
      payload.status = 'Supplier Answered';
    }

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
    <div className="grid field-grid">
      <section className="field-block need-block">
        <div className="field-title">Our need</div>
        <p className="small">This is Tenengroup/Lime&Lou expectation or guideline for this point.</p>
        {canEditInternal ? (
          <textarea rows={10} value={ourNeed} onChange={e => setOurNeed(e.target.value)} placeholder="Write our business need / guideline here..." />
        ) : (
          <div className="readonly-box">{ourNeed || 'No guideline yet.'}</div>
        )}
      </section>

      <section className="field-block supplier-block">
        <div className="field-title">Supplier answer</div>
        <p className="small">Supplier must complete this field with answer, process, SLA, limitation and documents if needed.</p>
        <textarea rows={10} value={supplierResponse} onChange={e => setSupplierResponse(e.target.value)} placeholder="Supplier answer..." />
      </section>

      <section className="field-block decision-block">
        <div className="field-title">Final decision</div>
        <p className="small">Internal decision after review: validated agreement, rejected point, clarification, compensation rule, or next action.</p>
        {canEditInternal ? (
          <textarea rows={7} value={finalDecision} onChange={e => setFinalDecision(e.target.value)} placeholder="Write final decision / agreement here..." />
        ) : (
          <div className="readonly-box">{finalDecision || 'No final decision yet.'}</div>
        )}
      </section>

      <section className="field-block status-block">
        <div className="field-title">Status</div>
        <p className="small">Workflow: Waiting Supplier → Supplier Answered → Discussion → Validated.</p>
        {canEditInternal ? (
          <select value={status} onChange={e => setStatus(e.target.value)}>
            {statuses.map(s => <option key={s} value={s}>{s}</option>)}
          </select>
        ) : (
          <span className="badge">{status}</span>
        )}
      </section>

      <div>
        <button className="btn" type="button" onClick={save} disabled={saving}>{saving ? 'Saving...' : 'Save'}</button>
        {message && <p className="small">{message}</p>}
      </div>
    </div>
  );
}
