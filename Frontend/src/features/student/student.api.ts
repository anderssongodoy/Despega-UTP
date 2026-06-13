import { apiClient } from "../../shared/api/http";
import type { StudentDashboard } from "../../shared/api/types";

export const defaultStudentId = "stu_camila";

export function getStudentDashboard(studentId = defaultStudentId) {
  return apiClient<StudentDashboard>(`/students/${studentId}/dashboard`);
}

export function getRoles() {
  return apiClient<{ roles: unknown[] }>("/roles");
}

export function completeOnboarding(studentId: string, payload: unknown) {
  return apiClient(`/students/${studentId}/onboarding`, { method: "POST", body: payload });
}

export function getDiagnosis(studentId = defaultStudentId) {
  return apiClient(`/students/${studentId}/diagnosis`);
}

export function getGaps(studentId = defaultStudentId, jobId = "job_data_retail") {
  return apiClient(`/students/${studentId}/gaps?jobId=${encodeURIComponent(jobId)}`);
}

export function getActionPlan(studentId = defaultStudentId) {
  return apiClient(`/students/${studentId}/action-plan`);
}

export function getEvidences(studentId = defaultStudentId) {
  return apiClient(`/students/${studentId}/evidences`);
}

export function createEvidence(studentId: string, payload: unknown) {
  return apiClient(`/students/${studentId}/evidences`, { method: "POST", body: payload });
}

export function getCv(studentId = defaultStudentId, roleId = "role_data_intern") {
  return apiClient(`/students/${studentId}/cv?roleId=${encodeURIComponent(roleId)}`);
}

export function getPassport(studentId = defaultStudentId) {
  return apiClient(`/students/${studentId}/passport`);
}

export function getInterviewKit(studentId = defaultStudentId, jobId = "job_data_retail") {
  return apiClient(`/students/${studentId}/interview-kit?jobId=${encodeURIComponent(jobId)}`);
}
