import { useState } from "react";
import type { CSSProperties } from "react";
import { ArrowRight, Briefcase, Building2, TriangleAlert, UserRound } from "lucide-react";
import { Link } from "react-router-dom";

import { getCompanyDashboard, getCompanyJobs } from "../company.api";
import { jobStatusEs, statusEs } from "../../../shared/config/labels";
import { appRoutes } from "../../../shared/config/routes";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";
import { StatusBadge } from "../../../shared/components/StatusBadge";

function ringColor(score: number): string {
  if (score >= 70) return "#22a995";
  if (score >= 50) return "#f6b84b";
  return "#d50032";
}

function ScoreRing({ score }: { score: number }) {
  const safe = Math.min(100, Math.max(0, Math.round(score)));
  return (
    <span className="score-ring" style={{ ["--pct"]: safe, ["--ring"]: ringColor(safe) } as CSSProperties}>
      <span>{safe}%</span>
    </span>
  );
}

export function CompanyDashboardPage() {
  const dashboard = useApi(() => getCompanyDashboard(), []);
  const jobs = useApi(() => getCompanyJobs(), []);

  if (dashboard.loading) {
    return (
      <div className="stack">
        <section className="page-heading">
          <p className="eyebrow">Empresa</p>
          <h2>Dashboard</h2>
        </section>
        <LoadingState />
      </div>
    );
  }

  if (dashboard.error || !dashboard.data) {
    return (
      <div className="stack">
        <section className="page-heading">
          <p className="eyebrow">Empresa</p>
          <h2>Dashboard</h2>
        </section>
        <ErrorState />
      </div>
    );
  }

  const data = dashboard.data;

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Empresa</p>
        <h2>{data.company.name}</h2>
        <p className="muted">
          Talento UTP pre-filtrado por afinidad: menos CVs que revisar, candidatos que llegan con evidencia.
        </p>
      </section>

      <div className="metrics-grid">
        <MetricCard label="Vacantes" value={data.activeJobs} helper="activas" />
        <MetricCard label="Candidatos" value={data.recommendedCandidates} helper="recomendados" />
        <MetricCard label="Match promedio" value={`${data.averageMatch}%`} helper="pre-filtrado" />
        <MetricCard label="Horas ahorradas" value={data.estimatedHoursSaved} helper="estimadas" />
      </div>

      <div className="content-grid">
        <Card>
          <div className="row-between">
            <h3 style={{ margin: 0 }}>Candidatos recomendados</h3>
            <Link
              to={appRoutes.companyTalent}
              className="list-row"
              style={{ gap: "0.3rem", fontWeight: 600, color: "var(--color-red)", fontSize: "0.88rem" }}
            >
              Ver talento <ArrowRight size={15} />
            </Link>
          </div>
          <div className="card-list" style={{ marginTop: "0.75rem" }}>
            {data.candidatePreview.length === 0 ? (
              <p className="muted">Aún no hay candidatos para tus vacantes.</p>
            ) : (
              data.candidatePreview.map((candidate) => (
                <div key={candidate.student_id} className="evidence-item">
                  <div className="row-between" style={{ gap: "0.75rem" }}>
                    <span className="list-row">
                      <span className="row-icon">
                        <UserRound size={18} />
                      </span>
                      <span className="stack compact" style={{ gap: "0.05rem" }}>
                        <strong>{candidate.name}</strong>
                        <small className="muted">{candidate.career}</small>
                      </span>
                    </span>
                    <span className="stack compact" style={{ alignItems: "center", gap: "0.3rem", flex: "none" }}>
                      <ScoreRing score={candidate.matchScore} />
                      <StatusBadge status={candidate.status}>{statusEs(candidate.status)}</StatusBadge>
                    </span>
                  </div>
                  {candidate.strengths && candidate.strengths.length > 0 ? (
                    <div className="trust-strip" style={{ marginTop: "0.6rem" }}>
                      {candidate.strengths.slice(0, 3).map((strength) => (
                        <span key={strength}>{strength}</span>
                      ))}
                    </div>
                  ) : null}
                </div>
              ))
            )}
          </div>
        </Card>

        <Card>
          <p className="eyebrow">
            <TriangleAlert size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Brechas más frecuentes
          </p>
          <p className="muted" style={{ margin: "0.2rem 0 0", fontSize: "0.85rem" }}>
            Habilidades que más faltan entre tus candidatos.
          </p>
          {data.topGaps.length > 0 ? (
            <div className="trust-strip" style={{ marginTop: "0.7rem" }}>
              {data.topGaps.map((gap) => (
                <span key={gap} className="chip">
                  {gap}
                </span>
              ))}
            </div>
          ) : (
            <p className="muted" style={{ marginTop: "0.7rem" }}>
              Sin brechas frecuentes: tus candidatos cubren bien los requisitos.
            </p>
          )}
        </Card>
      </div>

      <Card>
        <p className="eyebrow">
          <Briefcase size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Vacantes
        </p>
        {jobs.data && jobs.data.jobs.length > 0 ? (
          <div className="card-list" style={{ marginTop: "0.5rem" }}>
            {jobs.data.jobs.map((job) => (
              <div key={job.jobId} className="evidence-item">
                <div className="row-between" style={{ gap: "0.75rem" }}>
                  <span className="stack compact" style={{ gap: "0.15rem", minWidth: 0 }}>
                    <strong>{job.title}</strong>
                    <small className="muted">
                      {[job.modality, job.location].filter(Boolean).join(" · ")}
                    </small>
                  </span>
                  <StatusBadge status={job.status ?? "active"}>{jobStatusEs(job.status)}</StatusBadge>
                </div>
                <div className="trust-strip" style={{ marginTop: "0.55rem" }}>
                  <span>
                    <UserRound size={14} /> {job.recommendedCandidates ?? 0} candidatos
                  </span>
                  <span>
                    <Building2 size={14} /> match promedio {job.averageMatch ?? 0}%
                  </span>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="muted">Sin vacantes activas.</p>
        )}
      </Card>
    </div>
  );
}
