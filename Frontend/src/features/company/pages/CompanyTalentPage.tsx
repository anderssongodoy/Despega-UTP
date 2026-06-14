import { useState } from "react";
import clsx from "clsx";
import { UserRound } from "lucide-react";

import { getCandidateDetail, getJobCandidates } from "../company.api";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

type CandidateDetailData = {
  candidate: { id: string; name: string; career?: string; cycle?: number; modality?: string };
  match: { matchScore: number; status: string; gaps?: Array<{ skillName: string; message?: string }>; strengths?: string[] };
  evidences: Array<{ id: string; title: string; cv_bullet?: string }>;
};

function CandidateDetail({ studentId }: { studentId: string }) {
  const detail = useApi(() => getCandidateDetail(undefined, studentId) as Promise<CandidateDetailData>, [studentId]);

  if (detail.loading) return <LoadingState />;
  if (detail.error || !detail.data) return <ErrorState />;

  const { candidate, match, evidences } = detail.data;
  return (
    <div className="stack">
      <div className="row-between">
        <h3 style={{ margin: 0 }}>{candidate.name}</h3>
        <StatusBadge status={match.status}>{match.matchScore}%</StatusBadge>
      </div>
      <p className="muted" style={{ margin: 0 }}>
        {candidate.career} · {candidate.cycle} ciclo
      </p>

      {match.strengths && match.strengths.length > 0 ? (
        <div className="stack compact">
          <span className="chip">Fortalezas</span>
          <div className="trust-strip">
            {match.strengths.map((strength) => (
              <span key={strength}>{strength}</span>
            ))}
          </div>
        </div>
      ) : null}

      {match.gaps && match.gaps.length > 0 ? (
        <div className="stack compact">
          <span className="chip">Brechas a cubrir</span>
          {match.gaps.map((gap) => (
            <p key={gap.skillName} className="muted" style={{ margin: 0 }}>
              {gap.skillName}
              {gap.message ? ` · ${gap.message}` : ""}
            </p>
          ))}
        </div>
      ) : null}

      <div className="stack compact">
        <span className="chip">Evidencias</span>
        {evidences.length === 0 ? (
          <p className="muted" style={{ margin: 0 }}>
            Sin evidencias registradas.
          </p>
        ) : (
          evidences.map((evidence) => (
            <div key={evidence.id} className="evidence-item">
              <strong>{evidence.title}</strong>
              {evidence.cv_bullet ? <p className="cv-bullet">{evidence.cv_bullet}</p> : null}
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export function CompanyTalentPage() {
  const candidates = useApi(() => getJobCandidates(), []);
  const [selected, setSelected] = useState<string | null>(null);

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Talento recomendado</p>
        <h2>Candidatos rankeados con evidencia</h2>
        <p className="muted">Cada candidato llega con su match explicado y evidencia verificable.</p>
      </section>

      {candidates.loading ? (
        <LoadingState />
      ) : candidates.error || !candidates.data ? (
        <ErrorState />
      ) : candidates.data.candidates.length === 0 ? (
        <EmptyState title="Sin candidatos" description="Aun no hay candidatos con match suficiente para esta vacante." />
      ) : (
        <div className="content-grid">
          <div className="card-list">
            {candidates.data.candidates.map((candidate) => (
              <Card
                key={candidate.student_id}
                className={clsx("interactive", selected === candidate.student_id && "featured")}
                onClick={() => setSelected(candidate.student_id)}
              >
                <div className="row-between">
                  <span className="list-row">
                    <span className="row-icon">
                      <UserRound size={18} />
                    </span>
                    <span className="stack compact" style={{ gap: "0.05rem" }}>
                      <strong>{candidate.name}</strong>
                      <small style={{ opacity: 0.85 }}>{candidate.career}</small>
                    </span>
                  </span>
                  <StatusBadge status={candidate.status}>{candidate.matchScore}%</StatusBadge>
                </div>
                <div className="bar" aria-hidden="true" style={{ marginTop: "0.7rem" }}>
                  <span style={{ width: `${Math.min(100, Math.max(0, candidate.matchScore))}%` }} />
                </div>
              </Card>
            ))}
          </div>

          <Card>
            {selected ? (
              <CandidateDetail studentId={selected} />
            ) : (
              <EmptyState title="Selecciona un candidato" description="Toca un candidato para ver su match, fortalezas y evidencias." />
            )}
          </Card>
        </div>
      )}
    </div>
  );
}
