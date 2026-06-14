import { apiClient } from "../../shared/api/http";
import type { SessionResponse, UserRole, UsersResponse } from "../../shared/api/types";

export function getSession(userId = "stu_camila") {
  return apiClient<SessionResponse>(`/auth/session?userId=${encodeURIComponent(userId)}`);
}

export function login(email: string, password: string) {
  return apiClient<SessionResponse>("/auth/login", { method: "POST", body: { email, password } });
}

export function register(payload: { name: string; email: string; password: string; role: UserRole }) {
  return apiClient<SessionResponse>("/auth/register", { method: "POST", body: payload });
}

export function getUsers() {
  return apiClient<UsersResponse>("/auth/users");
}
