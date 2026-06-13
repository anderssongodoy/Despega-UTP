BEGIN;

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
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  role_id varchar,
  job_id varchar REFERENCES jobs(id) ON DELETE CASCADE,
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

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'chk_student_critical_gaps_source_scope'
  ) THEN
    ALTER TABLE student_critical_gaps
      ADD CONSTRAINT chk_student_critical_gaps_source_scope CHECK (
        (source = 'role' AND role_id IS NOT NULL AND job_id IS NULL)
        OR
        (source = 'job' AND job_id IS NOT NULL)
      );
  END IF;
END $$;

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

INSERT INTO skills (id, name, type, category) VALUES
  ('sk_algorithms', 'Algoritmos', 'technical', 'software'),
  ('sk_programming', 'Programacion', 'technical', 'software'),
  ('sk_oop', 'Programacion orientada a objetos', 'technical', 'software'),
  ('sk_database', 'Bases de datos', 'technical', 'data'),
  ('sk_excel', 'Excel', 'technical', 'office'),
  ('sk_sql', 'SQL', 'technical', 'data'),
  ('sk_web_development', 'Desarrollo web', 'technical', 'software'),
  ('sk_javascript', 'JavaScript', 'technical', 'software'),
  ('sk_project_management', 'Gestion de proyectos', 'soft', 'management'),
  ('sk_cybersecurity', 'Seguridad informatica', 'technical', 'cybersecurity'),
  ('sk_business_intelligence', 'Inteligencia de negocios', 'technical', 'data'),
  ('sk_cloud_services', 'Servicios cloud', 'technical', 'cloud'),
  ('sk_enterprise_architecture', 'Arquitectura empresarial', 'technical', 'architecture'),
  ('sk_it_service_management', 'Gestion del servicio TI', 'technical', 'it_management'),
  ('sk_process_management', 'Gestion por procesos', 'technical', 'operations'),
  ('sk_quality_management', 'Gestion de calidad', 'technical', 'quality'),
  ('sk_logistics', 'Logistica', 'technical', 'operations'),
  ('sk_operations_management', 'Gestion de operaciones', 'technical', 'operations'),
  ('sk_simulation', 'Simulacion', 'technical', 'operations'),
  ('sk_occupational_safety', 'Seguridad y salud ocupacional', 'technical', 'safety'),
  ('sk_supply_chain', 'Cadena de abastecimiento', 'technical', 'logistics'),
  ('sk_costs_budgets', 'Costos y presupuestos', 'technical', 'finance'),
  ('sk_process_automation', 'Automatizacion de procesos', 'technical', 'automation'),
  ('sk_environmental_management', 'Gestion del medio ambiente', 'technical', 'sustainability'),
  ('sk_legal_analysis', 'Analisis legal', 'technical', 'legal'),
  ('sk_legal_writing', 'Redaccion juridica', 'technical', 'legal'),
  ('sk_legal_argumentation', 'Argumentacion juridica', 'soft', 'legal'),
  ('sk_oral_litigation', 'Litigacion oral', 'soft', 'legal'),
  ('sk_labor_law', 'Derecho laboral', 'technical', 'legal'),
  ('sk_corporate_law', 'Derecho corporativo', 'technical', 'legal'),
  ('sk_tax_law', 'Derecho tributario', 'technical', 'legal'),
  ('sk_civil_procedure', 'Derecho procesal civil', 'technical', 'legal'),
  ('sk_criminal_law', 'Derecho penal', 'technical', 'legal'),
  ('sk_legal_research', 'Investigacion juridica', 'technical', 'legal'),
  ('sk_legal_ethics', 'Etica juridica', 'soft', 'legal'),
  ('sk_behavior_observation', 'Observacion del comportamiento', 'technical', 'psychology'),
  ('sk_psychological_interview', 'Entrevista psicologica', 'soft', 'psychology'),
  ('sk_psychometrics', 'Psicometria', 'technical', 'psychology'),
  ('sk_psychopathology', 'Psicopatologia', 'technical', 'psychology'),
  ('sk_differential_diagnosis', 'Diagnostico diferencial', 'technical', 'psychology'),
  ('sk_group_dynamics', 'Dinamica de grupos', 'soft', 'psychology'),
  ('sk_educational_psychology', 'Psicologia educativa', 'technical', 'psychology'),
  ('sk_vocational_diagnosis', 'Diagnostico vocacional', 'technical', 'psychology'),
  ('sk_human_resources', 'Gestion humana', 'soft', 'management'),
  ('sk_psychotherapeutic_techniques', 'Tecnicas psicoterapeuticas', 'technical', 'psychology'),
  ('sk_mental_health', 'Salud mental', 'technical', 'psychology'),
  ('sk_organizational_consulting', 'Consultoria organizacional', 'soft', 'psychology'),
  ('sk_business_management', 'Gestion general', 'soft', 'management'),
  ('sk_accounting', 'Contabilidad', 'technical', 'finance'),
  ('sk_finance', 'Finanzas', 'technical', 'finance'),
  ('sk_business_it', 'Informatica para los negocios', 'technical', 'business'),
  ('sk_marketing', 'Marketing', 'soft', 'marketing'),
  ('sk_market_research', 'Investigacion de mercados', 'technical', 'marketing'),
  ('sk_business_analytics', 'Analitica de datos', 'technical', 'data'),
  ('sk_sales_management', 'Gestion de ventas', 'soft', 'sales'),
  ('sk_human_talent_management', 'Gestion del talento humano', 'soft', 'management'),
  ('sk_digital_business', 'Negocios digitales', 'technical', 'business'),
  ('sk_negotiation', 'Negociacion', 'soft', 'business'),
  ('sk_strategic_management', 'Direccion estrategica', 'soft', 'management'),
  ('sk_commercial_management', 'Direccion comercial', 'soft', 'sales'),
  ('sk_budget_evaluation', 'Evaluacion presupuestal', 'technical', 'finance'),
  ('sk_powerbi', 'Power BI', 'technical', 'data'),
  ('sk_python', 'Python', 'technical', 'data'),
  ('sk_communication', 'Comunicacion', 'soft', 'soft_skills'),
  ('sk_effective_communication', 'Comunicacion efectiva', 'soft', 'soft_skills'),
  ('sk_english', 'Ingles', 'language', 'language'),
  ('sk_problem_solving', 'Resolucion de problemas', 'soft', 'soft_skills'),
  ('sk_teamwork', 'Trabajo en equipo', 'soft', 'soft_skills'),
  ('sk_leadership', 'Liderazgo', 'soft', 'soft_skills'),
  ('sk_scrum', 'Scrum', 'soft', 'agile'),
  ('sk_kanban', 'Kanban', 'soft', 'agile'),
  ('sk_git', 'Git', 'technical', 'software'),
  ('sk_gitflow', 'GitFlow', 'technical', 'software'),
  ('sk_jira', 'Jira', 'technical', 'project_management'),
  ('sk_bitbucket', 'Bitbucket', 'technical', 'software'),
  ('sk_qa', 'QA', 'technical', 'quality'),
  ('sk_cicd', 'CI/CD', 'technical', 'devops')
