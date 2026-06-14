import { useState } from "react";
import { Building2, Check, Target } from "lucide-react";

import {
  createApplication,
  getApplicationKit,
  getApplications,
  getJobMatches,
} from "../../opportunities/opportunities.api";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { applicationStatusEs } from "../../../shared/config/labels";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

function ApplicationKit({ jobId }: { jobId: string }) {
  const kit = useApi(() => getApplicationKit(getCurrentUserId(), jobId), [jobId]);

  if (kit.loading) return <LoadingState label="Preparando kit…" />;
  if (kit.error || !kit.data) return <ErrorState />;

  const data = kit.data;
  return (
    <div className="stack compact" style={{ marginTop: "0.9rem", borderTop: "1px solid var(--color-border)", paddingTop: "0.9rem" }}>
      <span className="chip">Mensaje de presentacion</span>
      <p className="muted" style={{ margin: 0 }}>
        {data.coverMessage}
      </p>
      {data.cvTips.length > 0 ? (
        <>
          <span className="chip">Tips de CV</span>
          <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
            {data.cvTips.map((tip, index) => (
              <li key={index} style={{ lineHeight: 1.5 }}>
                {tip}
              </li>
            ))}
          </ul>
        </>
      ) : null}
      <p style={{ margin: "0.2rem 0 0", display: "inline-flex", alignItems: "center", gap: "0.45rem", fontWeight: 600 }}>
        <Target size={16} /> Proxima accion: {data.nextAction}
      </p>
    </div>
  );
}

export function StudentOpportunitiesPage() {
  const matches = useApi(() => getJobMatches(), []);
  const applications = useApi(() => getApplications(), []);
  const [openKit, setOpenKit] = useState<string | null>(null);
  const [applyingTo, setApplyingTo] = useState<string | null>(null);
  const [appliedLocal, setAppliedLocal] = useState<Set<string>>(new Set());

  const appliedJobs = new Set<string>([
    ...appliedLocal,
    ...(applications.data?.applications.map((app) => app.job_id) ?? []),
  ]);

  async function apply(jobId: string) {
    setApplyingTo(jobId);
    try {
      await createApplication(getCurrentUserId(), { jobId, status: "prepared" });
      setAppliedLocal((prev) => new Set(prev).add(jobId));
    } catch {
      // leave button idle; backend may be unavailable
    } finally {
      setApplyingTo(null);
    }
  }

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Oportunidades</p>
        <h2>Vacantes recomendadas y kit de postulacion</h2>
        <p className="muted">Ordenadas por afinidad con tu perfil y evidencias.</p>
      </section>

      {applications.data && applications.data.applications.length > 0 ? (
        <Card>
          <p className="eyebrow">Mis postulaciones</p>
          <div className="stack compact" style={{ marginTop: "0.5rem" }}>
            {applications.data.applications.map((app) => (
              <div key={app.id} className="row-between">
                <span>
                  {app.title} · <span className="muted">{app.company_name}</span>
                </span>
                <span className="chip">{applicationStatusEs(app.status)}</span>
              </div>
            ))}
          </div>
        </Card>
      ) : null}

      {matches.loading ? (
        <LoadingState />
      ) : matches.error || !matches.data ? (
        <ErrorState />
      ) : matches.data.jobs.length === 0 ? (
        <EmptyState
          title="Aun no hay vacantes recomendadas"
          description="Completa tu perfil y evidencias para activar el match con empresas."
        />
      ) : (
        <div className="card-list">
          {matches.data.jobs.slice(0, 6).map((job) => {
            const jobId = job.jobId ?? job.job_id ?? "";
            const score = job.matchScore ?? 0;
            const isApplied = appliedJobs.has(jobId);
            return (
              <Card key={jobId}>
                <div className="row-between">
                  <span className="list-row">
                    <span className="row-icon">
                      <Building2 size={18} />
                    </span>
                    <span className="stack compact" style={{ gap: "0.1rem" }}>
                      <h3 style={{ margin: 0 }}>{job.title}</h3>
                      <p className="muted" style={{ margin: 0 }}>
                        {job.companyName ?? job.company_name}
                      </p>
                    </span>
                  </span>
                  <StatusBadge status={job.status}>{score}%</StatusBadge>
                </div>

                <div className="bar" aria-hidden="true" style={{ marginTop: "1rem" }}>
                  <span style={{ width: `${Math.min(100, Math.max(0, score))}%` }} />
                </div>

                <div className="pitch-controls" style={{ marginTop: "1rem" }}>
                  <button
                    type="button"
                    className="btn btn-secondary"
                    onClick={() => setOpenKit(openKit === jobId ? null : jobId)}
                  >
                    {openKit === jobId ? "Ocultar kit" : "Ver kit de postulacion"}
                  </button>
                  {isApplied ? (
                    <span className="btn btn-ghost" style={{ color: "var(--color-teal)", cursor: "default" }}>
                      <Check size={18} /> Postulado
                    </span>
                  ) : (
                    <button
                      type="button"
                      className="btn btn-primary"
                      onClick={() => apply(jobId)}
                      disabled={applyingTo === jobId}
                    >
                      {applyingTo === jobId ? "Postulando…" : "Postular"}
                    </button>
                  )}
                </div>

                {openKit === jobId ? <ApplicationKit jobId={jobId} /> : null}
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
