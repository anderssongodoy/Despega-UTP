import { apiClient } from "../../shared/api/http";
import type { ChallengeDetail, ChallengesResponse } from "../../shared/api/types";

export function getChallenges(roleId = "role_data_intern") {
  return apiClient<ChallengesResponse>(`/challenges?roleId=${encodeURIComponent(roleId)}`);
}

export function getChallenge(challengeId: string) {
  return apiClient<ChallengeDetail>(`/challenges/${challengeId}`);
}

export function submitChallenge(challengeId: string, payload: unknown) {
  return apiClient(`/challenges/${challengeId}/submit`, { method: "POST", body: payload });
}
