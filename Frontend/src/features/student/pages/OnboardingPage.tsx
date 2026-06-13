import { useNavigate } from "react-router-dom";

import { completeOnboarding } from "../student.api";
import { appRoutes } from "../../../routes";
import { Button } from "../../../shared/components/Button";
import { Card } from "../../../shared/components/Card";

export function OnboardingPage() {
  const navigate = useNavigate();

  async function submitDemoOnboarding() {
    await completeOnboarding("stu_nuevo", {
      academicProfile: {
        career: "Ingenieria de Sistemas e Informatica",
        cycle: 8,
        campus: "Lima Centro",
        modality: "Semipresencial",
      },
      employmentGoal: {
        targetRoleId: "role_data_intern",
        targetRoleName: "Practicante de Analisis de Datos",
        availability: "Practicas preprofesionales - 30h",
        preferredWorkMode: "Hibrido",
        applicationTimeframe: "En las proximas 2 semanas",
      },
      initialEvidence: {
        type: "academic_project",
        title: "Dashboard academico de ventas",
        context: "Proyecto de curso",
        actions: "Limpie datos y cree un dashboard en Power BI",
        result: "Identifique productos con mayor margen",
        skills: ["sk_excel", "sk_powerbi", "sk_communication"],
      },
      selfAssessment: {
        knownSkills: ["sk_excel", "sk_powerbi", "sk_communication"],
        perceivedGaps: ["sk_sql", "sk_english"],
        cvStatus: "incomplete",
        linkedinUrl: "",
      },
    });
    navigate(appRoutes.studentHome);
  }

  return (
    <main className="auth-page">
      <Card className="auth-card wide">
        <p className="eyebrow">Primera vez</p>
        <h1>Onboarding estudiante</h1>
        <p className="muted">
          Esta pantalla luego tendra pasos para perfil academico, meta laboral, evidencia inicial y autoevaluacion.
        </p>
        <div className="onboarding-steps">
          <span>1. Perfil</span>
          <span>2. Meta</span>
          <span>3. Evidencia</span>
          <span>4. Autoevaluacion</span>
        </div>
        <Button onClick={submitDemoOnboarding}>Completar onboarding demo</Button>
      </Card>
    </main>
  );
}
