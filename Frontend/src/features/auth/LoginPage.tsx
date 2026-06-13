import { useState } from "react";
import { useNavigate } from "react-router-dom";

import { getSession } from "./auth.api";
import { Button } from "../../shared/components/Button";
import { Card } from "../../shared/components/Card";

const demoUsers = [
  { id: "stu_camila", label: "Estudiante listo" },
  { id: "stu_nuevo", label: "Estudiante nuevo" },
  { id: "usr_recruiter_ana", label: "Empresa" },
  { id: "advisor_utp", label: "Asesor UTP" },
];

export function LoginPage() {
  const navigate = useNavigate();
  const [loadingUser, setLoadingUser] = useState<string | null>(null);
  const [error, setError] = useState("");

  async function enterAs(userId: string) {
    setLoadingUser(userId);
    setError("");
    try {
      const session = await getSession(userId);
      navigate(session.redirectTo);
    } catch {
      setError("No se pudo iniciar sesion demo. Revisa que el backend este activo.");
    } finally {
      setLoadingUser(null);
    }
  }

  return (
    <main className="auth-page">
      <Card className="auth-card">
        <span className="utp-logo">UTP</span>
        <h1>Despega UTP</h1>
        <p className="muted">Selecciona un rol demo para entrar al flujo.</p>
        <div className="stack">
          {demoUsers.map((user) => (
            <Button key={user.id} onClick={() => enterAs(user.id)} disabled={loadingUser === user.id}>
              {loadingUser === user.id ? "Ingresando..." : user.label}
            </Button>
          ))}
        </div>
        {error ? <p className="error-text">{error}</p> : null}
      </Card>
    </main>
  );
}
