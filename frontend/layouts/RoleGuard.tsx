"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuthStore } from "@/store/auth.store";
import { ROUTES } from "@/lib/constants";
import type { UserRole } from "@/types";
import { Loader2 } from "lucide-react";

interface RoleGuardProps {
  allow: UserRole[];
  children: React.ReactNode;
}

/**
 * Client-side route protection. Real authorization is still enforced server-side
 * by FastAPI's RBAC dependencies (require_admin/require_pharmacist/require_customer) —
 * this guard only controls what the UI shows/redirects to, it is not the security boundary.
 */
export function RoleGuard({ allow, children }: RoleGuardProps) {
  const router = useRouter();
  const { user, token, isHydrated } = useAuthStore();

  useEffect(() => {
    if (!isHydrated) return;
    if (!token || !user) {
      router.replace(ROUTES.login);
      return;
    }
    if (!allow.includes(user.role)) {
      router.replace(ROUTES.login);
    }
  }, [isHydrated, token, user, allow, router]);

  if (!isHydrated || !user || !allow.includes(user.role)) {
    return (
      <div className="flex min-h-[60vh] items-center justify-center">
        <Loader2 className="h-6 w-6 animate-spin text-primary" />
      </div>
    );
  }

  return <>{children}</>;
}
