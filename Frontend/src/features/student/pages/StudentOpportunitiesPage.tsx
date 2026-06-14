import { useState } from "react";
import type { CSSProperties } from "react";
import { Briefcase, Check, CheckCircle2, Clock, FileText, Laptop, MapPin, Target, TriangleAlert } from "lucide-react";

import {
  createApplication,
  getApplicationKit,
  getApplications,
  getJobMatches,
} from "../../opportunities/opportunities.api";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { applicationStatusEs, severityEs, statusEs } from "../../../shared/config/labels";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

function ringColor(score: number): string {
  if (score >= 70) return "#22a995";
  if (score >= 50) return "#f6b84b";
  return "#d50032";
}

function ApplicationKit({ jobId }: { jobId: string }) {
  const kit = useApi(() => getApplicationKit(getCurrentUserId(), jobId), [jobId]);

  if (kit.loading) return <LoadingState label="Preparando kit…" />;
  if (kit.error || !kit.data) return <ErrorState />;

  const data = kit.data;
  return (
    <div
      className="stack compact"
      style={{ marginTop: "1rem", borderTop: "1px solid var(--color-border)", paddingTop: "1rem" }}
    >
      <span className="chip">
        <FileText size={12} style={{ marginRight: 4 }} /> Mensaje de presentacion
      </span>
      <p className="muted" style={{ margin: 0, lineHeight: 1.55 }}>
        {data.coverMessage}
      </p>
      {data.cvTips.length > 0 ? (
        <>
          <span className="chip">Tips para tu CV</span>
          <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
            {data.cvTips.map((tip, index) => (
              <li key={index} style={{ lineHeight: 1.5 }}>
                {tip}
              </li>
            ))}
          </ul>
        </>
      ) : null}
      <p style={{ margin: "0.3rem 0 0", display: "inline-flex", alignItems: "center", gap: "0.45rem", fontWeight: 700 }}>
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
      // dejar el boton libre; el backend puede no estar disponible
    } finally {
      setApplyingTo(null);
    }
  }

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Oportunidades</p>
        <h2>Vacantes con match explicado</h2>
        <p className="muted">Ordenadas por afinidad con tu perfil. Cada una te dice por que encajas y que reforzar.</p>
      </section>

      {applications.data && applications.data.applications.length > 0 ? (
        <Card>
          <p className="eyebrow">
            <Briefcase size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Mis postulaciones
          </p>
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
            const strengths = job.strengths ?? [];
            const gaps = job.gaps ?? [];
            const meta = [job.modality, job.location, job.hours].filter(Boolean);
            return (
              <Card key={jobId}>
                <div className="row-between" style={{ alignItems: "flex-start", gap: "1rem" }}>
                  <span className="list-row" style={{ alignItems: "flex-start" }}>
                    <span className="row-icon">
                      <Briefcase size={18} />
                    </span>
                    <span className="stack compact" style={{ gap: "0.2rem" }}>
                      <h3 style={{ margin: 0 }}>{job.title}</h3>
                      <p className="muted" style={{ margin: 0 }}>
                        {job.companyName ?? job.company_name}
                      </p>
                      {meta.length > 0 ? (
                        <div className="opp-meta" style={{ marginTop: "0.15rem" }}>
                          {job.modality ? (
                            <span>
                              <Laptop size={13} /> {job.modality}
                            </span>
                          ) : null}
                          {job.location ? (
                            <span>
                              <MapPin size={13} /> {job.location}
                            </span>
                          ) : null}
                          {job.hours ? (
                            <span>
                              <Clock size={13} /> {job.hours}
                            </span>
                          ) : null}
                        </div>
                      ) : null}
                    </span>
                  </span>

                  <span className="stack compact" style={{ alignItems: "center", gap: "0.3rem", flex: "none" }}>
                    <span
                      className="score-ring"
                      style={{ ["--pct"]: score, ["--ring"]: ringColor(score) } as CSSProperties}
                    >
                      <span>{score}%</span>
                    </span>
                    <StatusBadge status={job.status}>{statusEs(job.status)}</StatusBadge>
                  </span>
                </div>

                {/* Match explicado */}
                {strengths.length > 0 || gaps.length > 0 ? (
                  <div className="content-grid" style={{ marginTop: "1rem" }}>
                    <div className="stack compact">
                      <span className="list-row" style={{ gap: "0.4rem" }}>
                        <CheckCircle2 size={15} style={{ color: "var(--color-teal)" }} /> <strong>Por que encajas</strong>
                      </span>
                      {strengths.length > 0 ? (
                        <div className="trust-strip">
                          {strengths.map((item, index) => (
                            <span key={index}>{item}</span>
                          ))}
                        </div>
                      ) : (
                        <p className="muted" style={{ margin: 0 }}>—</p>
                      )}
                    </div>
                    <div className="stack compact">
                      <span className="list-row" style={{ gap: "0.4rem" }}>
                        <TriangleAlert size={15} style={{ color: "var(--color-red)" }} /> <strong>Para reforzar</strong>
                      </span>
                      {gaps.length > 0 ? (
                        <div className="stack compact">
                          {gaps.slice(0, 3).map((gap) => (
                            <div key={gap.skillId ?? gap.skillName} className="row-between">
                              <span>{gap.skillName}</span>
                              <StatusBadge status={gap.severity}>{severityEs(gap.severity)}</StatusBadge>
                            </div>
                          ))}
                        </div>
                      ) : (
                        <p className="muted" style={{ margin: 0 }}>Sin brechas para esta vacante.</p>
                      )}
                    </div>
                  </div>
                ) : (
                  <div className="bar" aria-hidden="true" style={{ marginTop: "1rem" }}>
                    <span style={{ width: `${Math.min(100, Math.max(0, score))}%` }} />
                  </div>
                )}

                {/* Acciones */}
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
