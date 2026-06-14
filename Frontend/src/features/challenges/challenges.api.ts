import { apiClient } from "../../shared/api/http";
import type { ChallengeDetail, ChallengesResponse } from "../../shared/api/types";

export function getChallenges(roleId?: string) {
  const query = roleId ? `?roleId=${encodeURIComponent(roleId)}` : "";
  return apiClient<ChallengesResponse>(`/challenges${query}`);
}

export function getChallenge(challengeId: string) {
  return apiClient<ChallengeDetail>(`/challenges/${challengeId}`);
}
