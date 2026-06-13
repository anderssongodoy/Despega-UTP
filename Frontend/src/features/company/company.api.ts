import { apiClient } from "../../shared/api/http";

export const defaultCompanyId = "comp_retail_andino";

export function getCompanyDashboard(companyId = defaultCompanyId) {
  return apiClient(`/companies/${companyId}/dashboard`);
}

export function getCompanyJobs(companyId = defaultCompanyId) {
  return apiClient(`/companies/${companyId}/jobs`);
}

export function getJobCandidates(companyId = defaultCompanyId, jobId = "job_data_retail") {
  return apiClient(`/companies/${companyId}/jobs/${jobId}/candidates`);
}

export function getCandidateDetail(companyId = defaultCompanyId, studentId = "stu_camila", jobId = "job_data_retail") {
  return apiClient(`/companies/${companyId}/candidates/${studentId}?jobId=${encodeURIComponent(jobId)}`);
}
