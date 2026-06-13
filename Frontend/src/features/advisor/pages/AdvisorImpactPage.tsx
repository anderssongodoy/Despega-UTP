import { getAdvisorImpact } from "../advisor.api";
import { useApi } from "../../../shared/api/useApi";
import { Card } from "../../../shared/components/Card";
import { ErrorState } from "../../../shared/components/ErrorState";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";

export function AdvisorImpactPage() {
  const impact = useApi(() => getAdvisorImpact(), []);

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

                <div className="stack">
                  <Card>
                    <p className="eyebrow">Roles mas buscados</p>
                    <div className="stack compact" style={{ marginTop: "0.5rem" }}>
                      {data.topRoles.map((role) => (
                        <div key={role.role} className="row-between">
                          <span>{role.role}</span>
                          <span className="chip">{role.students}</span>
                        </div>
                      ))}
                    </div>
                  </Card>

                  <Card>
                    <p className="eyebrow">Brechas mas frecuentes</p>
                    <div className="trust-strip" style={{ marginTop: "0.5rem" }}>
                      {data.topGaps.map((gap) => (
                        <span key={gap} className="chip">
                          {gap}
                        </span>
                      ))}
                    </div>
                  </Card>
                </div>
              </div>
            </>
          );
        })()
      )}
    </div>
  );
}
