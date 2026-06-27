import { apiClient } from "@/lib/axios";
import type {
  Prescription,
  PrescriptionAnalysisResult,
  PrescriptionItemUpdatePayload,
  PrescriptionReviewPayload,
} from "@/types";

export const prescriptionService = {
  upload: async (file: File): Promise<PrescriptionAnalysisResult> => {
    const form = new FormData();
    form.append("file", file);
    const { data } = await apiClient.post<PrescriptionAnalysisResult>("/api/prescriptions/upload", form, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return data;
  },

  mine: async (): Promise<Prescription[]> => {
    const { data } = await apiClient.get<Prescription[]>("/api/prescriptions/mine");
    return data;
  },

  queue: async (): Promise<Prescription[]> => {
    const { data } = await apiClient.get<Prescription[]>("/api/prescriptions/queue");
    return data;
  },

  getById: async (id: number): Promise<Prescription> => {
    const { data } = await apiClient.get<Prescription>(`/api/prescriptions/${id}`);
    return data;
  },

  updateItem: async (itemId: number, payload: PrescriptionItemUpdatePayload): Promise<Prescription> => {
    const { data } = await apiClient.patch<Prescription>(`/api/prescriptions/items/${itemId}`, payload);
    return data;
  },

  review: async (id: number, payload: PrescriptionReviewPayload): Promise<Prescription> => {
    const { data } = await apiClient.patch<Prescription>(`/api/prescriptions/${id}/review`, payload);
    return data;
  },
};
