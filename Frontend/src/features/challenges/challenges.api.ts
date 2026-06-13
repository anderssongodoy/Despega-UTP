import { apiClient } from "../../shared/api/http";

export function getChallenges(roleId = "role_data_intern") {
  return apiClient<{ challenges: unknown[] }>(`/challenges?roleId=${encodeURIComponent(roleId)}`);
}

export function getChallenge(challengeId: string) {
  return apiClient(`/challenges/${challengeId}`);
}

export function submitChallenge(challengeId: string, payload: unknown) {
  return apiClient(`/challenges/${challengeId}/submit`, { method: "POST", body: payload });
}
