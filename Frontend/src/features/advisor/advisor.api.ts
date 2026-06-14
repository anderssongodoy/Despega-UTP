import { apiClient } from "../../shared/api/http";
import type { AdvisorImpact, CriticalGapStudentsResponse } from "../../shared/api/types";

export function getAdvisorImpact() {
  return apiClient<AdvisorImpact>("/advisor/impact");
}

export function getCriticalGapStudents(
  skillId: string,
  params?: { source?: "role" | "job"; roleId?: string; jobId?: string },
) {
  const query = new URLSearchParams();
  if (params?.source) query.set("source", params.source);
  if (params?.roleId) query.set("roleId", params.roleId);
  if (params?.jobId) query.set("jobId", params.jobId);
  const qs = query.toString();
  return apiClient<CriticalGapStudentsResponse>(
    `/critical-gaps/${encodeURIComponent(skillId)}/students${qs ? `?${qs}` : ""}`,
  );
}
