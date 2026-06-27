export type UserRole = "admin" | "pharmacist" | "customer";

export interface User {
  id: number;
  full_name: string;
  email: string;
  phone: string | null;
  role: UserRole;
  date_of_birth: string | null;
  is_pregnant: boolean;
  created_at: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user: User;
}

export interface RegisterPayload {
  full_name: string;
  email: string;
  phone?: string;
  password: string;
  role?: UserRole;
  date_of_birth?: string;
  is_pregnant?: boolean;
}

export interface LoginPayload {
  email: string;
  password: string;
}
