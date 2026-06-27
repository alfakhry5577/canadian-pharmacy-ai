"use client";

import { useQuery } from "@tanstack/react-query";
import { reportService } from "@/services/report.service";
import { queryKeys } from "@/lib/constants";

export function useSalesSummary(days = 30) {
  return useQuery({
    queryKey: queryKeys.salesSummary(days),
    queryFn: () => reportService.salesSummary(days),
  });
}
