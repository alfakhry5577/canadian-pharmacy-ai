"use client";

import { PageHeader } from "@/components/shared/PageHeader";
import { SalesSummaryCards } from "@/features/reports/SalesSummaryCards";
import { TopMedicationsTable } from "@/features/reports/TopMedicationsTable";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { SeverityBadge } from "@/components/shared/StatusBadges";
import { useSalesSummary } from "@/hooks/useReports";
import { useAlerts } from "@/hooks/useAlerts";

export default function AdminDashboardPage() {
  const { data: summary, isLoading } = useSalesSummary(30);
  const { data: alerts } = useAlerts(false);

  return (
    <div>
      <PageHeader title="نظرة عامة على الصيدلية" description="مؤشرات حقيقية من نظام المبيعات والمخزون والتنبيهات" />

      {isLoading || !summary ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-24 w-full rounded-2xl" />)}
        </div>
      ) : (
        <SalesSummaryCards summary={summary} />
      )}

      <div className="mt-6 grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader><CardTitle>أكثر الأدوية طلبًا (آخر 30 يومًا)</CardTitle></CardHeader>
          <CardContent>
            {summary ? <TopMedicationsTable items={summary.top_medications} /> : <Skeleton className="h-40 w-full" />}
          </CardContent>
        </Card>

        <Card>
          <CardHeader><CardTitle>أحدث التنبيهات</CardTitle></CardHeader>
          <CardContent className="space-y-3">
            {!alerts || alerts.length === 0 ? (
              <p className="text-sm text-muted-foreground">لا توجد تنبيهات نشطة حاليًا.</p>
            ) : (
              alerts.slice(0, 6).map((a) => (
                <div key={a.id} className="flex items-start gap-2 text-sm">
                  <SeverityBadge severity={a.severity} />
                  <span className="line-clamp-2 text-muted-foreground">{a.message_ar}</span>
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
