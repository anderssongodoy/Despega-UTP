import { useEffect, useState } from "react";

import { getStudentDashboard } from "../student.api";
import type { StudentDashboard } from "../../../shared/api/types";
import { Card } from "../../../shared/components/Card";
import { LoadingState } from "../../../shared/components/LoadingState";
import { MetricCard } from "../../../shared/components/MetricCard";
import { StatusBadge } from "../../../shared/components/StatusBadge";

export function StudentHomePage() {
  const [dashboard, setDashboard] = useState<StudentDashboard | null>(null);

  useEffect(() => {
    getStudentDashboard().then(setDashboard).catch(() => setDashboard(null));
  }, []);

  if (!dashboard) return <LoadingState />;

  return (
    <div className="stack">
      <section className="page-heading">
        <p className="eyebrow">Estudiante</p>
        <h2>Hola, {dashboard.student.name}</h2>
        <p className="muted">{dashboard.student.career} - {dashboard.student.cycle} ciclo</p>
      </section>

      <div className="metrics-grid">
        <MetricCard label="Preparacion" value={`${dashboard.goal.readinessScore}/100`} helper={dashboard.goal.roleName ?? "Sin meta"} />
        <MetricCard label="Evidencias" value={dashboard.progress.evidences} helper="listas para CV" />
        <MetricCard label="Postulaciones" value={dashboard.progress.applications} helper="preparadas" />
        <MetricCard label="Retos" value={dashboard.progress.challengesCompleted} helper="completados" />
      </div>

      <div className="content-grid">
        <Card>
          <p className="eyebrow">Proxima accion</p>
          <h3>{dashboard.nextBestAction.title}</h3>
          <p>{dashboard.nextBestAction.description}</p>
        </Card>
        <Card>
          <p className="eyebrow">Brechas criticas</p>
          <div className="stack compact">
            {dashboard.criticalGaps.map((gap) => (
              <div key={gap.skillName} className="row-between">
                <span>{gap.skillName}</span>
                <StatusBadge status={gap.severity}>{gap.severity}</StatusBadge>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
