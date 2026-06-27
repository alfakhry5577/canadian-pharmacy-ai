import { PackageX, ArrowLeftRight } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { formatCurrency } from "@/lib/utils";
import type { AlternativeInfo } from "@/hooks/useDrugAlternatives";

export function DrugAlternativesPanel({ alternatives }: { alternatives: Record<number, AlternativeInfo> }) {
  const outOfStock = Object.values(alternatives).filter((a) => !a.inStock);

  if (outOfStock.length === 0) return null;

  return (
    <Card>
      <CardContent className="p-6">
        <h3 className="mb-4 flex items-center gap-2 font-display text-lg font-bold">
          <ArrowLeftRight className="h-5 w-5 text-secondary" /> بدائل مقترحة لأصناف غير متوفرة
        </h3>
        <div className="space-y-3">
          {outOfStock.map((a) => (
            <div key={a.medication.id} className="rounded-xl border border-border p-4">
              <div className="mb-2 flex items-center gap-2">
                <Badge variant="destructive"><PackageX className="h-3 w-3" /> {a.medication.name_ar} غير متوفر</Badge>
              </div>
              {a.substitutes.length > 0 ? (
                <div className="flex flex-wrap gap-2">
                  {a.substitutes.map((s) => (
                    <Badge key={s.id} variant="outline">{s.name_ar} — {formatCurrency(s.price)}</Badge>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-muted-foreground">لا توجد بدائل متوفرة حاليًا بنفس المادة الفعالة.</p>
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}
