import { Link } from "react-router-dom";
import { ArrowRight, BookOpen, Building2, Sparkles, TriangleAlert } from "lucide-react";

import { getStudentDashboard } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { severityEs } from "../../../shared/config/labels";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";
import { StatusBadge } from "../../../shared/components/StatusBadge";

export function StudentHomePage() {
  const dash = useApi(() => getStudentDashboard(), []);

  if (dash.loading) return <LoadingState />;
  if (dash.error || !dash.data) return <ErrorState />;

  const dashboard = dash.data;
  const jobs = dashboard.recommendedJobs ?? [];
  const resources = dashboard.recommendedResources ?? [];

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Estudiante</p>
        <h2>Hola, {dashboard.student.name.split(" ")[0]}</h2>
        <p className="muted">
          {dashboard.student.career} · {dashboard.student.cycle} ciclo
          {dashboard.goal.roleName ? ` · Meta: ${dashboard.goal.roleName}` : ""}
        </p>
      </section>

      <div className="metrics-grid">
        <MetricCard
          label="Preparacion"
          value={`${dashboard.goal.readinessScore}/100`}
          helper={dashboard.goal.roleName ?? "Sin meta"}
        />
        <MetricCard label="Evidencias" value={dashboard.progress.evidences} helper="listas para tu CV" />
        <MetricCard label="Postulaciones" value={dashboard.progress.applications} helper="preparadas" />
        <MetricCard label="Retos" value={dashboard.progress.challengesCompleted} helper="completados" />
      </div>

      <div className="content-grid">
        <Card className="featured">
          <p className="eyebrow">
            <Sparkles size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Tu proxima accion
          </p>
          <h3>{dashboard.nextBestAction.title}</h3>
          <p>{dashboard.nextBestAction.description}</p>
          <Link to={appRoutes.studentRoute} className="btn btn-secondary" style={{ marginTop: "0.5rem" }}>
            Ver mi plan <ArrowRight size={18} />
          </Link>
        </Card>

        <Card>
          <p className="eyebrow">Brechas criticas</p>
          {dashboard.criticalGaps.length === 0 ? (
            <p className="muted" style={{ margin: 0 }}>
              Sin brechas criticas para tu meta actual.
            </p>
          ) : (
            <div className="stack compact">
              {dashboard.criticalGaps.map((gap) => (
                <div key={gap.skillName} className="evidence-item">
                  <div className="row-between">
                    <span className="list-row">
                      <span className="row-icon">
                        <TriangleAlert size={18} />
                      </span>
                      <strong>{gap.skillName}</strong>
                    </span>
                    <StatusBadge status={gap.severity}>{severityEs(gap.severity)}</StatusBadge>
                  </div>
                  {gap.message ? (
                    <p className="muted" style={{ margin: 0 }}>
                      {gap.message}
                    </p>
                  ) : null}
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>

      <div className="content-grid">
        <Card>
          <div className="row-between">
            <p className="eyebrow">
              <Building2 size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
              Vacantes recomendadas
            </p>
            <Link to={appRoutes.studentOpportunities} className="btn btn-ghost" style={{ minHeight: "auto", padding: "0.3rem 0.6rem" }}>
              Ver todas <ArrowRight size={16} />
            </Link>
          </div>
          {jobs.length === 0 ? (
            <p className="muted" style={{ margin: 0 }}>
              Completa tu perfil para activar el match con empresas.
            </p>
          ) : (
            <div className="card-list" style={{ marginTop: "0.5rem" }}>
              {jobs.map((job) => {
                const score = job.matchScore ?? 0;
                return (
                  <div key={job.jobId ?? job.job_id} className="evidence-item">
                    <div className="row-between">
                      <span className="stack compact" style={{ gap: "0.05rem" }}>
                        <strong>{job.title}</strong>
                        <small className="muted">{job.companyName ?? job.company_name}</small>
                      </span>
                      <StatusBadge status={job.status}>{score}%</StatusBadge>
                    </div>
                    <div className="bar" aria-hidden="true" style={{ marginTop: "0.6rem" }}>
                      <span style={{ width: `${Math.min(100, Math.max(0, score))}%` }} />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </Card>

        <Card>
          <p className="eyebrow">
            <BookOpen size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Recursos recomendados
          </p>
          {resources.length === 0 ? (
            <p className="muted" style={{ margin: 0 }}>
              Aun no hay recursos sugeridos.
            </p>
          ) : (
            <div className="stack compact" style={{ marginTop: "0.5rem" }}>
              {resources.map((resource) => (
                <div key={resource.resourceId ?? resource.id ?? resource.name} className="evidence-item">
                  <strong>{resource.name}</strong>
                  {resource.reason ? (
                    <p className="muted" style={{ margin: 0 }}>
                      {resource.reason}
                    </p>
                  ) : null}
                </div>
              ))}
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}
