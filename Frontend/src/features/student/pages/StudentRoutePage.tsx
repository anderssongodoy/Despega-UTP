import { Link } from "react-router-dom";
import { ArrowRight, CircleCheck, Clock, ListChecks, Target, TriangleAlert } from "lucide-react";

import { getActionPlan, getDiagnosis, getGaps } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { severityEs } from "../../../shared/config/labels";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

function barClass(status: string) {
  if (status === "ready") return "bar-ready";
  if (status === "partial") return "bar-partial";
  return "bar-critical";
}

function readinessLabel(score: number): string {
  if (score >= 75) return "Listo para postular";
  if (score >= 55) return "Vas muy bien";
  if (score >= 30) return "En construccion";
  return "Punto de partida";
}

function LevelDots({ current, required }: { current: number; required: number }) {
  const total = Math.max(required, 1);
  return (
    <span style={{ display: "inline-flex", gap: 3 }} aria-hidden="true">
      {Array.from({ length: total }).map((_, index) => (
        <span
          key={index}
          style={{
            width: 9,
            height: 9,
            borderRadius: "50%",
            background: index < current ? "var(--color-teal)" : "rgba(16,16,16,0.14)",
          }}
        />
      ))}
    </span>
  );
}

export function StudentRoutePage() {
  const diagnosis = useApi(() => getDiagnosis(), []);
  const gaps = useApi(() => getGaps(), []);
  const plan = useApi(() => getActionPlan(), []);

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Ruta profesional</p>
        <h2>Tu ruta hacia la meta</h2>
        <p className="muted">Donde estas hoy, que brechas cerrar y un plan concreto para lograrlo.</p>
      </section>

      {/* Progreso hacia la meta */}
      {diagnosis.loading ? (
        <LoadingState />
      ) : diagnosis.error || !diagnosis.data ? (
        <ErrorState />
      ) : (
        <Card className="featured">
          <p className="eyebrow">
            <Target size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Meta: {diagnosis.data.role.roleName}
          </p>
          <div className="score-block" style={{ marginTop: "0.5rem" }}>
            <span className="score-number">
              {diagnosis.data.readinessScore}
              <small style={{ color: "rgba(255,255,255,0.8)" }}>/100</small>
            </span>
            <div className="stack compact" style={{ gap: "0.2rem" }}>
              <strong style={{ fontSize: "1.05rem" }}>{readinessLabel(diagnosis.data.readinessScore)}</strong>
              <span style={{ opacity: 0.92 }}>{diagnosis.data.message}</span>
            </div>
          </div>
          <div
            className="bar"
            aria-hidden="true"
            style={{ marginTop: "0.9rem", background: "rgba(255,255,255,0.25)" }}
          >
            <span style={{ width: `${Math.min(100, diagnosis.data.readinessScore)}%`, background: "#fff" }} />
          </div>
          {gaps.data ? (
            <p style={{ margin: "0.9rem 0 0", display: "inline-flex", alignItems: "center", gap: "0.45rem" }}>
              {gaps.data.canApplyToday ? <CircleCheck size={16} /> : <TriangleAlert size={16} />}
              {gaps.data.applyAdvice}
            </p>
          ) : null}
          <div>
            <Link to={appRoutes.studentOpportunities} className="btn btn-secondary" style={{ marginTop: "0.9rem" }}>
              Ver vacantes para mi meta <ArrowRight size={18} />
            </Link>
          </div>
        </Card>
      )}

      {/* Diagnostico por dimension */}
      {diagnosis.data ? (
        <Card>
          <p className="eyebrow">Tu perfil por dimension</p>
          <div className="stack" style={{ marginTop: "0.75rem" }}>
            {diagnosis.data.dimensions.map((dim) => (
              <div key={dim.name} className="dim-row">
                <span>{dim.name}</span>
                <span className="bar" aria-hidden="true">
                  <span className={barClass(dim.status)} style={{ width: `${Math.min(100, Math.max(0, dim.score))}%` }} />
                </span>
                <span className="dim-score">{dim.score}</span>
              </div>
            ))}
          </div>
        </Card>
      ) : null}

      {/* Brechas a cerrar */}
      <Card>
        <p className="eyebrow">
          <TriangleAlert size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Brechas a cerrar
        </p>
        <h3 style={{ margin: "0.1rem 0 0" }}>Lo que te separa de tu meta</h3>
        {gaps.loading ? (
          <LoadingState />
        ) : gaps.error || !gaps.data ? (
          <ErrorState />
        ) : gaps.data.gaps.length === 0 ? (
          <EmptyState
            title="Sin brechas criticas"
            description="Tu perfil ya cubre lo principal para tu meta. ¡Ahora a postular!"
          />
        ) : (
          <div className="card-list" style={{ marginTop: "1rem" }}>
            {gaps.data.gaps.map((gap) => (
              <div key={gap.skillId} className="evidence-item">
                <div className="row-between">
                  <strong>{gap.skillName}</strong>
                  <StatusBadge status={gap.severity}>{severityEs(gap.severity)}</StatusBadge>
                </div>
                <div className="row-between" style={{ alignItems: "center" }}>
                  <span className="muted" style={{ display: "inline-flex", alignItems: "center", gap: "0.5rem" }}>
                    <LevelDots current={gap.currentLevel} required={gap.requiredLevel} />
                    Nivel {gap.currentLevel} de {gap.requiredLevel}
                  </span>
                </div>
                <p className="muted" style={{ margin: 0 }}>
                  {gap.recommendedAction}
                </p>
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Plan de accion */}
      <Card>
        <p className="eyebrow">
          <ListChecks size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Tu plan
        </p>
        {plan.loading ? (
          <LoadingState />
        ) : plan.error || !plan.data ? (
          <ErrorState />
        ) : plan.data.days.length === 0 ? (
          <EmptyState title="Sin plan por ahora" description="Cuando tengas brechas, aqui veras tu plan paso a paso." />
        ) : (
          <div className="timeline" style={{ marginTop: "1rem" }}>
            {plan.data.days.map((day) => (
              <div key={`${day.day}-${day.title}`} className="timeline-item">
                <span className="timeline-day">
                  {day.day}
                  <small>dia</small>
                </span>
                <div className="stack compact" style={{ gap: "0.2rem" }}>
                  <strong>{day.title}</strong>
                  <span className="muted" style={{ display: "inline-flex", alignItems: "center", gap: "0.4rem" }}>
                    <Clock size={14} /> {day.minutes} min
                    {day.resourceId ? (
                      <>
                        {" · "}
                        <CircleCheck size={14} /> recurso UTP
                      </>
                    ) : null}
                  </span>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}