ON CONFLICT (id) DO NOTHING;

INSERT INTO role_skill_requirements
  (id, role_id, skill_id, required_level, priority, reason)
VALUES
  ('rsr_role_data_intern_excel', 'role_data_intern', 'sk_excel', 4, 'critical', 'Base para limpieza, analisis y reportes operativos.'),
  ('rsr_role_data_intern_sql', 'role_data_intern', 'sk_sql', 3, 'critical', 'Necesario para consultar y cruzar datos.'),
  ('rsr_role_data_intern_powerbi', 'role_data_intern', 'sk_powerbi', 3, 'important', 'Necesario para construir tableros y comunicar indicadores.'),
  ('rsr_role_data_intern_business_intelligence', 'role_data_intern', 'sk_business_intelligence', 3, 'important', 'Necesario para convertir datos en indicadores de negocio.'),
  ('rsr_role_data_intern_communication', 'role_data_intern', 'sk_communication', 3, 'important', 'Necesario para explicar hallazgos a negocio.'),
  ('rsr_role_data_intern_english', 'role_data_intern', 'sk_english', 3, 'important', 'Amplia acceso a vacantes y documentacion tecnica.'),
  ('rsr_role_data_intern_problem_solving', 'role_data_intern', 'sk_problem_solving', 3, 'important', 'Necesario para estructurar problemas de datos y proponer acciones.')
ON CONFLICT (role_id, skill_id) DO NOTHING;

COMMIT;
