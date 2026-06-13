import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowRight } from "lucide-react";

import { completeOnboarding, getRoles } from "../student.api";
import { appRoutes } from "../../../shared/config/routes";
import { getCurrentUserId } from "../../../shared/auth/authStore";
import { useApi } from "../../../shared/api/useApi";
import { Button } from "../../../shared/components/Button";
import { Card } from "../../../shared/components/Card";

const fallbackRoles = [{ id: "role_data_intern", name: "Practicante de Analisis de Datos" }];

export function OnboardingPage() {
  const navigate = useNavigate();
  const roles = useApi(() => getRoles(), []);
  const [roleId, setRoleId] = useState("role_data_intern");
  const [saving, setSaving] = useState(false);

  const roleOptions = roles.data?.roles?.length ? roles.data.roles : fallbackRoles;

  async function submitDemoOnboarding() {
    const selected = roleOptions.find((role) => role.id === roleId);
    setSaving(true);
    try {
      await completeOnboarding(getCurrentUserId(), {
        academicProfile: {
          career: "Ingenieria de Sistemas e Informatica",
          cycle: 8,
          campus: "Lima Centro",
          modality: "Semipresencial",
        },
        employmentGoal: {
          targetRoleId: roleId,
          targetRoleName: selected?.name ?? "Practicante de Analisis de Datos",
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
    } finally {
      setSaving(false);
    }
  }

  return (
    <main className="auth-page">
      <Card className="auth-card wide">
        <div className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </div>
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

        <div className="stack compact">
          <label className="eyebrow" htmlFor="role-select">
            Meta laboral
          </label>
          <select
            id="role-select"
            className="field"
            value={roleId}
            onChange={(event) => setRoleId(event.target.value)}
            disabled={roles.loading}
          >
            {roleOptions.map((role) => (
              <option key={role.id} value={role.id}>
                {role.name}
              </option>
            ))}
          </select>
        </div>

        <Button onClick={submitDemoOnboarding} disabled={saving}>
          {saving ? "Guardando…" : "Completar onboarding demo"} <ArrowRight size={18} />
        </Button>
      </Card>
    </main>
  );
}
