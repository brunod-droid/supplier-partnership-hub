'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

type Role = 'admin' | 'internal' | 'supplier';

type Props = {
  requirementId: string;
  role: Role;
  initialTitle: string;
  initialOurNeed: string;
  initialExampleResponse: string | null;
  initialSupplierResponse: string | null;
  initialFinalDecision: string | null;
  initialStatus: string;
  initialIsHidden?: boolean;
};

const statuses = [
  'Waiting Supplier',
  'Supplier Answered',
  'Discussion',
  'Validated'
];

function statusClass(status: string) {
  if (status === 'Validated') return 'status status-validated';
  if (status === 'Discussion') return 'status status-discussion';
  if (status === 'Supplier Answered') return 'status status-answered';
  return 'status status-waiting';
}

function splitNeed(text: string) {
  const clean = text || '';
  const markers = ['What we need', 'Why this matters', 'Example / expected format', 'Example'];
  const found = markers
    .map((marker) => ({ marker, index: clean.indexOf(marker) }))
    .filter((item) => item.index >= 0)
    .sort((a, b) => a.index - b.index);

  if (!found.length) {
    return [{ title: 'Our requirement', body: clean }];
  }

  return found.map((item, index) => {
    const start = item.index + item.marker.length;
    const end = found[index + 1]?.index ?? clean.length;
    return {
      title: item.marker === 'What we need' ? 'What we need' : item.marker,
      body: clean.slice(start, end).trim()
    };
  }).filter((section) => section.body);
}

function TextBlock({ text }: { text: string }) {
  const lines = text.split('\n').map((line) => line.trim()).filter(Boolean);
  return (
    <div className="text-block">
      {lines.map((line, index) => {
        const isBullet = line.startsWith('-') || line.startsWith('•');
        return <p key={index} className={isBullet ? 'bullet-line' : undefined}>{line}</p>;
      })}
    </div>
  );
}

export default function RequirementEditor({
  requirementId,
  role,
  initialTitle,
  initialOurNeed,
  initialExampleResponse,
  initialSupplierResponse,
  initialFinalDecision,
  initialStatus,
  initialIsHidden = false
}: Props) {
  const supabase = createClient();
  const router = useRouter();
  const isSupplier = role === 'supplier';
  const canManage = !isSupplier;

  const [ourNeed, setOurNeed] = useState(initialOurNeed || '');
  const [exampleResponse, setExampleResponse] = useState(initialExampleResponse || '');
  const [supplierResponse, setSupplierResponse] = useState(initialSupplierResponse || '');
  const [finalDecision, setFinalDecision] = useState(initialFinalDecision || '');
  const [status, setStatus] = useState(initialStatus || 'Waiting Supplier');
  const [isHidden, setIsHidden] = useState(Boolean(initialIsHidden));
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState('');
  const sections = useMemo(() => splitNeed(ourNeed), [ourNeed]);

  async function save() {
    setSaving(true);
    setMessage('');

    const payload: Record<string, string | boolean> = {
      supplier_response: supplierResponse,
      updated_at: new Date().toISOString()
    };

    if (canManage) {
      payload.our_need = ourNeed;
      payload.example_response = exampleResponse;
      payload.final_decision = finalDecision;
      payload.status = status;
      payload.is_hidden = isHidden;
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
    <div className="handbook-requirement">
      <section className="hero-card requirement-hero">
        <div>
          <p className="eyebrow">Requirement</p>
          <h2>{initialTitle}</h2>
        </div>
        <div className="hero-actions">
          {isHidden && <span className="badge">Hidden from workspace list</span>}
          <span className={statusClass(status)}>{status}</span>
        </div>
      </section>

      <section className="playbook-section">
        <div className="section-heading">
          <p className="eyebrow">Tenengroup requirement</p>
          <h2>Our need</h2>
        </div>
        <div className="need-sections">
          {sections.map((section) => (
            <article key={section.title} className="need-card">
              <h3>{section.title}</h3>
              <TextBlock text={section.body} />
            </article>
          ))}
        </div>
      </section>

      {exampleResponse && (
        <section className="playbook-section soft-section">
          <div className="section-heading">
            <p className="eyebrow">To help you answer</p>
            <h2>Example / expected format</h2>
          </div>
          <TextBlock text={exampleResponse} />
        </section>
      )}

      {canManage && (
        <details className="admin-editor">
          <summary>Edit Tenengroup requirement and example</summary>
          <div className="grid" style={{ marginTop: 16 }}>
            <label>
              <b>Our need source text</b>
              <textarea
                rows={10}
                value={ourNeed}
                onChange={(e) => setOurNeed(e.target.value)}
                placeholder="Write Tenengroup needs / guidelines here..."
              />
            </label>
            <label>
              <b>Example / expected format</b>
              <textarea
                rows={5}
                value={exampleResponse}
                onChange={(e) => setExampleResponse(e.target.value)}
                placeholder="Add an example to help the supplier answer correctly..."
              />
            </label>
          </div>
        </details>
      )}

      <section className="playbook-section response-section">
        <div className="section-heading">
          <p className="eyebrow">Supplier input</p>
          <h2>Supplier answer</h2>
        </div>
        <textarea
          rows={10}
          value={supplierResponse}
          onChange={(e) => setSupplierResponse(e.target.value)}
          placeholder="Supplier writes the answer here. Add operational details, owner, timing, documents and limitations."
        />
      </section>

      <section className="playbook-section decision-section">
        <div className="section-heading">
          <p className="eyebrow">Tenengroup validation</p>
          <h2>Final decision</h2>
        </div>
        <textarea
          rows={7}
          value={finalDecision}
          onChange={(e) => setFinalDecision(e.target.value)}
          disabled={isSupplier}
          placeholder="Tenengroup writes the final decision, validation, condition, or remaining gap here."
        />
        {isSupplier && <p className="muted">Final decision is read-only for supplier users.</p>}
      </section>

      <section className="playbook-section control-section">
        <div className="control-grid">
          <label>
            <b>Status</b>
            <select value={status} onChange={(e) => setStatus(e.target.value)} disabled={isSupplier}>
              {statuses.map((s) => (
                <option key={s} value={s}>{s}</option>
              ))}
            </select>
            {isSupplier && <p className="muted">When the supplier saves an answer, the line moves to Supplier Answered automatically.</p>}
          </label>

          {canManage && (
            <label className="check-row">
              <input type="checkbox" checked={isHidden} onChange={(e) => setIsHidden(e.target.checked)} />
              <span>Hide this requirement from the workspace list</span>
            </label>
          )}
        </div>

        <div className="save-bar">
          <button className="btn" type="button" onClick={save} disabled={saving}>
            {saving ? 'Saving...' : 'Save changes'}
          </button>
          {message && <p className="muted">{message}</p>}
        </div>
      </section>
    </div>
  );
}
