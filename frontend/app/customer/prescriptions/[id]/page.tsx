"use client";

import { useParams } from "next/navigation";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Callout } from "@/components/ui/callout";
import { PrescriptionStatusBadge } from "@/components/shared/StatusBadges";
import { PrescriptionItemsTable } from "@/features/prescriptions/PrescriptionItemsTable";
import { usePrescriptionDetail } from "@/hooks/usePrescriptions";
import { formatDate, prescriptionImageUrl } from "@/lib/utils";

export default function PrescriptionDetailPage() {
  const params = useParams<{ id: string }>();
  const id = Number(params.id);
  const { data: prescription, isLoading } = usePrescriptionDetail(id);

  if (isLoading) {
    return <div className="space-y-4"><Skeleton className="h-10 w-1/3" /><Skeleton className="h-64 w-full" /></div>;
  }

  if (!prescription) {
    return <Callout variant="critical">لم يتم العثور على هذه الوصفة.</Callout>;
  }

  return (
    <div>
      <PageHeader
        title={`وصفة #${prescription.id}`}
        description={`تم الرفع في ${formatDate(prescription.created_at)}`}
        action={<PrescriptionStatusBadge status={prescription.status} />}
      />

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-1">
          <CardContent className="p-4">
            <p className="mb-3 text-sm font-semibold">صورة الوصفة الأصلية</p>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={prescriptionImageUrl(prescription.image_path)}
              alt="صورة الوصفة الطبية"
              className="w-full rounded-xl border border-border object-contain"
            />
          </CardContent>
        </Card>

        <div className="space-y-6 lg:col-span-2">
          {prescription.pharmacist_notes && (
            <Callout variant="info" title="ملاحظات الصيدلاني">{prescription.pharmacist_notes}</Callout>
          )}

          <Card>
            <CardContent className="p-6">
              <h3 className="mb-4 font-display text-lg font-bold">البنود المستخرجة</h3>
              {prescription.items.length === 0 ? (
                <p className="text-sm text-muted-foreground">لا توجد بنود مستخرجة لهذه الوصفة.</p>
              ) : (
                <PrescriptionItemsTable items={prescription.items} />
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
