"use client";

import { useParams, useRouter } from "next/navigation";
import { useState } from "react";
import { CheckCircle2, XCircle } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { Callout } from "@/components/ui/callout";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { PrescriptionItemsTable } from "@/features/prescriptions/PrescriptionItemsTable";
import { DrugAlternativesPanel } from "@/features/inventory/DrugAlternativesPanel";
import { usePrescriptionDetail, useReviewPrescription, useUpdatePrescriptionItem } from "@/hooks/usePrescriptions";
import { useAlerts } from "@/hooks/useAlerts";
import { useDrugAlternatives } from "@/hooks/useDrugAlternatives";
import { SeverityBadge } from "@/components/shared/StatusBadges";
import { prescriptionImageUrl } from "@/lib/utils";
import { toast } from "@/store/ui.store";
import { ROUTES } from "@/lib/constants";

export default function PharmacistQueueDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const id = Number(params.id);

  const { data: prescription, isLoading } = usePrescriptionDetail(id);
  const { data: alerts } = useAlerts(false);
  const updateItem = useUpdatePrescriptionItem();
  const reviewMutation = useReviewPrescription();
  const [notes, setNotes] = useState("");

  const matchedIds = prescription?.items.map((i) => i.matched_medication_id) ?? [];
  const { data: alternatives } = useDrugAlternatives(matchedIds);

  const relatedAlerts = (alerts ?? []).filter((a) => a.related_prescription_id === id);

  const decide = (status: "reviewed" | "rejected") => {
    reviewMutation.mutate(
      { id, payload: { status, pharmacist_notes: notes || undefined } },
      {
        onSuccess: () => {
          toast({ title: status === "reviewed" ? "تم اعتماد الوصفة" : "تم رفض الوصفة", variant: status === "reviewed" ? "success" : "destructive" });
          router.push(ROUTES.pharmacist.queue);
        },
      }
    );
  };

  if (isLoading) return <div className="space-y-4"><Skeleton className="h-10 w-1/3" /><Skeleton className="h-64 w-full" /></div>;
  if (!prescription) return <Callout variant="critical">لم يتم العثور على هذه الوصفة.</Callout>;

  return (
    <div>
      <PageHeader title={`مراجعة وصفة #${prescription.id}`} description={`زبون #${prescription.customer_id}`} />

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-1">
          <CardContent className="p-4">
            <p className="mb-3 text-sm font-semibold">صورة الوصفة الأصلية</p>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={prescriptionImageUrl(prescription.image_path)} alt="صورة الوصفة" className="w-full rounded-xl border border-border object-contain" />

            {prescription.raw_ocr_text && (
              <details className="mt-3">
                <summary className="cursor-pointer text-xs font-semibold text-muted-foreground">عرض النص الخام المستخرج (OCR)</summary>
                <pre className="mt-2 whitespace-pre-wrap rounded-lg bg-muted p-3 text-xs">{prescription.raw_ocr_text}</pre>
              </details>
            )}
          </CardContent>
        </Card>

        <div className="space-y-6 lg:col-span-2">
          {relatedAlerts.length > 0 && (
            <Card>
              <CardContent className="space-y-2 p-6">
                <h3 className="mb-2 font-display text-lg font-bold">تنبيهات السلامة لهذه الوصفة</h3>
                {relatedAlerts.map((a) => (
                  <div key={a.id} className="flex items-start gap-2 rounded-lg bg-muted p-3 text-sm">
                    <SeverityBadge severity={a.severity} />
                    <span>{a.message_ar}</span>
                  </div>
                ))}
              </CardContent>
            </Card>
          )}

          <Card>
            <CardContent className="p-6">
              <h3 className="mb-4 font-display text-lg font-bold">البنود المستخرجة (قابلة للتعديل)</h3>
              <PrescriptionItemsTable
                items={prescription.items}
                editable
                isUpdating={updateItem.isPending}
                onUpdateItem={(itemId, payload) => updateItem.mutate({ itemId, payload })}
              />
            </CardContent>
          </Card>

          {alternatives && <DrugAlternativesPanel alternatives={alternatives} />}

          <Card>
            <CardContent className="p-6">
              <Label htmlFor="notes">ملاحظات الصيدلاني (تُعرض للزبون)</Label>
              <Textarea id="notes" value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="مثال: تم التأكد من الجرعات، يمكن الصرف." />
              <div className="mt-4 flex gap-3">
                <Button onClick={() => decide("reviewed")} isLoading={reviewMutation.isPending}>
                  <CheckCircle2 className="h-4 w-4" /> اعتماد الوصفة
                </Button>
                <Button variant="destructive" onClick={() => decide("rejected")} isLoading={reviewMutation.isPending}>
                  <XCircle className="h-4 w-4" /> رفض الوصفة
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
