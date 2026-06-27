"use client";

import { useState } from "react";
import { PlusCircle } from "lucide-react";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter, DialogTrigger,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useMedicationSearch } from "@/hooks/useMedicationSearch";
import { useAddInventoryBatch } from "@/hooks/useInventory";
import { toast } from "@/store/ui.store";
import type { Medication } from "@/types";

export function StockFormDialog() {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Medication | null>(null);
  const [quantity, setQuantity] = useState(0);
  const [reorderThreshold, setReorderThreshold] = useState(10);
  const [batchNo, setBatchNo] = useState("");
  const [expiryDate, setExpiryDate] = useState("");

  const { results } = useMedicationSearch(query);
  const addBatch = useAddInventoryBatch();

  const reset = () => {
    setQuery(""); setSelected(null); setQuantity(0); setReorderThreshold(10); setBatchNo(""); setExpiryDate("");
  };

  const handleSubmit = () => {
    if (!selected) return;
    addBatch.mutate(
      {
        medicationId: selected.id,
        payload: {
          quantity,
          reorder_threshold: reorderThreshold,
          batch_no: batchNo || undefined,
          expiry_date: expiryDate || undefined,
        },
      },
      {
        onSuccess: () => {
          toast({ title: "تمت إضافة الدفعة بنجاح", variant: "success" });
          setOpen(false);
          reset();
        },
        onError: () => toast({ title: "فشل إضافة الدفعة", variant: "destructive" }),
      }
    );
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button><PlusCircle className="h-4 w-4" /> إضافة دفعة مخزون</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>إضافة دفعة مخزون جديدة</DialogTitle>
          <DialogDescription>اختر الدواء من الكتالوج ثم أدخل تفاصيل الدفعة.</DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div>
            <Label>الدواء</Label>
            {selected ? (
              <div className="flex items-center justify-between rounded-lg border border-border p-2.5 text-sm">
                <span>{selected.name_ar}</span>
                <Button size="sm" variant="ghost" onClick={() => setSelected(null)}>تغيير</Button>
              </div>
            ) : (
              <>
                <Input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="ابحث عن الدواء..." />
                {results.length > 0 && (
                  <div className="mt-1 max-h-40 overflow-y-auto rounded-lg border border-border">
                    {results.map((r) => (
                      <button
                        key={r.medication.id}
                        onClick={() => setSelected(r.medication)}
                        className="block w-full px-3 py-2 text-start text-sm hover:bg-accent"
                      >
                        {r.medication.name_ar}
                      </button>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label>الكمية</Label>
              <Input type="number" value={quantity} onChange={(e) => setQuantity(Number(e.target.value))} />
            </div>
            <div>
              <Label>حد إعادة الطلب</Label>
              <Input type="number" value={reorderThreshold} onChange={(e) => setReorderThreshold(Number(e.target.value))} />
            </div>
            <div>
              <Label>رقم التشغيلة</Label>
              <Input value={batchNo} onChange={(e) => setBatchNo(e.target.value)} />
            </div>
            <div>
              <Label>تاريخ الانتهاء</Label>
              <Input type="date" value={expiryDate} onChange={(e) => setExpiryDate(e.target.value)} />
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button onClick={handleSubmit} disabled={!selected} isLoading={addBatch.isPending}>حفظ</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
