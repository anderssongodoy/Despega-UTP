-- ============================================================
-- DESPEGA UTP - SCRIPT UNICO DE DEMO PARA JUECES
-- Archivo: despega_utp_demo.sql
-- ============================================================
-- Crea TODO el esquema y carga TODOS los datos de demo.
-- Idempotente: se puede correr varias veces sin duplicar (ON CONFLICT DO NOTHING).
--
-- USO (PostgreSQL):
--   1) Crea la base:   CREATE DATABASE despega_utp;
--   2) Ejecuta este script sobre esa base:
--        psql -U postgres -d despega_utp -f despega_utp_demo.sql
--      (o desde pgAdmin: abre la base despega_utp y corre el archivo)
--
-- Password universal de demo: demo123
--
-- USUARIOS DE PRUEBA
--   Con datos (onboarding hecho):
--     - camila.torres@utp.edu.pe   (estudiante con perfil completo)
--     - andrea.salazar@utp.edu.pe, mateo.rivas@utp.edu.pe, lucia.herrera@utp.edu.pe ... (mas estudiantes)
--     - ana@retailandino.pe        (empresa)
--     - paola@talentolab.pe        (empresa)
--     - asesor@utp.edu.pe          (asesor)
--   Sin onboarding (para probar el flujo desde cero):
--     - prueba1@utp.edu.pe ... prueba5@utp.edu.pe
--   Todos con password: demo123
-- ============================================================

