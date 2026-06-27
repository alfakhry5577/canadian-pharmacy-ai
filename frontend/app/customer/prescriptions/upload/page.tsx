"use client";

import { useState } from "react";
import Link from "next/link";
import { CheckCircle2, Loader2, ScanLine, ShieldCheck, Sparkles } from "lucide-react";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent } from "@/components/ui/card";
import { Callout } from "@/components/ui/callout";
import { Button } from "@/components/ui/button";
import { UploadDropzone } from "@/features/prescriptions/UploadDropzone";
import { PrescriptionItemsTable } from "@/features/prescriptions/PrescriptionItemsTable";
import { SafetyFlagsList } from "@/features/prescriptions/SafetyFlagsList";
import { useUploadPrescription } from "@/hooks/usePrescriptions";
import { extractErrorMessage } from "@/lib/axios";
import { ROUTES } from "@/lib/constants";

const PIPELINE_STEPS = [
  { icon: ScanLine, label: "استخراج النص (OCR)" },
  { icon: Sparkles, label: "تحليل الذكاء الاصطناعي" },
  { icon: ShieldCheck, label: "فحوصات السلامة الدوائية" },
];

export default function PrescriptionUploadPage() {
  const uploadMutation = useUploadPrescription();
  const [step, setStep] = useState(0);

  const handleFile = (file: File) => {
    setStep(0);
    const progressTimer = setInterval(() => setStep((s) => Math.min(s + 1, PIPELINE_STEPS.length - 1)), 700);
    uploadMutation.mutate(file, { onSettled: () => clearInterval(progressTimer) });
  };

  const result = uploadMutation.data;

  return (
    <div>
      <PageHeader title="رفع وتحليل وصفة طبية" description="صوّر وصفتك أو ارفع صورة واضحة لها، وسيقوم النظام بتحليلها فورًا" />

      {!result && (
        <Card>
          <CardContent className="p-6">
            <UploadDropzone onFileSelected={handleFile} isUploading={uploadMutation.isPending} />

            {uploadMutation.isPending && (
              <div className="mt-6 flex justify-center gap-8">
                {PIPELINE_STEPS.map((s, i) => (
                  <div key={s.label} className="flex flex-col items-center gap-2 text-center">
                    <div className={`flex h-10 w-10 items-center justify-center rounded-full ${i <= step ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"}`}>
                      {i < step ? <CheckCircle2 className="h-5 w-5" /> : i === step ? <Loader2 className="h-5 w-5 animate-spin" /> : <s.icon className="h-5 w-5" />}
                    </div>
                    <p className="max-w-[90px] text-xs text-muted-foreground">{s.label}</p>
                  </div>
                ))}
              </div>
            )}

            {uploadMutation.isError && (
              <Callout variant="critical" className="mt-4">{extractErrorMessage(uploadMutation.error)}</Callout>
            )}
          </CardContent>
        </Card>
      )}

      {result && (
        <div className="space-y-6">
          <Callout variant="info" title="تم رفع الوصفة بنجاح">
            بانتظار مراجعة الصيدلاني واعتمادها قبل الصرف النهائي. ستظهر هذه الوصفة في صفحة "وصفاتي" بحالتها المحدّثة.
          </Callout>

          <Card>
            <CardContent className="p-6">
              <h3 className="mb-4 font-display text-lg font-bold">البنود المستخرجة من الوصفة</h3>
              {result.prescription.items.length === 0 ? (
                <p className="text-sm text-muted-foreground">
                  لم يتمكن النظام من استخراج بنود واضحة من الصورة. سيقوم الصيدلاني بمراجعة الصورة الأصلية مباشرة.
                </p>
              ) : (
                <PrescriptionItemsTable items={result.prescription.items} />
              )}
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-6">
              <h3 className="mb-4 font-display text-lg font-bold">فحوصات السلامة</h3>
              <SafetyFlagsList flags={result.safety_flags} disclaimer={result.disclaimer_ar} />
            </CardContent>
          </Card>

          <div className="flex gap-3">
            <Button asChild><Link href={ROUTES.customer.prescriptionDetail(result.prescription.id)}>عرض تفاصيل الوصفة</Link></Button>
            <Button variant="outline" onClick={() => uploadMutation.reset()}>رفع وصفة أخرى</Button>
          </div>
        </div>
      )}
    </div>
  );
}
