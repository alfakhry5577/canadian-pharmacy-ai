"use client";

import Link from "next/link";
import { FileText, UploadCloud } from "lucide-react";
import { PageHeader, EmptyState } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { PrescriptionHistoryList } from "@/features/prescriptions/PrescriptionHistoryList";
import { useMyPrescriptions } from "@/hooks/usePrescriptions";
import { ROUTES } from "@/lib/constants";

export default function CustomerPrescriptionsPage() {
  const { data: prescriptions, isLoading } = useMyPrescriptions();

  return (
    <div>
      <PageHeader
        title="وصفاتي الطبية"
        description="سجل كل الوصفات التي رفعتها وحالتها"
        action={<Button asChild><Link href={ROUTES.customer.prescriptionUpload}><UploadCloud className="h-4 w-4" /> رفع وصفة جديدة</Link></Button>}
      />

      {isLoading && <div className="space-y-3">{Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-20 w-full rounded-2xl" />)}</div>}

      {!isLoading && (!prescriptions || prescriptions.length === 0) && (
        <EmptyState
          icon={FileText}
          title="لا توجد وصفات مرفوعة بعد"
          description="ابدأ برفع صورة وصفتك الطبية الأولى."
          action={<Button asChild className="mt-2"><Link href={ROUTES.customer.prescriptionUpload}>رفع وصفة</Link></Button>}
        />
      )}

      {prescriptions && prescriptions.length > 0 && <PrescriptionHistoryList prescriptions={prescriptions} />}
    </div>
  );
}