-- ============================================================
-- 1. ESQUEMA (TABLAS E INDICES)
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  id varchar PRIMARY KEY,
  name varchar NOT NULL,
  email varchar NOT NULL UNIQUE,
  role varchar NOT NULL CHECK (role IN ('student', 'company', 'advisor')),
  auth_provider varchar NOT NULL CHECK (auth_provider IN ('microsoft', 'credentials')),
  password_hash varchar,
  onboarding_completed boolean NOT NULL DEFAULT false,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS students (
  id varchar PRIMARY KEY REFERENCES users(id),
  career varchar NOT NULL,
  cycle int NOT NULL CHECK (cycle BETWEEN 1 AND 12),
  campus varchar NOT NULL,
  modality varchar NOT NULL,
  availability varchar,
  english_level varchar,
  linkedin_url varchar,
  cv_status varchar NOT NULL CHECK (cv_status IN ('missing', 'incomplete', 'updated')),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS companies (
  id varchar PRIMARY KEY,
  name varchar NOT NULL,
  sector varchar NOT NULL,
  description text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS company_users (
  id varchar PRIMARY KEY,
  user_id varchar NOT NULL REFERENCES users(id),
  company_id varchar NOT NULL REFERENCES companies(id),
  position varchar,
  UNIQUE (user_id, company_id)
);

CREATE TABLE IF NOT EXISTS student_goals (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id),
  role_id varchar NOT NULL,
  target_role_name varchar NOT NULL,
  availability varchar,
  preferred_work_mode varchar,
  application_timeframe varchar,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS skills (
  id varchar PRIMARY KEY,
  name varchar NOT NULL,
  type varchar NOT NULL CHECK (type IN ('technical', 'soft', 'language')),
  category varchar,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS student_skills (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id),
  skill_id varchar NOT NULL REFERENCES skills(id),
  level int NOT NULL CHECK (level BETWEEN 0 AND 5),
  source varchar NOT NULL CHECK (source IN ('self_reported', 'evidence', 'challenge', 'advisor')),
  updated_at timestamp NOT NULL DEFAULT now(),
  UNIQUE (student_id, skill_id)
);

CREATE TABLE IF NOT EXISTS evidences (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id),
  title varchar NOT NULL,
  type varchar NOT NULL CHECK (type IN ('academic_project', 'work_experience', 'volunteer', 'family_business', 'challenge')),
  context text,
  actions text NOT NULL,
  result text NOT NULL,
  cv_bullet text,
  star_story text,
  source varchar NOT NULL CHECK (source IN ('onboarding', 'manual', 'challenge')),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS evidence_skills (
  id varchar PRIMARY KEY,
  evidence_id varchar NOT NULL REFERENCES evidences(id),
  skill_id varchar NOT NULL REFERENCES skills(id),
  confidence int CHECK (confidence BETWEEN 0 AND 100),
  UNIQUE (evidence_id, skill_id)
);

CREATE TABLE IF NOT EXISTS jobs (
  id varchar PRIMARY KEY,
  company_id varchar NOT NULL REFERENCES companies(id),
  role_id varchar,
  title varchar NOT NULL,
  modality varchar NOT NULL,
  location varchar NOT NULL,
  hours varchar,
  description text NOT NULL,
  status varchar NOT NULL CHECK (status IN ('active', 'closed')),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS job_requirements (
  id varchar PRIMARY KEY,
  job_id varchar NOT NULL REFERENCES jobs(id),
  skill_id varchar NOT NULL REFERENCES skills(id),
  required_level int NOT NULL CHECK (required_level BETWEEN 0 AND 5),
  importance varchar NOT NULL CHECK (importance IN ('critical', 'important', 'optional')),
  UNIQUE (job_id, skill_id)
);

CREATE TABLE IF NOT EXISTS applications (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id),
  job_id varchar NOT NULL REFERENCES jobs(id),
  status varchar NOT NULL CHECK (status IN ('prepared', 'applied', 'interviewing', 'rejected', 'accepted')),
  notes text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now(),
  UNIQUE (student_id, job_id)
);

CREATE TABLE IF NOT EXISTS challenge_submissions (
  id varchar PRIMARY KEY,
  challenge_id varchar NOT NULL,
  student_id varchar NOT NULL REFERENCES students(id),
  answers_json jsonb NOT NULL,
  score int NOT NULL CHECK (score BETWEEN 0 AND 100),
  feedback text,
  generated_evidence_id varchar REFERENCES evidences(id),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

CREATE INDEX IF NOT EXISTS idx_students_career_cycle ON students(career, cycle);

CREATE INDEX IF NOT EXISTS idx_student_goals_student_active ON student_goals(student_id, active);

CREATE INDEX IF NOT EXISTS idx_student_skills_student ON student_skills(student_id);

CREATE INDEX IF NOT EXISTS idx_evidences_student ON evidences(student_id);

CREATE INDEX IF NOT EXISTS idx_jobs_company_status ON jobs(company_id, status);

CREATE INDEX IF NOT EXISTS idx_job_requirements_job ON job_requirements(job_id);

CREATE INDEX IF NOT EXISTS idx_applications_student ON applications(student_id);

CREATE INDEX IF NOT EXISTS idx_applications_job ON applications(job_id);

CREATE TABLE IF NOT EXISTS role_skill_requirements (
  id varchar PRIMARY KEY,
  role_id varchar NOT NULL,
  skill_id varchar NOT NULL REFERENCES skills(id),
  required_level int NOT NULL CHECK (required_level BETWEEN 0 AND 5),
  priority varchar NOT NULL CHECK (priority IN ('critical', 'important', 'optional')),
  reason text,
  created_at timestamp NOT NULL DEFAULT now(),
  UNIQUE (role_id, skill_id)
);

CREATE TABLE IF NOT EXISTS student_critical_gaps (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id),
  role_id varchar,
  job_id varchar REFERENCES jobs(id),
  skill_id varchar NOT NULL REFERENCES skills(id),
  severity varchar NOT NULL CHECK (severity IN ('critical', 'partial')),
  source varchar NOT NULL CHECK (source IN ('role', 'job')),
  reason text,
  status varchar NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now(),
  CONSTRAINT chk_student_critical_gaps_source_scope CHECK (
    (source = 'role' AND role_id IS NOT NULL AND job_id IS NULL)
    OR
    (source = 'job' AND job_id IS NOT NULL)
  )
);

CREATE INDEX IF NOT EXISTS idx_role_skill_requirements_role
  ON role_skill_requirements(role_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_role_skill_requirements_role_skill
  ON role_skill_requirements(role_id, skill_id);

CREATE INDEX IF NOT EXISTS idx_student_critical_gaps_student_status
  ON student_critical_gaps(student_id, status);

CREATE UNIQUE INDEX IF NOT EXISTS uq_student_critical_gaps_role
  ON student_critical_gaps(student_id, role_id, skill_id)
  WHERE source = 'role' AND role_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_student_critical_gaps_job
  ON student_critical_gaps(student_id, job_id, skill_id)
  WHERE source = 'job' AND job_id IS NOT NULL;

-- ============================================================
-- 2. DATOS DE DEMO (volcado completo desde la base que usa la app)
-- ============================================================

INSERT INTO users (id, name, email, role, auth_provider, password_hash, onboarding_completed, created_at, updated_at) VALUES
  ('advisor_utp', 'Asesor Empleabilidad', 'asesor@utp.edu.pe', 'advisor', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_andrea', 'Andrea Salazar', 'andrea.salazar@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_camila', 'Camila Torres', 'camila.torres@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_diego', 'Diego Ramos', 'diego.ramos@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_lucia', 'Lucia Herrera', 'lucia.herrera@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_luis', 'Luis Mendoza', 'luis.mendoza@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_mateo', 'Mateo Rivas', 'mateo.rivas@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_nuevo', 'Nuevo Estudiante', 'nuevo.estudiante@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('stu_prueba1', 'Estudiante Prueba 1', 'prueba1@utp.edu.pe', 'student', 'credentials', NULL, false, '2026-06-14 15:44:19.170237'::timestamp, '2026-06-14 15:44:19.170237'::timestamp),
  ('stu_prueba2', 'Estudiante Prueba 2', 'prueba2@utp.edu.pe', 'student', 'credentials', NULL, false, '2026-06-14 15:44:19.170237'::timestamp, '2026-06-14 15:44:19.170237'::timestamp),
  ('stu_prueba3', 'Estudiante Prueba 3', 'prueba3@utp.edu.pe', 'student', 'credentials', NULL, false, '2026-06-14 15:44:19.170237'::timestamp, '2026-06-14 15:44:19.170237'::timestamp),
  ('stu_prueba4', 'Estudiante Prueba 4', 'prueba4@utp.edu.pe', 'student', 'credentials', NULL, false, '2026-06-14 15:44:19.170237'::timestamp, '2026-06-14 15:44:19.170237'::timestamp),
  ('stu_prueba5', 'Estudiante Prueba 5', 'prueba5@utp.edu.pe', 'student', 'credentials', NULL, false, '2026-06-14 15:44:19.170237'::timestamp, '2026-06-14 15:44:19.170237'::timestamp),
  ('stu_renzo', 'Renzo Castillo', 'renzo.castillo@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_valeria', 'Valeria Paredes', 'valeria.paredes@utp.edu.pe', 'student', 'microsoft', NULL, true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('usr_ac01d8d3ef', 'Test Empresa', 'test.empresa@demo.pe', 'company', 'credentials', NULL, true, '2026-06-13 12:27:57.506889'::timestamp, '2026-06-13 12:27:57.506889'::timestamp),
  ('usr_recruiter_ana', 'Ana Reclutadora', 'ana@retailandino.pe', 'company', 'credentials', 'demo-password-hash', true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('usr_recruiter_talento', 'Paola Talento', 'paola@talentolab.pe', 'company', 'credentials', 'demo-password-hash', true, '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO companies (id, name, sector, description, created_at, updated_at) VALUES
  ('comp_datamarket', 'DataMarket Peru', 'Tecnologia / datos', 'Empresa de soluciones de datos y software interno.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('comp_finanzas_nova', 'Finanzas Nova', 'Servicios financieros', 'Fintech local con foco en reportes y eficiencia financiera.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('comp_logisur', 'Logisur', 'Logistica', 'Operador logistico con procesos de almacen y distribucion.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('comp_retail_andino', 'Retail Andino', 'Retail', 'Cadena retail con operaciones comerciales y analitica de ventas.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('comp_talentolab', 'TalentoLab', 'Consultoria RRHH', 'Consultora de talento, clima laboral y seleccion.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO company_users (id, user_id, company_id, position) VALUES
  ('cu_retail_ana', 'usr_recruiter_ana', 'comp_retail_andino', 'Reclutadora'),
  ('cu_talentolab_paola', 'usr_recruiter_talento', 'comp_talentolab', 'People Partner')
ON CONFLICT DO NOTHING;

INSERT INTO students (id, career, cycle, campus, modality, availability, english_level, linkedin_url, cv_status, created_at, updated_at) VALUES
  ('stu_andrea', 'Psicologia', 8, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', NULL, 'incomplete', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_camila', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'https://linkedin.com/in/camila-torres-utp', 'incomplete', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_diego', 'Administracion', 7, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', NULL, 'incomplete', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_lucia', 'Comunicaciones', 7, 'Lima Centro', 'Semipresencial', 'Medio tiempo', 'Intermedio', NULL, 'incomplete', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_luis', 'Ingenieria Industrial', 9, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', NULL, 'updated', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_mateo', 'Ingenieria de Software', 9, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/mateo-rivas-utp', 'updated', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_nuevo', 'Ingenieria de Sistemas e Informatica', 1, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', '', 'missing', '2026-06-13 10:23:00.641471'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('stu_renzo', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Norte', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'https://linkedin.com/in/renzo-castillo-utp', 'updated', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('stu_valeria', 'Marketing', 6, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/valeria-paredes-utp', 'updated', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO skills (id, name, type, category, active) VALUES
  ('sk_accounting', 'Contabilidad', 'technical', 'finance', true),
  ('sk_algorithms', 'Algoritmos', 'technical', 'software', true),
  ('sk_analytics_marketing', 'Metricas digitales', 'technical', 'marketing', true),
  ('sk_api', 'APIs REST', 'technical', 'software', true),
  ('sk_behavior_observation', 'Observacion del comportamiento', 'technical', 'psychology', true),
  ('sk_bitbucket', 'Bitbucket', 'technical', 'software', true),
  ('sk_budget_evaluation', 'Evaluacion presupuestal', 'technical', 'finance', true),
  ('sk_business_analytics', 'Analitica de datos', 'technical', 'data', true),
  ('sk_business_intelligence', 'Inteligencia de negocios', 'technical', 'data', true),
  ('sk_business_it', 'Informatica para los negocios', 'technical', 'business', true),
  ('sk_business_management', 'Gestion general', 'soft', 'management', true),
  ('sk_cicd', 'CI/CD', 'technical', 'devops', true),
  ('sk_civil_procedure', 'Derecho procesal civil', 'technical', 'legal', true),
  ('sk_cloud_services', 'Servicios cloud', 'technical', 'cloud', true),
  ('sk_commercial_management', 'Direccion comercial', 'soft', 'sales', true),
  ('sk_communication', 'Comunicacion', 'soft', 'soft_skills', true),
  ('sk_copywriting', 'Redaccion', 'soft', 'communication', true),
  ('sk_corporate_law', 'Derecho corporativo', 'technical', 'legal', true),
  ('sk_costs_budgets', 'Costos y presupuestos', 'technical', 'finance', true),
  ('sk_criminal_law', 'Derecho penal', 'technical', 'legal', true),
  ('sk_cybersecurity', 'Seguridad informatica', 'technical', 'cybersecurity', true),
  ('sk_database', 'Bases de datos', 'technical', 'data', true),
  ('sk_differential_diagnosis', 'Diagnostico diferencial', 'technical', 'psychology', true),
  ('sk_digital_business', 'Negocios digitales', 'technical', 'business', true),
  ('sk_educational_psychology', 'Psicologia educativa', 'technical', 'psychology', true),
  ('sk_effective_communication', 'Comunicacion efectiva', 'soft', 'soft_skills', true),
  ('sk_english', 'Ingles', 'language', 'language', true),
  ('sk_enterprise_architecture', 'Arquitectura empresarial', 'technical', 'architecture', true),
  ('sk_environmental_management', 'Gestion del medio ambiente', 'technical', 'sustainability', true),
  ('sk_excel', 'Excel', 'technical', 'office', true),
  ('sk_finance', 'Finanzas', 'technical', 'finance', true),
  ('sk_git', 'Git', 'technical', 'software', true),
  ('sk_gitflow', 'GitFlow', 'technical', 'software', true),
  ('sk_group_dynamics', 'Dinamica de grupos', 'soft', 'psychology', true),
  ('sk_hr_interviews', 'Entrevistas semiestructuradas', 'soft', 'hr', true),
  ('sk_human_resources', 'Gestion humana', 'soft', 'management', true),
  ('sk_human_talent_management', 'Gestion del talento humano', 'soft', 'management', true),
  ('sk_interview', 'Entrevista', 'soft', 'employability', true),
  ('sk_it_service_management', 'Gestion del servicio TI', 'technical', 'it_management', true),
  ('sk_javascript', 'JavaScript', 'technical', 'software', true),
  ('sk_jira', 'Jira', 'technical', 'project_management', true),
  ('sk_kanban', 'Kanban', 'soft', 'agile', true),
  ('sk_labor_law', 'Derecho laboral', 'technical', 'legal', true),
  ('sk_leadership', 'Liderazgo', 'soft', 'soft_skills', true),
  ('sk_legal_analysis', 'Analisis legal', 'technical', 'legal', true),
  ('sk_legal_argumentation', 'Argumentacion juridica', 'soft', 'legal', true),
  ('sk_legal_ethics', 'Etica juridica', 'soft', 'legal', true),
  ('sk_legal_research', 'Investigacion juridica', 'technical', 'legal', true),
  ('sk_legal_writing', 'Redaccion juridica', 'technical', 'legal', true),
  ('sk_logistics', 'Logistica', 'technical', 'operations', true),
  ('sk_market_research', 'Investigacion de mercados', 'technical', 'marketing', true),
  ('sk_marketing', 'Marketing', 'soft', 'marketing', true),
  ('sk_mental_health', 'Salud mental', 'technical', 'psychology', true),
  ('sk_negotiation', 'Negociacion', 'soft', 'business', true),
  ('sk_occupational_safety', 'Seguridad y salud ocupacional', 'technical', 'safety', true),
  ('sk_oop', 'Programacion orientada a objetos', 'technical', 'software', true),
  ('sk_operations_management', 'Gestion de operaciones', 'technical', 'operations', true),
  ('sk_oral_litigation', 'Litigacion oral', 'soft', 'legal', true),
  ('sk_organizational_consulting', 'Consultoria organizacional', 'soft', 'psychology', true),
  ('sk_powerbi', 'Power BI', 'technical', 'data', true),
  ('sk_problem_solving', 'Resolucion de problemas', 'soft', 'soft_skills', true),
  ('sk_process_analysis', 'Analisis de procesos', 'technical', 'operations', true),
  ('sk_process_automation', 'Automatizacion de procesos', 'technical', 'automation', true),
  ('sk_process_management', 'Gestion por procesos', 'technical', 'operations', true),
  ('sk_programming', 'Programacion', 'technical', 'software', true),
  ('sk_project_management', 'Gestion de proyectos', 'soft', 'management', true),
  ('sk_psychological_interview', 'Entrevista psicologica', 'soft', 'psychology', true),
  ('sk_psychometrics', 'Psicometria', 'technical', 'psychology', true),
  ('sk_psychopathology', 'Psicopatologia', 'technical', 'psychology', true),
  ('sk_psychotherapeutic_techniques', 'Tecnicas psicoterapeuticas', 'technical', 'psychology', true),
  ('sk_python', 'Python', 'technical', 'data', true),
  ('sk_qa', 'QA', 'technical', 'quality', true),
  ('sk_quality_management', 'Gestion de calidad', 'technical', 'quality', true),
  ('sk_sales_management', 'Gestion de ventas', 'soft', 'sales', true),
  ('sk_scrum', 'Scrum', 'soft', 'agile', true),
  ('sk_simulation', 'Simulacion', 'technical', 'operations', true),
  ('sk_sql', 'SQL', 'technical', 'data', true),
  ('sk_strategic_management', 'Direccion estrategica', 'soft', 'management', true),
  ('sk_supply_chain', 'Cadena de abastecimiento', 'technical', 'logistics', true),
  ('sk_tax_law', 'Derecho tributario', 'technical', 'legal', true),
  ('sk_teamwork', 'Trabajo en equipo', 'soft', 'soft_skills', true),
  ('sk_testing', 'Pruebas unitarias', 'technical', 'software', true),
  ('sk_vocational_diagnosis', 'Diagnostico vocacional', 'technical', 'psychology', true),
  ('sk_web_development', 'Desarrollo web', 'technical', 'software', true)
ON CONFLICT DO NOTHING;

INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active, created_at) VALUES
  ('goal_andrea_people', 'stu_andrea', 'role_people_analytics', 'Practicante de People Analytics', 'Medio tiempo', 'Remoto', 'En las proximas 4 semanas', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_camila_data', 'stu_camila', 'role_data_intern', 'Practicante de Analisis de Datos', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_diego_commercial', 'stu_diego', 'role_commercial_analyst', 'Asistente Comercial Junior', 'Medio tiempo', 'Hibrido', 'Este mes', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_lucia_mkt_analytics', 'stu_lucia', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Medio tiempo', 'Hibrido', 'En las proximas 4 semanas', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_luis_ops', 'stu_luis', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h', 'Presencial', 'Este mes', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_mateo_dev', 'stu_mateo', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_renzo_support', 'stu_renzo', 'role_it_support', 'Soporte TI Junior', 'Tiempo completo', 'Presencial', 'Este mes', true, '2026-06-12 20:26:41.589115'::timestamp),
  ('goal_stu_nuevo_666f5091', 'stu_nuevo', 'role_data_intern', 'Practicante de Analisis de Datos', 'Medio tiempo', 'Hibrido', 'Aun explorando', true, '2026-06-13 21:33:42.002338'::timestamp),
  ('goal_valeria_marketing', 'stu_valeria', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Practicas preprofesionales - 30h', 'Hibrido', 'Este mes', true, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO student_skills (id, student_id, skill_id, level, source, updated_at) VALUES
  ('ss_andrea_comm', 'stu_andrea', 'sk_communication', 5, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_andrea_hr', 'stu_andrea', 'sk_hr_interviews', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_andrea_powerbi', 'stu_andrea', 'sk_powerbi', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_andrea_python', 'stu_andrea', 'sk_python', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_camila_comm', 'stu_camila', 'sk_communication', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_camila_english', 'stu_camila', 'sk_english', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_camila_excel', 'stu_camila', 'sk_excel', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_camila_powerbi', 'stu_camila', 'sk_powerbi', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_camila_sql', 'stu_camila', 'sk_sql', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_diego_comm', 'stu_diego', 'sk_communication', 4, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_diego_excel', 'stu_diego', 'sk_excel', 3, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_diego_powerbi', 'stu_diego', 'sk_powerbi', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_lucia_copy', 'stu_lucia', 'sk_copywriting', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_lucia_excel', 'stu_lucia', 'sk_excel', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_lucia_metrics', 'stu_lucia', 'sk_analytics_marketing', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_lucia_powerbi', 'stu_lucia', 'sk_powerbi', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_luis_excel', 'stu_luis', 'sk_excel', 3, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_luis_process', 'stu_luis', 'sk_process_analysis', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_luis_sql', 'stu_luis', 'sk_sql', 1, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_mateo_api', 'stu_mateo', 'sk_api', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_mateo_comm', 'stu_mateo', 'sk_communication', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_mateo_git', 'stu_mateo', 'sk_git', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_mateo_python', 'stu_mateo', 'sk_python', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_mateo_testing', 'stu_mateo', 'sk_testing', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_renzo_comm', 'stu_renzo', 'sk_communication', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_renzo_python', 'stu_renzo', 'sk_python', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_renzo_sql', 'stu_renzo', 'sk_sql', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_stu_nuevo_sk_business_intelligence', 'stu_nuevo', 'sk_business_intelligence', 3, 'self_reported', '2026-06-13 21:33:42.002338'::timestamp),
  ('ss_stu_nuevo_sk_powerbi', 'stu_nuevo', 'sk_powerbi', 3, 'self_reported', '2026-06-13 21:33:42.002338'::timestamp),
  ('ss_stu_nuevo_sk_problem_solving', 'stu_nuevo', 'sk_problem_solving', 3, 'self_reported', '2026-06-13 21:33:42.002338'::timestamp),
  ('ss_valeria_copy', 'stu_valeria', 'sk_copywriting', 4, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_valeria_metrics', 'stu_valeria', 'sk_analytics_marketing', 3, 'evidence', '2026-06-12 20:26:41.589115'::timestamp),
  ('ss_valeria_powerbi', 'stu_valeria', 'sk_powerbi', 2, 'self_reported', '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source, created_at, updated_at) VALUES
  ('ev_andrea_clima', 'stu_andrea', 'Encuesta de clima para proyecto academico', 'academic_project', 'Curso de psicologia organizacional', 'Diseno encuesta, aplico entrevistas y sintetizo hallazgos de clima.', 'Se identificaron factores de motivacion y riesgo para el equipo analizado.', 'Disene y analice una encuesta de clima organizacional, sintetizando hallazgos accionables para mejorar motivacion del equipo.', 'Situacion: diagnostico de clima. Accion: encuesta y entrevistas. Resultado: hallazgos priorizados.', 'onboarding', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_camila_dashboard', 'stu_camila', 'Dashboard de ventas para curso de BI', 'academic_project', 'Proyecto final de curso', 'Limpie datos en Excel y cree un dashboard en Power BI para analizar ventas.', 'El equipo identifico productos con mayor margen y presento recomendaciones.', 'Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel, identificando productos de mayor margen para apoyar decisiones comerciales.', 'Situacion: proyecto final de BI. Tarea: convertir una base desordenada en insight. Accion: limpie datos, modele indicadores y cree dashboard. Resultado: el equipo priorizo productos de mayor margen.', 'onboarding', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_camila_family', 'stu_camila', 'Atencion al cliente en negocio familiar', 'family_business', 'Apoyo operativo en tienda familiar', 'Registre pedidos, ordene incidencias y respondi consultas de clientes.', 'Se redujeron errores de pedido usando una lista de control.', 'Gestione atencion a clientes y registro de pedidos, reduciendo errores mediante una lista de control.', 'Situacion: tienda familiar con errores frecuentes. Accion: cree checklist y seguimiento. Resultado: menos reclamos y mejor orden.', 'manual', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_lucia_campaign', 'stu_lucia', 'Campana de contenidos para emprendimiento', 'academic_project', 'Proyecto de comunicacion digital', 'Planifico calendario, redacto piezas y midio engagement de publicaciones.', 'El reporte identifico formatos con mayor interaccion.', 'Planifique y analice una campana de contenidos, usando metricas de engagement para recomendar formatos con mejor desempeno.', 'Situacion: emprendimiento sin lectura de metricas. Accion: calendario y reporte. Resultado: formatos priorizados.', 'onboarding', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_luis_process', 'stu_luis', 'Analisis de tiempos de proceso', 'academic_project', 'Curso de gestion de operaciones', 'Medi tiempos, identifique cuellos de botella y propuse redistribucion de tareas.', 'La propuesta reducia tiempos estimados en el flujo simulado.', 'Analice tiempos de proceso e identifique cuellos de botella para proponer mejoras operativas.', 'Situacion: flujo lento. Accion: medicion y analisis. Resultado: propuesta de mejora.', 'onboarding', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_mateo_api', 'stu_mateo', 'API de reservas con Python', 'academic_project', 'Curso de arquitectura de software', 'Construyo endpoints REST, modelo de datos y pruebas unitarias para reservas.', 'El prototipo permitio registrar y consultar reservas sin errores criticos.', 'Construyo una API REST en Python con pruebas unitarias para gestionar reservas academicas.', 'Situacion: proyecto de curso. Accion: diseno endpoints y pruebas. Resultado: API funcional para demo tecnica.', 'onboarding', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_renzo_support', 'stu_renzo', 'Documentacion de incidencias TI', 'work_experience', 'Apoyo a laboratorio de computo', 'Registro incidencias, clasifico causas y documento soluciones frecuentes.', 'Se redujo el tiempo de respuesta para incidencias repetidas.', 'Documente incidencias TI y soluciones frecuentes, reduciendo tiempos de atencion para problemas repetidos.', 'Situacion: incidencias recurrentes. Accion: registro y documentacion. Resultado: respuesta mas rapida.', 'manual', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('ev_stu_andrea_5e60fcb2', 'stu_andrea', 'Proyecto academico', 'academic_project', 'En la universidad me pidieron un proyecto academico', 'Diseñoe y prototipe mi proyecto con figma ', 'Logre una nota sobresaliente y felicitaciones de mi profesor', 'Diseñoe y prototipe mi proyecto con figma  para lograr Logre una nota sobresaliente y felicitaciones de mi profesor.', 'Situacion: En la universidad me pidieron un proyecto academico. Accion: Diseñoe y prototipe mi proyecto con figma . Resultado: Logre una nota sobresaliente y felicitaciones de mi profesor.', 'manual', '2026-06-13 19:54:58.566088'::timestamp, '2026-06-13 19:54:58.566088'::timestamp),
  ('ev_stu_nuevo_0558877c', 'stu_nuevo', 'Trackademy', 'academic_project', 'Ciclo 9', 'Frontend y Backend', 'Un 20', 'Frontend y Backend para lograr: Un 20.', 'Situacion: Ciclo 9. Accion: Frontend y Backend. Resultado: Un 20.', 'onboarding', '2026-06-13 21:33:42.002338'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('ev_valeria_social', 'stu_valeria', 'Reporte de redes para marca local', 'academic_project', 'Curso de marketing digital', 'Compare publicaciones por alcance, interaccion y conversion estimada.', 'Se priorizaron formatos cortos con mayor engagement.', 'Analice metricas de redes sociales y recomende formatos de contenido con mayor engagement.', 'Situacion: marca sin analisis. Accion: reporte de metricas. Resultado: recomendacion de formatos.', 'manual', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO evidence_skills (id, evidence_id, skill_id, confidence) VALUES
  ('esk_andrea_comm', 'ev_andrea_clima', 'sk_communication', 95),
  ('esk_andrea_hr', 'ev_andrea_clima', 'sk_hr_interviews', 90),
  ('esk_camila_dash_comm', 'ev_camila_dashboard', 'sk_communication', 70),
  ('esk_camila_dash_excel', 'ev_camila_dashboard', 'sk_excel', 90),
  ('esk_camila_dash_powerbi', 'ev_camila_dashboard', 'sk_powerbi', 85),
  ('esk_camila_family_comm', 'ev_camila_family', 'sk_communication', 80),
  ('esk_camila_family_problem', 'ev_camila_family', 'sk_problem_solving', 75),
  ('esk_ev_stu_nuevo_0558877c_sk_api', 'ev_stu_nuevo_0558877c', 'sk_api', 70),
  ('esk_ev_stu_nuevo_0558877c_sk_git', 'ev_stu_nuevo_0558877c', 'sk_git', 70),
  ('esk_ev_stu_nuevo_0558877c_sk_programming', 'ev_stu_nuevo_0558877c', 'sk_programming', 70),
  ('esk_ev_stu_nuevo_0558877c_sk_project_management', 'ev_stu_nuevo_0558877c', 'sk_project_management', 70),
  ('esk_ev_stu_nuevo_0558877c_sk_web_development', 'ev_stu_nuevo_0558877c', 'sk_web_development', 70),
  ('esk_lucia_copy', 'ev_lucia_campaign', 'sk_copywriting', 88),
  ('esk_lucia_metrics', 'ev_lucia_campaign', 'sk_analytics_marketing', 75),
  ('esk_luis_process', 'ev_luis_process', 'sk_process_analysis', 88),
  ('esk_mateo_api_api', 'ev_mateo_api', 'sk_api', 90),
  ('esk_mateo_api_python', 'ev_mateo_api', 'sk_python', 90),
  ('esk_mateo_api_testing', 'ev_mateo_api', 'sk_testing', 80),
  ('esk_renzo_sql', 'ev_renzo_support', 'sk_sql', 65),
  ('esk_valeria_metrics', 'ev_valeria_social', 'sk_analytics_marketing', 85)
ON CONFLICT DO NOTHING;

INSERT INTO jobs (id, company_id, role_id, title, modality, location, hours, description, status, created_at, updated_at) VALUES
  ('job_bi_finanzas', 'comp_finanzas_nova', 'role_data_intern', 'Practicante BI Junior', 'Remoto', 'Lima', '30h semanales', 'Construir reportes y dashboards para el area financiera.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_commercial_retail', 'comp_retail_andino', 'role_commercial_analyst', 'Asistente Comercial Junior', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar seguimiento comercial, reportes de ventas y coordinacion con tiendas.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_data_retail', 'comp_retail_andino', 'role_data_intern', 'Practicante de Analisis de Datos', 'Hibrido', 'Lima', '30h semanales', 'Apoyar reportes comerciales, limpieza de bases y tableros de seguimiento para decisiones retail.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_dev_datamarket', 'comp_datamarket', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Hibrido', 'Lima', '30h semanales', 'Construir funcionalidades internas, APIs y documentacion tecnica.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_hr_talentolab', 'comp_talentolab', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Remoto', 'Lima', 'Medio tiempo', 'Apoyar entrevistas, clima laboral y seguimiento de candidatos.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_marketing_analytics_talentolab', 'comp_talentolab', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Hibrido', 'Lima', 'Medio tiempo', 'Leer metricas digitales y proponer mejoras de contenido.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_marketing_talentolab', 'comp_talentolab', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar contenidos, pauta basica y reportes de campanas.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_operations_logisur', 'comp_logisur', 'role_operations_intern', 'Practicante de Operaciones', 'Presencial', 'Lima', '30h semanales', 'Apoyar analisis de procesos logisticos y mejora continua.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_ops_retail', 'comp_retail_andino', 'role_operations_intern', 'Practicante de Operaciones Retail', 'Presencial', 'Lima', '30h semanales', 'Analizar procesos de tienda, inventario y tiempos de reposicion.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_people_analytics_talentolab', 'comp_talentolab', 'role_people_analytics', 'Practicante de People Analytics', 'Remoto', 'Lima', 'Medio tiempo', 'Analizar encuestas, clima laboral y datos de talento.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('job_support_datamarket', 'comp_datamarket', 'role_it_support', 'Soporte TI Junior', 'Presencial', 'Lima', 'Tiempo completo', 'Atender incidencias, documentar soluciones y apoyar soporte interno.', 'active', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO job_requirements (id, job_id, skill_id, required_level, importance) VALUES
  ('jr_bi_english', 'job_bi_finanzas', 'sk_english', 3, 'important'),
  ('jr_bi_powerbi', 'job_bi_finanzas', 'sk_powerbi', 4, 'critical'),
  ('jr_bi_sql', 'job_bi_finanzas', 'sk_sql', 3, 'critical'),
  ('jr_commercial_comm', 'job_commercial_retail', 'sk_communication', 4, 'critical'),
  ('jr_commercial_excel', 'job_commercial_retail', 'sk_excel', 3, 'critical'),
  ('jr_commercial_powerbi', 'job_commercial_retail', 'sk_powerbi', 2, 'important'),
  ('jr_data_comm', 'job_data_retail', 'sk_communication', 3, 'important'),
  ('jr_data_english', 'job_data_retail', 'sk_english', 3, 'important'),
  ('jr_data_excel', 'job_data_retail', 'sk_excel', 4, 'critical'),
  ('jr_data_powerbi', 'job_data_retail', 'sk_powerbi', 3, 'critical'),
  ('jr_data_sql', 'job_data_retail', 'sk_sql', 3, 'critical'),
  ('jr_dev_api', 'job_dev_datamarket', 'sk_api', 4, 'critical'),
  ('jr_dev_comm', 'job_dev_datamarket', 'sk_communication', 3, 'important'),
  ('jr_dev_git', 'job_dev_datamarket', 'sk_git', 3, 'important'),
  ('jr_dev_python', 'job_dev_datamarket', 'sk_python', 4, 'critical'),
  ('jr_hr_comm', 'job_hr_talentolab', 'sk_communication', 4, 'critical'),
  ('jr_hr_interviews', 'job_hr_talentolab', 'sk_hr_interviews', 4, 'critical'),
  ('jr_marketing_copy', 'job_marketing_talentolab', 'sk_copywriting', 4, 'critical'),
  ('jr_marketing_metrics', 'job_marketing_talentolab', 'sk_analytics_marketing', 3, 'important'),
  ('jr_mkt_analytics_copy', 'job_marketing_analytics_talentolab', 'sk_copywriting', 3, 'important'),
  ('jr_mkt_analytics_excel', 'job_marketing_analytics_talentolab', 'sk_excel', 3, 'critical'),
  ('jr_mkt_analytics_metrics', 'job_marketing_analytics_talentolab', 'sk_analytics_marketing', 3, 'critical'),
  ('jr_mkt_analytics_powerbi', 'job_marketing_analytics_talentolab', 'sk_powerbi', 2, 'important'),
  ('jr_ops_excel_logisur', 'job_operations_logisur', 'sk_excel', 3, 'important'),
  ('jr_ops_excel_retail', 'job_ops_retail', 'sk_excel', 3, 'critical'),
  ('jr_ops_process_logisur', 'job_operations_logisur', 'sk_process_analysis', 4, 'critical'),
  ('jr_ops_process_retail', 'job_ops_retail', 'sk_process_analysis', 3, 'critical'),
  ('jr_people_hr', 'job_people_analytics_talentolab', 'sk_hr_interviews', 3, 'important'),
  ('jr_people_powerbi', 'job_people_analytics_talentolab', 'sk_powerbi', 3, 'critical'),
  ('jr_people_python', 'job_people_analytics_talentolab', 'sk_python', 3, 'critical'),
  ('jr_support_comm', 'job_support_datamarket', 'sk_communication', 3, 'critical'),
  ('jr_support_sql', 'job_support_datamarket', 'sk_sql', 2, 'important')
ON CONFLICT DO NOTHING;

INSERT INTO applications (id, student_id, job_id, status, notes, created_at, updated_at) VALUES
  ('app_andrea_people', 'stu_andrea', 'job_people_analytics_talentolab', 'prepared', 'Reforzar Python basico.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('app_camila_bi_finanzas', 'stu_camila', 'job_bi_finanzas', 'prepared', 'Aspiracional: reforzar SQL antes de postular.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('app_camila_data_retail', 'stu_camila', 'job_data_retail', 'prepared', 'CV ajustado pendiente de enviar.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('app_lucia_marketing_analytics', 'stu_lucia', 'job_marketing_analytics_talentolab', 'prepared', 'Completar evidencia de metricas.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('app_mateo_dev', 'stu_mateo', 'job_dev_datamarket', 'prepared', 'Buen fit tecnico; practicar pitch tecnico.', '2026-06-12 20:26:41.589115'::timestamp, '2026-06-12 20:26:41.589115'::timestamp),
  ('app_stu_nuevo_b3176797', 'stu_nuevo', 'job_people_analytics_talentolab', 'prepared', '', '2026-06-13 23:53:49.314358'::timestamp, '2026-06-13 23:53:49.314358'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO challenge_submissions (id, challenge_id, student_id, answers_json, score, feedback, generated_evidence_id, created_at) VALUES
  ('sub_andrea_people_python', 'cha_people_analytics_python', 'stu_andrea', '{"dataset": "encuesta clima", "finding": "satisfaccion menor en comunicacion interna"}'::jsonb, 71, 'Buen enfoque humano; falta detalle tecnico de analisis.', NULL, '2026-06-12 20:26:41.589115'::timestamp),
  ('sub_camila_sales_insight', 'cha_sales_insight', 'stu_camila', '{"summary": "Mayor margen en categorias de baja rotacion", "recommendation": "Priorizar surtido y seguimiento semanal"}'::jsonb, 82, 'Buen analisis comercial; falta explicar supuestos.', NULL, '2026-06-12 20:26:41.589115'::timestamp),
  ('sub_mateo_soft_story', 'cha_soft_skills_technical_story', 'stu_mateo', '{"technicalDecision": "API REST con capas", "businessExplanation": "Separar capas facilita mantenimiento y reduce errores"}'::jsonb, 74, 'La explicacion es clara, puede cerrar con impacto de negocio.', NULL, '2026-06-12 20:26:41.589115'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO role_skill_requirements (id, role_id, skill_id, required_level, priority, reason, created_at) VALUES
  ('rsr_demo_commercial_comm', 'role_commercial_analyst', 'sk_communication', 3, 'important', 'Comunicar resultados comerciales.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_commercial', 'role_commercial_analyst', 'sk_commercial_management', 3, 'critical', 'Gestionar indicadores comerciales.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_english', 'role_commercial_analyst', 'sk_english', 2, 'optional', 'Leer informacion regional.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_excel', 'role_commercial_analyst', 'sk_excel', 3, 'critical', 'Trabajar reportes comerciales.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_finance', 'role_commercial_analyst', 'sk_finance', 3, 'important', 'Entender rentabilidad y margen.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_negotiation', 'role_commercial_analyst', 'sk_negotiation', 3, 'important', 'Coordinar acuerdos internos o externos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_commercial_sales', 'role_commercial_analyst', 'sk_sales_management', 3, 'important', 'Analizar ventas y objetivos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_data_python', 'role_data_intern', 'sk_python', 2, 'important', 'Automatizar limpieza y analisis basico.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_comm', 'role_hr_intern', 'sk_communication', 3, 'critical', 'Comunicarse con candidatos y equipos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_english', 'role_hr_intern', 'sk_english', 2, 'optional', 'Leer referencias de talento.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_groups', 'role_hr_intern', 'sk_group_dynamics', 3, 'important', 'Facilitar actividades grupales.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_human_resources', 'role_hr_intern', 'sk_human_resources', 3, 'critical', 'Gestionar informacion de personas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_interview', 'role_hr_intern', 'sk_psychological_interview', 3, 'important', 'Apoyar entrevistas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_hr_talent', 'role_hr_intern', 'sk_human_talent_management', 3, 'critical', 'Apoyar procesos de talento.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_it_comm', 'role_it_support', 'sk_communication', 3, 'critical', 'Atender usuarios internos con claridad.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_it_english', 'role_it_support', 'sk_english', 2, 'optional', 'Usar documentacion tecnica.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_it_itil', 'role_it_support', 'sk_it_service_management', 3, 'critical', 'Gestionar tickets e incidencias TI.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_it_problem', 'role_it_support', 'sk_problem_solving', 3, 'important', 'Diagnosticar incidentes frecuentes.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_it_security', 'role_it_support', 'sk_cybersecurity', 2, 'important', 'Aplicar buenas practicas de seguridad.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_marketing_comm', 'role_marketing_assistant', 'sk_communication', 3, 'critical', 'Comunicar mensajes de marca.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_marketing_english', 'role_marketing_assistant', 'sk_english', 2, 'optional', 'Leer referencias de mercado.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_marketing_excel', 'role_marketing_assistant', 'sk_excel', 3, 'important', 'Ordenar reportes de campana.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_marketing_marketing', 'role_marketing_assistant', 'sk_marketing', 3, 'critical', 'Ejecutar acciones de marketing.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_marketing_research', 'role_marketing_assistant', 'sk_market_research', 3, 'important', 'Entender clientes y campanas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_ba', 'role_marketing_analytics', 'sk_business_analytics', 3, 'critical', 'Analizar desempeno de campanas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_comm', 'role_marketing_analytics', 'sk_communication', 3, 'important', 'Presentar hallazgos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_english', 'role_marketing_analytics', 'sk_english', 2, 'optional', 'Leer benchmarks.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_excel', 'role_marketing_analytics', 'sk_excel', 3, 'important', 'Preparar bases de datos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_marketing', 'role_marketing_analytics', 'sk_marketing', 3, 'critical', 'Entender objetivos de marketing.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_powerbi', 'role_marketing_analytics', 'sk_powerbi', 3, 'important', 'Visualizar indicadores.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_mkt_analytics_research', 'role_marketing_analytics', 'sk_market_research', 3, 'important', 'Interpretar comportamiento del consumidor.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_english', 'role_operations_intern', 'sk_english', 2, 'optional', 'Leer procedimientos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_excel', 'role_operations_intern', 'sk_excel', 3, 'important', 'Analizar reportes operativos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_logistics', 'role_operations_intern', 'sk_logistics', 3, 'important', 'Coordinar abastecimiento y almacenes.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_operations', 'role_operations_intern', 'sk_operations_management', 3, 'critical', 'Gestionar flujos operativos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_powerbi', 'role_operations_intern', 'sk_powerbi', 2, 'important', 'Monitorear indicadores.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_problem', 'role_operations_intern', 'sk_problem_solving', 3, 'important', 'Resolver cuellos de botella.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_process', 'role_operations_intern', 'sk_process_management', 3, 'critical', 'Documentar y mejorar procesos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_ops_quality', 'role_operations_intern', 'sk_quality_management', 3, 'important', 'Controlar calidad operativa.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_ba', 'role_people_analytics', 'sk_business_analytics', 3, 'critical', 'Analizar metricas de talento.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_comm', 'role_people_analytics', 'sk_communication', 3, 'important', 'Explicar hallazgos de personas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_english', 'role_people_analytics', 'sk_english', 2, 'optional', 'Leer benchmarks de talento.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_excel', 'role_people_analytics', 'sk_excel', 3, 'important', 'Preparar datos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_hr', 'role_people_analytics', 'sk_human_resources', 3, 'critical', 'Entender datos de personas.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_people_powerbi', 'role_people_analytics', 'sk_powerbi', 3, 'important', 'Construir reportes de RRHH.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_database', 'role_software_intern', 'sk_database', 3, 'important', 'Persistir y consultar datos de aplicacion.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_english', 'role_software_intern', 'sk_english', 2, 'optional', 'Leer documentacion tecnica.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_git', 'role_software_intern', 'sk_git', 2, 'important', 'Colaborar en repositorios de codigo.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_js', 'role_software_intern', 'sk_javascript', 3, 'important', 'Implementar funcionalidades frontend o fullstack.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_oop', 'role_software_intern', 'sk_oop', 3, 'critical', 'Modelar soluciones orientadas a objetos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_problem', 'role_software_intern', 'sk_problem_solving', 3, 'important', 'Resolver bugs y requerimientos ambiguos.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_programming', 'role_software_intern', 'sk_programming', 3, 'critical', 'Construir funcionalidades mantenibles.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_demo_software_web', 'role_software_intern', 'sk_web_development', 3, 'important', 'Desarrollar interfaces o APIs web.', '2026-06-13 22:12:45.105146'::timestamp),
  ('rsr_role_data_intern_business_intelligence', 'role_data_intern', 'sk_business_intelligence', 3, 'important', 'Convertir datos en indicadores accionables.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_communication', 'role_data_intern', 'sk_communication', 3, 'important', 'Explicar hallazgos a negocio.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_english', 'role_data_intern', 'sk_english', 3, 'important', 'Leer documentacion y reportes regionales.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_excel', 'role_data_intern', 'sk_excel', 4, 'important', 'Manejar bases y reportes operativos.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_powerbi', 'role_data_intern', 'sk_powerbi', 3, 'critical', 'Construir tableros de seguimiento.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_problem_solving', 'role_data_intern', 'sk_problem_solving', 3, 'important', 'Necesario para estructurar problemas de datos y proponer acciones.', '2026-06-13 15:59:44.566723'::timestamp),
  ('rsr_role_data_intern_sql', 'role_data_intern', 'sk_sql', 3, 'critical', 'Consultar y cruzar datos para analisis de negocio.', '2026-06-13 15:59:44.566723'::timestamp)
ON CONFLICT DO NOTHING;

INSERT INTO student_critical_gaps (id, student_id, role_id, job_id, skill_id, severity, source, reason, status, created_at, updated_at) VALUES
  ('scg_stu_andrea_job_job_data_retail_sk_english', 'stu_andrea', 'role_people_analytics', 'job_data_retail', 'sk_english', 'partial', 'job', 'Refuerza Ingles: estas en nivel 0 y el objetivo requiere nivel 3.', 'open', '2026-06-13 19:16:57.354917'::timestamp, '2026-06-14 12:53:40.356215'::timestamp),
  ('scg_stu_andrea_job_job_data_retail_sk_excel', 'stu_andrea', 'role_people_analytics', 'job_data_retail', 'sk_excel', 'critical', 'job', 'Refuerza Excel: estas en nivel 0 y el objetivo requiere nivel 4.', 'open', '2026-06-13 19:16:57.354917'::timestamp, '2026-06-14 12:53:40.356215'::timestamp),
  ('scg_stu_andrea_job_job_data_retail_sk_powerbi', 'stu_andrea', 'role_people_analytics', 'job_data_retail', 'sk_powerbi', 'critical', 'job', 'Refuerza Power BI: estas en nivel 1 y el objetivo requiere nivel 3.', 'open', '2026-06-13 19:16:57.354917'::timestamp, '2026-06-14 12:53:40.356215'::timestamp),
  ('scg_stu_andrea_job_job_data_retail_sk_sql', 'stu_andrea', 'role_people_analytics', 'job_data_retail', 'sk_sql', 'critical', 'job', 'Refuerza SQL: estas en nivel 0 y el objetivo requiere nivel 3.', 'open', '2026-06-13 19:16:57.354917'::timestamp, '2026-06-14 12:53:40.356215'::timestamp),
  ('scg_stu_andrea_role_role_people_analytics_sk_business_analytics', 'stu_andrea', 'role_people_analytics', NULL, 'sk_business_analytics', 'critical', 'role', 'Analizar metricas de talento.', 'open', '2026-06-14 12:43:48.707710'::timestamp, '2026-06-14 12:59:06.772971'::timestamp),
  ('scg_stu_andrea_role_role_people_analytics_sk_english', 'stu_andrea', 'role_people_analytics', NULL, 'sk_english', 'partial', 'role', 'Leer benchmarks de talento.', 'open', '2026-06-14 12:43:48.707710'::timestamp, '2026-06-14 12:59:06.772971'::timestamp),
  ('scg_stu_andrea_role_role_people_analytics_sk_excel', 'stu_andrea', 'role_people_analytics', NULL, 'sk_excel', 'partial', 'role', 'Preparar datos.', 'open', '2026-06-14 12:43:48.707710'::timestamp, '2026-06-14 12:59:06.772971'::timestamp),
  ('scg_stu_andrea_role_role_people_analytics_sk_human_resources', 'stu_andrea', 'role_people_analytics', NULL, 'sk_human_resources', 'critical', 'role', 'Entender datos de personas.', 'open', '2026-06-14 12:43:48.707710'::timestamp, '2026-06-14 12:59:06.772971'::timestamp),
  ('scg_stu_andrea_role_role_people_analytics_sk_powerbi', 'stu_andrea', 'role_people_analytics', NULL, 'sk_powerbi', 'partial', 'role', 'Construir reportes de RRHH.', 'open', '2026-06-14 12:43:48.707710'::timestamp, '2026-06-14 12:59:06.772971'::timestamp),
  ('scg_stu_camila_job_job_data_retail_sk_english', 'stu_camila', 'role_data_intern', 'job_data_retail', 'sk_english', 'partial', 'job', 'Refuerza Ingles: estas en nivel 1 y el objetivo requiere nivel 3.', 'open', '2026-06-13 20:14:28.830681'::timestamp, '2026-06-13 20:14:29.109296'::timestamp),
  ('scg_stu_camila_job_job_data_retail_sk_sql', 'stu_camila', 'role_data_intern', 'job_data_retail', 'sk_sql', 'critical', 'job', 'Refuerza SQL: estas en nivel 2 y el objetivo requiere nivel 3.', 'open', '2026-06-13 20:14:28.830681'::timestamp, '2026-06-13 20:14:29.109296'::timestamp),
  ('scg_stu_camila_role_role_data_intern_sk_business_intelligence', 'stu_camila', 'role_data_intern', NULL, 'sk_business_intelligence', 'partial', 'role', 'Necesario para convertir datos en indicadores de negocio.', 'open', '2026-06-13 16:00:01.387353'::timestamp, '2026-06-13 21:32:15.576605'::timestamp),
  ('scg_stu_camila_role_role_data_intern_sk_english', 'stu_camila', 'role_data_intern', NULL, 'sk_english', 'partial', 'role', 'Amplia acceso a vacantes y documentacion tecnica.', 'open', '2026-06-13 16:00:01.387353'::timestamp, '2026-06-13 21:32:15.576605'::timestamp),
  ('scg_stu_camila_role_role_data_intern_sk_problem_solving', 'stu_camila', 'role_data_intern', NULL, 'sk_problem_solving', 'partial', 'role', 'Necesario para estructurar problemas de datos y proponer acciones.', 'open', '2026-06-13 16:00:01.387353'::timestamp, '2026-06-13 21:32:15.576605'::timestamp),
  ('scg_stu_camila_role_role_data_intern_sk_sql', 'stu_camila', 'role_data_intern', NULL, 'sk_sql', 'critical', 'role', 'Necesario para consultar y cruzar datos.', 'open', '2026-06-13 16:00:01.387353'::timestamp, '2026-06-13 21:32:15.576605'::timestamp),
  ('scg_stu_nuevo_job_job_data_retail_sk_communication', 'stu_nuevo', 'role_data_intern', 'job_data_retail', 'sk_communication', 'partial', 'job', 'Refuerza Comunicacion: estas en nivel 0 y el objetivo requiere nivel 3.', 'open', '2026-06-13 21:45:52.441385'::timestamp, '2026-06-14 11:36:25.660362'::timestamp),
  ('scg_stu_nuevo_job_job_data_retail_sk_english', 'stu_nuevo', 'role_data_intern', 'job_data_retail', 'sk_english', 'partial', 'job', 'Refuerza Ingles: estas en nivel 0 y el objetivo requiere nivel 3.', 'open', '2026-06-13 21:45:52.441385'::timestamp, '2026-06-14 11:36:25.660362'::timestamp),
  ('scg_stu_nuevo_job_job_data_retail_sk_excel', 'stu_nuevo', 'role_data_intern', 'job_data_retail', 'sk_excel', 'critical', 'job', 'Refuerza Excel: estas en nivel 0 y el objetivo requiere nivel 4.', 'open', '2026-06-13 21:45:52.441385'::timestamp, '2026-06-14 11:36:25.660362'::timestamp),
  ('scg_stu_nuevo_job_job_data_retail_sk_sql', 'stu_nuevo', 'role_data_intern', 'job_data_retail', 'sk_sql', 'critical', 'job', 'Refuerza SQL: estas en nivel 0 y el objetivo requiere nivel 3.', 'open', '2026-06-13 21:45:52.441385'::timestamp, '2026-06-14 11:36:25.660362'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_business_intelligence', 'stu_nuevo', 'role_data_intern', NULL, 'sk_business_intelligence', 'partial', 'role', 'Necesario para convertir datos en indicadores de negocio.', 'resolved', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_communication', 'stu_nuevo', 'role_data_intern', NULL, 'sk_communication', 'partial', 'role', 'Explicar hallazgos a negocio.', 'open', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-14 11:40:29.559880'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_english', 'stu_nuevo', 'role_data_intern', NULL, 'sk_english', 'partial', 'role', 'Leer documentacion y reportes regionales.', 'open', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-14 11:40:29.559880'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_excel', 'stu_nuevo', 'role_data_intern', NULL, 'sk_excel', 'partial', 'role', 'Manejar bases y reportes operativos.', 'open', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-14 11:40:29.559880'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_powerbi', 'stu_nuevo', 'role_data_intern', NULL, 'sk_powerbi', 'partial', 'role', 'Necesario para construir tableros y comunicar indicadores.', 'resolved', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_problem_solving', 'stu_nuevo', 'role_data_intern', NULL, 'sk_problem_solving', 'partial', 'role', 'Necesario para estructurar problemas de datos y proponer acciones.', 'resolved', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-13 21:33:42.002338'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_python', 'stu_nuevo', 'role_data_intern', NULL, 'sk_python', 'partial', 'role', 'Automatizar limpieza y analisis basico.', 'open', '2026-06-13 22:14:50.039357'::timestamp, '2026-06-14 11:40:29.559880'::timestamp),
  ('scg_stu_nuevo_role_role_data_intern_sk_sql', 'stu_nuevo', 'role_data_intern', NULL, 'sk_sql', 'critical', 'role', 'Consultar y cruzar datos para analisis de negocio.', 'open', '2026-06-13 20:22:33.940078'::timestamp, '2026-06-14 11:40:29.559880'::timestamp)
ON CONFLICT DO NOTHING;

-- ============================================================
-- VALIDACIONES RAPIDAS (opcional)
-- ============================================================
-- SELECT role, count(*) FROM users GROUP BY role;
-- SELECT email FROM users WHERE onboarding_completed = false;  -- usuarios de prueba
