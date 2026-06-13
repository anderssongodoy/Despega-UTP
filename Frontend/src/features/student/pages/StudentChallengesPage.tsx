import { useState } from "react";
import { CircleCheck, Clock, Trophy } from "lucide-react";

import { getChallenge, getChallenges, submitChallenge } from "../../challenges/challenges.api";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";

type SubmitResult = { score: number; evidenceId: string };

function ChallengeDetailView({ challengeId }: { challengeId: string }) {
  const detail = useApi(() => getChallenge(challengeId), [challengeId]);

  if (detail.loading) return <LoadingState label="Cargando reto…" />;
  if (detail.error || !detail.data) return <ErrorState />;

  const questions = detail.data.questions ?? [];
  return (
    <div
      className="stack compact"
      style={{ marginTop: "0.85rem", borderTop: "1px solid var(--color-border)", paddingTop: "0.85rem" }}
    >
      {questions.length > 0 ? (
        <>
          <span className="chip">Preguntas del reto</span>
          <ul className="stack compact" style={{ margin: 0, paddingLeft: "1.1rem" }}>
            {questions.map((question) => (
              <li key={question.id} style={{ lineHeight: 1.5 }}>
                {question.label}
              </li>
            ))}
          </ul>
        </>
      ) : (
        <p className="muted" style={{ margin: 0 }}>
          Este reto no tiene preguntas detalladas todavia.
        </p>
      )}
    </div>
  );
}

export function StudentChallengesPage() {
  const challenges = useApi(() => getChallenges(), []);
  const [submitting, setSubmitting] = useState<string | null>(null);
  const [results, setResults] = useState<Record<string, SubmitResult>>({});
  const [openDetail, setOpenDetail] = useState<string | null>(null);

  async function resolveChallenge(challengeId: string) {
    setSubmitting(challengeId);
    try {
      const response = (await submitChallenge(challengeId, {
        studentId: getCurrentUserId(),
        score: 80,
        answers: [],
      })) as { score: number; generatedEvidenceId: string };
      setResults((prev) => ({
        ...prev,
        [challengeId]: { score: response.score, evidenceId: response.generatedEvidenceId },
      }));
    } catch {
      // keep silent; button returns to idle
    } finally {
      setSubmitting(null);
    }
  }

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Retos</p>
        <h2>Micro-retos para generar evidencia</h2>
        <p className="muted">Completa retos cortos y convierte el resultado en evidencia verificable.</p>
      </section>

      {challenges.loading ? (
        <LoadingState />
      ) : challenges.error || !challenges.data ? (
        <ErrorState />
      ) : challenges.data.challenges.length === 0 ? (
        <EmptyState title="No hay retos disponibles" description="Pronto se activaran retos para tu rol objetivo." />
      ) : (
        <div className="card-list">
          {challenges.data.challenges.map((challenge) => {
            const result = results[challenge.id];
            return (
              <Card key={challenge.id}>
                <div className="row-between">
                  <span className="list-row">
                    <span className="row-icon">
                      <Trophy size={18} />
                    </span>
                    <strong>{challenge.title}</strong>
                  </span>
                  {challenge.difficulty ? <span className="chip">{challenge.difficulty}</span> : null}
                </div>

                {challenge.brief ? (
                  <p className="muted" style={{ marginTop: "0.6rem" }}>
                    {challenge.brief}
                  </p>
                ) : null}

                <div className="trust-strip" style={{ marginTop: "0.4rem" }}>
                  {challenge.durationMinutes ? (
                    <span>
                      <Clock size={15} /> {challenge.durationMinutes} min
                    </span>
                  ) : null}
                  {challenge.skills?.slice(0, 3).map((skill) => (
                    <span key={skill} className="chip">
                      {skill.replace(/^sk_/, "").replace(/_/g, " ")}
                    </span>
                  ))}
                </div>

                <div className="pitch-controls" style={{ marginTop: "1rem" }}>
                  <button
                    type="button"
                    className="btn btn-secondary"
                    onClick={() => setOpenDetail(openDetail === challenge.id ? null : challenge.id)}
                  >
                    {openDetail === challenge.id ? "Ocultar detalle" : "Ver detalle"}
                  </button>
                  {result ? (
                    <span className="btn btn-ghost" style={{ color: "var(--color-teal)", cursor: "default" }}>
                      <CircleCheck size={18} /> Score {result.score}/100 · evidencia generada
                    </span>
                  ) : (
                    <button
                      type="button"
                      className="btn btn-primary"
                      onClick={() => resolveChallenge(challenge.id)}
                      disabled={submitting === challenge.id}
                    >
                      {submitting === challenge.id ? "Enviando…" : "Resolver reto (demo)"}
                    </button>
                  )}
                </div>
                {openDetail === challenge.id ? <ChallengeDetailView challengeId={challenge.id} /> : null}
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
