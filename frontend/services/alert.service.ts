import { apiClient } from "@/lib/axios";
import type { Alert } from "@/types";

export const alertService = {
  list: async (resolved = false): Promise<Alert[]> => {
    const { data } = await apiClient.get<Alert[]>("/api/alerts", { params: { resolved } });
    return data;
  },

  scan: async (): Promise<Alert[]> => {
    const { data } = await apiClient.post<Alert[]>("/api/alerts/scan");
    return data;
  },

  resolve: async (id: number): Promise<Alert> => {
    const { data } = await apiClient.patch<Alert>(`/api/alerts/${id}/resolve`);
    return data;
  },
};
