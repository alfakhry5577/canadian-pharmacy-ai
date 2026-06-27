"use client";

import {
  LayoutDashboard, Users, Boxes, BarChart3, BotMessageSquare, ScrollText, Settings,
} from "lucide-react";
import { RoleGuard } from "@/layouts/RoleGuard";
import { DashboardLayout, type NavItem } from "@/layouts/DashboardLayout";
import { ROUTES } from "@/lib/constants";

const navItems: NavItem[] = [
  { label: "نظرة عامة", href: ROUTES.admin.dashboard, icon: LayoutDashboard },
  { label: "المستخدمون", href: ROUTES.admin.users, icon: Users },
  { label: "المخزون", href: ROUTES.admin.inventory, icon: Boxes },
  { label: "التقارير", href: ROUTES.admin.reports, icon: BarChart3 },
  { label: "مراقبة الذكاء الاصطناعي", href: ROUTES.admin.aiMonitoring, icon: BotMessageSquare },
  { label: "سجل التدقيق", href: ROUTES.admin.auditLogs, icon: ScrollText },
  { label: "الإعدادات", href: ROUTES.admin.settings, icon: Settings },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return (
    <RoleGuard allow={["admin"]}>
      <DashboardLayout navItems={navItems} portalLabel="بوابة الإدارة">
        {children}
      </DashboardLayout>
    </RoleGuard>
  );
}
