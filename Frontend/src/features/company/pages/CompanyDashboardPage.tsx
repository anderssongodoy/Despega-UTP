import { Briefcase, Building2, UserRound } from "lucide-react";

import { getCompanyDashboard, getCompanyJobs } from "../company.api";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";
import { StatusBadge } from "../../../shared/components/StatusBadge";

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
        <p className="muted">Resumen de vacantes, candidatos y ahorro estimado en preseleccion.</p>
      </section>

      <div className="metrics-grid">
        <MetricCard label="Vacantes" value={data.activeJobs} helper="activas" />
        <MetricCard label="Candidatos" value={data.recommendedCandidates} helper="recomendados" />
        <MetricCard label="Match promedio" value={`${data.averageMatch}%`} helper="pre-filtrado" />
        <MetricCard label="Horas ahorradas" value={data.estimatedHoursSaved} helper="estimadas" />
      </div>

      <div className="content-grid">
        <Card>
          <h3>Candidatos recomendados</h3>
          <div className="card-list" style={{ marginTop: "0.75rem" }}>
            {data.candidatePreview.length === 0 ? (
              <p className="muted">Aun no hay candidatos para tus vacantes.</p>
            ) : (
              data.candidatePreview.map((candidate) => (
                <div key={candidate.student_id} className="evidence-item">
                  <div className="row-between">
                    <span className="list-row">
                      <span className="row-icon">
                        <UserRound size={18} />
                      </span>
                      <span className="stack compact" style={{ gap: "0.05rem" }}>
                        <strong>{candidate.name}</strong>
                        <small className="muted">{candidate.career}</small>
                      </span>
                    </span>
                    <StatusBadge status={candidate.status}>{candidate.matchScore}%</StatusBadge>
                  </div>
                  <div className="bar" aria-hidden="true" style={{ marginTop: "0.6rem" }}>
                    <span style={{ width: `${Math.min(100, Math.max(0, candidate.matchScore))}%` }} />
                  </div>
                </div>
              ))
            )}
          </div>
        </Card>

        <Card>
          <p className="eyebrow">
            <Building2 size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Brechas mas frecuentes
          </p>
          <div className="trust-strip" style={{ marginTop: "0.5rem" }}>
            {data.topGaps.map((gap) => (
              <span key={gap} className="chip">
                {gap}
              </span>
            ))}
          </div>
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
                <div className="row-between">
                  <strong>{job.title}</strong>
                  <span className="chip">{job.status}</span>
                </div>
                <p className="muted" style={{ margin: 0 }}>
                  {job.recommendedCandidates ?? 0} candidatos · match promedio {job.averageMatch ?? 0}%
                </p>
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
