import { useState } from "react";
import { useNavigate } from "react-router-dom";
import clsx from "clsx";
import {
  AlertCircle,
  Building2,
  CheckCircle2,
  GraduationCap,
  LineChart,
  LogIn,
  Sparkles,
  UserPlus,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

import { getUsers, login, register } from "./auth.api";
import type { AuthUser, UserRole } from "../../shared/api/types";
import { setSession } from "../../shared/auth/authStore";
import { useApi } from "../../shared/api/useApi";

const roleIcon: Record<UserRole, LucideIcon> = {
  student: GraduationCap,
  company: Building2,
  advisor: LineChart,
};

const roleLabel: Record<UserRole, string> = {
  student: "Estudiantes",
  company: "Empresas",
  advisor: "Asesor",
};

function errorMessage(error: unknown, fallback: string): string {
  if (error && typeof error === "object" && "payload" in error) {
    const payload = (error as { payload?: { detail?: string } }).payload;
    if (payload?.detail) return payload.detail;
  }
  return fallback;
}

export function LoginPage() {
  const navigate = useNavigate();
  const users = useApi(() => getUsers(), []);

  const [mode, setMode] = useState<"login" | "register">("login");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState<UserRole>("student");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  async function doLogin(emailValue: string, passwordValue: string) {
    setBusy(true);
    setError("");
    try {
      const session = await login(emailValue, passwordValue);
      setSession(session);
      navigate(session.redirectTo);
    } catch (err) {
      setError(errorMessage(err, "No se pudo iniciar sesion."));
    } finally {
      setBusy(false);
    }
  }

  async function doRegister() {
    setBusy(true);
    setError("");
    try {
      const session = await register({ name, email, password, role });
      setSession(session);
      navigate(session.redirectTo);
    } catch (err) {
      setError(errorMessage(err, "No se pudo crear la cuenta."));
    } finally {
      setBusy(false);
    }
  }

  const demoPassword = users.data?.demoPassword ?? "demo123";
  const roleGroups: UserRole[] = ["student", "company", "advisor"];

  return (
    <main className="auth-page">
      <div className="auth-split">
        <aside className="auth-brand-panel">
          <div className="brand-lockup">
            <span className="utp-logo">UTP</span>
            <strong>Despega UTP</strong>
          </div>
          <div className="stack">
            <h2>Tu ruta de empleabilidad, en un solo lugar.</h2>
            <ul className="panel-bullets">
              <li>
                <CheckCircle2 size={18} /> Estudiantes, empresas y UTP en una plataforma
              </li>
              <li>
                <CheckCircle2 size={18} /> Match explicado con evidencia
              </li>
              <li>
                <CheckCircle2 size={18} /> Crea tu cuenta o entra con una demo
              </li>
            </ul>
          </div>
          <p style={{ margin: 0, opacity: 0.82, fontWeight: 600 }}>Demo MVP · UTP</p>
        </aside>

        <section className="auth-main">
          <div className="tabs" role="tablist" aria-label="Acceso">
            <button
              type="button"
              role="tab"
              aria-selected={mode === "login"}
              className={clsx("tab", mode === "login" && "active")}
              onClick={() => {
                setMode("login");
                setError("");
              }}
            >
              Iniciar sesion
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={mode === "register"}
              className={clsx("tab", mode === "register" && "active")}
              onClick={() => {
                setMode("register");
                setError("");
              }}
            >
              Crear cuenta
            </button>
          </div>

          {mode === "login" ? (
            <form
              className="stack compact"
              onSubmit={(event) => {
                event.preventDefault();
                doLogin(email, password);
              }}
            >
              <label className="eyebrow" htmlFor="email">
                Email
              </label>
              <input
                id="email"
                type="email"
                className="field"
                placeholder="tu@correo.pe"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
              />
              <label className="eyebrow" htmlFor="password">
                Contrasena
              </label>
              <input
                id="password"
                type="password"
                className="field"
                placeholder="demo123"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                required
              />
              <button type="submit" className="btn btn-primary" disabled={busy} style={{ marginTop: "0.4rem" }}>
                <LogIn size={18} /> {busy ? "Entrando…" : "Iniciar sesion"}
              </button>
            </form>
          ) : (
            <form
              className="stack compact"
              onSubmit={(event) => {
                event.preventDefault();
                doRegister();
              }}
            >
              <label className="eyebrow" htmlFor="name">
                Nombre
              </label>
              <input
                id="name"
                className="field"
                placeholder="Tu nombre"
                value={name}
                onChange={(event) => setName(event.target.value)}
                required
              />
              <label className="eyebrow" htmlFor="reg-email">
                Email
              </label>
              <input
                id="reg-email"
                type="email"
                className="field"
                placeholder="tu@correo.pe"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                required
              />
              <label className="eyebrow" htmlFor="reg-password">
                Contrasena
              </label>
              <input
                id="reg-password"
                type="password"
                className="field"
                placeholder="Crea una contrasena"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
                required
              />
              <label className="eyebrow" htmlFor="role">
                Rol
              </label>
              <select id="role" className="field" value={role} onChange={(event) => setRole(event.target.value as UserRole)}>
                <option value="student">Estudiante</option>
                <option value="company">Empresa</option>
                <option value="advisor">Asesor UTP</option>
              </select>
              <button type="submit" className="btn btn-primary" disabled={busy} style={{ marginTop: "0.4rem" }}>
                <UserPlus size={18} /> {busy ? "Creando…" : "Crear cuenta"}
              </button>
            </form>
          )}

          {error ? (
            <p className="error-text" role="alert">
              <AlertCircle size={16} /> {error}
            </p>
          ) : null}

          {mode === "login" && users.data ? (
            <div className="stack compact">
              <span className="chip">
                <Sparkles size={12} style={{ marginRight: 4 }} /> Cuentas demo · contrasena {demoPassword}
              </span>
              <div className="role-grid" style={{ maxHeight: 220, overflowY: "auto" }}>
                {roleGroups.flatMap((groupRole) => {
                  const groupUsers = users.data!.users.filter((user) => user.role === groupRole);
                  if (groupUsers.length === 0) return [];
                  const Icon = roleIcon[groupRole];
                  return [
                    <p key={`label-${groupRole}`} className="eyebrow" style={{ margin: "0.4rem 0 0" }}>
                      {roleLabel[groupRole]}
                    </p>,
                    ...groupUsers.map((user: AuthUser) => (
                      <button
                        key={user.id}
                        type="button"
                        className="role-card"
                        onClick={() => doLogin(user.email, demoPassword)}
                        disabled={busy}
                      >
                        <span className="role-icon">
                          <Icon size={18} />
                        </span>
                        <span className="role-text">
                          <strong>{user.name}</strong>
                          <small>{user.email}</small>
                        </span>
                      </button>
                    )),
                  ];
                })}
              </div>
            </div>
          ) : null}
        </section>
      </div>
    </main>
  );
}
