import { Card } from "../../../shared/components/Card";

export function StudentChallengesPage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Retos</p>
        <h2>Micro-retos para generar evidencia</h2>
      </section>
      <Card>
        <h3>Insight rapido de ventas</h3>
        <p className="muted">Conectar con `/api/challenges?roleId=role_data_intern` y submit.</p>
      </Card>
    </div>
  );
}
