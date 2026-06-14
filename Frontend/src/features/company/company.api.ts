import { apiClient } from "../../shared/api/http";
import { getCurrentCompanyId } from "../../shared/auth/authStore";
import type {
  CandidateDetail,
  CandidatesResponse,
  CompanyDashboard,
  CompanyJobsResponse,
} from "../../shared/api/types";

export function getCompanyDashboard(companyId = getCurrentCompanyId()) {
  return apiClient<CompanyDashboard>(`/companies/${companyId}/dashboard`);
}

export function getCompanyJobs(companyId = getCurrentCompanyId()) {
  return apiClient<CompanyJobsResponse>(`/companies/${companyId}/jobs`);
}

export function getJobCandidates(jobId: string, companyId = getCurrentCompanyId()) {
  return apiClient<CandidatesResponse>(`/companies/${companyId}/jobs/${jobId}/candidates`);
}

export function getCandidateDetail(studentId: string, jobId: string, companyId = getCurrentCompanyId()) {
  return apiClient<CandidateDetail>(
    `/companies/${companyId}/candidates/${studentId}?jobId=${encodeURIComponent(jobId)}`,
  );
}
