"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, LogOut, type LucideIcon } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { NotificationBell } from "@/components/shared/NotificationBell";
import { useAuth } from "@/hooks/useAuth";
import { ROLE_LABELS_AR } from "@/lib/constants";
import { initials } from "@/lib/utils";

export interface NavItem {
  label: string;
  href: string;
  icon: LucideIcon;
  badge?: number;
}

interface DashboardLayoutProps {
  navItems: NavItem[];
  portalLabel: string;
  children: React.ReactNode;
}

export function DashboardLayout({ navItems, portalLabel, children }: DashboardLayoutProps) {
  const pathname = usePathname();
  const { user, logout } = useAuth();
  const [mobileOpen, setMobileOpen] = useState(false);

  const SidebarContent = (
    <>
      <div className="mb-8 flex items-center justify-between px-2">
        <div>
          <p className="font-display text-lg font-bold text-primary">روشتة AI</p>
          <p className="text-xs text-muted-foreground">{portalLabel}</p>
        </div>
        <NotificationBell />
      </div>
      <nav className="flex flex-1 flex-col gap-1">
        {navItems.map((item) => {
          const active = pathname === item.href || pathname?.startsWith(item.href + "/");
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                "flex items-center justify-between gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors",
                active ? "bg-primary/10 text-primary" : "text-muted-foreground hover:bg-muted hover:text-foreground"
              )}
            >
              <span className="flex items-center gap-3">
                <Icon className="h-4 w-4" />
                {item.label}
              </span>
              {!!item.badge && (
                <span className="rounded-full bg-destructive px-2 py-0.5 text-[10px] font-bold text-destructive-foreground">
                  {item.badge}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="mt-auto flex items-center gap-3 rounded-xl border border-border p-3">
        <Avatar className="h-9 w-9">
          <AvatarFallback>{user ? initials(user.full_name) : "?"}</AvatarFallback>
        </Avatar>
        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-semibold">{user?.full_name}</p>
          <p className="text-xs text-muted-foreground">{user ? ROLE_LABELS_AR[user.role] : ""}</p>
        </div>
        <Button variant="ghost" size="icon" onClick={logout} aria-label="تسجيل الخروج">
          <LogOut className="h-4 w-4" />
        </Button>
      </div>
    </>
  );

  return (
    <div className="min-h-screen bg-background">
      {/* Desktop sidebar */}
      <aside className="fixed inset-y-0 start-0 hidden w-64 flex-col border-e border-border bg-card p-4 lg:flex">
        {SidebarContent}
      </aside>

      {/* Mobile sidebar */}
      {mobileOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          <div className="absolute inset-0 bg-black/40" onClick={() => setMobileOpen(false)} />
          <aside className="absolute inset-y-0 start-0 flex w-72 flex-col bg-card p-4 shadow-xl">{SidebarContent}</aside>
        </div>
      )}

      <div className="lg:ps-64">
        <header className="sticky top-0 z-30 flex items-center justify-between border-b border-border bg-card/80 px-4 py-3 backdrop-blur lg:hidden">
          <Button variant="ghost" size="icon" onClick={() => setMobileOpen(true)}>
            <Menu className="h-5 w-5" />
          </Button>
          <p className="font-display font-bold text-primary">روشتة AI</p>
          <NotificationBell />
        </header>

        <main className="p-4 sm:p-6 lg:p-8">{children}</main>
      </div>
    </div>
  );
}
