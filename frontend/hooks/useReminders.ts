"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { customerService } from "@/services/customer.service";
import { queryKeys } from "@/lib/constants";
import type { ReminderCreatePayload } from "@/types";

export function useReminders() {
  return useQuery({ queryKey: queryKeys.reminders, queryFn: customerService.listReminders });
}

export function useCreateReminder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: ReminderCreatePayload) => customerService.createReminder(payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: queryKeys.reminders }),
  });
}

export function useCancelReminder() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => customerService.cancelReminder(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: queryKeys.reminders }),
  });
}

export function useLoyalty() {
  return useQuery({ queryKey: queryKeys.loyalty, queryFn: customerService.loyalty });
}
