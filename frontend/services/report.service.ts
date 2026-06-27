import { apiClient } from "@/lib/axios";
import type { SalesSummary } from "@/types";

export const reportService = {
  salesSummary: async (days = 30): Promise<SalesSummary> => {
    const { data } = await apiClient.get<SalesSummary>("/api/reports/sales-summary", { params: { days } });
    return data;
  },
};
