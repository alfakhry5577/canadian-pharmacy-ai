"use client";

import { useState } from "react";
import { PageHeader } from "@/components/shared/PageHeader";
import { SalesSummaryCards } from "@/features/reports/SalesSummaryCards";
import { TopMedicationsTable } from "@/features/reports/TopMedicationsTable";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useSalesSummary } from "@/hooks/useReports";

const RANGES = [
  { label: "7 أيام", value: "7" },
  { label: "30 يومًا", value: "30" },
  { label: "90 يومًا", value: "90" },
];

export default function AdminReportsPage() {
  const [days, setDays] = useState("30");
  const { data: summary, isLoading } = useSalesSummary(Number(days));

  return (
    <div>
      <PageHeader title="تقارير المبيعات" description="إيرادات، أكثر الأدوية طلبًا، ومؤشرات المخزون" />

      <Tabs value={days} onValueChange={setDays} className="mb-6">
        <TabsList>
          {RANGES.map((r) => <TabsTrigger key={r.value} value={r.value}>{r.label}</TabsTrigger>)}
        </TabsList>
      </Tabs>

      {isLoading || !summary ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-24 w-full rounded-2xl" />)}
        </div>
      ) : (
        <SalesSummaryCards summary={summary} />
      )}

      <Card className="mt-6">
        <CardHeader><CardTitle>تفاصيل المبيعات حسب الدواء</CardTitle></CardHeader>
        <CardContent>{summary ? <TopMedicationsTable items={summary.top_medications} /> : <Skeleton className="h-40 w-full" />}</CardContent>
      </Card>
    </div>
  );
}
