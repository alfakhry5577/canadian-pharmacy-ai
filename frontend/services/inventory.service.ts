import { apiClient } from "@/lib/axios";
import type { InventoryItem, InventoryUpdatePayload } from "@/types";

export const inventoryService = {
  list: async (): Promise<InventoryItem[]> => {
    const { data } = await apiClient.get<InventoryItem[]>("/api/inventory");
    return data;
  },

  lowStock: async (): Promise<InventoryItem[]> => {
    const { data } = await apiClient.get<InventoryItem[]>("/api/inventory/low-stock");
    return data;
  },

  addBatch: async (medicationId: number, payload: InventoryUpdatePayload): Promise<InventoryItem> => {
    const { data } = await apiClient.post<InventoryItem>(`/api/inventory/${medicationId}`, payload);
    return data;
  },

  update: async (itemId: number, payload: InventoryUpdatePayload): Promise<InventoryItem> => {
    const { data } = await apiClient.patch<InventoryItem>(`/api/inventory/${itemId}`, payload);
    return data;
  },
};
