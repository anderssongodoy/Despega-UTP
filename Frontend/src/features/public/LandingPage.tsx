import { Link } from "react-router-dom";
import {
  ArrowRight,
  Building2,
  GraduationCap,
  LineChart,
  ShieldCheck,
  Sparkles,
} from "lucide-react";

import { appRoutes } from "../../shared/config/routes";

const features = [
  {
    icon: GraduationCap,
    title: "Estudiantes",
    body: "Ruta personalizada, CV vivo, retos y postulación lista para enviar.",
  },
  {
    icon: Building2,
    title: "Empresas",
    body: "Candidatos con match explicado y evidencia verificable, sin ruido.",
  },
  {
    icon: LineChart,
    title: "UTP",
    body: "Brechas e impacto de empleabilidad medibles por carrera y cohorte.",
  },
];

export function LandingPage() {
  return (
    <main className="landing-page">
      <nav className="landing-nav">
        <div className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </div>
        <Link to={appRoutes.login} className="btn btn-secondary">
          Ingresar
        </Link>
      </nav>

      <section className="hero">
        <div className="hero-copy">
          <span className="hero-badge">
            <Sparkles size={14} /> Ruta de empleabilidad inteligente
          </span>
          <h1 className="hero-title">
            De estudiante con CV a{" "}
            <span className="accent">talento listo para la industria.</span>
          </h1>
          <p className="hero-lead">
            Diagnostica brechas, transforma evidencias en perfil profesional y
            conecta el talento UTP con empresas — todo en un solo flujo.
          </p>
          <div className="hero-actions">
            <Link to={appRoutes.login} className="btn btn-primary">
              Ingresar a la demo <ArrowRight size={18} />
            </Link>
            <a href="#roles" className="btn btn-ghost">
              Ver cómo funciona
            </a>
          </div>
          <div className="trust-strip">
            <span>
              <ShieldCheck size={16} /> Match explicado con evidencia
            </span>
            <span>
              <LineChart size={16} /> Impacto medible por carrera
            </span>
          </div>
        </div>

        <div className="feature-cards" id="roles">
          {features.map(({ icon: Icon, title, body }) => (
            <article className="feature-card" key={title}>
              <span className="feature-icon">
                <Icon size={22} />
              </span>
              <strong>{title}</strong>
              <span>{body}</span>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
