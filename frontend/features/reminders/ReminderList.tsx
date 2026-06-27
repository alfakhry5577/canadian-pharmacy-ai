"use client";

import { useState } from "react";
import { Bell, PlusCircle, Trash2 } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter, DialogTrigger,
} from "@/components/ui/dialog";
import { useMedicationSearch } from "@/hooks/useMedicationSearch";
import { useCreateReminder, useCancelReminder, useReminders } from "@/hooks/useReminders";
import { formatDateOnly } from "@/lib/utils";
import { toast } from "@/store/ui.store";
import { Skeleton } from "@/components/ui/skeleton";
import { EmptyState } from "@/components/shared/PageHeader";
import type { Medication } from "@/types";

function AddReminderDialog() {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState<Medication | null>(null);
  const [frequency, setFrequency] = useState(30);
  const { results } = useMedicationSearch(query);
  const createReminder = useCreateReminder();

  const handleSubmit = () => {
    if (!selected) return;
    createReminder.mutate(
      { medication_id: selected.id, frequency_days: frequency },
      {
        onSuccess: () => {
          toast({ title: "تم إضافة التذكير", variant: "success" });
          setOpen(false);
          setSelected(null);
          setQuery("");
        },
      }
    );
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button><PlusCircle className="h-4 w-4" /> تذكير جديد</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>إضافة تذكير بإعادة الشراء</DialogTitle>
          <DialogDescription>سيتم تنبيهك عند اقتراب موعد إعادة شراء الدواء.</DialogDescription>
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
                      <button key={r.medication.id} onClick={() => setSelected(r.medication)} className="block w-full px-3 py-2 text-start text-sm hover:bg-accent">
                        {r.medication.name_ar}
                      </button>
                    ))}
                  </div>
                )}
              </>
            )}
          </div>
          <div>
            <Label>التكرار (بالأيام)</Label>
            <Input type="number" value={frequency} onChange={(e) => setFrequency(Number(e.target.value))} />
          </div>
        </div>
        <DialogFooter>
          <Button onClick={handleSubmit} disabled={!selected} isLoading={createReminder.isPending}>حفظ</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export function ReminderList() {
  const { data: reminders, isLoading } = useReminders();
  const cancelReminder = useCancelReminder();

  if (isLoading) {
    return <div className="space-y-3">{Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-16 w-full" />)}</div>;
  }

  return (
    <div className="space-y-4">
      <div className="flex justify-end"><AddReminderDialog /></div>

      {!reminders || reminders.length === 0 ? (
        <EmptyState icon={Bell} title="لا توجد تذكيرات حاليًا" description="أضف تذكيرًا لإعادة شراء أدويتك المزمنة قبل نفادها." />
      ) : (
        <div className="space-y-3">
          {reminders.map((r) => (
            <Card key={r.id}>
              <CardContent className="flex items-center justify-between p-4">
                <div className="flex items-center gap-3">
                  <div className="rounded-lg bg-secondary/15 p-2.5"><Bell className="h-4 w-4 text-secondary" /></div>
                  <div>
                    <p className="font-semibold">دواء #{r.medication_id}</p>
                    <p className="text-xs text-muted-foreground">
                      موعد التذكير القادم: {formatDateOnly(r.next_reminder_date)} · كل {r.frequency_days} يومًا
                    </p>
                  </div>
                </div>
                <Button variant="ghost" size="icon" onClick={() => cancelReminder.mutate(r.id)} aria-label="إلغاء التذكير">
                  <Trash2 className="h-4 w-4 text-destructive" />
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
