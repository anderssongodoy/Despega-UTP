import { apiClient } from "../../shared/api/http";
import { getCurrentCompanyId } from "../../shared/auth/authStore";
import type { CandidatesResponse, CompanyDashboard, CompanyJobsResponse } from "../../shared/api/types";

export function getCompanyDashboard(companyId = getCurrentCompanyId()) {
  return apiClient<CompanyDashboard>(`/companies/${companyId}/dashboard`);
}

export function getCompanyJobs(companyId = getCurrentCompanyId()) {
  return apiClient<CompanyJobsResponse>(`/companies/${companyId}/jobs`);
}

export function getJobCandidates(companyId = getCurrentCompanyId(), jobId = "job_data_retail") {
  return apiClient<CandidatesResponse>(`/companies/${companyId}/jobs/${jobId}/candidates`);
}

export function getCandidateDetail(companyId = getCurrentCompanyId(), studentId = "stu_camila", jobId = "job_data_retail") {
  return apiClient(`/companies/${companyId}/candidates/${studentId}?jobId=${encodeURIComponent(jobId)}`);
}
