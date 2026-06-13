import { Briefcase, Building2, ChartNoAxesCombined, Home, LogOut, Route, Trophy, UserRound } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { NavLink, Navigate, Outlet, useLocation, useNavigate } from "react-router-dom";

import { appRoutes } from "../config/routes";
import type { UserRole } from "../api/types";
import { clearSession, useSession } from "../auth/authStore";

type NavItem = {
  to: string;
  label: string;
  icon: LucideIcon;
};

type NavGroup = {
  title: string;
  role: UserRole;
  items: NavItem[];
};

const navGroups: NavGroup[] = [
  {
    title: "Estudiante",
    role: "student",
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
    role: "company",
    items: [
      { to: appRoutes.companyDashboard, label: "Dashboard empresa", icon: Building2 },
      { to: appRoutes.companyTalent, label: "Talento recomendado", icon: UserRound },
    ],
  },
  {
    title: "Asesor",
    role: "advisor",
    items: [{ to: appRoutes.advisorImpact, label: "Impacto UTP", icon: ChartNoAxesCombined }],
  },
];

const roleLabel: Record<UserRole, string> = {
  student: "Estudiante",
  company: "Empresa",
  advisor: "Asesor UTP",
};

export function AppShell() {
  const session = useSession();
  const location = useLocation();
  const navigate = useNavigate();

  if (!session) {
    return <Navigate to={appRoutes.login} replace />;
  }

  const visibleGroups = navGroups.filter((group) => group.role === session.user.role);
  const activeItem = visibleGroups.flatMap((group) => group.items).find((item) => item.to === location.pathname);

  function logout() {
    clearSession();
    navigate(appRoutes.login);
  }

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
          {visibleGroups.map((group) => (
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

        <div className="sidebar-footer">
          <span className="utp-logo">{session.user.name.charAt(0).toUpperCase()}</span>
          <div style={{ flex: 1, minWidth: 0 }}>
            <strong style={{ display: "block", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
              {session.user.name}
            </strong>
            <small style={{ display: "block", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>
              {session.user.email}
            </small>
          </div>
          <button type="button" className="icon-btn" onClick={logout} aria-label="Cerrar sesion" title="Cerrar sesion">
            <LogOut size={18} />
          </button>
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div>
            <p className="eyebrow">MVP Hackathon UTP+</p>
            <h1>{activeItem?.label ?? "Despega UTP"}</h1>
          </div>
          <span className="session-pill">{roleLabel[session.user.role]}</span>
        </header>
        <div className="page-container">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
