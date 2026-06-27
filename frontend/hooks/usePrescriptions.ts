"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { prescriptionService } from "@/services/prescription.service";
import { queryKeys } from "@/lib/constants";
import type { PrescriptionItemUpdatePayload, PrescriptionReviewPayload } from "@/types";

export function useMyPrescriptions() {
  return useQuery({
    queryKey: queryKeys.prescriptionsMine,
    queryFn: prescriptionService.mine,
  });
}

export function usePrescriptionDetail(id: number) {
  return useQuery({
    queryKey: queryKeys.prescriptionDetail(id),
    queryFn: () => prescriptionService.getById(id),
    enabled: !!id,
  });
}

export function useUploadPrescription() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (file: File) => prescriptionService.upload(file),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: queryKeys.prescriptionsMine });
    },
  });
}

export function usePrescriptionQueue() {
  return useQuery({
    queryKey: queryKeys.prescriptionQueue,
    queryFn: prescriptionService.queue,
    refetchInterval: 30_000, // poll so new uploads appear for the pharmacist without a manual refresh
  });
}

export function useUpdatePrescriptionItem() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ itemId, payload }: { itemId: number; payload: PrescriptionItemUpdatePayload }) =>
      prescriptionService.updateItem(itemId, payload),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.prescriptionDetail(data.id), data);
      queryClient.invalidateQueries({ queryKey: queryKeys.prescriptionQueue });
    },
  });
}

export function useReviewPrescription() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: PrescriptionReviewPayload }) =>
      prescriptionService.review(id, payload),
    onSuccess: (data) => {
      queryClient.setQueryData(queryKeys.prescriptionDetail(data.id), data);
      queryClient.invalidateQueries({ queryKey: queryKeys.prescriptionQueue });
    },
  });
}
