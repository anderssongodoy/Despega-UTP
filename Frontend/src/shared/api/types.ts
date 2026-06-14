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
  modality?: string;
  location?: string;
  hours?: string;
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

export type DiagnosisDimension = { name: string; score: number; status: string };

export type Diagnosis = {
  studentId: string;
  role: { roleId: string; roleName: string };
  readinessScore: number;
  dimensions: DiagnosisDimension[];
  message: string;
};

export type GapItem = {
  skillId: string;
  skillName: string;
  currentLevel: number;
  requiredLevel: number;
  severity: GapSeverity;
  recommendedAction: string;
};

export type GapsResponse = {
  studentId: string;
  jobId: string;
  matchScore: number;
  gaps: GapItem[];
  canApplyToday: boolean;
  applyAdvice: string;
};

export type ActionPlanDay = {
  day: number;
  title: string;
  type: string;
  minutes: number;
  resourceId: string | null;
};

export type ActionPlan = { studentId: string; days: ActionPlanDay[] };

export type Evidence = {
  id: string;
  title: string;
  type: string;
  context?: string;
  actions?: string;
  result?: string;
  cv_bullet?: string;
  star_story?: string;
  source?: string;
};

export type EvidencesResponse = { evidences: Evidence[] };

export type CvResponse = {
  studentId: string;
  roleId: string;
  summary: string;
  bullets: string[];
};

export type InterviewKit = {
  studentId: string;
  jobId: string;
  pitch: string;
  questions: string[];
  risksToAddress: Array<{ skillId?: string; skillName: string; severity?: GapSeverity; message?: string }>;
};

export type ChallengeQuestion = { id: string; type: string; label: string };

export type Challenge = {
  id: string;
  title: string;
  difficulty?: string;
  durationMinutes?: number;
  skills?: string[];
  roleId?: string;
  brief?: string;
  datasetPreview?: Array<Record<string, unknown>>;
  questions?: ChallengeQuestion[];
};

export type ChallengesResponse = { challenges: Challenge[] };

export type CompanyJob = {
  jobId: string;
  title: string;
  roleId?: string;
  modality?: string;
  location?: string;
  hours?: string;
  status?: string;
  recommendedCandidates?: number;
  averageMatch?: number;
};

export type Candidate = {
  student_id: string;
  name: string;
  career?: string;
  cycle?: number;
  modality?: string;
  matchScore: number;
  status: MatchStatus;
  gaps?: SkillGap[];
  strengths?: string[];
};

export type CompanyDashboard = {
  company: { id: string; name: string; sector?: string };
  activeJobs: number;
  recommendedCandidates: number;
  averageMatch: number;
  strongMatches: number;
  topGaps: string[];
  jobs: CompanyJob[];
  candidatePreview: Candidate[];
};

export type CandidatesResponse = { jobId: string; candidates: Candidate[] };

export type CandidateDetail = {
  candidate: {
    id: string;
    name: string;
    email?: string;
    career?: string;
    cycle?: number;
    modality?: string;
    cv_status?: string;
  };
  jobId: string;
  match: { matchScore: number; status: MatchStatus; gaps?: SkillGap[]; strengths?: string[] };
  evidences: Array<{ id: string; title: string; cv_bullet?: string }>;
};

export type AdvisorImpact = {
  totals: { students: number; evidences: number; applications: number; companies: number; activeJobs: number };
  byCareer: Array<{ career: string; students: number }>;
  topRoles: Array<{ role: string; students: number }>;
  seedMetrics?: unknown;
  topGaps: string[];
};

export type ApplicationKit = {
  studentId: string;
  job: { id: string; title: string; description?: string; company_name?: string };
  match: { matchScore: number; status: MatchStatus; gaps?: SkillGap[]; strengths?: string[] };
  cvTips: string[];
  coverMessage: string;
  nextAction: string;
};

export type Application = {
  id: string;
  status: string;
  notes?: string;
  created_at?: string;
  job_id: string;
  title: string;
  company_name?: string;
};

export type ApplicationsResponse = { applications: Application[] };

