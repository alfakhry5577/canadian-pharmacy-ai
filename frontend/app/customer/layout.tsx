"use client";

import { LayoutDashboard, Search, FileText, Bell, Award, MessageSquareText } from "lucide-react";
import { RoleGuard } from "@/layouts/RoleGuard";
import { DashboardLayout, type NavItem } from "@/layouts/DashboardLayout";
import { ROUTES } from "@/lib/constants";

const navItems: NavItem[] = [
  { label: "الرئيسية", href: ROUTES.customer.dashboard, icon: LayoutDashboard },
  { label: "البحث عن دواء", href: ROUTES.customer.search, icon: Search },
  { label: "وصفاتي", href: ROUTES.customer.prescriptions, icon: FileText },
  { label: "التذكيرات", href: ROUTES.customer.reminders, icon: Bell },
  { label: "نقاط الولاء", href: ROUTES.customer.loyalty, icon: Award },
  { label: "المساعد الذكي", href: ROUTES.customer.chat, icon: MessageSquareText },
];

export default function CustomerLayout({ children }: { children: React.ReactNode }) {
  return (
    <RoleGuard allow={["customer"]}>
      <DashboardLayout navItems={navItems} portalLabel="بوابة الزبون">
        {children}
      </DashboardLayout>
    </RoleGuard>
  );
}
