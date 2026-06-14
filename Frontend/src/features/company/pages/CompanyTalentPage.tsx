import { useState } from "react";
import type { CSSProperties } from "react";
import clsx from "clsx";
import {
  CheckCircle2,
  ExternalLink,
  FileText,
  GraduationCap,
  Mail,
  TriangleAlert,
  UserRound,
} from "lucide-react";

import { getCandidateDetail, getCompanyJobs, getJobCandidates } from "../company.api";
import { jobStatusEs, severityEs, statusEs } from "../../../shared/config/labels";
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

function ScoreRing({ score }: { score: number }) {
  const safe = Math.min(100, Math.max(0, Math.round(score)));
  return (
    <span className="score-ring" style={{ ["--pct"]: safe, ["--ring"]: ringColor(safe) } as CSSProperties}>
      <span>{safe}%</span>
    </span>
  );
}

function CandidateDetail({ studentId, jobId }: { studentId: string; jobId: string }) {
  const detail = useApi(() => getCandidateDetail(studentId, jobId), [studentId, jobId]);

  if (detail.loading) return <LoadingState label="Cargando candidato…" />;
  if (detail.error || !detail.data) return <ErrorState />;

  const { candidate, match, evidences } = detail.data;
  const strengths = match.strengths ?? [];
  const gaps = match.gaps ?? [];
  const meta = [candidate.career, candidate.cycle ? `${candidate.cycle}° ciclo` : null, candidate.modality]
    .filter(Boolean)
    .join(" · ");

  return (
    <div className="stack">
      <div className="row-between" style={{ alignItems: "flex-start", gap: "1rem" }}>
        <div className="stack compact" style={{ gap: "0.2rem", minWidth: 0 }}>
          <h3 style={{ margin: 0 }}>{candidate.name}</h3>
          {meta ? (
            <p className="muted" style={{ margin: 0 }}>
              {meta}
            </p>
          ) : null}
          {candidate.email ? (
            <span className="muted" style={{ display: "inline-flex", alignItems: "center", gap: "0.35rem", fontSize: "0.85rem" }}>
              <Mail size={13} /> {candidate.email}
            </span>
          ) : null}
        </div>
        <div className="stack compact" style={{ alignItems: "center", gap: "0.35rem", flex: "none" }}>
          <ScoreRing score={match.matchScore} />
          <StatusBadge status={match.status}>{statusEs(match.status)}</StatusBadge>
        </div>
      </div>

      <div className="content-grid">
        <div className="stack compact">
          <span className="list-row" style={{ gap: "0.4rem" }}>
            <CheckCircle2 size={15} style={{ color: "var(--color-teal)" }} /> <strong>Por qué encaja</strong>
          </span>
          {strengths.length > 0 ? (
            <div className="trust-strip">
              {strengths.map((strength) => (
                <span key={strength}>{strength}</span>
              ))}
            </div>
          ) : (
            <p className="muted" style={{ margin: 0 }}>Sin fortalezas registradas para esta vacante.</p>
          )}
        </div>

        <div className="stack compact">
          <span className="list-row" style={{ gap: "0.4rem" }}>
            <TriangleAlert size={15} style={{ color: "var(--color-red)" }} /> <strong>Brechas a cubrir</strong>
          </span>
          {gaps.length > 0 ? (
            <div className="stack compact">
              {gaps.slice(0, 4).map((gap) => (
                <div key={gap.skillId ?? gap.skillName} className="row-between">
                  <span>{gap.skillName}</span>
                  <StatusBadge status={gap.severity}>{severityEs(gap.severity)}</StatusBadge>
                </div>
              ))}
            </div>
          ) : (
            <p className="muted" style={{ margin: 0 }}>Cumple todos los requisitos de la vacante.</p>
          )}
        </div>
      </div>

      <div className="stack compact">
        <span className="list-row" style={{ gap: "0.4rem" }}>
          <FileText size={15} /> <strong>Evidencias verificables</strong>
        </span>
        {evidences.length === 0 ? (
          <p className="muted" style={{ margin: 0 }}>
            Sin evidencias registradas.
          </p>
        ) : (
          <div className="card-list">
            {evidences.map((evidence) => (
              <div key={evidence.id} className="evidence-item">
                <strong>{evidence.title}</strong>
                {evidence.cv_bullet ? <p className="cv-bullet">{evidence.cv_bullet}</p> : null}
              </div>
            ))}
          </div>
        )}
      </div>

      <a
        className="btn btn-secondary"
        href={`${window.location.origin}/portfolio/${candidate.id}`}
        target="_blank"
        rel="noreferrer"
        style={{ alignSelf: "flex-start" }}
      >
        <ExternalLink size={18} /> Ver portafolio completo
      </a>
    </div>
  );
}

