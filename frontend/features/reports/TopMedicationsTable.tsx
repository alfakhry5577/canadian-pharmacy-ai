import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { formatCurrency } from "@/lib/utils";
import type { TopMedicationStat } from "@/types";

export function TopMedicationsTable({ items }: { items: TopMedicationStat[] }) {
  const max = Math.max(1, ...items.map((i) => i.total_quantity_sold));

  if (items.length === 0) {
    return <p className="py-8 text-center text-sm text-muted-foreground">لا توجد بيانات مبيعات كافية في هذه الفترة بعد.</p>;
  }

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>الدواء</TableHead>
          <TableHead>الكمية المباعة</TableHead>
          <TableHead>الإيراد</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {items.map((item) => (
          <TableRow key={item.medication_id}>
            <TableCell className="font-medium">{item.name_ar}</TableCell>
            <TableCell>
              <div className="flex items-center gap-2">
                <div className="h-2 w-28 overflow-hidden rounded-full bg-muted">
                  <div className="h-full rounded-full bg-primary" style={{ width: `${(item.total_quantity_sold / max) * 100}%` }} />
                </div>
                <span className="text-xs text-muted-foreground">{item.total_quantity_sold}</span>
              </div>
            </TableCell>
            <TableCell>{formatCurrency(item.total_revenue)}</TableCell>
          </TableRow>
        ))}
      </TableBody>
    </Table>
  );
}
