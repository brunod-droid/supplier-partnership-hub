'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '../../lib/supabase-browser';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  async function signIn(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return setError(error.message);
    router.push('/dashboard');
    router.refresh();
  }

  return (
    <main className="container" style={{ maxWidth: 520 }}>
      <div className="card">
        <h1>Supplier Partnership Hub</h1>
        <p className="small">Private access for Bruno, Tenengroup and suppliers.</p>
        <form className="grid" onSubmit={signIn}>
          <label>Email<input className="input" value={email} onChange={e => setEmail(e.target.value)} /></label>
          <label>Password<input className="input" type="password" value={password} onChange={e => setPassword(e.target.value)} /></label>
          {error && <p style={{ color: '#b91c1c' }}>{error}</p>}
          <button className="btn">Sign in</button>
        </form>
      </div>
    </main>
  );
}
