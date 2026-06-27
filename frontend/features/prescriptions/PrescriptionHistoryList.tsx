import Link from "next/link";
import { FileText, ChevronLeft } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { PrescriptionStatusBadge } from "@/components/shared/StatusBadges";
import { formatDate } from "@/lib/utils";
import { ROUTES } from "@/lib/constants";
import type { Prescription } from "@/types";

export function PrescriptionHistoryList({ prescriptions }: { prescriptions: Prescription[] }) {
  return (
    <div className="space-y-3">
      {prescriptions.map((p) => (
        <Link key={p.id} href={ROUTES.customer.prescriptionDetail(p.id)}>
          <Card className="transition-shadow hover:shadow-md">
            <CardContent className="flex items-center justify-between gap-4 p-4">
              <div className="flex items-center gap-3">
                <div className="rounded-lg bg-primary/10 p-2.5">
                  <FileText className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <p className="font-semibold">وصفة #{p.id}</p>
                  <p className="text-xs text-muted-foreground">{formatDate(p.created_at)} · {p.items.length} بند</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <PrescriptionStatusBadge status={p.status} />
                <ChevronLeft className="h-4 w-4 text-muted-foreground" />
              </div>
            </CardContent>
          </Card>
        </Link>
      ))}
    </div>
  );
}
