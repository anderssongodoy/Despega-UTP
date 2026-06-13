export type UserRole = "student" | "company" | "advisor";
export type MatchStatus = "ready" | "viable" | "aspirational" | "not_recommended";
export type GapSeverity = "critical" | "partial";

export type SessionResponse = {
  user: {
    id: string;
    name: string;
    email: string;
    role: UserRole;
  };
  companyId?: string;
  authProvider: "microsoft" | "credentials";
  requiresOnboarding: boolean;
  redirectTo: string;
};

export type SkillGap = {
  skillId?: string;
  skillName: string;
  currentLevel?: number;
  requiredLevel?: number;
  severity: GapSeverity;
  message: string;
};

export type JobMatch = {
  job_id?: string;
  jobId?: string;
  title: string;
  company_name?: string;
  companyName?: string;
  matchScore: number;
  status: MatchStatus;
  gaps?: SkillGap[];
  strengths?: string[];
};

export type StudentDashboard = {
  student: {
    id: string;
    name: string;
    career: string;
    cycle: number;
    modality: string;
  };
  goal: {
    roleId: string | null;
    roleName: string | null;
    readinessScore: number;
    status: MatchStatus;
  };
  nextBestAction: {
    title: string;
    description: string;
    targetPage: string;
  };
  criticalGaps: SkillGap[];
  recommendedJobs: JobMatch[];
  recommendedResources: Array<{ id?: string; resourceId?: string; name: string; reason?: string }>;
  progress: {
    evidences: number;
    challengesCompleted: number;
    applications: number;
    interviewPractice: number;
  };
};
