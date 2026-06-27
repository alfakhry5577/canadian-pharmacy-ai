"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { inventoryService } from "@/services/inventory.service";
import { queryKeys } from "@/lib/constants";
import type { InventoryUpdatePayload } from "@/types";

export function useInventory() {
  return useQuery({ queryKey: queryKeys.inventory, queryFn: inventoryService.list });
}

export function useLowStockInventory() {
  return useQuery({ queryKey: queryKeys.inventoryLowStock, queryFn: inventoryService.lowStock });
}

export function useAddInventoryBatch() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ medicationId, payload }: { medicationId: number; payload: InventoryUpdatePayload }) =>
      inventoryService.addBatch(medicationId, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.inventory });
      queryClient.invalidateQueries({ queryKey: queryKeys.inventoryLowStock });
    },
  });
}

export function useUpdateInventoryItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ itemId, payload }: { itemId: number; payload: InventoryUpdatePayload }) =>
      inventoryService.update(itemId, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.inventory });
      queryClient.invalidateQueries({ queryKey: queryKeys.inventoryLowStock });
    },
  });
}
