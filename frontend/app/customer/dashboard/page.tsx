"use client";

import Link from "next/link";
import { UploadCloud, Search, Bell, MessageSquareText, FileText, Award } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useAuthStore } from "@/store/auth.store";
import { useMyPrescriptions } from "@/hooks/usePrescriptions";
import { useReminders, useLoyalty } from "@/hooks/useReminders";
import { ROUTES } from "@/lib/constants";

const QUICK_ACTIONS = [
  { icon: UploadCloud, title: "رفع وصفة جديدة", href: ROUTES.customer.prescriptionUpload },
  { icon: Search, title: "البحث عن دواء", href: ROUTES.customer.search },
  { icon: MessageSquareText, title: "المساعد الذكي", href: ROUTES.customer.chat },
  { icon: Bell, title: "تذكيراتي", href: ROUTES.customer.reminders },
];

export default function CustomerDashboardPage() {
  const { user } = useAuthStore();
  const { data: prescriptions, isLoading: loadingPrescriptions } = useMyPrescriptions();
  const { data: reminders, isLoading: loadingReminders } = useReminders();
  const { data: loyalty, isLoading: loadingLoyalty } = useLoyalty();

  return (
    <div>
      <PageHeader title={`مرحبًا، ${user?.full_name ?? ""} 👋`} description="نظرة سريعة على حسابك في الصيدلية" />

      <div className="mb-8 grid gap-4 sm:grid-cols-3">
        <Card>
          <CardContent className="flex items-center gap-4 p-5">
            <div className="rounded-xl bg-primary/10 p-3"><FileText className="h-5 w-5 text-primary" /></div>
            <div>
              <p className="text-xs text-muted-foreground">إجمالي وصفاتي</p>
              {loadingPrescriptions ? <Skeleton className="mt-1 h-6 w-10" /> : <p className="font-display text-xl font-bold">{prescriptions?.length ?? 0}</p>}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-4 p-5">
            <div className="rounded-xl bg-secondary/15 p-3"><Bell className="h-5 w-5 text-secondary" /></div>
            <div>
              <p className="text-xs text-muted-foreground">تذكيرات فعّالة</p>
              {loadingReminders ? <Skeleton className="mt-1 h-6 w-10" /> : <p className="font-display text-xl font-bold">{reminders?.length ?? 0}</p>}
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="flex items-center gap-4 p-5">
            <div className="rounded-xl bg-success/15 p-3"><Award className="h-5 w-5 text-success" /></div>
            <div>
              <p className="text-xs text-muted-foreground">نقاط الولاء</p>
              {loadingLoyalty ? <Skeleton className="mt-1 h-6 w-10" /> : <p className="font-display text-xl font-bold">{loyalty?.points ?? 0}</p>}
            </div>
          </CardContent>
        </Card>
      </div>

      <h2 className="mb-4 font-display text-lg font-bold">إجراءات سريعة</h2>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {QUICK_ACTIONS.map((action) => (
          <Link key={action.href} href={action.href}>
            <Card className="h-full transition-shadow hover:shadow-md">
              <CardContent className="flex flex-col items-center gap-3 p-6 text-center">
                <div className="rounded-xl bg-primary/10 p-3"><action.icon className="h-6 w-6 text-primary" /></div>
                <p className="font-semibold">{action.title}</p>
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
