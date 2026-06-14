import { ApiError } from "../../shared/api/http";
import { env } from "../../shared/config/env";
import type { CvAnalyzeResponse } from "../../shared/api/types";

/**
 * Sube un PDF a POST /api/cv/analyze (multipart, campo "file").
 * No usa apiClient porque ese fuerza JSON; aquí mandamos FormData.
 */
export async function analyzeCv(file: File): Promise<CvAnalyzeResponse> {
  const form = new FormData();
  form.append("file", file);

  const response = await fetch(`${env.apiBaseUrl}/cv/analyze`, {
    method: "POST",
    body: form,
  });

  const payload = await response.json().catch(() => null);
  if (!response.ok) {
    throw new ApiError("CV analyze failed", response.status, payload);
  }
  return payload as CvAnalyzeResponse;
}
