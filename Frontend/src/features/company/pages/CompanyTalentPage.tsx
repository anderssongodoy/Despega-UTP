import { Card } from "../../../shared/components/Card";

export function CompanyTalentPage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Talento recomendado</p>
        <h2>Candidatos rankeados con evidencia</h2>
      </section>
      <Card>
        <h3>Camila Torres - 74%</h3>
        <p className="muted">Conectar con candidatos por vacante y detalle de candidato.</p>
      </Card>
    </div>
  );
}
