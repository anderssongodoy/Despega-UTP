import { Card } from "../../../shared/components/Card";
import { MetricCard } from "../../../shared/components/MetricCard";

export function AdvisorImpactPage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Asesor UTP</p>
        <h2>Impacto institucional de empleabilidad</h2>
      </section>
      <div className="metrics-grid">
        <MetricCard label="Estudiantes" value="8" helper="activos demo" />
        <MetricCard label="Evidencias" value="8" helper="generadas" />
        <MetricCard label="Empresas" value="5" helper="con vacantes" />
        <MetricCard label="Vacantes" value="11" helper="activas" />
      </div>
      <Card>
        <h3>Conectar con `/api/advisor/impact`</h3>
      </Card>
    </div>
  );
}
