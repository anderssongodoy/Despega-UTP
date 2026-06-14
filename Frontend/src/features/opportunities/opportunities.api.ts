import { apiClient } from "../../shared/api/http";
import { getCurrentUserId } from "../../shared/auth/authStore";
import type { ApplicationKit, ApplicationsResponse, JobMatch } from "../../shared/api/types";

export function getJobMatches(studentId = getCurrentUserId()) {
  return apiClient<{ studentId: string; jobs: JobMatch[] }>(`/students/${studentId}/job-matches`);
}

export function getApplicationKit(studentId = getCurrentUserId(), jobId = "job_data_retail") {
  return apiClient<ApplicationKit>(`/students/${studentId}/jobs/${jobId}/application-kit`);
}

export function getApplications(studentId = getCurrentUserId()) {
  return apiClient<ApplicationsResponse>(`/students/${studentId}/applications`);
}

export function createApplication(studentId: string, payload: { jobId: string; status?: string; notes?: string }) {
  return apiClient<{ id: string; studentId: string; jobId: string; status: string }>(
    `/students/${studentId}/applications`,
    { method: "POST", body: payload },
  );
}
