import { Award, FolderGit2 } from "lucide-react";

import { getCv, getPassport } from "../student.api";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { EmptyState } from "../../../shared/components/EmptyState";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";

/** Presentación pública del estudiante (reutilizada en el tab Portafolio y en /portfolio/:id). */
export function StudentPortfolio({ studentId }: { studentId: string }) {
  const passport = useApi(() => getPassport(studentId), [studentId]);
  const cv = useApi(() => getCv(studentId), [studentId]);

  if (passport.loading) return <LoadingState />;
  if (passport.error || !passport.data) return <ErrorState />;

  const student = passport.data.student;
  const skills = passport.data.skills ?? [];
  const evidences = passport.data.evidences ?? [];
  const name = student?.name ?? "Estudiante UTP";
  const meta = [student?.career, student?.cycle ? `${student.cycle} ciclo` : null].filter(Boolean).join(" · ");
  const maxLevel = Math.max(5, ...skills.map((skill) => skill.level));

  return (
    <div className="stack">
      <Card className="featured">
        <p className="eyebrow">Portafolio profesional · Despega UTP</p>
        <h2 style={{ margin: "0.3rem 0 0", fontSize: "1.9rem", fontWeight: 800, letterSpacing: "-0.02em" }}>{name}</h2>
        {meta ? <p style={{ margin: "0.2rem 0 0" }}>{meta}</p> : null}
        {cv.data?.summary ? <p style={{ margin: "0.7rem 0 0", lineHeight: 1.6 }}>{cv.data.summary}</p> : null}
      </Card>

      {skills.length > 0 ? (
        <Card>
          <p className="eyebrow">
            <Award size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
            Habilidades
          </p>
          <div className="stack compact" style={{ marginTop: "0.5rem" }}>
            {skills.map((skill) => (
              <div key={skill.id} className="dim-row">
                <span>{skill.name}</span>
                <span className="bar" aria-hidden="true">
                  <span className="bar-ready" style={{ width: `${Math.min(100, (skill.level / maxLevel) * 100)}%` }} />
                </span>
                <span className="dim-score">{skill.level}</span>
              </div>
            ))}
          </div>
        </Card>
      ) : null}

      <Card>
        <p className="eyebrow">
          <FolderGit2 size={14} style={{ verticalAlign: "-2px", marginRight: 6 }} />
          Logros y evidencias
        </p>
        {evidences.length === 0 ? (
          <EmptyState title="Aun sin evidencias" description="Las evidencias del estudiante apareceran aqui." />
        ) : (
          <div className="card-list" style={{ marginTop: "0.5rem" }}>
            {evidences.map((evidence) => (
              <div key={evidence.id} className="evidence-item">
                <strong>{evidence.title}</strong>
                {evidence.cv_bullet ? <p className="cv-bullet">{evidence.cv_bullet}</p> : null}
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
}
