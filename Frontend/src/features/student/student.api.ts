import { apiClient } from "../../shared/api/http";
import { getCurrentUserId } from "../../shared/auth/authStore";
import type {
  ActionPlan,
  CvResponse,
  Diagnosis,
  EvidencesResponse,
  GapsResponse,
  InterviewKit,
  Passport,
  RolesResponse,
  StudentDashboard,
} from "../../shared/api/types";

export function getStudentDashboard(studentId = getCurrentUserId()) {
  return apiClient<StudentDashboard>(`/students/${studentId}/dashboard`);
}

export function getRoles() {
  return apiClient<RolesResponse>("/roles");
}

export function completeOnboarding(studentId: string, payload: unknown) {
  return apiClient(`/students/${studentId}/onboarding`, { method: "POST", body: payload });
}

export function getDiagnosis(studentId = getCurrentUserId()) {
  return apiClient<Diagnosis>(`/students/${studentId}/diagnosis`);
}

export function getGaps(studentId = getCurrentUserId(), jobId = "job_data_retail") {
  return apiClient<GapsResponse>(`/students/${studentId}/gaps?jobId=${encodeURIComponent(jobId)}`);
}

export function getActionPlan(studentId = getCurrentUserId()) {
  return apiClient<ActionPlan>(`/students/${studentId}/action-plan`);
}

export function getEvidences(studentId = getCurrentUserId()) {
  return apiClient<EvidencesResponse>(`/students/${studentId}/evidences`);
}

export function createEvidence(studentId: string, payload: unknown) {
  return apiClient(`/students/${studentId}/evidences`, { method: "POST", body: payload });
}

export function getCv(studentId = getCurrentUserId(), roleId = "role_data_intern") {
  return apiClient<CvResponse>(`/students/${studentId}/cv?roleId=${encodeURIComponent(roleId)}`);
}

export function getPassport(studentId = getCurrentUserId()) {
  return apiClient<Passport>(`/students/${studentId}/passport`);
}

export function getInterviewKit(studentId = getCurrentUserId(), jobId = "job_data_retail") {
  return apiClient<InterviewKit>(`/students/${studentId}/interview-kit?jobId=${encodeURIComponent(jobId)}`);
}
