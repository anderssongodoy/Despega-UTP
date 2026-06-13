import { Briefcase, Building2, ChartNoAxesCombined, Home, Route, Trophy, UserRound } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { NavLink, Outlet, useLocation } from "react-router-dom";

import { appRoutes } from "../config/routes";

type NavItem = {
  to: string;
  label: string;
  icon: LucideIcon;
};

type NavGroup = {
  title: string;
  items: NavItem[];
};

const navGroups: NavGroup[] = [
  {
    title: "Estudiante",
    items: [
      { to: appRoutes.studentHome, label: "Inicio", icon: Home },
      { to: appRoutes.studentRoute, label: "Ruta profesional", icon: Route },
      { to: appRoutes.studentProfile, label: "Perfil profesional", icon: UserRound },
      { to: appRoutes.studentOpportunities, label: "Oportunidades", icon: Briefcase },
      { to: appRoutes.studentChallenges, label: "Retos", icon: Trophy },
    ],
  },
  {
    title: "Empresa",
    items: [
      { to: appRoutes.companyDashboard, label: "Dashboard empresa", icon: Building2 },
      { to: appRoutes.companyTalent, label: "Talento recomendado", icon: UserRound },
    ],
  },
  {
    title: "Asesor",
    items: [{ to: appRoutes.advisorImpact, label: "Impacto UTP", icon: ChartNoAxesCombined }],
  },
];

export function AppShell() {
  const location = useLocation();
  const activeItem = navGroups.flatMap((group) => group.items).find((item) => item.to === location.pathname);

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <div>
            <strong>Despega UTP</strong>
            <small>Ruta de empleabilidad</small>
          </div>
        </div>

        <nav className="side-nav" aria-label="Navegacion principal">
          {navGroups.map((group) => (
            <div key={group.title} className="nav-group">
              <p>{group.title}</p>
              {group.items.map((item) => {
                const Icon = item.icon;
                return (
                  <NavLink key={item.to} to={item.to} className={({ isActive }) => (isActive ? "active" : undefined)}>
                    <Icon size={18} />
                    <span>{item.label}</span>
                  </NavLink>
                );
              })}
            </div>
          ))}
        </nav>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div>
            <p className="eyebrow">MVP Hackathon UTP+</p>
            <h1>{activeItem?.label ?? "Despega UTP"}</h1>
          </div>
          <span className="session-pill">Demo</span>
        </header>
        <div className="page-container">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
