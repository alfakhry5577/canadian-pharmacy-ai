import { apiClient } from "@/lib/axios";
import type { Medication, MedicationCreatePayload, MedicationSearchResult } from "@/types";

export const medicationService = {
  search: async (q: string): Promise<MedicationSearchResult[]> => {
    const { data } = await apiClient.get<MedicationSearchResult[]>("/api/medications/search", {
      params: { q },
    });
    return data;
  },

  getById: async (id: number): Promise<Medication> => {
    const { data } = await apiClient.get<Medication>(`/api/medications/${id}`);
    return data;
  },

  create: async (payload: MedicationCreatePayload): Promise<Medication> => {
    const { data } = await apiClient.post<Medication>("/api/medications", payload);
    return data;
  },
};
