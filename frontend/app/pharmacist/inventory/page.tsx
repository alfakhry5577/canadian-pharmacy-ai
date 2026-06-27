"use client";

import { useMemo } from "react";
import { Boxes } from "lucide-react";
import { PageHeader, EmptyState } from "@/components/shared/PageHeader";
import { Skeleton } from "@/components/ui/skeleton";
import { InventoryTable } from "@/features/inventory/InventoryTable";
import { StockFormDialog } from "@/features/inventory/StockFormDialog";
import { useInventory } from "@/hooks/useInventory";
import { useQueries } from "@tanstack/react-query";
import { medicationService } from "@/services/medication.service";
import type { Medication } from "@/types";

export default function PharmacistInventoryPage() {
  const { data: items, isLoading } = useInventory();
  const medicationIds = useMemo(() => Array.from(new Set((items ?? []).map((i) => i.medication_id))), [items]);

  const medicationQueries = useQueries({
    queries: medicationIds.map((id) => ({
      queryKey: ["medications", "detail", id],
      queryFn: () => medicationService.getById(id),
    })),
  });

  const medicationsById = useMemo(() => {
    const map: Record<number, Medication> = {};
    medicationQueries.forEach((q) => { if (q.data) map[q.data.id] = q.data; });
    return map;
  }, [medicationQueries]);

  return (
    <div>
      <PageHeader title="إدارة المخزون" description="تتبع الكميات، تواريخ الانتهاء، وحدود إعادة الطلب" action={<StockFormDialog />} />

      {isLoading && <div className="space-y-3">{Array.from({ length: 4 }).map((_, i) => <Skeleton key={i} className="h-12 w-full" />)}</div>}

      {!isLoading && (!items || items.length === 0) && (
        <EmptyState icon={Boxes} title="لا توجد دفعات مخزون مسجّلة بعد" description="ابدأ بإضافة أول دفعة مخزون لدواء من الكتالوج." />
      )}

      {items && items.length > 0 && <InventoryTable items={items} medicationsById={medicationsById} />}
    </div>
  );
}
