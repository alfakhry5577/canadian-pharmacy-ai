"use client";

import { BellRing, RefreshCcw, CheckCircle2 } from "lucide-react";
import { PageHeader, EmptyState } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { SeverityBadge } from "@/components/shared/StatusBadges";
import { useAlerts, useResolveAlert, useRunAlertScan } from "@/hooks/useAlerts";
import { formatDate } from "@/lib/utils";
import { toast } from "@/store/ui.store";

export default function PharmacistAlertsPage() {
  const { data: alerts, isLoading } = useAlerts(false);
  const resolveAlert = useResolveAlert();
  const runScan = useRunAlertScan();

  return (
    <div>
      <PageHeader
        title="التنبيهات"
        description="تنبيهات المخزون المنخفض، انتهاء الصلاحية، والسلامة الدوائية"
        action={
          <Button
            variant="outline"
            isLoading={runScan.isPending}
            onClick={() => runScan.mutate(undefined, { onSuccess: (created) => toast({ title: `تم رصد ${created.length} تنبيه جديد`, variant: "default" }) })}
          >
            <RefreshCcw className="h-4 w-4" /> فحص المخزون الآن
          </Button>
        }
      />

      {isLoading && <div className="space-y-3">{Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-16 w-full" />)}</div>}

      {!isLoading && (!alerts || alerts.length === 0) && (
        <EmptyState icon={BellRing} title="لا توجد تنبيهات نشطة" description="كل شيء تحت السيطرة حاليًا." />
      )}

      <div className="space-y-3">
        {alerts?.map((a) => (
          <Card key={a.id}>
            <CardContent className="flex items-center justify-between gap-4 p-4">
              <div className="flex items-start gap-3">
                <SeverityBadge severity={a.severity} />
                <div>
                  <p className="text-sm">{a.message_ar}</p>
                  <p className="mt-1 text-xs text-muted-foreground">{formatDate(a.created_at)}</p>
                </div>
              </div>
              <Button size="sm" variant="ghost" onClick={() => resolveAlert.mutate(a.id)} isLoading={resolveAlert.isPending}>
                <CheckCircle2 className="h-4 w-4" /> تعليم كمحلول
              </Button>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
}
