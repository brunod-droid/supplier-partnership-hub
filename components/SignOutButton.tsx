'use client';
import { useRouter } from 'next/navigation';
import { createClient } from '../lib/supabase-browser';

export default function SignOutButton() {
  const router = useRouter();
  async function signOut() {
    await createClient().auth.signOut();
    router.push('/login');
    router.refresh();
  }
  return <button className="btn secondary" onClick={signOut}>Sign out</button>;
}