function CandidatesPanel({ jobId }: { jobId: string }) {
  const candidates = useApi(() => getJobCandidates(jobId), [jobId]);
  const [selected, setSelected] = useState<string | null>(null);

  if (candidates.loading) return <LoadingState />;
  if (candidates.error || !candidates.data) return <ErrorState />;
  if (candidates.data.candidates.length === 0) {
    return (
      <EmptyState
        title="Sin candidatos para esta vacante"
        description="Aún no hay estudiantes con match suficiente. Prueba con otra vacante."
      />
    );
  }

  const list = candidates.data.candidates;
  const activeStudent = selected ?? list[0].student_id;

  return (
    <div className="content-grid">
      <div className="card-list">
        {list.map((candidate) => (
          <Card
            key={candidate.student_id}
            className={clsx("interactive", activeStudent === candidate.student_id && "featured")}
            onClick={() => setSelected(candidate.student_id)}
          >
            <div className="row-between" style={{ gap: "0.75rem" }}>
              <span className="list-row">
                <span className="row-icon">
                  <UserRound size={18} />
                </span>
                <span className="stack compact" style={{ gap: "0.05rem" }}>
                  <strong>{candidate.name}</strong>
                  <small style={{ opacity: 0.85 }}>{candidate.career}</small>
                </span>
              </span>
              <ScoreRing score={candidate.matchScore} />
            </div>
            {candidate.strengths && candidate.strengths.length > 0 ? (
              <div className="trust-strip" style={{ marginTop: "0.7rem" }}>
                {candidate.strengths.slice(0, 3).map((strength) => (
                  <span key={strength}>{strength}</span>
                ))}
              </div>
            ) : null}
          </Card>
        ))}
      </div>

      <Card>
        <CandidateDetail studentId={activeStudent} jobId={jobId} />
      </Card>
    </div>
  );
}

export function CompanyTalentPage() {
  const jobs = useApi(() => getCompanyJobs(), []);
  const [activeJob, setActiveJob] = useState<string | null>(null);

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Talento recomendado</p>
        <h2>Candidatos rankeados con evidencia</h2>
        <p className="muted">Elige una vacante y revisa candidatos pre-filtrados, con su match explicado y evidencia verificable.</p>
      </section>

      {jobs.loading ? (
        <LoadingState />
      ) : jobs.error || !jobs.data ? (
        <ErrorState />
      ) : jobs.data.jobs.length === 0 ? (
        <EmptyState title="Sin vacantes" description="Publica una vacante para empezar a recibir candidatos." />
      ) : (
        (() => {
          const jobList = jobs.data.jobs;
          const currentJob = activeJob ?? jobList[0].jobId;
          return (
            <>
              <div className="tabs" role="tablist" aria-label="Vacantes">
                {jobList.map((job) => (
                  <button
                    key={job.jobId}
                    type="button"
                    role="tab"
                    aria-selected={currentJob === job.jobId}
                    className={clsx("tab", currentJob === job.jobId && "active")}
                    onClick={() => setActiveJob(job.jobId)}
                  >
                    {job.title}
                    {job.status ? <span className="chip" style={{ marginLeft: "0.5rem" }}>{jobStatusEs(job.status)}</span> : null}
                  </button>
                ))}
              </div>
              <CandidatesPanel key={currentJob} jobId={currentJob} />
            </>
          );
        })()
      )}
    </div>
  );
}
