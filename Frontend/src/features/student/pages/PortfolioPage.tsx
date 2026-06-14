import { Link, useParams } from "react-router-dom";

import { StudentPortfolio } from "../components/StudentPortfolio";
import { appRoutes } from "../../../shared/config/routes";

export function PortfolioPage() {
  const { studentId } = useParams<{ studentId: string }>();

  return (
    <main className="landing-page">
      <nav className="landing-nav">
        <Link to={appRoutes.landing} className="brand-lockup">
          <span className="utp-logo">UTP</span>
          <strong>Despega UTP</strong>
        </Link>
      </nav>
      <div style={{ width: "min(880px, 100%)", margin: "0 auto" }}>
        <StudentPortfolio studentId={studentId ?? ""} />
      </div>
    </main>
  );
}
