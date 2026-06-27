import { apiClient } from "@/lib/axios";
import type { AuthResponse, LoginPayload, RegisterPayload, User } from "@/types";

export const authService = {
  register: async (payload: RegisterPayload): Promise<AuthResponse> => {
    const { data } = await apiClient.post<AuthResponse>("/api/auth/register", payload);
    return data;
  },

  login: async (payload: LoginPayload): Promise<AuthResponse> => {
    const { data } = await apiClient.post<AuthResponse>("/api/auth/login", payload);
    return data;
  },

  me: async (): Promise<User> => {
    const { data } = await apiClient.get<User>("/api/auth/me");
    return data;
  },

  addAllergy: async (substance_name: string): Promise<User> => {
    const { data } = await apiClient.post<User>("/api/auth/me/allergies", { substance_name });
    return data;
  },

  addChronicCondition: async (condition_name: string, notes?: string): Promise<User> => {
    const { data } = await apiClient.post<User>("/api/auth/me/chronic-conditions", { condition_name, notes });
    return data;
  },
};
