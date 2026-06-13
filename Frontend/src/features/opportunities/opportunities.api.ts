import { apiClient } from "../../shared/api/http";
import type { JobMatch } from "../../shared/api/types";

export function getJobs() {
  return apiClient<{ jobs: unknown[] }>("/jobs");
}

export function getJobMatches(studentId = "stu_camila") {
  return apiClient<{ studentId: string; jobs: JobMatch[] }>(`/students/${studentId}/job-matches`);
}

export function getApplicationKit(studentId = "stu_camila", jobId = "job_data_retail") {
  return apiClient(`/students/${studentId}/jobs/${jobId}/application-kit`);
}

export function getApplications(studentId = "stu_camila") {
  return apiClient(`/students/${studentId}/applications`);
}

export function createApplication(studentId: string, payload: unknown) {
  return apiClient(`/students/${studentId}/applications`, { method: "POST", body: payload });
}
