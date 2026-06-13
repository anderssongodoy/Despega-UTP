import { Card } from "../../../shared/components/Card";
import { MetricCard } from "../../../shared/components/MetricCard";

export function CompanyDashboardPage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Empresa</p>
        <h2>Retail Andino</h2>
      </section>
      <div className="metrics-grid">
        <MetricCard label="Vacantes" value="3" helper="activas" />
        <MetricCard label="Candidatos" value="12" helper="recomendados" />
        <MetricCard label="Match promedio" value="71%" helper="pre-filtrado" />
        <MetricCard label="Horas ahorradas" value="24" helper="estimadas" />
      </div>
      <Card>
        <h3>Conectar con `/api/companies/comp_retail_andino/dashboard`</h3>
      </Card>
    </div>
  );
}
