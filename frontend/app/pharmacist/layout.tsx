"use client";

import { LayoutDashboard, ClipboardList, Boxes, BellRing, MessageSquareText } from "lucide-react";
import { RoleGuard } from "@/layouts/RoleGuard";
import { DashboardLayout, type NavItem } from "@/layouts/DashboardLayout";
import { ROUTES } from "@/lib/constants";
import { usePrescriptionQueue } from "@/hooks/usePrescriptions";
import { useAlerts } from "@/hooks/useAlerts";

export default function PharmacistLayout({ children }: { children: React.ReactNode }) {
  const { data: queue } = usePrescriptionQueue();
  const { data: alerts } = useAlerts(false);

  const navItems: NavItem[] = [
    { label: "الرئيسية", href: ROUTES.pharmacist.dashboard, icon: LayoutDashboard },
    { label: "مراجعة الوصفات", href: ROUTES.pharmacist.queue, icon: ClipboardList, badge: queue?.length },
    { label: "المخزون", href: ROUTES.pharmacist.inventory, icon: Boxes },
    { label: "التنبيهات", href: ROUTES.pharmacist.alerts, icon: BellRing, badge: alerts?.length },
    { label: "المساعد الذكي", href: ROUTES.pharmacist.chat, icon: MessageSquareText },
  ];

  return (
    <RoleGuard allow={["pharmacist", "admin"]}>
      <DashboardLayout navItems={navItems} portalLabel="بوابة الصيدلاني">
        {children}
      </DashboardLayout>
    </RoleGuard>
  );
}
