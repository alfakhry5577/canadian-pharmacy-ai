"use client";

import Link from "next/link";
import { ClipboardList, Boxes, BellRing, TrendingUp } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { usePrescriptionQueue } from "@/hooks/usePrescriptions";
import { useAlerts } from "@/hooks/useAlerts";
import { useLowStockInventory } from "@/hooks/useInventory";
import { useSalesSummary } from "@/hooks/useReports";
import { formatCurrency } from "@/lib/utils";
import { ROUTES } from "@/lib/constants";

function StatLink({ icon: Icon, label, value, href, isLoading, tone }: any) {
  return (
    <Link href={href}>
      <Card className="h-full transition-shadow hover:shadow-md">
        <CardContent className="flex items-center gap-4 p-5">
          <div className={`rounded-xl p-3 ${tone ?? "bg-primary/10 text-primary"}`}>
            <Icon className="h-5 w-5" />
          </div>
          <div>
            <p className="text-xs text-muted-foreground">{label}</p>
            {isLoading ? <Skeleton className="mt-1 h-6 w-12" /> : <p className="font-display text-xl font-bold">{value}</p>}
          </div>
        </CardContent>
      </Card>
    </Link>
  );
}

export default function PharmacistDashboardPage() {
  const { data: queue, isLoading: loadingQueue } = usePrescriptionQueue();
  const { data: alerts, isLoading: loadingAlerts } = useAlerts(false);
  const { data: lowStock, isLoading: loadingLowStock } = useLowStockInventory();
  const { data: summary, isLoading: loadingSummary } = useSalesSummary(30);

  return (
    <div>
      <PageHeader title="لوحة الصيدلاني" description="نظرة عامة على الوصفات والمخزون والتنبيهات" />

      <div className="mb-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatLink icon={ClipboardList} label="وصفات بانتظار المراجعة" value={queue?.length ?? 0} href={ROUTES.pharmacist.queue} isLoading={loadingQueue} />
        <StatLink icon={BellRing} label="تنبيهات نشطة" value={alerts?.length ?? 0} href={ROUTES.pharmacist.alerts} isLoading={loadingAlerts} tone="bg-warning/10 text-warning" />
        <StatLink icon={Boxes} label="أصناف مخزون منخفض" value={lowStock?.length ?? 0} href={ROUTES.pharmacist.inventory} isLoading={loadingLowStock} tone="bg-destructive/10 text-destructive" />
        <StatLink icon={TrendingUp} label="إيرادات آخر 30 يومًا" value={summary ? formatCurrency(summary.total_revenue) : "-"} href={ROUTES.pharmacist.inventory} isLoading={loadingSummary} tone="bg-success/10 text-success" />
      </div>
    </div>
  );
}
