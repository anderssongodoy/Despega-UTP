import { apiClient } from "../../shared/api/http";

export function getAdvisorImpact() {
  return apiClient("/advisor/impact");
}
