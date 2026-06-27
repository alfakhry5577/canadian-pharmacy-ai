"use client";

import { useState } from "react";
import { AlertTriangle, Check, Pencil } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { formatDateOnly, cn } from "@/lib/utils";
import { useUpdateInventoryItem } from "@/hooks/useInventory";
import type { InventoryItem, Medication } from "@/types";

interface InventoryTableProps {
  items: InventoryItem[];
  medicationsById: Record<number, Medication>;
}

export function InventoryTable({ items, medicationsById }: InventoryTableProps) {
  const [editingId, setEditingId] = useState<number | null>(null);
  const [qty, setQty] = useState(0);
  const updateItem = useUpdateInventoryItem();

  const isExpiringSoon = (iso: string | null) => {
    if (!iso) return false;
    const days = (new Date(iso).getTime() - Date.now()) / (1000 * 60 * 60 * 24);
    return days <= 60;
  };

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>الدواء</TableHead>
          <TableHead>رقم التشغيلة</TableHead>
          <TableHead>الكمية</TableHead>
          <TableHead>حد إعادة الطلب</TableHead>
          <TableHead>تاريخ الانتهاء</TableHead>
          <TableHead>الحالة</TableHead>
          <TableHead>إجراء</TableHead>
        </TableRow>
      </TableHeader>
      <TableBody>
        {items.map((item) => {
          const med = medicationsById[item.medication_id];
          const expiring = isExpiringSoon(item.expiry_date);
          const isEditing = editingId === item.id;
          return (
            <TableRow key={item.id} className={cn(item.is_low_stock && "bg-destructive/5")}>
              <TableCell className="font-medium">{med?.name_ar ?? `#${item.medication_id}`}</TableCell>
              <TableCell className="font-mono text-xs">{item.batch_no ?? "—"}</TableCell>
              <TableCell>
                {isEditing ? (
                  <Input type="number" value={qty} onChange={(e) => setQty(Number(e.target.value))} className="h-9 w-24" />
                ) : (
                  item.quantity
                )}
              </TableCell>
              <TableCell>{item.reorder_threshold}</TableCell>
              <TableCell className={cn(expiring && "font-semibold text-warning")}>
                {formatDateOnly(item.expiry_date)}
              </TableCell>
              <TableCell>
                <div className="flex flex-wrap gap-1.5">
                  {item.is_low_stock && (
                    <Badge variant="destructive"><AlertTriangle className="h-3 w-3" /> منخفض</Badge>
                  )}
                  {expiring && <Badge variant="warning">قرب الانتهاء</Badge>}
                  {!item.is_low_stock && !expiring && <Badge variant="success">جيد</Badge>}
                </div>
              </TableCell>
              <TableCell>
                {isEditing ? (
                  <Button
                    size="sm"
                    isLoading={updateItem.isPending}
                    onClick={() => {
                      updateItem.mutate({ itemId: item.id, payload: { quantity: qty } });
                      setEditingId(null);
                    }}
                  >
                    <Check className="h-3.5 w-3.5" /> حفظ
                  </Button>
                ) : (
                  <Button size="sm" variant="ghost" onClick={() => { setEditingId(item.id); setQty(item.quantity); }}>
                    <Pencil className="h-3.5 w-3.5" />
                  </Button>
                )}
              </TableCell>
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}