export type Passport = {
  student?: {
    id: string;
    name?: string;
    email?: string;
    career?: string;
    cycle?: number;
    modality?: string;
    [key: string]: unknown;
  };
  skills: Array<{ id: string; name: string; level: number }>;
  evidences: Array<{ id: string; title: string; cv_bullet?: string }>;
};

export type ChallengeDetail = Challenge & {
  datasetPreview?: Array<Record<string, unknown>>;
  questions?: Array<{ id: string; type: string; label: string }>;
};

export type CompanyJobsResponse = { jobs: CompanyJob[] };

export type RoleSkillReq = { skillId: string; requiredLevel?: number; importance?: string };

export type Role = {
  id: string;
  name: string;
  family?: string;
  description?: string;
  recommendedCycleMin?: number;
  skills?: RoleSkillReq[];
};

export type RolesResponse = { roles: Role[] };

export type OnboardingResult = {
  studentId: string;
  onboardingCompleted: boolean;
  createdEvidence?: { id: string; title: string; cvBullet: string };
  goal: { roleId: string; roleName: string };
  initialDiagnosis: { readinessScore: number; status: string; criticalGaps: string[] };
  redirectTo: string;
};

export type AuthUser = { id: string; name: string; email: string; role: UserRole };

export type UsersResponse = { users: AuthUser[]; demoPassword: string };

export type CriticalGapStudent = {
  studentId: string;
  fullName: string;
  email: string;
  career?: string;
  cycle?: number;
  roleId?: string | null;
  jobId?: string | null;
  skillId: string;
  skillName: string;
  severity: string;
  status: string;
  currentLevel?: number;
  requiredLevel?: number;
  source: string;
};

export type CriticalGapStudentsResponse = {
  skillId: string;
  skillName: string;
  status: string;
  source: string;
  totalAffected: number;
  students: CriticalGapStudent[];
};

export type CvEducacion = {
  institucion?: string | null;
  titulo?: string | null;
  estado?: string | null;
  ano?: string | null;
};

export type CvExperiencia = {
  empresa?: string | null;
  cargo?: string | null;
  fecha_inicio?: string | null;
  fecha_fin?: string | null;
  ubicacion?: string | null;
  responsabilidades?: string[];
  tecnologias?: string[];
};

export type CvIdioma = { idioma?: string | null; nivel?: string | null };

export type CvAnalysis = {
  nombre?: string | null;
  apellido?: string | null;
  edad?: string | null;
  correo?: string | null;
  telefono?: string | null;
  linkedin?: string | null;
  github?: string | null;
  direccion?: string | null;
  profesion?: string | null;
  resumen?: string | null;
  educacion?: CvEducacion[];
  experiencia?: CvExperiencia[];
  certificaciones?: string[];
  idiomas?: CvIdioma[];
  skills_tecnicas?: string[];
  skills_blandas?: string[];
  fortalezas?: string[];
  faltantes?: string[];
  recomendaciones?: string[];
  score?: number;
  ats_score?: number;
  error?: string;
};

export type CvAnalyzeResponse = { success: boolean; data: CvAnalysis };

export type AudioDimension = { puntaje?: number; observacion?: string };

export type PitchStructure = {
  presentacion?: boolean;
  propuesta_valor?: boolean;
  problema_o_necesidad?: boolean;
  solucion_o_aporte?: boolean;
  beneficios?: boolean;
  por_que_tu?: boolean;
  llamado_a_accion?: boolean;
};

export type PitchAnalysis = {
  resumen_general?: string;
  estructura_pitch?: PitchStructure;
  evaluacion_discurso?: {
    claridad?: AudioDimension;
    estructura?: AudioDimension;
    vocabulario?: AudioDimension;
    confianza?: AudioDimension;
    fluidez?: AudioDimension;
    puntaje_total?: number;
  };
  palabras_clave_tecnicas?: string[];
  fortalezas_comunicacion?: string[];
  areas_de_mejora?: string[];
  recomendaciones?: string[];
  apto_para_entrevista?: boolean;
  nivel_comunicacion?: string;
};

export type PitchAnalyzeResponse = {
  success: boolean;
  data: {
    transcripcion: { transcripcion_completa: string; segmentos: unknown[]; duracion_segundos: number };
    analisis: PitchAnalysis;
  };
};
