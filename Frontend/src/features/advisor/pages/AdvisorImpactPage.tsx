import { useState } from "react";
import clsx from "clsx";
import { Briefcase, Target, Users } from "lucide-react";

import { getAdvisorImpact, getCriticalGapStudents } from "../advisor.api";
import type { CriticalGapStudent } from "../../../shared/api/types";
import { severityEs } from "../../../shared/config/labels";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";
import { StatusBadge } from "../../../shared/components/StatusBadge";

// Skills críticas más relevantes (IDs reales del catálogo del backend).
const CRITICAL_SKILLS = [
  { id: "sk_sql", name: "SQL" },
  { id: "sk_english", name: "Ingles" },
  { id: "sk_powerbi", name: "Power BI" },
  { id: "sk_python", name: "Python" },
  { id: "sk_excel", name: "Excel" },
  { id: "sk_communication", name: "Comunicacion" },
  { id: "sk_problem_solving", name: "Resolucion de problemas" },
  { id: "sk_business_intelligence", name: "Inteligencia de Negocios" },
];

function groupByStudent(rows: CriticalGapStudent[]): CriticalGapStudent[][] {
  const groups = new Map<string, CriticalGapStudent[]>();
  for (const row of rows) {
    const list = groups.get(row.studentId) ?? [];
    list.push(row);
    groups.set(row.studentId, list);
  }
  return [...groups.values()];
}

function AffectedStudents({ skillId }: { skillId: string }) {
  const affected = useApi(() => getCriticalGapStudents(skillId), [skillId]);

  if (affected.loading) return <LoadingState label="Buscando estudiantes afectados…" />;
  if (affected.error || !affected.data) {
    return (
      <ErrorState
        title="No se pudo cargar la brecha"
        description="Si el backend responde 500, falta correr el seed de critical gaps en la base (ver instrucciones)."
      />
    );
  }

  const data = affected.data;
  if (data.students.length === 0) {
    return <EmptyState title={`Sin estudiantes con brecha en ${data.skillName}`} description="Nadie tiene esta brecha abierta ahora mismo." />;
  }

  return (
    <div className="stack compact" style={{ marginTop: "0.75rem" }}>
      <span className="chip">
        {data.totalAffected} brecha(s) abierta(s) en {data.skillName}
      </span>
      <div className="card-list">
        {groupByStudent(data.students).map((contexts) => {
          const student = contexts[0];
          return (
            <div key={student.studentId} className="evidence-item">
              <div className="row-between">
                <span className="list-row">
                  <span className="row-icon">
                    <Users size={18} />
                  </span>
                  <span className="stack compact" style={{ gap: "0.05rem" }}>
                    <strong>{student.fullName}</strong>
                    <small className="muted">
                      {student.career}
                      {student.cycle ? ` · ${student.cycle} ciclo` : ""} · {student.email}
                    </small>
                  </span>
                </span>
                <StatusBadge status={student.severity}>{severityEs(student.severity)}</StatusBadge>
              </div>
              <div className="trust-strip" style={{ marginTop: "0.4rem" }}>
                {contexts.map((context, index) => (
                  <span key={index} className="chip">
                    {context.source === "role"
                      ? `Rol: ${context.roleId ?? "-"}`
                      : `Vacante: ${context.jobId ?? "-"}`}
                    {" · "}
                    nivel {context.currentLevel ?? 0}/{context.requiredLevel ?? 0}
                  </span>
                ))}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export function AdvisorImpactPage() {
  const impact = useApi(() => getAdvisorImpact(), []);
  const [selectedSkill, setSelectedSkill] = useState<{ id: string; name: string } | null>(null);

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Asesor UTP</p>
        <h2>Impacto institucional de empleabilidad</h2>
        <p className="muted">Brechas por carrera, evidencias generadas y conexion con empresas.</p>
      </section>

      {impact.loading ? (
        <LoadingState />
      ) : impact.error || !impact.data ? (
        <ErrorState />
      ) : (
        (() => {
          const data = impact.data;
          const maxCareer = Math.max(1, ...data.byCareer.map((row) => row.students));
          return (
            <>
              <div className="metrics-grid">
                <MetricCard label="Estudiantes" value={data.totals.students} helper="activos" />
                <MetricCard label="Evidencias" value={data.totals.evidences} helper="generadas" />
                <MetricCard label="Empresas" value={data.totals.companies} helper="con vacantes" />
                <MetricCard label="Vacantes" value={data.totals.activeJobs} helper="activas" />
              </div>

              <div className="content-grid">
                <Card>
                  <h3>Estudiantes por carrera</h3>
                  <div className="stack" style={{ marginTop: "1rem" }}>
                    {data.byCareer.map((row) => (
                      <div key={row.career} className="dim-row">
                        <span>{row.career}</span>
                        <span className="bar" aria-hidden="true">
                          <span style={{ width: `${(row.students / maxCareer) * 100}%` }} />
                        </span>
                        <span className="dim-score">{row.students}</span>
                      </div>
                    ))}
                  </div>
                </Card>

                <Card>
                  <p className="eyebrow">
                    <Briefcase size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
                    Roles mas buscados
                  </p>
                  <div className="stack compact" style={{ marginTop: "0.5rem" }}>
                    {data.topRoles.map((role) => (
                      <div key={role.role} className="row-between">
                        <span>{role.role}</span>
                        <span className="chip">{role.students}</span>
                      </div>
                    ))}
                  </div>
                </Card>
              </div>

              {/* Brechas más comunes — clic para ver estudiantes afectados */}
              <Card>
                <p className="eyebrow">
                  <Target size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
                  Brechas criticas — clic para ver estudiantes
                </p>
                <div className="chip-group" style={{ marginTop: "0.5rem" }}>
                  {CRITICAL_SKILLS.map((skill) => (
                    <button
                      key={skill.id}
                      type="button"
                      className={clsx("chip-toggle", selectedSkill?.id === skill.id && "selected")}
                      onClick={() =>
                        setSelectedSkill((current) => (current?.id === skill.id ? null : { id: skill.id, name: skill.name }))
                      }
                    >
                      {skill.name}
                    </button>
                  ))}
                </div>

                {selectedSkill ? <AffectedStudents skillId={selectedSkill.id} /> : (
                  <p className="muted" style={{ marginTop: "0.75rem" }}>
                    Selecciona una brecha para ver que estudiantes la tienen abierta.
                  </p>
                )}
              </Card>
            </>
          );
        })()
      )}
    </div>
  );
}
