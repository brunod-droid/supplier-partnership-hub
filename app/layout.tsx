import './globals.css';

export const metadata = {
  title: 'Supplier Partnership Hub',
  description: 'Tenengroup supplier collaboration portal'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
