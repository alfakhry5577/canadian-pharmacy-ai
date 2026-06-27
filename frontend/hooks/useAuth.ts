"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { authService } from "@/services/auth.service";
import { useAuthStore } from "@/store/auth.store";
import { queryKeys, ROUTES } from "@/lib/constants";
import type { LoginPayload, RegisterPayload, UserRole } from "@/types";

function homeRouteForRole(role: UserRole): string {
  if (role === "admin") return ROUTES.admin.dashboard;
  if (role === "pharmacist") return ROUTES.pharmacist.dashboard;
  return ROUTES.customer.dashboard;
}

export function useAuth() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const { token, user, isHydrated, setAuth, clearAuth } = useAuthStore();

  const meQuery = useQuery({
    queryKey: queryKeys.me,
    queryFn: authService.me,
    enabled: isHydrated && !!token && !user,
    retry: false,
  });

  const loginMutation = useMutation({
    mutationFn: (payload: LoginPayload) => authService.login(payload),
    onSuccess: (data) => {
      setAuth(data.access_token, data.user);
      router.push(homeRouteForRole(data.user.role));
    },
  });

  const registerMutation = useMutation({
    mutationFn: (payload: RegisterPayload) => authService.register(payload),
    onSuccess: (data) => {
      setAuth(data.access_token, data.user);
      router.push(homeRouteForRole(data.user.role));
    },
  });

  const logout = () => {
    clearAuth();
    queryClient.clear();
    router.push(ROUTES.login);
  };

  return {
    user,
    token,
    isHydrated,
    isAuthenticated: !!token && !!user,
    isLoadingMe: meQuery.isLoading,
    login: loginMutation.mutateAsync,
    isLoggingIn: loginMutation.isPending,
    loginError: loginMutation.error,
    register: registerMutation.mutateAsync,
    isRegistering: registerMutation.isPending,
    registerError: registerMutation.error,
    logout,
  };
}
