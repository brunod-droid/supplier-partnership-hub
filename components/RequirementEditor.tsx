'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

type Props = {
  requirementId: string;
  role: 'admin' | 'internal' | 'supplier';
  initialOurNeed: string;
  initialExampleResponse: string | null;
  initialSupplierResponse: string | null;
  initialFinalDecision: string | null;
  initialStatus: string;
};

const statuses = [
  'Waiting Supplier',
  'Supplier Answered',
  'Discussion',
  'Validated'
];

export default function RequirementEditor({
  requirementId,
  role,
  initialOurNeed,
  initialExampleResponse,
  initialSupplierResponse,
  initialFinalDecision,
  initialStatus
}: Props) {
  const supabase = createClient();
  const router = useRouter();
  const isSupplier = role === 'supplier';
  const [ourNeed, setOurNeed] = useState(initialOurNeed || '');
  const [exampleResponse, setExampleResponse] = useState(initialExampleResponse || '');
  const [supplierResponse, setSupplierResponse] = useState(initialSupplierResponse || '');
  const [finalDecision, setFinalDecision] = useState(initialFinalDecision || '');
  const [status, setStatus] = useState(initialStatus || 'Waiting Supplier');
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');

  async function save() {
    setSaving(true);
    setMessage('');

    const payload: Record<string, string> = {
      supplier_response: supplierResponse,
      updated_at: new Date().toISOString()
    };

    if (!isSupplier) {
      payload.our_need = ourNeed;
      payload.example_response = exampleResponse;
      payload.final_decision = finalDecision;
      payload.status = status;
    } else if (status === 'Waiting Supplier') {
      payload.status = 'Supplier Answered';
    }

    const { error } = await supabase
      .from('requirements')
      .update(payload)
      .eq('id', requirementId);

    setSaving(false);

    if (error) {
      setMessage(error.message);
      return;
    }

    setMessage('Saved successfully.');
    router.refresh();
  }

  return (
    <section className="card">
      <div className="grid">
        <label>
          <b>Our need</b>
          <textarea
            rows={10}
            value={ourNeed}
            onChange={(e) => setOurNeed(e.target.value)}
            disabled={isSupplier}
            placeholder="Write Tenengroup needs / guidelines here..."
          />
          {isSupplier && <p className="small">Read-only for supplier users.</p>}
        </label>

        <label>
          <b>Example / expected format</b>
          <textarea
            rows={5}
            value={exampleResponse}
            onChange={(e) => setExampleResponse(e.target.value)}
            disabled={isSupplier}
            placeholder="Add a short example to help the supplier answer correctly..."
          />
          {isSupplier && <p className="small">This example is here to help you structure your answer.</p>}
        </label>

        <label>
          <b>Supplier answer</b>
          <textarea
            rows={8}
            value={supplierResponse}
            onChange={(e) => setSupplierResponse(e.target.value)}
            placeholder="Supplier writes the answer here..."
          />
        </label>

        <label>
          <b>Final decision</b>
          <textarea
            rows={6}
            value={finalDecision}
            onChange={(e) => setFinalDecision(e.target.value)}
            disabled={isSupplier}
            placeholder="Write the final decision, validation, or remaining condition here..."
          />
          {isSupplier && <p className="small">Read-only for supplier users.</p>}
        </label>

        <label>
          <b>Status</b>
          <select value={status} onChange={(e) => setStatus(e.target.value)} disabled={isSupplier}>
            {statuses.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
          {isSupplier && <p className="small">Supplier answers automatically move the line to Supplier Answered.</p>}
        </label>

        <div className="nav">
          <button className="btn" type="button" onClick={save} disabled={saving}>
            {saving ? 'Saving...' : 'Save'}
          </button>
          {message && <p className="small">{message}</p>}
        </div>
      </div>
    </section>
  );
}
