import { apiClient } from "../../shared/api/http";
import type { AdvisorImpact } from "../../shared/api/types";

export function getAdvisorImpact() {
  return apiClient<AdvisorImpact>("/advisor/impact");
}
