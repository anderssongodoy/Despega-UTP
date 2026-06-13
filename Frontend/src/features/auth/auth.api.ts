import { apiClient } from "../../shared/api/http";
import type { SessionResponse } from "../../shared/api/types";

export function getSession(userId = "stu_camila") {
  return apiClient<SessionResponse>(`/auth/session?userId=${encodeURIComponent(userId)}`);
}
