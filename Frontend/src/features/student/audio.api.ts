import { ApiError } from "../../shared/api/http";
import { env } from "../../shared/config/env";
import type { PitchAnalyzeResponse } from "../../shared/api/types";

/** Sube el audio del pitch a POST /api/audio/analyze (Whisper + GPT). */
export async function analyzePitchAudio(blob: Blob): Promise<PitchAnalyzeResponse> {
  const form = new FormData();
  form.append("file", blob, "pitch.webm");

  const response = await fetch(`${env.apiBaseUrl}/audio/analyze`, {
    method: "POST",
    body: form,
  });

  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    throw new ApiError("Audio analyze failed", response.status, payload);
  }
  return payload as PitchAnalyzeResponse;
}
