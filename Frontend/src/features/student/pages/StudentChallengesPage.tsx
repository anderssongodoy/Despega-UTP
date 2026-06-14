import { useState } from "react";
import { Check, Clock, ListChecks, MessagesSquare, Target, Trophy } from "lucide-react";

import { getChallenges } from "../../challenges/challenges.api";
import { getStudentDashboard } from "../student.api";
import { ALL_SKILLS } from "../../../shared/config/skills";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import type { Challenge } from "../../../shared/api/types";

const SKILL_NAME = new Map(ALL_SKILLS.map((skill) => [skill.id, skill.name]));
const PRACTICED_KEY = "despega_retos_practicados";

function skillLabel(id: string): string {
  return SKILL_NAME.get(id) ?? id.replace(/^sk_/, "").replace(/_/g, " ");
}

function loadPracticed(): Set<string> {
  try {
    return new Set(JSON.parse(localStorage.getItem(PRACTICED_KEY) ?? "[]"));
  } catch {
    return new Set();
  }
}

function formatCell(value: unknown): string {
  if (Array.isArray(value)) return value.join(", ");
  if (value === null || value === undefined) return "—";
  return String(value);
}

function DatasetTable({ rows }: { rows: Array<Record<string, unknown>> }) {
  if (!rows || rows.length === 0) return null;
  const columns = Array.from(new Set(rows.flatMap((row) => Object.keys(row))));
  return (
    <div className="data-table-wrap">
      <table className="data-table">
        <thead>
          <tr>
            {columns.map((column) => (
              <th key={column}>{column}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row, index) => (
            <tr key={index}>
              {columns.map((column) => (
                <td key={column}>{formatCell(row[column])}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

function ChallengeCard({
  challenge,
  practiced,
  onTogglePracticed,
}: {
  challenge: Challenge;
  practiced: boolean;
  onTogglePracticed: () => void;
}) {
  const [open, setOpen] = useState(false);
  const tasks = challenge.questions ?? [];
  const dataset = challenge.datasetPreview ?? [];

  return (
    <Card>
      <div className="row-between" style={{ alignItems: "flex-start", gap: "1rem" }}>
        <span className="list-row" style={{ alignItems: "flex-start" }}>
          <span className="row-icon">
            <Trophy size={18} />
          </span>
          <span className="stack compact" style={{ gap: "0.2rem" }}>
            <h3 style={{ margin: 0 }}>{challenge.title}</h3>
            {challenge.brief ? (
              <p className="muted" style={{ margin: 0, lineHeight: 1.5 }}>
                {challenge.brief}
              </p>
            ) : null}
          </span>
        </span>
        {challenge.difficulty ? <span className="chip">{challenge.difficulty}</span> : null}
      </div>

      <div className="trust-strip" style={{ marginTop: "0.7rem" }}>
        {challenge.durationMinutes ? (
          <span>
            <Clock size={15} /> {challenge.durationMinutes} min aprox.
          </span>
        ) : null}
        {challenge.skills?.slice(0, 4).map((skill) => (
          <span key={skill} className="chip">
            {skillLabel(skill)}
          </span>
        ))}
      </div>

      <div className="pitch-controls" style={{ marginTop: "1rem" }}>
        <button type="button" className="btn btn-primary" onClick={() => setOpen((value) => !value)}>
          {open ? "Ocultar reto" : "Ver el reto"}
        </button>
        <button
          type="button"
          className={practiced ? "btn btn-ghost" : "btn btn-secondary"}
          onClick={onTogglePracticed}
          style={practiced ? { color: "var(--color-teal)" } : undefined}
        >
          {practiced ? (
            <>
              <Check size={16} /> Practicado
            </>
          ) : (
            "Marcar como practicado"
          )}
        </button>
      </div>

      {open ? (
        <div
          className="stack"
          style={{ marginTop: "1rem", borderTop: "1px solid var(--color-border)", paddingTop: "1rem" }}
        >
          {dataset.length > 0 ? (
            <div className="stack compact">
              <span className="eyebrow">Datos del caso</span>
              <DatasetTable rows={dataset} />
            </div>
          ) : null}

          {tasks.length > 0 ? (
            <div className="stack compact">
              <span className="list-row" style={{ gap: "0.4rem" }}>
                <ListChecks size={16} /> <strong>Lo que debes resolver</strong>
              </span>
              <ol className="stack compact" style={{ margin: 0, paddingLeft: "1.2rem" }}>
                {tasks.map((task) => (
                  <li key={task.id} style={{ lineHeight: 1.5 }}>
                    {task.label}
                  </li>
                ))}
              </ol>
            </div>
          ) : null}

          <div
            className="stack compact"
            style={{ padding: "0.85rem 1rem", borderRadius: 12, background: "var(--color-soft, rgba(16,16,16,0.03))" }}
          >
            <span className="list-row" style={{ gap: "0.4rem" }}>
              <MessagesSquare size={16} style={{ color: "var(--color-teal)" }} /> <strong>Cómo demostrarlo en tu entrevista</strong>
            </span>
            <p className="muted" style={{ margin: 0, lineHeight: 1.55 }}>
              Resuélvelo en tu computadora (Excel, SQL, un documento o el programa que uses) y prepárate para explicar
              tu razonamiento, qué encontraste y por qué. Eso es lo que convence a un reclutador de que sí sabes.
            </p>
          </div>
        </div>
      ) : null}
    </Card>
  );
}

export function StudentChallengesPage() {
  const dashboard = useApi(() => getStudentDashboard(), []);
  const roleId = dashboard.data?.goal.roleId ?? null;
  const roleName = dashboard.data?.goal.roleName ?? null;
  const challenges = useApi(() => getChallenges(roleId ?? undefined), [roleId]);

  const [practiced, setPracticed] = useState<Set<string>>(() => loadPracticed());

  function togglePracticed(id: string) {
    setPracticed((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      localStorage.setItem(PRACTICED_KEY, JSON.stringify([...next]));
      return next;
    });
  }

  const list = challenges.data?.challenges ?? [];
  const done = list.filter((challenge) => practiced.has(challenge.id)).length;

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Retos de práctica</p>
        <h2>Ejercicios para llegar listo a la entrevista</h2>
        <p className="muted">
          Casos cortos {roleName ? <>orientados a <strong>{roleName}</strong></> : "de tu rol objetivo"}. Resuélvelos en
          tu computadora y practica cómo explicarlos: es la mejor forma de demostrar que sabes hacer el trabajo.
        </p>
      </section>

      <Card className="featured">
        <div className="trust-strip text-white" style={{ gap: "1.2rem" }}>
          <span className=" text-white">
            <Target size={15} /> Analiza un caso real
          </span>
          <span className=" text-white">
            <ListChecks size={15} /> Resuélvelo en tu computadora
          </span>
          <span className=" text-white">
            <MessagesSquare size={15} /> Prepárate para explicarlo
          </span>
          {list.length > 0 ? (
            <span className="text-white" style={{ marginLeft: "auto", fontWeight: 600 }}>
              {done}/{list.length} practicados
            </span>
          ) : null}
        </div>
      </Card>

      {challenges.loading || dashboard.loading ? (
        <LoadingState />
      ) : challenges.error || !challenges.data ? (
        <ErrorState />
      ) : list.length === 0 ? (
        <EmptyState title="No hay retos disponibles" description="Pronto se activarán retos para tu rol objetivo." />
      ) : (
        <div className="card-list">
          {list.map((challenge) => (
            <ChallengeCard
              key={challenge.id}
              challenge={challenge}
              practiced={practiced.has(challenge.id)}
              onTogglePracticed={() => togglePracticed(challenge.id)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
