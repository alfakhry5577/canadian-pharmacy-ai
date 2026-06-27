"use client";

import Link from "next/link";
import { ClipboardList, ChevronLeft, FileText } from "lucide-react";
import { PageHeader, EmptyState } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { usePrescriptionQueue } from "@/hooks/usePrescriptions";
import { formatDate } from "@/lib/utils";
import { ROUTES } from "@/lib/constants";

export default function PharmacistQueuePage() {
  const { data: queue, isLoading } = usePrescriptionQueue();

  return (
    <div>
      <PageHeader title="مراجعة الوصفات" description="الوصفات التي حلّلها النظام وتنتظر مراجعتك واعتمادها (الأقدم أولًا)" />

      {isLoading && <div className="space-y-3">{Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-20 w-full rounded-2xl" />)}</div>}

      {!isLoading && (!queue || queue.length === 0) && (
        <EmptyState icon={ClipboardList} title="لا توجد وصفات بانتظار المراجعة" description="عمل رائع! قائمة الانتظار فارغة حاليًا." />
      )}

      <div className="space-y-3">
        {queue?.map((p) => (
          <Link key={p.id} href={ROUTES.pharmacist.queueDetail(p.id)}>
            <Card className="transition-shadow hover:shadow-md">
              <CardContent className="flex items-center justify-between gap-4 p-4">
                <div className="flex items-center gap-3">
                  <div className="rounded-lg bg-primary/10 p-2.5"><FileText className="h-5 w-5 text-primary" /></div>
                  <div>
                    <p className="font-semibold">وصفة #{p.id} — زبون #{p.customer_id}</p>
                    <p className="text-xs text-muted-foreground">رُفعت في {formatDate(p.created_at)} · {p.items.length} بند مستخرج</p>
                  </div>
                </div>
                <ChevronLeft className="h-4 w-4 text-muted-foreground" />
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
