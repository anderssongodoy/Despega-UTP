import { Award, FolderGit2, GraduationCap, Sparkles } from "lucide-react";

import { getCv, getPassport } from "../student.api";
import { useApi } from "../../../shared/api/useApi";
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
  const skills = [...(passport.data.skills ?? [])].sort((a, b) => b.level - a.level);
  const evidences = passport.data.evidences ?? [];
  const name = student?.name ?? "Estudiante UTP";
  const initial = name.charAt(0).toUpperCase();
  const meta = [
    student?.career,
    student?.cycle ? `${student.cycle}° ciclo` : null,
    student?.modality,
  ]
    .filter(Boolean)
    .join(" · ");
  const summary = cv.data?.summary;
  const maxLevel = Math.max(5, ...skills.map((skill) => skill.level));
  const topSkill = skills[0];

  return (
    <div className="portfolio">
      {/* Portada */}
      <header className="portfolio-hero">
        <span className="portfolio-avatar">{initial}</span>
        <div className="stack compact" style={{ gap: "0.3rem", minWidth: 0 }}>
          <span className="portfolio-eyebrow">Portafolio profesional</span>
          <h1 className="portfolio-name">{name}</h1>
          {meta ? <p className="portfolio-meta">{meta}</p> : null}
          {summary ? <p className="portfolio-summary">{summary}</p> : null}
        </div>
      </header>

      {/* Métricas */}
      <div className="portfolio-stats">
        <div className="portfolio-stat">
          <strong>{skills.length}</strong>
          <span>habilidades</span>
        </div>
        <div className="portfolio-stat">
          <strong>{evidences.length}</strong>
          <span>evidencias</span>
        </div>
        {topSkill ? (
          <div className="portfolio-stat">
            <strong style={{ fontSize: "1.05rem" }}>{topSkill.name}</strong>
            <span>habilidad destacada</span>
          </div>
        ) : null}
      </div>

      {/* Habilidades */}
      {skills.length > 0 ? (
        <section className="portfolio-section">
          <h2 className="portfolio-section-title">
            <Award size={18} /> Habilidades
          </h2>
          <div className="portfolio-skills">
            {skills.map((skill) => (
              <div key={skill.id} className="portfolio-skill">
                <div className="row-between">
                  <span style={{ fontWeight: 600 }}>{skill.name}</span>
                  <span className="muted" style={{ fontSize: "0.8rem" }}>
                    {skill.level}/{maxLevel}
                  </span>
                </div>
                <span className="bar" aria-hidden="true">
                  <span className="bar-ready" style={{ width: `${Math.min(100, (skill.level / maxLevel) * 100)}%` }} />
                </span>
              </div>
            ))}
          </div>
        </section>
      ) : null}

      {/* Evidencias */}
      <section className="portfolio-section">
        <h2 className="portfolio-section-title">
          <FolderGit2 size={18} /> Logros y evidencias
        </h2>
        {evidences.length === 0 ? (
          <EmptyState title="Aún sin evidencias" description="Las evidencias del estudiante aparecerán aquí." />
        ) : (
          <div className="portfolio-evidences">
            {evidences.map((evidence) => (
              <article key={evidence.id} className="portfolio-evidence">
                <span className="portfolio-evidence-icon">
                  <Sparkles size={15} />
                </span>
                <div className="stack compact" style={{ gap: "0.25rem", minWidth: 0 }}>
                  <strong>{evidence.title}</strong>
                  {evidence.cv_bullet ? (
                    <p className="muted" style={{ margin: 0, lineHeight: 1.55 }}>
                      {evidence.cv_bullet}
                    </p>
                  ) : null}
                </div>
              </article>
            ))}
          </div>
        )}
      </section>

      <footer className="portfolio-foot">
        <GraduationCap size={15} /> Generado con Despega UTP · Ruta Laboral
      </footer>
    </div>
  );
}
