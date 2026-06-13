import { Link } from "react-router-dom";
import { ArrowRight, Building2, GraduationCap, LineChart } from "lucide-react";

import { appRoutes } from "../../shared/config/routes";
import { Button } from "../../shared/components/Button";
import { Card } from "../../shared/components/Card";

export function LandingPage() {
  return (
    <main className="landing-page">
      <section className="hero-panel">
        <div className="brand-lockup hero-brand">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </div>
        <div className="hero-copy">
          <p className="eyebrow">Ruta de empleabilidad inteligente</p>
          <h1>De estudiante con CV a talento listo para la industria.</h1>
          <p>
            Un MVP para diagnosticar brechas, transformar evidencias en perfil profesional y conectar talento UTP con empresas.
          </p>
          <Link to={appRoutes.login}>
            <Button>
              Ingresar a la demo <ArrowRight size={18} />
            </Button>
          </Link>
        </div>
        <div className="hero-grid">
          <Card>
            <GraduationCap />
            <strong>Estudiantes</strong>
            <span>Ruta, CV, retos y postulacion preparada.</span>
          </Card>
          <Card>
            <Building2 />
            <strong>Empresas</strong>
            <span>Candidatos con match explicado y evidencia.</span>
          </Card>
          <Card>
            <LineChart />
            <strong>UTP</strong>
            <span>Brechas e impacto de empleabilidad por carrera.</span>
          </Card>
        </div>
      </section>
    </main>
  );
}
