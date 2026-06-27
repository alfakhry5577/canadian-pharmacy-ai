import Link from "next/link";
import { ROUTES } from "@/lib/constants";

export function AuthLayout({ children, title, subtitle }: { children: React.ReactNode; title: string; subtitle: string }) {
  return (
    <div className="flex min-h-screen items-center justify-center bg-gradient-to-b from-accent to-background px-4 py-12">
      <div className="w-full max-w-md">
        <Link href={ROUTES.home} className="mb-8 block text-center font-display text-2xl font-bold text-primary">
          روشتة AI
        </Link>
        <div className="rounded-2xl border border-border bg-card p-8 shadow-sm">
          <h1 className="mb-1 font-display text-xl font-bold">{title}</h1>
          <p className="mb-6 text-sm text-muted-foreground">{subtitle}</p>
          {children}
        </div>
      </div>
    </div>
  );
}
