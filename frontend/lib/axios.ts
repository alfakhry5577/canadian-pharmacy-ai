import axios, { AxiosError } from "axios";
import { API_BASE_URL } from "@/lib/constants";
import { useAuthStore } from "@/store/auth.store";

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30_000,
});

apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Token expired/invalid — clear local auth so RoleGuard redirects to /login.
      useAuthStore.getState().clearAuth();
    }
    return Promise.reject(error);
  }
);

/** Extracts a human-readable Arabic error message from a FastAPI error response. */
export function extractErrorMessage(error: unknown, fallback = "حدث خطأ غير متوقع، يرجى المحاولة لاحقًا"): string {
  if (axios.isAxiosError(error)) {
    const detail = error.response?.data?.detail;
    if (typeof detail === "string") return detail;
    if (Array.isArray(detail) && detail[0]?.msg) return detail[0].msg;
  }
  return fallback;
}
