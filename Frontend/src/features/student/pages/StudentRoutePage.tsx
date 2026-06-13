import { useState } from "react";
import { Link } from "react-router-dom";
import clsx from "clsx";
import { ArrowRight, CircleCheck, Clock, TriangleAlert } from "lucide-react";

import { getActionPlan, getDiagnosis, getGaps } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { StatusBadge } from "../../../shared/components/StatusBadge";

const TABS = ["Meta", "Diagnostico", "Brechas", "Plan"] as const;
type Tab = (typeof TABS)[number];

function barClass(status: string) {
  if (status === "ready") return "bar-ready";
  if (status === "partial") return "bar-partial";
  return "bar-critical";
}

function readinessStatus(score: number) {
  if (score >= 75) return "ready";
  if (score >= 55) return "partial";
  return "critical";
}

const severityLabel: Record<string, string> = {
  critical: "Critica",
  partial: "Parcial",
};

export function StudentRoutePage() {
  const [tab, setTab] = useState<Tab>("Meta");
  const diagnosis = useApi(() => getDiagnosis(), []);
  const gaps = useApi(() => getGaps(), []);
  const plan = useApi(() => getActionPlan(), []);

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Ruta profesional</p>
        <h2>Diagnostico, brechas y plan de accion</h2>
        <p className="muted">Tu meta laboral, las brechas detectadas y un plan a 14 dias.</p>
      </section>

      <div className="tabs" role="tablist" aria-label="Secciones de la ruta">
        {TABS.map((item) => (
          <button
            key={item}
            type="button"
            role="tab"
            aria-selected={tab === item}
            className={clsx("tab", tab === item && "active")}
            onClick={() => setTab(item)}
          >
            {item}
          </button>
        ))}
      </div>

      {tab === "Meta" &&
        (diagnosis.loading ? (
          <LoadingState />
        ) : diagnosis.error || !diagnosis.data ? (
          <ErrorState />
        ) : (
          <Card>
            <p className="eyebrow">Meta laboral</p>
            <h3>{diagnosis.data.role.roleName}</h3>
            <div className="score-block" style={{ margin: "0.75rem 0 1rem" }}>
              <span className="score-number">
                {diagnosis.data.readinessScore}
                <small>/100</small>
              </span>
              <StatusBadge status={readinessStatus(diagnosis.data.readinessScore)}>
                Preparacion
              </StatusBadge>
            </div>
            <p className="muted">{diagnosis.data.message}</p>
            <Link to={appRoutes.studentOpportunities} className="btn btn-primary" style={{ marginTop: "0.5rem" }}>
              Ver vacantes <ArrowRight size={18} />
            </Link>
          </Card>
        ))}

      {tab === "Diagnostico" &&
        (diagnosis.loading ? (
          <LoadingState />
        ) : diagnosis.error || !diagnosis.data ? (
          <ErrorState />
        ) : (
          <Card>
            <h3>Diagnostico por dimension</h3>
            <div className="stack" style={{ marginTop: "1rem" }}>
              {diagnosis.data.dimensions.map((dim) => (
                <div key={dim.name} className="dim-row">
                  <span>{dim.name}</span>
                  <span className="bar" aria-hidden="true">
                    <span
                      className={barClass(dim.status)}
                      style={{ width: `${Math.min(100, Math.max(0, dim.score))}%` }}
                    />
                  </span>
                  <span className="dim-score">{dim.score}</span>
                </div>
              ))}
            </div>
          </Card>
        ))}

      {tab === "Brechas" &&
        (gaps.loading ? (
          <LoadingState />
        ) : gaps.error || !gaps.data ? (
          <ErrorState />
        ) : (
          <div className="stack">
            <Card className={gaps.data.canApplyToday ? "featured" : undefined}>
              <p className="eyebrow">{gaps.data.canApplyToday ? "Puedes postular hoy" : "Antes de postular"}</p>
              <p style={{ margin: 0 }}>{gaps.data.applyAdvice}</p>
            </Card>
            <Card>
              <h3>Brechas para esta vacante</h3>
              <div className="stack compact" style={{ marginTop: "0.75rem" }}>
                {gaps.data.gaps.map((gap) => (
                  <div key={gap.skillId} className="evidence-item">
                    <div className="row-between">
                      <span className="list-row">
                        <span className="row-icon">
                          <TriangleAlert size={18} />
                        </span>
                        <strong>{gap.skillName}</strong>
                      </span>
                      <StatusBadge status={gap.severity}>
                        {severityLabel[gap.severity] ?? gap.severity}
                      </StatusBadge>
                    </div>
                    <p className="muted" style={{ margin: 0 }}>
                      Nivel {gap.currentLevel} de {gap.requiredLevel} requerido · {gap.recommendedAction}
                    </p>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        ))}

      {tab === "Plan" &&
        (plan.loading ? (
          <LoadingState />
        ) : plan.error || !plan.data ? (
          <ErrorState />
        ) : (
          <Card>
            <h3>Plan de accion</h3>
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
          </Card>
        ))}
    </div>
  );
}
