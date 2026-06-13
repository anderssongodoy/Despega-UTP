import { Card } from "../../../shared/components/Card";

export function StudentRoutePage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Ruta profesional</p>
        <h2>Diagnostico, brechas y plan de accion</h2>
      </section>
      <div className="tabs-mock">
        <span className="active">Meta</span>
        <span>Diagnostico</span>
        <span>Brechas</span>
        <span>Plan</span>
      </div>
      <Card>
        <h3>Plan 14 dias</h3>
        <p className="muted">Conectar con `/api/students/stu_camila/action-plan` y `/api/students/stu_camila/gaps`.</p>
      </Card>
    </div>
  );
}
