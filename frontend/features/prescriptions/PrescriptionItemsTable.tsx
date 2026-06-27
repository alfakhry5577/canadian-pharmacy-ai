"use client";

import { useState } from "react";
import { CheckCircle2, Pencil } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { confidenceToPercent } from "@/lib/utils";
import type { PrescriptionItem, PrescriptionItemUpdatePayload } from "@/types";

interface PrescriptionItemsTableProps {
  items: PrescriptionItem[];
  editable?: boolean;
  onUpdateItem?: (itemId: number, payload: PrescriptionItemUpdatePayload) => void;
  isUpdating?: boolean;
}

export function PrescriptionItemsTable({ items, editable, onUpdateItem, isUpdating }: PrescriptionItemsTableProps) {
  const [editingId, setEditingId] = useState<number | null>(null);
  const [draft, setDraft] = useState<PrescriptionItemUpdatePayload>({});

  const startEdit = (item: PrescriptionItem) => {
    setEditingId(item.id);
    setDraft({
      dosage_text: item.dosage_text ?? "",
      frequency_text: item.frequency_text ?? "",
      duration_text: item.duration_text ?? "",
    });
  };

  const save = (itemId: number) => {
    onUpdateItem?.(itemId, draft);
    setEditingId(null);
  };

  return (
    <Table>
      <TableHeader>
        <TableRow>
          <TableHead>الاسم كما ظهر في الروشتة</TableHead>
          <TableHead>الجرعة</TableHead>
          <TableHead>عدد المرات</TableHead>
          <TableHead>المدة</TableHead>
          <TableHead>دقة القراءة</TableHead>
          <TableHead>الحالة</TableHead>
          {editable && <TableHead>إجراء</TableHead>}
        </TableRow>
      </TableHeader>
      <TableBody>
        {items.map((item) => {
          const isEditing = editingId === item.id;
          const pct = confidenceToPercent(item.confidence_score);
          return (
            <TableRow key={item.id}>
              <TableCell className="font-medium">{item.extracted_medication_name}</TableCell>
              <TableCell>
                {isEditing ? (
                  <Input
                    value={draft.dosage_text ?? ""}
                    onChange={(e) => setDraft((d) => ({ ...d, dosage_text: e.target.value }))}
                    className="h-9 w-28"
                  />
                ) : (
                  item.dosage_text || "—"
                )}
              </TableCell>
              <TableCell>
                {isEditing ? (
                  <Input
                    value={draft.frequency_text ?? ""}
                    onChange={(e) => setDraft((d) => ({ ...d, frequency_text: e.target.value }))}
                    className="h-9 w-28"
                  />
                ) : (
                  item.frequency_text || "—"
                )}
              </TableCell>
              <TableCell>
                {isEditing ? (
                  <Input
                    value={draft.duration_text ?? ""}
                    onChange={(e) => setDraft((d) => ({ ...d, duration_text: e.target.value }))}
                    className="h-9 w-28"
                  />
                ) : (
                  item.duration_text || "—"
                )}
              </TableCell>
              <TableCell className="w-32">
                <div className="flex items-center gap-2">
                  <Progress value={pct} className="h-1.5" />
                  <span className="text-xs text-muted-foreground">{pct}%</span>
                </div>
              </TableCell>
              <TableCell>
                {item.pharmacist_confirmed ? (
                  <Badge variant="success"><CheckCircle2 className="h-3 w-3" /> مؤكد</Badge>
                ) : (
                  <Badge variant="warning">بانتظار التأكيد</Badge>
                )}
              </TableCell>
              {editable && (
                <TableCell>
                  {isEditing ? (
                    <div className="flex gap-1">
                      <Button size="sm" onClick={() => save(item.id)} isLoading={isUpdating}>حفظ</Button>
                      <Button size="sm" variant="ghost" onClick={() => setEditingId(null)}>إلغاء</Button>
                    </div>
                  ) : (
                    <div className="flex gap-1">
                      <Button size="sm" variant="ghost" onClick={() => startEdit(item)}>
                        <Pencil className="h-3.5 w-3.5" />
                      </Button>
                      {!item.pharmacist_confirmed && (
                        <Button size="sm" variant="outline" onClick={() => onUpdateItem?.(item.id, { pharmacist_confirmed: true })}>
                          تأكيد
                        </Button>
                      )}
                    </div>
                  )}
                </TableCell>
              )}
            </TableRow>
          );
        })}
      </TableBody>
    </Table>
  );
}
