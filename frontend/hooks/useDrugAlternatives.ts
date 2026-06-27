"use client";

import { useQuery } from "@tanstack/react-query";
import { medicationService } from "@/services/medication.service";
import type { Medication } from "@/types";

export interface AlternativeInfo {
  medication: Medication;
  inStock: boolean;
  quantityAvailable: number;
  substitutes: Medication[];
}

export function useDrugAlternatives(medicationIds: (number | null)[]) {
  const ids = Array.from(new Set(medicationIds.filter((id): id is number => id != null)));

  return useQuery({
    queryKey: ["drug-alternatives", ids],
    queryFn: async (): Promise<Record<number, AlternativeInfo>> => {
      const entries = await Promise.all(
        ids.map(async (id) => {
          const medication = await medicationService.getById(id);
          // Substitutes/stock are only surfaced via search — reuse it with the exact name.
          const searchResults = await medicationService.search(medication.name_ar);
          const match = searchResults.find((r) => r.medication.id === id);
          return [
            id,
            {
              medication,
              inStock: match?.in_stock ?? false,
              quantityAvailable: match?.quantity_available ?? 0,
              substitutes: match?.substitutes ?? [],
            },
          ] as const;
        })
      );
      return Object.fromEntries(entries);
    },
    enabled: ids.length > 0,
  });
}
