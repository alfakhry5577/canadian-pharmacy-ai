"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { alertService } from "@/services/alert.service";
import { queryKeys } from "@/lib/constants";

export function useAlerts(resolved = false) {
  return useQuery({
    queryKey: queryKeys.alerts(resolved),
    queryFn: () => alertService.list(resolved),
    refetchInterval: 60_000,
  });
}

export function useRunAlertScan() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: alertService.scan,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.alerts(false) });
    },
  });
}

export function useResolveAlert() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => alertService.resolve(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.alerts(false) });
      queryClient.invalidateQueries({ queryKey: queryKeys.alerts(true) });
    },
  });
}
