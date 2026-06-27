import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { formatCurrency } from "@/lib/utils";
import type { MedicationSearchResult } from "@/types";
import { PackageCheck, PackageX, ShieldAlert } from "lucide-react";

export function MedicationResultCard({ result }: { result: MedicationSearchResult }) {
  const { medication, in_stock, quantity_available, substitutes } = result;

  return (
    <Card>
      <CardContent className="p-5">
        <div className="flex items-start justify-between gap-3">
          <div>
            <p className="font-display text-base font-bold">{medication.name_ar}</p>
            <p className="text-xs text-muted-foreground">{medication.name_en}</p>
            {medication.active_ingredient && (
              <p className="mt-1 text-xs text-muted-foreground">
                المادة الفعالة: {medication.active_ingredient.name_ar}
              </p>
            )}
          </div>
          <p className="whitespace-nowrap font-display text-lg font-bold text-primary">
            {formatCurrency(medication.price)}
          </p>
        </div>

        <div className="mt-3 flex flex-wrap items-center gap-2">
          {medication.requires_prescription && (
            <Badge variant="secondary">
              <ShieldAlert className="h-3 w-3" /> يتطلب وصفة طبية
            </Badge>
          )}
          {in_stock ? (
            <Badge variant="success">
              <PackageCheck className="h-3 w-3" /> متوفر ({quantity_available})
            </Badge>
          ) : (
            <Badge variant="destructive">
              <PackageX className="h-3 w-3" /> غير متوفر حاليًا
            </Badge>
          )}
        </div>

        {medication.general_usage && (
          <p className="mt-3 text-sm leading-relaxed text-muted-foreground">{medication.general_usage}</p>
        )}

        {!in_stock && substitutes.length > 0 && (
          <>
            <Separator className="my-4" />
            <p className="mb-2 text-sm font-semibold">بدائل متوفرة بنفس المادة الفعالة (بحاجة لتأكيد الصيدلاني):</p>
            <div className="flex flex-wrap gap-2">
              {substitutes.map((s) => (
                <Badge key={s.id} variant="outline">
                  {s.name_ar} — {formatCurrency(s.price)}
                </Badge>
              ))}
            </div>
          </>
        )}
      </CardContent>
    </Card>
  );
}
