import { createBrowserRouter, Navigate } from "react-router-dom";

import { AppShell } from "./shared/layouts/AppShell";
import { LandingPage } from "./features/public/LandingPage";
import { LoginPage } from "./features/auth/LoginPage";
import { OnboardingPage } from "./features/student/pages/OnboardingPage";
import { PortfolioPage } from "./features/student/pages/PortfolioPage";
import { StudentHomePage } from "./features/student/pages/StudentHomePage";
import { StudentRoutePage } from "./features/student/pages/StudentRoutePage";
import { StudentProfilePage } from "./features/student/pages/StudentProfilePage";
import { StudentOpportunitiesPage } from "./features/student/pages/StudentOpportunitiesPage";
import { StudentChallengesPage } from "./features/student/pages/StudentChallengesPage";
import { CompanyDashboardPage } from "./features/company/pages/CompanyDashboardPage";
import { CompanyTalentPage } from "./features/company/pages/CompanyTalentPage";
import { AdvisorImpactPage } from "./features/advisor/pages/AdvisorImpactPage";
import { appRoutes } from "./shared/config/routes";

export const router = createBrowserRouter([
  { path: appRoutes.landing, element: <LandingPage /> },
  { path: appRoutes.login, element: <LoginPage /> },
  { path: appRoutes.onboarding, element: <OnboardingPage /> },
  { path: appRoutes.portfolio, element: <PortfolioPage /> },
  {
    element: <AppShell />,
    children: [
      { path: appRoutes.studentHome, element: <StudentHomePage /> },
      { path: appRoutes.studentRoute, element: <StudentRoutePage /> },
      { path: appRoutes.studentProfile, element: <StudentProfilePage /> },
      { path: appRoutes.studentOpportunities, element: <StudentOpportunitiesPage /> },
      { path: appRoutes.studentChallenges, element: <StudentChallengesPage /> },
      { path: appRoutes.companyDashboard, element: <CompanyDashboardPage /> },
      { path: appRoutes.companyTalent, element: <CompanyTalentPage /> },
      { path: appRoutes.advisorImpact, element: <AdvisorImpactPage /> },
    ],
  },
  { path: "*", element: <Navigate to={appRoutes.login} replace /> },
]);
