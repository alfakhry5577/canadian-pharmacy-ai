"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { useAuthStore } from "@/store/auth.store";
import { ROUTES } from "@/lib/constants";

function homeForRole(role?: string) {
  if (role === "admin") return ROUTES.admin.dashboard;
  if (role === "pharmacist") return ROUTES.pharmacist.dashboard;
  return ROUTES.customer.dashboard;
}

export function Navbar() {
  const { user, token } = useAuthStore();

  return (
    <header className="sticky top-0 z-40 border-b border-border bg-background/85 backdrop-blur">
      <div className="container flex h-16 items-center justify-between">
        <Link href={ROUTES.home} className="font-display text-xl font-bold text-primary">
          روشتة AI
        </Link>

        <nav className="hidden items-center gap-6 text-sm font-medium text-muted-foreground md:flex">
          <a href="#features" className="hover:text-foreground">المميزات</a>
          <a href="#how-it-works" className="hover:text-foreground">كيف يعمل</a>
          <a href="#safety" className="hover:text-foreground">السلامة الطبية</a>
        </nav>

        <div className="flex items-center gap-2">
          {token && user ? (
            <Button asChild size="sm">
              <Link href={homeForRole(user.role)}>لوحتي</Link>
            </Button>
          ) : (
            <>
              <Button asChild variant="ghost" size="sm">
                <Link href={ROUTES.login}>تسجيل الدخول</Link>
              </Button>
              <Button asChild size="sm">
                <Link href={ROUTES.register}>إنشاء حساب</Link>
              </Button>
            </>
          )}
        </div>
      </div>
    </header>
  );
}
