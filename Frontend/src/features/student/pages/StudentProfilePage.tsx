import { Card } from "../../../shared/components/Card";

export function StudentProfilePage() {
  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Perfil profesional</p>
        <h2>Evidencias, CV, pasaporte y entrevista</h2>
      </section>
      <div className="content-grid">
        <Card>
          <h3>Evidencias</h3>
          <p className="muted">Conectar con evidencias y generador de bullets.</p>
        </Card>
        <Card>
          <h3>CV orientado a rol</h3>
          <p className="muted">Conectar con `/api/students/stu_camila/cv`.</p>
        </Card>
      </div>
    </div>
  );
}
