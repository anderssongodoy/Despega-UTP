-- ============================================================
-- DESPEGA UTP - SCRIPT UNICO DE DEMO PARA JUECES
-- Archivo: despega_utp_demo.sql
-- Ejecutar sobre base de datos: despega_utp
-- Password demo: demo123
-- ============================================================

BEGIN;

-- ============================================================
-- 1. ESQUEMA BASE Y DATA INICIAL
-- Fuente: init_postgres_demo.sql
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

INSERT INTO users (id, name, email, role, auth_provider, password_hash, onboarding_completed) VALUES
  ('stu_camila', 'Camila Torres', 'camila.torres@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_diego', 'Diego Ramos', 'diego.ramos@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_valeria', 'Valeria Paredes', 'valeria.paredes@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_luis', 'Luis Mendoza', 'luis.mendoza@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_andrea', 'Andrea Salazar', 'andrea.salazar@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_renzo', 'Renzo Castillo', 'renzo.castillo@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_mateo', 'Mateo Rivas', 'mateo.rivas@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_lucia', 'Lucia Herrera', 'lucia.herrera@utp.edu.pe', 'student', 'microsoft', NULL, true),
  ('stu_nuevo', 'Nuevo Estudiante', 'nuevo.estudiante@utp.edu.pe', 'student', 'microsoft', NULL, false),
  ('usr_recruiter_ana', 'Ana Reclutadora', 'ana@retailandino.pe', 'company', 'credentials', 'demo-password-hash', true),
  ('usr_recruiter_talento', 'Paola Talento', 'paola@talentolab.pe', 'company', 'credentials', 'demo-password-hash', true),
  ('advisor_utp', 'Asesor Empleabilidad', 'asesor@utp.edu.pe', 'advisor', 'microsoft', NULL, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO students (id, career, cycle, campus, modality, availability, english_level, linkedin_url, cv_status) VALUES
  ('stu_camila', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'https://linkedin.com/in/camila-torres-utp', 'incomplete'),
  ('stu_diego', 'Administracion', 7, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', NULL, 'incomplete'),
  ('stu_valeria', 'Marketing', 6, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/valeria-paredes-utp', 'updated'),
  ('stu_luis', 'Ingenieria Industrial', 9, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', NULL, 'updated'),
  ('stu_andrea', 'Psicologia', 8, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', NULL, 'incomplete'),
  ('stu_renzo', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Norte', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'https://linkedin.com/in/renzo-castillo-utp', 'updated'),
  ('stu_mateo', 'Ingenieria de Software', 9, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/mateo-rivas-utp', 'updated'),
  ('stu_lucia', 'Comunicaciones', 7, 'Lima Centro', 'Semipresencial', 'Medio tiempo', 'Intermedio', NULL, 'incomplete')
ON CONFLICT (id) DO NOTHING;

INSERT INTO companies (id, name, sector, description) VALUES
  ('comp_retail_andino', 'Retail Andino', 'Retail', 'Cadena retail con operaciones comerciales y analitica de ventas.'),
  ('comp_finanzas_nova', 'Finanzas Nova', 'Servicios financieros', 'Fintech local con foco en reportes y eficiencia financiera.'),
  ('comp_logisur', 'Logisur', 'Logistica', 'Operador logistico con procesos de almacen y distribucion.'),
  ('comp_talentolab', 'TalentoLab', 'Consultoria RRHH', 'Consultora de talento, clima laboral y seleccion.'),
  ('comp_datamarket', 'DataMarket Peru', 'Tecnologia / datos', 'Empresa de soluciones de datos y software interno.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO company_users (id, user_id, company_id, position) VALUES
  ('cu_retail_ana', 'usr_recruiter_ana', 'comp_retail_andino', 'Reclutadora'),
  ('cu_talentolab_paola', 'usr_recruiter_talento', 'comp_talentolab', 'People Partner')
ON CONFLICT (id) DO NOTHING;

INSERT INTO skills (id, name, type, category) VALUES
  ('sk_excel', 'Excel', 'technical', 'office'),
  ('sk_powerbi', 'Power BI', 'technical', 'data'),
  ('sk_sql', 'SQL', 'technical', 'data'),
  ('sk_python', 'Python', 'technical', 'data'),
  ('sk_git', 'Git', 'technical', 'software'),
  ('sk_api', 'APIs REST', 'technical', 'software'),
  ('sk_testing', 'Pruebas unitarias', 'technical', 'software'),
  ('sk_communication', 'Comunicacion', 'soft', 'soft_skills'),
  ('sk_teamwork', 'Trabajo en equipo', 'soft', 'soft_skills'),
  ('sk_problem_solving', 'Resolucion de problemas', 'soft', 'soft_skills'),
  ('sk_interview', 'Entrevista', 'soft', 'employability'),
  ('sk_english', 'Ingles', 'language', 'language'),
  ('sk_copywriting', 'Redaccion', 'soft', 'communication'),
  ('sk_analytics_marketing', 'Metricas digitales', 'technical', 'marketing'),
  ('sk_hr_interviews', 'Entrevistas semiestructuradas', 'soft', 'hr'),
  ('sk_process_analysis', 'Analisis de procesos', 'technical', 'operations')
ON CONFLICT (id) DO NOTHING;

INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active) VALUES
  ('goal_camila_data', 'stu_camila', 'role_data_intern', 'Practicante de Analisis de Datos', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true),
  ('goal_diego_commercial', 'stu_diego', 'role_commercial_analyst', 'Asistente Comercial Junior', 'Medio tiempo', 'Hibrido', 'Este mes', true),
  ('goal_valeria_marketing', 'stu_valeria', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Practicas preprofesionales - 30h', 'Hibrido', 'Este mes', true),
  ('goal_luis_ops', 'stu_luis', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h', 'Presencial', 'Este mes', true),
  ('goal_andrea_people', 'stu_andrea', 'role_people_analytics', 'Practicante de People Analytics', 'Medio tiempo', 'Remoto', 'En las proximas 4 semanas', true),
  ('goal_renzo_support', 'stu_renzo', 'role_it_support', 'Soporte TI Junior', 'Tiempo completo', 'Presencial', 'Este mes', true),
  ('goal_mateo_dev', 'stu_mateo', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true),
  ('goal_lucia_mkt_analytics', 'stu_lucia', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Medio tiempo', 'Hibrido', 'En las proximas 4 semanas', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO student_skills (id, student_id, skill_id, level, source) VALUES
  ('ss_camila_excel', 'stu_camila', 'sk_excel', 4, 'evidence'),
  ('ss_camila_powerbi', 'stu_camila', 'sk_powerbi', 3, 'evidence'),
  ('ss_camila_sql', 'stu_camila', 'sk_sql', 2, 'self_reported'),
  ('ss_camila_english', 'stu_camila', 'sk_english', 1, 'self_reported'),
  ('ss_camila_comm', 'stu_camila', 'sk_communication', 3, 'evidence'),
  ('ss_camila_interview', 'stu_camila', 'sk_interview', 2, 'self_reported'),
  ('ss_diego_excel', 'stu_diego', 'sk_excel', 3, 'self_reported'),
  ('ss_diego_comm', 'stu_diego', 'sk_communication', 4, 'self_reported'),
  ('ss_diego_powerbi', 'stu_diego', 'sk_powerbi', 1, 'self_reported'),
  ('ss_valeria_copy', 'stu_valeria', 'sk_copywriting', 4, 'evidence'),
  ('ss_valeria_metrics', 'stu_valeria', 'sk_analytics_marketing', 3, 'evidence'),
  ('ss_valeria_powerbi', 'stu_valeria', 'sk_powerbi', 2, 'self_reported'),
  ('ss_luis_process', 'stu_luis', 'sk_process_analysis', 4, 'evidence'),
  ('ss_luis_excel', 'stu_luis', 'sk_excel', 3, 'self_reported'),
  ('ss_luis_sql', 'stu_luis', 'sk_sql', 1, 'self_reported'),
  ('ss_andrea_hr', 'stu_andrea', 'sk_hr_interviews', 4, 'evidence'),
  ('ss_andrea_comm', 'stu_andrea', 'sk_communication', 5, 'evidence'),
  ('ss_andrea_python', 'stu_andrea', 'sk_python', 1, 'self_reported'),
  ('ss_andrea_powerbi', 'stu_andrea', 'sk_powerbi', 1, 'self_reported'),
  ('ss_renzo_sql', 'stu_renzo', 'sk_sql', 3, 'evidence'),
  ('ss_renzo_python', 'stu_renzo', 'sk_python', 2, 'self_reported'),
  ('ss_renzo_comm', 'stu_renzo', 'sk_communication', 2, 'self_reported'),
  ('ss_mateo_python', 'stu_mateo', 'sk_python', 4, 'evidence'),
  ('ss_mateo_git', 'stu_mateo', 'sk_git', 4, 'evidence'),
  ('ss_mateo_api', 'stu_mateo', 'sk_api', 4, 'evidence'),
  ('ss_mateo_testing', 'stu_mateo', 'sk_testing', 3, 'evidence'),
  ('ss_mateo_comm', 'stu_mateo', 'sk_communication', 2, 'self_reported'),
  ('ss_lucia_copy', 'stu_lucia', 'sk_copywriting', 4, 'evidence'),
  ('ss_lucia_metrics', 'stu_lucia', 'sk_analytics_marketing', 3, 'evidence'),
  ('ss_lucia_excel', 'stu_lucia', 'sk_excel', 2, 'self_reported'),
  ('ss_lucia_powerbi', 'stu_lucia', 'sk_powerbi', 1, 'self_reported')
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source) VALUES
  ('ev_camila_dashboard', 'stu_camila', 'Dashboard de ventas para curso de BI', 'academic_project', 'Proyecto final de curso', 'Limpie datos en Excel y cree un dashboard en Power BI para analizar ventas.', 'El equipo identifico productos con mayor margen y presento recomendaciones.', 'Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel, identificando productos de mayor margen para apoyar decisiones comerciales.', 'Situacion: proyecto final de BI. Tarea: convertir una base desordenada en insight. Accion: limpie datos, modele indicadores y cree dashboard. Resultado: el equipo priorizo productos de mayor margen.', 'onboarding'),
  ('ev_camila_family', 'stu_camila', 'Atencion al cliente en negocio familiar', 'family_business', 'Apoyo operativo en tienda familiar', 'Registre pedidos, ordene incidencias y respondi consultas de clientes.', 'Se redujeron errores de pedido usando una lista de control.', 'Gestione atencion a clientes y registro de pedidos, reduciendo errores mediante una lista de control.', 'Situacion: tienda familiar con errores frecuentes. Accion: cree checklist y seguimiento. Resultado: menos reclamos y mejor orden.', 'manual'),
  ('ev_mateo_api', 'stu_mateo', 'API de reservas con Python', 'academic_project', 'Curso de arquitectura de software', 'Construyo endpoints REST, modelo de datos y pruebas unitarias para reservas.', 'El prototipo permitio registrar y consultar reservas sin errores criticos.', 'Construyo una API REST en Python con pruebas unitarias para gestionar reservas academicas.', 'Situacion: proyecto de curso. Accion: diseno endpoints y pruebas. Resultado: API funcional para demo tecnica.', 'onboarding'),
  ('ev_andrea_clima', 'stu_andrea', 'Encuesta de clima para proyecto academico', 'academic_project', 'Curso de psicologia organizacional', 'Diseno encuesta, aplico entrevistas y sintetizo hallazgos de clima.', 'Se identificaron factores de motivacion y riesgo para el equipo analizado.', 'Disene y analice una encuesta de clima organizacional, sintetizando hallazgos accionables para mejorar motivacion del equipo.', 'Situacion: diagnostico de clima. Accion: encuesta y entrevistas. Resultado: hallazgos priorizados.', 'onboarding'),
  ('ev_lucia_campaign', 'stu_lucia', 'Campana de contenidos para emprendimiento', 'academic_project', 'Proyecto de comunicacion digital', 'Planifico calendario, redacto piezas y midio engagement de publicaciones.', 'El reporte identifico formatos con mayor interaccion.', 'Planifique y analice una campana de contenidos, usando metricas de engagement para recomendar formatos con mejor desempeno.', 'Situacion: emprendimiento sin lectura de metricas. Accion: calendario y reporte. Resultado: formatos priorizados.', 'onboarding'),
  ('ev_renzo_support', 'stu_renzo', 'Documentacion de incidencias TI', 'work_experience', 'Apoyo a laboratorio de computo', 'Registro incidencias, clasifico causas y documento soluciones frecuentes.', 'Se redujo el tiempo de respuesta para incidencias repetidas.', 'Documente incidencias TI y soluciones frecuentes, reduciendo tiempos de atencion para problemas repetidos.', 'Situacion: incidencias recurrentes. Accion: registro y documentacion. Resultado: respuesta mas rapida.', 'manual'),
  ('ev_luis_process', 'stu_luis', 'Analisis de tiempos de proceso', 'academic_project', 'Curso de gestion de operaciones', 'Medi tiempos, identifique cuellos de botella y propuse redistribucion de tareas.', 'La propuesta reducia tiempos estimados en el flujo simulado.', 'Analice tiempos de proceso e identifique cuellos de botella para proponer mejoras operativas.', 'Situacion: flujo lento. Accion: medicion y analisis. Resultado: propuesta de mejora.', 'onboarding'),
  ('ev_valeria_social', 'stu_valeria', 'Reporte de redes para marca local', 'academic_project', 'Curso de marketing digital', 'Compare publicaciones por alcance, interaccion y conversion estimada.', 'Se priorizaron formatos cortos con mayor engagement.', 'Analice metricas de redes sociales y recomende formatos de contenido con mayor engagement.', 'Situacion: marca sin analisis. Accion: reporte de metricas. Resultado: recomendacion de formatos.', 'manual')
ON CONFLICT (id) DO NOTHING;

INSERT INTO evidence_skills (id, evidence_id, skill_id, confidence) VALUES
  ('esk_camila_dash_excel', 'ev_camila_dashboard', 'sk_excel', 90),
  ('esk_camila_dash_powerbi', 'ev_camila_dashboard', 'sk_powerbi', 85),
  ('esk_camila_dash_comm', 'ev_camila_dashboard', 'sk_communication', 70),
  ('esk_camila_family_comm', 'ev_camila_family', 'sk_communication', 80),
  ('esk_camila_family_problem', 'ev_camila_family', 'sk_problem_solving', 75),
  ('esk_mateo_api_python', 'ev_mateo_api', 'sk_python', 90),
  ('esk_mateo_api_api', 'ev_mateo_api', 'sk_api', 90),
  ('esk_mateo_api_testing', 'ev_mateo_api', 'sk_testing', 80),
  ('esk_andrea_hr', 'ev_andrea_clima', 'sk_hr_interviews', 90),
  ('esk_andrea_comm', 'ev_andrea_clima', 'sk_communication', 95),
  ('esk_lucia_copy', 'ev_lucia_campaign', 'sk_copywriting', 88),
  ('esk_lucia_metrics', 'ev_lucia_campaign', 'sk_analytics_marketing', 75),
  ('esk_renzo_sql', 'ev_renzo_support', 'sk_sql', 65),
  ('esk_luis_process', 'ev_luis_process', 'sk_process_analysis', 88),
  ('esk_valeria_metrics', 'ev_valeria_social', 'sk_analytics_marketing', 85)
ON CONFLICT (id) DO NOTHING;

INSERT INTO jobs (id, company_id, role_id, title, modality, location, hours, description, status) VALUES
  ('job_data_retail', 'comp_retail_andino', 'role_data_intern', 'Practicante de Analisis de Datos', 'Hibrido', 'Lima', '30h semanales', 'Apoyar reportes comerciales, limpieza de bases y tableros de seguimiento para decisiones retail.', 'active'),
  ('job_commercial_retail', 'comp_retail_andino', 'role_commercial_analyst', 'Asistente Comercial Junior', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar seguimiento comercial, reportes de ventas y coordinacion con tiendas.', 'active'),
  ('job_ops_retail', 'comp_retail_andino', 'role_operations_intern', 'Practicante de Operaciones Retail', 'Presencial', 'Lima', '30h semanales', 'Analizar procesos de tienda, inventario y tiempos de reposicion.', 'active'),
  ('job_bi_finanzas', 'comp_finanzas_nova', 'role_data_intern', 'Practicante BI Junior', 'Remoto', 'Lima', '30h semanales', 'Construir reportes y dashboards para el area financiera.', 'active'),
  ('job_operations_logisur', 'comp_logisur', 'role_operations_intern', 'Practicante de Operaciones', 'Presencial', 'Lima', '30h semanales', 'Apoyar analisis de procesos logisticos y mejora continua.', 'active'),
  ('job_marketing_talentolab', 'comp_talentolab', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar contenidos, pauta basica y reportes de campanas.', 'active'),
  ('job_hr_talentolab', 'comp_talentolab', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Remoto', 'Lima', 'Medio tiempo', 'Apoyar entrevistas, clima laboral y seguimiento de candidatos.', 'active'),
  ('job_support_datamarket', 'comp_datamarket', 'role_it_support', 'Soporte TI Junior', 'Presencial', 'Lima', 'Tiempo completo', 'Atender incidencias, documentar soluciones y apoyar soporte interno.', 'active'),
  ('job_dev_datamarket', 'comp_datamarket', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Hibrido', 'Lima', '30h semanales', 'Construir funcionalidades internas, APIs y documentacion tecnica.', 'active'),
  ('job_people_analytics_talentolab', 'comp_talentolab', 'role_people_analytics', 'Practicante de People Analytics', 'Remoto', 'Lima', 'Medio tiempo', 'Analizar encuestas, clima laboral y datos de talento.', 'active'),
  ('job_marketing_analytics_talentolab', 'comp_talentolab', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Hibrido', 'Lima', 'Medio tiempo', 'Leer metricas digitales y proponer mejoras de contenido.', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO job_requirements (id, job_id, skill_id, required_level, importance) VALUES
  ('jr_data_excel', 'job_data_retail', 'sk_excel', 4, 'critical'),
  ('jr_data_powerbi', 'job_data_retail', 'sk_powerbi', 3, 'critical'),
  ('jr_data_sql', 'job_data_retail', 'sk_sql', 3, 'critical'),
  ('jr_data_english', 'job_data_retail', 'sk_english', 3, 'critical'),
  ('jr_data_interview', 'job_data_retail', 'sk_interview', 3, 'important'),
  ('jr_commercial_excel', 'job_commercial_retail', 'sk_excel', 3, 'critical'),
  ('jr_commercial_comm', 'job_commercial_retail', 'sk_communication', 4, 'critical'),
  ('jr_commercial_powerbi', 'job_commercial_retail', 'sk_powerbi', 2, 'important'),
  ('jr_ops_process_retail', 'job_ops_retail', 'sk_process_analysis', 3, 'critical'),
  ('jr_ops_excel_retail', 'job_ops_retail', 'sk_excel', 3, 'critical'),
  ('jr_bi_powerbi', 'job_bi_finanzas', 'sk_powerbi', 4, 'critical'),
  ('jr_bi_sql', 'job_bi_finanzas', 'sk_sql', 3, 'critical'),
  ('jr_bi_english', 'job_bi_finanzas', 'sk_english', 3, 'important'),
  ('jr_ops_process_logisur', 'job_operations_logisur', 'sk_process_analysis', 4, 'critical'),
  ('jr_ops_excel_logisur', 'job_operations_logisur', 'sk_excel', 3, 'important'),
  ('jr_marketing_copy', 'job_marketing_talentolab', 'sk_copywriting', 4, 'critical'),
  ('jr_marketing_metrics', 'job_marketing_talentolab', 'sk_analytics_marketing', 3, 'important'),
  ('jr_hr_interviews', 'job_hr_talentolab', 'sk_hr_interviews', 4, 'critical'),
  ('jr_hr_comm', 'job_hr_talentolab', 'sk_communication', 4, 'critical'),
  ('jr_support_sql', 'job_support_datamarket', 'sk_sql', 2, 'important'),
  ('jr_support_comm', 'job_support_datamarket', 'sk_communication', 3, 'critical'),
  ('jr_dev_python', 'job_dev_datamarket', 'sk_python', 4, 'critical'),
  ('jr_dev_api', 'job_dev_datamarket', 'sk_api', 4, 'critical'),
  ('jr_dev_git', 'job_dev_datamarket', 'sk_git', 3, 'important'),
  ('jr_dev_comm', 'job_dev_datamarket', 'sk_communication', 3, 'important'),
  ('jr_people_python', 'job_people_analytics_talentolab', 'sk_python', 3, 'critical'),
  ('jr_people_powerbi', 'job_people_analytics_talentolab', 'sk_powerbi', 3, 'critical'),
  ('jr_people_hr', 'job_people_analytics_talentolab', 'sk_hr_interviews', 3, 'important'),
  ('jr_mkt_analytics_metrics', 'job_marketing_analytics_talentolab', 'sk_analytics_marketing', 3, 'critical'),
  ('jr_mkt_analytics_excel', 'job_marketing_analytics_talentolab', 'sk_excel', 3, 'critical'),
  ('jr_mkt_analytics_powerbi', 'job_marketing_analytics_talentolab', 'sk_powerbi', 2, 'important'),
  ('jr_mkt_analytics_copy', 'job_marketing_analytics_talentolab', 'sk_copywriting', 3, 'important')
ON CONFLICT (id) DO NOTHING;

INSERT INTO applications (id, student_id, job_id, status, notes) VALUES
  ('app_camila_data_retail', 'stu_camila', 'job_data_retail', 'prepared', 'CV ajustado pendiente de enviar.'),
  ('app_camila_bi_finanzas', 'stu_camila', 'job_bi_finanzas', 'prepared', 'Aspiracional: reforzar SQL antes de postular.'),
  ('app_mateo_dev', 'stu_mateo', 'job_dev_datamarket', 'prepared', 'Buen fit tecnico; practicar pitch tecnico.'),
  ('app_andrea_people', 'stu_andrea', 'job_people_analytics_talentolab', 'prepared', 'Reforzar Python basico.'),
  ('app_lucia_marketing_analytics', 'stu_lucia', 'job_marketing_analytics_talentolab', 'prepared', 'Completar evidencia de metricas.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO challenge_submissions (id, challenge_id, student_id, answers_json, score, feedback, generated_evidence_id) VALUES
  ('sub_camila_sales_insight', 'cha_sales_insight', 'stu_camila', '{"summary":"Mayor margen en categorias de baja rotacion","recommendation":"Priorizar surtido y seguimiento semanal"}', 82, 'Buen analisis comercial; falta explicar supuestos.', NULL),
  ('sub_mateo_soft_story', 'cha_soft_skills_technical_story', 'stu_mateo', '{"technicalDecision":"API REST con capas","businessExplanation":"Separar capas facilita mantenimiento y reduce errores"}', 74, 'La explicacion es clara, puede cerrar con impacto de negocio.', NULL),
  ('sub_andrea_people_python', 'cha_people_analytics_python', 'stu_andrea', '{"dataset":"encuesta clima","finding":"satisfaccion menor en comunicacion interna"}', 71, 'Buen enfoque humano; falta detalle tecnico de analisis.', NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 2. SKILLS REALES, ROLE REQUIREMENTS Y CRITICAL GAPS
-- Fuente: seed_real_skills_requirements_and_critical_gaps.sql
-- ============================================================

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

-- ============================================================
-- 3. DATA DEMO INTERCORP, ESTUDIANTES, EMPRESAS Y VACANTES
-- Fuente: seed_demo_intercorp_students_companies.sql
-- ============================================================

-- Demo Intercorp seed: students, companies, jobs, skills and critical gaps.
-- Safe to rerun. Preserves existing data.


INSERT INTO skills (id, name, type, category) VALUES
  ('sk_algorithms', 'Algoritmos', 'technical', 'software'),
  ('sk_programming', 'Programacion', 'technical', 'software'),
  ('sk_oop', 'Programacion orientada a objetos', 'technical', 'software'),
  ('sk_database', 'Bases de datos', 'technical', 'data'),
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
  ('sk_excel', 'Excel', 'technical', 'office'),
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

INSERT INTO role_skill_requirements (id, role_id, skill_id, required_level, priority, reason) VALUES
  ('rsr_demo_data_sql', 'role_data_intern', 'sk_sql', 3, 'critical', 'Consultar y cruzar datos para analisis de negocio.'),
  ('rsr_demo_data_powerbi', 'role_data_intern', 'sk_powerbi', 3, 'critical', 'Construir tableros de seguimiento.'),
  ('rsr_demo_data_python', 'role_data_intern', 'sk_python', 2, 'important', 'Automatizar limpieza y analisis basico.'),
  ('rsr_demo_data_bi', 'role_data_intern', 'sk_business_intelligence', 3, 'important', 'Convertir datos en indicadores accionables.'),
  ('rsr_demo_data_excel', 'role_data_intern', 'sk_excel', 4, 'important', 'Manejar bases y reportes operativos.'),
  ('rsr_demo_data_comm', 'role_data_intern', 'sk_communication', 3, 'important', 'Explicar hallazgos a negocio.'),
  ('rsr_demo_data_english', 'role_data_intern', 'sk_english', 3, 'important', 'Leer documentacion y reportes regionales.'),
  ('rsr_demo_software_programming', 'role_software_intern', 'sk_programming', 3, 'critical', 'Construir funcionalidades mantenibles.'),
  ('rsr_demo_software_oop', 'role_software_intern', 'sk_oop', 3, 'critical', 'Modelar soluciones orientadas a objetos.'),
  ('rsr_demo_software_database', 'role_software_intern', 'sk_database', 3, 'important', 'Persistir y consultar datos de aplicacion.'),
  ('rsr_demo_software_git', 'role_software_intern', 'sk_git', 2, 'important', 'Colaborar en repositorios de codigo.'),
  ('rsr_demo_software_web', 'role_software_intern', 'sk_web_development', 3, 'important', 'Desarrollar interfaces o APIs web.'),
  ('rsr_demo_software_js', 'role_software_intern', 'sk_javascript', 3, 'important', 'Implementar funcionalidades frontend o fullstack.'),
  ('rsr_demo_software_problem', 'role_software_intern', 'sk_problem_solving', 3, 'important', 'Resolver bugs y requerimientos ambiguos.'),
  ('rsr_demo_software_english', 'role_software_intern', 'sk_english', 2, 'optional', 'Leer documentacion tecnica.'),
  ('rsr_demo_it_itil', 'role_it_support', 'sk_it_service_management', 3, 'critical', 'Gestionar tickets e incidencias TI.'),
  ('rsr_demo_it_comm', 'role_it_support', 'sk_communication', 3, 'critical', 'Atender usuarios internos con claridad.'),
  ('rsr_demo_it_problem', 'role_it_support', 'sk_problem_solving', 3, 'important', 'Diagnosticar incidentes frecuentes.'),
  ('rsr_demo_it_security', 'role_it_support', 'sk_cybersecurity', 2, 'important', 'Aplicar buenas practicas de seguridad.'),
  ('rsr_demo_it_english', 'role_it_support', 'sk_english', 2, 'optional', 'Usar documentacion tecnica.'),
  ('rsr_demo_marketing_marketing', 'role_marketing_assistant', 'sk_marketing', 3, 'critical', 'Ejecutar acciones de marketing.'),
  ('rsr_demo_marketing_research', 'role_marketing_assistant', 'sk_market_research', 3, 'important', 'Entender clientes y campanas.'),
  ('rsr_demo_marketing_comm', 'role_marketing_assistant', 'sk_communication', 3, 'critical', 'Comunicar mensajes de marca.'),
  ('rsr_demo_marketing_excel', 'role_marketing_assistant', 'sk_excel', 3, 'important', 'Ordenar reportes de campana.'),
  ('rsr_demo_marketing_english', 'role_marketing_assistant', 'sk_english', 2, 'optional', 'Leer referencias de mercado.'),
  ('rsr_demo_mkt_analytics_marketing', 'role_marketing_analytics', 'sk_marketing', 3, 'critical', 'Entender objetivos de marketing.'),
  ('rsr_demo_mkt_analytics_ba', 'role_marketing_analytics', 'sk_business_analytics', 3, 'critical', 'Analizar desempeno de campanas.'),
  ('rsr_demo_mkt_analytics_powerbi', 'role_marketing_analytics', 'sk_powerbi', 3, 'important', 'Visualizar indicadores.'),
  ('rsr_demo_mkt_analytics_excel', 'role_marketing_analytics', 'sk_excel', 3, 'important', 'Preparar bases de datos.'),
  ('rsr_demo_mkt_analytics_research', 'role_marketing_analytics', 'sk_market_research', 3, 'important', 'Interpretar comportamiento del consumidor.'),
  ('rsr_demo_mkt_analytics_comm', 'role_marketing_analytics', 'sk_communication', 3, 'important', 'Presentar hallazgos.'),
  ('rsr_demo_mkt_analytics_english', 'role_marketing_analytics', 'sk_english', 2, 'optional', 'Leer benchmarks.'),
  ('rsr_demo_ops_operations', 'role_operations_intern', 'sk_operations_management', 3, 'critical', 'Gestionar flujos operativos.'),
  ('rsr_demo_ops_process', 'role_operations_intern', 'sk_process_management', 3, 'critical', 'Documentar y mejorar procesos.'),
  ('rsr_demo_ops_logistics', 'role_operations_intern', 'sk_logistics', 3, 'important', 'Coordinar abastecimiento y almacenes.'),
  ('rsr_demo_ops_quality', 'role_operations_intern', 'sk_quality_management', 3, 'important', 'Controlar calidad operativa.'),
  ('rsr_demo_ops_excel', 'role_operations_intern', 'sk_excel', 3, 'important', 'Analizar reportes operativos.'),
  ('rsr_demo_ops_powerbi', 'role_operations_intern', 'sk_powerbi', 2, 'important', 'Monitorear indicadores.'),
  ('rsr_demo_ops_problem', 'role_operations_intern', 'sk_problem_solving', 3, 'important', 'Resolver cuellos de botella.'),
  ('rsr_demo_ops_english', 'role_operations_intern', 'sk_english', 2, 'optional', 'Leer procedimientos.'),
  ('rsr_demo_commercial_commercial', 'role_commercial_analyst', 'sk_commercial_management', 3, 'critical', 'Gestionar indicadores comerciales.'),
  ('rsr_demo_commercial_sales', 'role_commercial_analyst', 'sk_sales_management', 3, 'important', 'Analizar ventas y objetivos.'),
  ('rsr_demo_commercial_excel', 'role_commercial_analyst', 'sk_excel', 3, 'critical', 'Trabajar reportes comerciales.'),
  ('rsr_demo_commercial_finance', 'role_commercial_analyst', 'sk_finance', 3, 'important', 'Entender rentabilidad y margen.'),
  ('rsr_demo_commercial_negotiation', 'role_commercial_analyst', 'sk_negotiation', 3, 'important', 'Coordinar acuerdos internos o externos.'),
  ('rsr_demo_commercial_comm', 'role_commercial_analyst', 'sk_communication', 3, 'important', 'Comunicar resultados comerciales.'),
  ('rsr_demo_commercial_english', 'role_commercial_analyst', 'sk_english', 2, 'optional', 'Leer informacion regional.'),
  ('rsr_demo_hr_talent', 'role_hr_intern', 'sk_human_talent_management', 3, 'critical', 'Apoyar procesos de talento.'),
  ('rsr_demo_hr_human_resources', 'role_hr_intern', 'sk_human_resources', 3, 'critical', 'Gestionar informacion de personas.'),
  ('rsr_demo_hr_comm', 'role_hr_intern', 'sk_communication', 3, 'critical', 'Comunicarse con candidatos y equipos.'),
  ('rsr_demo_hr_groups', 'role_hr_intern', 'sk_group_dynamics', 3, 'important', 'Facilitar actividades grupales.'),
  ('rsr_demo_hr_interview', 'role_hr_intern', 'sk_psychological_interview', 3, 'important', 'Apoyar entrevistas.'),
  ('rsr_demo_hr_english', 'role_hr_intern', 'sk_english', 2, 'optional', 'Leer referencias de talento.'),
  ('rsr_demo_people_hr', 'role_people_analytics', 'sk_human_resources', 3, 'critical', 'Entender datos de personas.'),
  ('rsr_demo_people_ba', 'role_people_analytics', 'sk_business_analytics', 3, 'critical', 'Analizar metricas de talento.'),
  ('rsr_demo_people_powerbi', 'role_people_analytics', 'sk_powerbi', 3, 'important', 'Construir reportes de RRHH.'),
  ('rsr_demo_people_excel', 'role_people_analytics', 'sk_excel', 3, 'important', 'Preparar datos.'),
  ('rsr_demo_people_comm', 'role_people_analytics', 'sk_communication', 3, 'important', 'Explicar hallazgos de personas.'),
  ('rsr_demo_people_english', 'role_people_analytics', 'sk_english', 2, 'optional', 'Leer benchmarks de talento.')
ON CONFLICT (role_id, skill_id) DO UPDATE SET
  required_level = EXCLUDED.required_level,
  priority = EXCLUDED.priority,
  reason = EXCLUDED.reason;

INSERT INTO companies (id, name, sector, description) VALUES
  ('comp_interbank', 'Interbank', 'Financiera', 'Banco del ecosistema Intercorp.'),
  ('comp_interseguro', 'Interseguro', 'Financiera', 'Aseguradora del ecosistema Intercorp.'),
  ('comp_inteligo', 'Inteligo', 'Financiera', 'Servicios de inversion y gestion patrimonial.'),
  ('comp_izipay', 'Izipay', 'Financiera / pagos', 'Soluciones de pagos digitales.'),
  ('comp_interfondos', 'Interfondos', 'Financiera', 'Administradora de fondos.'),
  ('comp_plazavea', 'Plaza Vea', 'Retail', 'Supermercados y consumo masivo.'),
  ('comp_makro', 'Makro', 'Retail', 'Mayorista de alimentos y consumo.'),
  ('comp_mass', 'Mass', 'Retail', 'Tiendas de cercania.'),
  ('comp_realplaza', 'Real Plaza', 'Retail inmobiliario', 'Centros comerciales.'),
  ('comp_oechsle', 'Oechsle', 'Retail', 'Tienda por departamentos.'),
  ('comp_promart', 'Promart', 'Retail mejoramiento del hogar', 'Retail de construccion y hogar.'),
  ('comp_vivanda', 'Vivanda', 'Retail', 'Supermercado premium.'),
  ('comp_financiera_oh', 'Financiera Oh', 'Financiera', 'Servicios financieros retail.'),
  ('comp_inkafarma', 'Inkafarma', 'Salud', 'Cadena de boticas.'),
  ('comp_mifarma', 'Mifarma', 'Salud', 'Cadena de boticas.'),
  ('comp_clinica_aviva', 'Clinica Aviva', 'Salud', 'Clinica de servicios de salud.'),
  ('comp_quimica_suiza', 'Quimica Suiza', 'Salud / distribucion', 'Distribucion farmaceutica y salud.'),
  ('comp_utp', 'UTP', 'Educacion', 'Universidad Tecnologica del Peru.'),
  ('comp_innova_schools', 'Innova Schools', 'Educacion', 'Red de colegios.'),
  ('comp_idat', 'IDAT', 'Educacion', 'Instituto de educacion superior.'),
  ('comp_zegel', 'Zegel', 'Educacion', 'Escuela de negocios.')
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  sector = EXCLUDED.sector,
  description = EXCLUDED.description,
  updated_at = now();

WITH demo_students(id, name, email, career, cycle, campus, modality, availability, english_level, cv_status, role_id, target_role_name) AS (
  VALUES
  ('stu_sis_001', 'Lucia Vargas Demo', 'lucia.vargas.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 6, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_002', 'Diego Castro Demo', 'diego.castro.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 7, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_003', 'Valeria Rojas Demo', 'valeria.rojas.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_it_support', 'Soporte TI Junior'),
  ('stu_sis_004', 'Mateo Torres Demo', 'mateo.torres.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 9, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_005', 'Camila Leon Demo', 'camila.leon.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Centro', 'A distancia', 'Tiempo completo', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_006', 'Renzo Salas Demo', 'renzo.salas.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 6, 'Lima Norte', 'Semipresencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_it_support', 'Soporte TI Junior'),
  ('stu_sis_007', 'Andrea Molina Demo', 'andrea.molina.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 7, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_008', 'Bruno Herrera Demo', 'bruno.herrera.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_009', 'Sofia Mendoza Demo', 'sofia.mendoza.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 9, 'Lima Centro', 'Presencial', 'Tiempo completo', 'Basico', 'updated', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_010', 'Joaquin Paredes Demo', 'joaquin.paredes.demo@utp.edu.pe', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_adm_001', 'Mariana Flores Demo', 'mariana.flores.demo@utp.edu.pe', 'Administracion de Empresas', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_002', 'Rodrigo Silva Demo', 'rodrigo.silva.demo@utp.edu.pe', 'Administracion de Empresas', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_adm_003', 'Natalia Bravo Demo', 'natalia.bravo.demo@utp.edu.pe', 'Administracion de Empresas', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_marketing_analytics', 'Asistente de Marketing Analytics'),
  ('stu_adm_004', 'Sebastian Cruz Demo', 'sebastian.cruz.demo@utp.edu.pe', 'Administracion de Empresas', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_005', 'Fiorella Reyes Demo', 'fiorella.reyes.demo@utp.edu.pe', 'Administracion de Empresas', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_adm_006', 'Gabriel Lozano Demo', 'gabriel.lozano.demo@utp.edu.pe', 'Administracion de Empresas', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_adm_007', 'Paula Vega Demo', 'paula.vega.demo@utp.edu.pe', 'Administracion de Empresas', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_008', 'Daniel Rios Demo', 'daniel.rios.demo@utp.edu.pe', 'Administracion de Empresas', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_marketing_analytics', 'Asistente de Marketing Analytics'),
  ('stu_adm_009', 'Carolina Peña Demo', 'carolina.pena.demo@utp.edu.pe', 'Administracion de Empresas', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_010', 'Alonso Navarro Demo', 'alonso.navarro.demo@utp.edu.pe', 'Administracion de Empresas', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_ind_001', 'Claudia Campos Demo', 'claudia.campos.demo@utp.edu.pe', 'Ingenieria Industrial', 6, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_002', 'Hugo Ramirez Demo', 'hugo.ramirez.demo@utp.edu.pe', 'Ingenieria Industrial', 7, 'Lima Norte', 'Semipresencial', 'Medio tiempo', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_003', 'Milagros Soto Demo', 'milagros.soto.demo@utp.edu.pe', 'Ingenieria Industrial', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_004', 'Marco Cardenas Demo', 'marco.cardenas.demo@utp.edu.pe', 'Ingenieria Industrial', 9, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_005', 'Elena Fuentes Demo', 'elena.fuentes.demo@utp.edu.pe', 'Ingenieria Industrial', 10, 'Lima Centro', 'A distancia', 'Tiempo completo', 'Basico', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_006', 'Pablo Aguirre Demo', 'pablo.aguirre.demo@utp.edu.pe', 'Ingenieria Industrial', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_007', 'Rosa Villanueva Demo', 'rosa.villanueva.demo@utp.edu.pe', 'Ingenieria Industrial', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_008', 'Ivan Morales Demo', 'ivan.morales.demo@utp.edu.pe', 'Ingenieria Industrial', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_009', 'Karla Salazar Demo', 'karla.salazar.demo@utp.edu.pe', 'Ingenieria Industrial', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_010', 'Oscar Medina Demo', 'oscar.medina.demo@utp.edu.pe', 'Ingenieria Industrial', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_psi_001', 'Ana Quintana Demo', 'ana.quintana.demo@utp.edu.pe', 'Psicologia', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_002', 'Luis Ibarra Demo', 'luis.ibarra.demo@utp.edu.pe', 'Psicologia', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_003', 'Daniela Prieto Demo', 'daniela.prieto.demo@utp.edu.pe', 'Psicologia', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_004', 'Fernando Nuñez Demo', 'fernando.nunez.demo@utp.edu.pe', 'Psicologia', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_005', 'Patricia Solis Demo', 'patricia.solis.demo@utp.edu.pe', 'Psicologia', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_006', 'Miguel Arias Demo', 'miguel.arias.demo@utp.edu.pe', 'Psicologia', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_007', 'Gabriela Luna Demo', 'gabriela.luna.demo@utp.edu.pe', 'Psicologia', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_008', 'Rafael Espinoza Demo', 'rafael.espinoza.demo@utp.edu.pe', 'Psicologia', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_009', 'Monica Valdez Demo', 'monica.valdez.demo@utp.edu.pe', 'Psicologia', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_010', 'Nicolas Benites Demo', 'nicolas.benites.demo@utp.edu.pe', 'Psicologia', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_001', 'Jimena Robles Demo', 'jimena.robles.demo@utp.edu.pe', 'Derecho', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_002', 'Tomas Acosta Demo', 'tomas.acosta.demo@utp.edu.pe', 'Derecho', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_003', 'Luciana Campos Demo', 'luciana.campos.demo@utp.edu.pe', 'Derecho', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_004', 'Emilio Paz Demo', 'emilio.paz.demo@utp.edu.pe', 'Derecho', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_005', 'Renata Galvez Demo', 'renata.galvez.demo@utp.edu.pe', 'Derecho', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_006', 'Sergio Ponce Demo', 'sergio.ponce.demo@utp.edu.pe', 'Derecho', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_007', 'Antonella Diaz Demo', 'antonella.diaz.demo@utp.edu.pe', 'Derecho', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_008', 'Felipe Renteria Demo', 'felipe.renteria.demo@utp.edu.pe', 'Derecho', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_009', 'Isabella Chavez Demo', 'isabella.chavez.demo@utp.edu.pe', 'Derecho', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_010', 'Matias Aguilar Demo', 'matias.aguilar.demo@utp.edu.pe', 'Derecho', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior')
)
INSERT INTO users (id, name, email, role, auth_provider, password_hash, onboarding_completed)
SELECT id, name, email, 'student', 'microsoft', NULL, true
FROM demo_students
ON CONFLICT (id) DO NOTHING;

WITH demo_students(id, name, email, career, cycle, campus, modality, availability, english_level, cv_status, role_id, target_role_name) AS (
  VALUES
  ('stu_sis_001', '', '', 'Ingenieria de Sistemas e Informatica', 6, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_002', '', '', 'Ingenieria de Sistemas e Informatica', 7, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_003', '', '', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_it_support', 'Soporte TI Junior'),
  ('stu_sis_004', '', '', 'Ingenieria de Sistemas e Informatica', 9, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_005', '', '', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Centro', 'A distancia', 'Tiempo completo', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_006', '', '', 'Ingenieria de Sistemas e Informatica', 6, 'Lima Norte', 'Semipresencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_it_support', 'Soporte TI Junior'),
  ('stu_sis_007', '', '', 'Ingenieria de Sistemas e Informatica', 7, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_008', '', '', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_sis_009', '', '', 'Ingenieria de Sistemas e Informatica', 9, 'Lima Centro', 'Presencial', 'Tiempo completo', 'Basico', 'updated', 'role_software_intern', 'Practicante de Desarrollo de Software'),
  ('stu_sis_010', '', '', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_adm_001', '', '', 'Administracion de Empresas', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_002', '', '', 'Administracion de Empresas', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_adm_003', '', '', 'Administracion de Empresas', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_marketing_analytics', 'Asistente de Marketing Analytics'),
  ('stu_adm_004', '', '', 'Administracion de Empresas', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_005', '', '', 'Administracion de Empresas', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_data_intern', 'Practicante de Analisis de Datos'),
  ('stu_adm_006', '', '', 'Administracion de Empresas', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_adm_007', '', '', 'Administracion de Empresas', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_008', '', '', 'Administracion de Empresas', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_marketing_analytics', 'Asistente de Marketing Analytics'),
  ('stu_adm_009', '', '', 'Administracion de Empresas', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_adm_010', '', '', 'Administracion de Empresas', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_marketing_assistant', 'Asistente de Marketing Digital'),
  ('stu_ind_001', '', '', 'Ingenieria Industrial', 6, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_002', '', '', 'Ingenieria Industrial', 7, 'Lima Norte', 'Semipresencial', 'Medio tiempo', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_003', '', '', 'Ingenieria Industrial', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_004', '', '', 'Ingenieria Industrial', 9, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_005', '', '', 'Ingenieria Industrial', 10, 'Lima Centro', 'A distancia', 'Tiempo completo', 'Basico', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_006', '', '', 'Ingenieria Industrial', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_007', '', '', 'Ingenieria Industrial', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_008', '', '', 'Ingenieria Industrial', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_009', '', '', 'Ingenieria Industrial', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_ind_010', '', '', 'Ingenieria Industrial', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_operations_intern', 'Practicante de Operaciones'),
  ('stu_psi_001', '', '', 'Psicologia', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_002', '', '', 'Psicologia', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_003', '', '', 'Psicologia', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_004', '', '', 'Psicologia', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_005', '', '', 'Psicologia', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_006', '', '', 'Psicologia', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_007', '', '', 'Psicologia', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_008', '', '', 'Psicologia', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_psi_009', '', '', 'Psicologia', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_people_analytics', 'Practicante de People Analytics'),
  ('stu_psi_010', '', '', 'Psicologia', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_001', '', '', 'Derecho', 6, 'Lima Centro', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_002', '', '', 'Derecho', 7, 'Lima Norte', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_003', '', '', 'Derecho', 8, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_004', '', '', 'Derecho', 9, 'Lima Sur', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_005', '', '', 'Derecho', 10, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_006', '', '', 'Derecho', 6, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_007', '', '', 'Derecho', 7, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_008', '', '', 'Derecho', 8, 'Lima Sur', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'incomplete', 'role_commercial_analyst', 'Analista Comercial Junior'),
  ('stu_der_009', '', '', 'Derecho', 9, 'Lima Centro', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'updated', 'role_hr_intern', 'Practicante de Recursos Humanos'),
  ('stu_der_010', '', '', 'Derecho', 10, 'Lima Norte', 'Presencial', 'Practicas preprofesionales - 30h', 'Basico', 'updated', 'role_commercial_analyst', 'Analista Comercial Junior')
)
INSERT INTO students (id, career, cycle, campus, modality, availability, english_level, linkedin_url, cv_status)
SELECT id, career, cycle, campus, modality, availability, english_level, NULL, cv_status
FROM demo_students
ON CONFLICT (id) DO NOTHING;

WITH demo_students(id, role_id, target_role_name, availability) AS (
  VALUES
  ('stu_sis_001', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h'),
  ('stu_sis_002', 'role_data_intern', 'Practicante de Analisis de Datos', 'Medio tiempo'),
  ('stu_sis_003', 'role_it_support', 'Soporte TI Junior', 'Practicas preprofesionales - 30h'),
  ('stu_sis_004', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h'),
  ('stu_sis_005', 'role_data_intern', 'Practicante de Analisis de Datos', 'Tiempo completo'),
  ('stu_sis_006', 'role_it_support', 'Soporte TI Junior', 'Medio tiempo'),
  ('stu_sis_007', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h'),
  ('stu_sis_008', 'role_data_intern', 'Practicante de Analisis de Datos', 'Practicas preprofesionales - 30h'),
  ('stu_sis_009', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Tiempo completo'),
  ('stu_sis_010', 'role_data_intern', 'Practicante de Analisis de Datos', 'Practicas preprofesionales - 30h'),
  ('stu_adm_001', 'role_commercial_analyst', 'Analista Comercial Junior', 'Medio tiempo'),
  ('stu_adm_002', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Practicas preprofesionales - 30h'),
  ('stu_adm_003', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Practicas preprofesionales - 30h'),
  ('stu_adm_004', 'role_commercial_analyst', 'Analista Comercial Junior', 'Tiempo completo'),
  ('stu_adm_005', 'role_data_intern', 'Practicante de Analisis de Datos', 'Medio tiempo'),
  ('stu_adm_006', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Medio tiempo'),
  ('stu_adm_007', 'role_commercial_analyst', 'Analista Comercial Junior', 'Practicas preprofesionales - 30h'),
  ('stu_adm_008', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Practicas preprofesionales - 30h'),
  ('stu_adm_009', 'role_commercial_analyst', 'Analista Comercial Junior', 'Tiempo completo'),
  ('stu_adm_010', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Practicas preprofesionales - 30h'),
  ('stu_ind_001', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_ind_002', 'role_operations_intern', 'Practicante de Operaciones', 'Medio tiempo'),
  ('stu_ind_003', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_ind_004', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_ind_005', 'role_operations_intern', 'Practicante de Operaciones', 'Tiempo completo'),
  ('stu_ind_006', 'role_operations_intern', 'Practicante de Operaciones', 'Medio tiempo'),
  ('stu_ind_007', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_ind_008', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_ind_009', 'role_operations_intern', 'Practicante de Operaciones', 'Tiempo completo'),
  ('stu_ind_010', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h'),
  ('stu_psi_001', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Medio tiempo'),
  ('stu_psi_002', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_psi_003', 'role_people_analytics', 'Practicante de People Analytics', 'Practicas preprofesionales - 30h'),
  ('stu_psi_004', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Tiempo completo'),
  ('stu_psi_005', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Medio tiempo'),
  ('stu_psi_006', 'role_people_analytics', 'Practicante de People Analytics', 'Medio tiempo'),
  ('stu_psi_007', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_psi_008', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_psi_009', 'role_people_analytics', 'Practicante de People Analytics', 'Tiempo completo'),
  ('stu_psi_010', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_der_001', 'role_commercial_analyst', 'Analista Comercial Junior', 'Medio tiempo'),
  ('stu_der_002', 'role_commercial_analyst', 'Analista Comercial Junior', 'Practicas preprofesionales - 30h'),
  ('stu_der_003', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_der_004', 'role_commercial_analyst', 'Analista Comercial Junior', 'Tiempo completo'),
  ('stu_der_005', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Medio tiempo'),
  ('stu_der_006', 'role_commercial_analyst', 'Analista Comercial Junior', 'Medio tiempo'),
  ('stu_der_007', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Practicas preprofesionales - 30h'),
  ('stu_der_008', 'role_commercial_analyst', 'Analista Comercial Junior', 'Practicas preprofesionales - 30h'),
  ('stu_der_009', 'role_hr_intern', 'Practicante de Recursos Humanos', 'Tiempo completo'),
  ('stu_der_010', 'role_commercial_analyst', 'Analista Comercial Junior', 'Practicas preprofesionales - 30h')
)
INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active)
SELECT 'goal_demo_' || id, id, role_id, target_role_name, availability, 'Hibrido', 'Este mes', true
FROM demo_students
ON CONFLICT (id) DO NOTHING;

WITH skills_data(student_id, skill_id, level) AS (
  SELECT 'stu_sis_' || lpad(n::text, 3, '0'), skill_id, level
  FROM generate_series(1, 10) n
  CROSS JOIN LATERAL (VALUES
    ('sk_programming', CASE WHEN n IN (4,5,8,10) THEN 4 ELSE 3 END),
    ('sk_oop', CASE WHEN n IN (1,7) THEN 2 ELSE 3 END),
    ('sk_database', CASE WHEN n IN (2,8,10) THEN 3 ELSE 2 END),
    ('sk_sql', CASE WHEN n IN (2,5,8,10) THEN 3 ELSE 1 END),
    ('sk_git', CASE WHEN n IN (1,4,9) THEN 2 ELSE 1 END),
    ('sk_communication', CASE WHEN n IN (3,6) THEN 2 ELSE 3 END),
    ('sk_english', CASE WHEN n IN (4,5,10) THEN 3 ELSE 1 END),
    ('sk_problem_solving', CASE WHEN n IN (4,8,9) THEN 3 ELSE 2 END)
  ) v(skill_id, level)
  UNION ALL
  SELECT 'stu_adm_' || lpad(n::text, 3, '0'), skill_id, level
  FROM generate_series(1, 10) n
  CROSS JOIN LATERAL (VALUES
    ('sk_business_management', 3),
    ('sk_accounting', CASE WHEN n IN (4,7,9) THEN 3 ELSE 2 END),
    ('sk_finance', CASE WHEN n IN (4,9) THEN 3 ELSE 1 END),
    ('sk_marketing', CASE WHEN n IN (2,6,10) THEN 3 ELSE 2 END),
    ('sk_sales_management', CASE WHEN n IN (1,4,7,9) THEN 3 ELSE 2 END),
    ('sk_negotiation', CASE WHEN n IN (1,7) THEN 3 ELSE 1 END),
    ('sk_excel', CASE WHEN n IN (1,4,7,9) THEN 3 ELSE 2 END),
    ('sk_communication', 3),
    ('sk_english', CASE WHEN n IN (2,4,9) THEN 2 ELSE 1 END)
  ) v(skill_id, level)
  UNION ALL
  SELECT 'stu_ind_' || lpad(n::text, 3, '0'), skill_id, level
  FROM generate_series(1, 10) n
  CROSS JOIN LATERAL (VALUES
    ('sk_process_management', CASE WHEN n IN (2,4,7,9) THEN 3 ELSE 2 END),
    ('sk_operations_management', CASE WHEN n IN (4,5,9) THEN 3 ELSE 2 END),
    ('sk_logistics', CASE WHEN n IN (2,7) THEN 3 ELSE 1 END),
    ('sk_quality_management', CASE WHEN n IN (4,9) THEN 3 ELSE 1 END),
    ('sk_excel', CASE WHEN n IN (2,4,7,9) THEN 3 ELSE 2 END),
    ('sk_communication', 3),
    ('sk_teamwork', 3),
    ('sk_english', CASE WHEN n IN (2,4,9) THEN 2 ELSE 1 END)
  ) v(skill_id, level)
  UNION ALL
  SELECT 'stu_psi_' || lpad(n::text, 3, '0'), skill_id, level
  FROM generate_series(1, 10) n
  CROSS JOIN LATERAL (VALUES
    ('sk_behavior_observation', 3),
    ('sk_psychological_interview', CASE WHEN n IN (2,4,7,10) THEN 3 ELSE 1 END),
    ('sk_psychometrics', CASE WHEN n IN (4,7) THEN 3 ELSE 1 END),
    ('sk_group_dynamics', CASE WHEN n IN (1,2,7) THEN 3 ELSE 2 END),
    ('sk_human_resources', CASE WHEN n IN (3,6,9) THEN 3 ELSE 2 END),
    ('sk_communication', CASE WHEN n IN (1,2,4,7,10) THEN 3 ELSE 2 END),
    ('sk_teamwork', 3),
    ('sk_english', CASE WHEN n IN (2,4,9) THEN 2 ELSE 1 END)
  ) v(skill_id, level)
  UNION ALL
  SELECT 'stu_der_' || lpad(n::text, 3, '0'), skill_id, level
  FROM generate_series(1, 10) n
  CROSS JOIN LATERAL (VALUES
    ('sk_legal_analysis', CASE WHEN n IN (2,4,8,10) THEN 3 ELSE 2 END),
    ('sk_legal_writing', CASE WHEN n IN (4,10) THEN 3 ELSE 1 END),
    ('sk_legal_argumentation', CASE WHEN n IN (2,4,8) THEN 3 ELSE 2 END),
    ('sk_labor_law', CASE WHEN n IN (3,5,7,9) THEN 3 ELSE 1 END),
    ('sk_corporate_law', CASE WHEN n IN (2,4,6,8,10) THEN 3 ELSE 1 END),
    ('sk_legal_research', CASE WHEN n IN (4,8) THEN 3 ELSE 2 END),
    ('sk_communication', 3),
    ('sk_negotiation', CASE WHEN n IN (1,2,4,6,8,10) THEN 3 ELSE 2 END),
    ('sk_english', CASE WHEN n IN (2,4,9) THEN 2 ELSE 1 END)
  ) v(skill_id, level)
)
INSERT INTO student_skills (id, student_id, skill_id, level, source)
SELECT 'ss_demo_' || student_id || '_' || skill_id, student_id, skill_id, level, 'self_reported'
FROM skills_data
ON CONFLICT (student_id, skill_id) DO NOTHING;

INSERT INTO jobs (id, company_id, role_id, title, modality, location, hours, description, status) VALUES
  ('job_demo_interbank_data_001', 'comp_interbank', 'role_data_intern', 'Practicante de Analitica Comercial', 'Hibrido', 'Lima', '30h semanales', 'Apoyar analisis comercial, reportes y tableros para banca retail.', 'active'),
  ('job_demo_interbank_risk_001', 'comp_interbank', 'role_data_intern', 'Practicante de Riesgos', 'Hibrido', 'Lima', '30h semanales', 'Apoyar seguimiento de indicadores y bases de riesgo.', 'active'),
  ('job_demo_interbank_tech_001', 'comp_interbank', 'role_software_intern', 'Practicante de Tecnologia', 'Hibrido', 'Lima', '30h semanales', 'Apoyar desarrollo de soluciones internas.', 'active'),
  ('job_demo_interbank_legal_001', 'comp_interbank', 'role_commercial_analyst', 'Practicante Legal Corporativo', 'Hibrido', 'Lima', '30h semanales', 'Apoyar revision contractual y consultas corporativas.', 'active'),
  ('job_demo_izipay_data_001', 'comp_izipay', 'role_data_intern', 'Practicante de Data Analytics', 'Hibrido', 'Lima', '30h semanales', 'Analizar transacciones, tableros y metricas de producto.', 'active'),
  ('job_demo_izipay_product_001', 'comp_izipay', 'role_marketing_analytics', 'Practicante de Producto Digital', 'Hibrido', 'Lima', '30h semanales', 'Apoyar discovery, metricas y seguimiento de producto digital.', 'active'),
  ('job_demo_izipay_ops_001', 'comp_izipay', 'role_operations_intern', 'Practicante de Operaciones', 'Hibrido', 'Lima', '30h semanales', 'Apoyar mejora de procesos operativos de pagos.', 'active'),
  ('job_demo_inteligo_finance_001', 'comp_inteligo', 'role_commercial_analyst', 'Practicante de Finanzas', 'Hibrido', 'Lima', '30h semanales', 'Apoyar reportes financieros y analisis de cartera.', 'active'),
  ('job_demo_inteligo_investment_001', 'comp_inteligo', 'role_commercial_analyst', 'Practicante de Analisis de Inversiones', 'Hibrido', 'Lima', '30h semanales', 'Apoyar analisis de oportunidades de inversion.', 'active'),
  ('job_demo_interseguro_process_001', 'comp_interseguro', 'role_operations_intern', 'Practicante de Procesos', 'Hibrido', 'Lima', '30h semanales', 'Mapear procesos y proponer mejoras en seguros.', 'active'),
  ('job_demo_interseguro_customer_001', 'comp_interseguro', 'role_commercial_analyst', 'Practicante de Experiencia del Cliente', 'Hibrido', 'Lima', '30h semanales', 'Apoyar medicion y mejoras de experiencia.', 'active'),
  ('job_demo_plazavea_ops_001', 'comp_plazavea', 'role_operations_intern', 'Practicante de Operaciones Retail', 'Presencial', 'Lima', '30h semanales', 'Analizar procesos de tienda y reposicion.', 'active'),
  ('job_demo_plazavea_commercial_001', 'comp_plazavea', 'role_commercial_analyst', 'Asistente de Gestion Comercial', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar reportes comerciales y seguimiento de ventas.', 'active'),
  ('job_demo_plazavea_logistics_001', 'comp_plazavea', 'role_operations_intern', 'Practicante de Logistica', 'Presencial', 'Lima', '30h semanales', 'Apoyar abastecimiento, inventarios y distribucion.', 'active'),
  ('job_demo_mass_ops_001', 'comp_mass', 'role_operations_intern', 'Practicante de Operaciones', 'Presencial', 'Lima', '30h semanales', 'Apoyar control operativo en tiendas de cercania.', 'active'),
  ('job_demo_mass_supply_001', 'comp_mass', 'role_operations_intern', 'Asistente de Abastecimiento', 'Hibrido', 'Lima', 'Medio tiempo', 'Apoyar seguimiento de abastecimiento y quiebres.', 'active'),
  ('job_demo_makro_logistics_001', 'comp_makro', 'role_operations_intern', 'Practicante de Logistica', 'Presencial', 'Lima', '30h semanales', 'Apoyar flujos de almacen mayorista.', 'active'),
  ('job_demo_oechsle_marketing_001', 'comp_oechsle', 'role_marketing_assistant', 'Practicante de Marketing', 'Hibrido', 'Lima', '30h semanales', 'Apoyar campanas comerciales y contenido.', 'active'),
  ('job_demo_oechsle_hr_001', 'comp_oechsle', 'role_hr_intern', 'Practicante de Gestion Humana', 'Hibrido', 'Lima', '30h semanales', 'Apoyar seleccion y actividades internas.', 'active'),
  ('job_demo_promart_operations_001', 'comp_promart', 'role_operations_intern', 'Practicante de Procesos', 'Presencial', 'Lima', '30h semanales', 'Apoyar mejora continua y procesos de tienda.', 'active'),
  ('job_demo_promart_safety_001', 'comp_promart', 'role_operations_intern', 'Practicante de Seguridad y Salud Ocupacional', 'Presencial', 'Lima', '30h semanales', 'Apoyar controles de seguridad y salud ocupacional.', 'active'),
  ('job_demo_inkafarma_hr_001', 'comp_inkafarma', 'role_hr_intern', 'Practicante de Gestion Humana', 'Hibrido', 'Lima', '30h semanales', 'Apoyar procesos de talento para boticas.', 'active'),
  ('job_demo_inkafarma_legal_001', 'comp_inkafarma', 'role_hr_intern', 'Practicante Legal Laboral', 'Hibrido', 'Lima', '30h semanales', 'Apoyar consultas laborales y documentacion legal.', 'active'),
  ('job_demo_mifarma_selection_001', 'comp_mifarma', 'role_hr_intern', 'Practicante de Seleccion', 'Hibrido', 'Lima', '30h semanales', 'Apoyar entrevistas y filtro de candidatos.', 'active'),
  ('job_demo_realplaza_admin_001', 'comp_realplaza', 'role_commercial_analyst', 'Practicante de Administracion', 'Hibrido', 'Lima', '30h semanales', 'Apoyar control administrativo y reportes.', 'active'),
  ('job_demo_realplaza_legal_001', 'comp_realplaza', 'role_commercial_analyst', 'Practicante Legal', 'Hibrido', 'Lima', '30h semanales', 'Apoyar revision de contratos y documentos legales.', 'active'),
  ('job_demo_utp_it_support_001', 'comp_utp', 'role_it_support', 'Practicante de Soporte TI', 'Presencial', 'Lima', '30h semanales', 'Atender incidencias y documentar soluciones.', 'active'),
  ('job_demo_utp_hr_001', 'comp_utp', 'role_hr_intern', 'Practicante de Gestion Humana', 'Hibrido', 'Lima', '30h semanales', 'Apoyar procesos de talento y clima.', 'active'),
  ('job_demo_innova_psychology_001', 'comp_innova_schools', 'role_hr_intern', 'Practicante de Psicologia Educativa', 'Presencial', 'Lima', '30h semanales', 'Apoyar acompanamiento psicopedagogico.', 'active'),
  ('job_demo_idat_marketing_001', 'comp_idat', 'role_marketing_assistant', 'Practicante de Marketing', 'Hibrido', 'Lima', '30h semanales', 'Apoyar campanas educativas.', 'active'),
  ('job_demo_zegel_people_analytics_001', 'comp_zegel', 'role_people_analytics', 'Practicante de People Analytics', 'Hibrido', 'Lima', '30h semanales', 'Apoyar reportes y analisis de talento.', 'active')
ON CONFLICT (id) DO UPDATE SET
  company_id = EXCLUDED.company_id,
  role_id = EXCLUDED.role_id,
  title = EXCLUDED.title,
  modality = EXCLUDED.modality,
  location = EXCLUDED.location,
  hours = EXCLUDED.hours,
  description = EXCLUDED.description,
  status = EXCLUDED.status,
  updated_at = now();

INSERT INTO job_requirements (id, job_id, skill_id, required_level, importance) VALUES
  ('jr_demo_interbank_data_sql', 'job_demo_interbank_data_001', 'sk_sql', 4, 'critical'),
  ('jr_demo_interbank_data_powerbi', 'job_demo_interbank_data_001', 'sk_powerbi', 3, 'critical'),
  ('jr_demo_interbank_data_python', 'job_demo_interbank_data_001', 'sk_python', 3, 'important'),
  ('jr_demo_interbank_data_excel', 'job_demo_interbank_data_001', 'sk_excel', 4, 'important'),
  ('jr_demo_interbank_data_comm', 'job_demo_interbank_data_001', 'sk_communication', 3, 'important'),
  ('jr_demo_interbank_data_english', 'job_demo_interbank_data_001', 'sk_english', 3, 'important'),
  ('jr_demo_interbank_risk_sql', 'job_demo_interbank_risk_001', 'sk_sql', 3, 'critical'),
  ('jr_demo_interbank_risk_powerbi', 'job_demo_interbank_risk_001', 'sk_powerbi', 3, 'important'),
  ('jr_demo_interbank_risk_finance', 'job_demo_interbank_risk_001', 'sk_finance', 3, 'important'),
  ('jr_demo_interbank_risk_excel', 'job_demo_interbank_risk_001', 'sk_excel', 4, 'critical'),
  ('jr_demo_interbank_risk_comm', 'job_demo_interbank_risk_001', 'sk_communication', 3, 'important'),
  ('jr_demo_interbank_tech_programming', 'job_demo_interbank_tech_001', 'sk_programming', 3, 'critical'),
  ('jr_demo_interbank_tech_oop', 'job_demo_interbank_tech_001', 'sk_oop', 3, 'critical'),
  ('jr_demo_interbank_tech_git', 'job_demo_interbank_tech_001', 'sk_git', 3, 'important'),
  ('jr_demo_interbank_tech_cloud', 'job_demo_interbank_tech_001', 'sk_cloud_services', 2, 'important'),
  ('jr_demo_interbank_tech_qa', 'job_demo_interbank_tech_001', 'sk_qa', 2, 'important'),
  ('jr_demo_interbank_legal_analysis', 'job_demo_interbank_legal_001', 'sk_legal_analysis', 3, 'critical'),
  ('jr_demo_interbank_legal_writing', 'job_demo_interbank_legal_001', 'sk_legal_writing', 3, 'critical'),
  ('jr_demo_interbank_legal_corporate', 'job_demo_interbank_legal_001', 'sk_corporate_law', 3, 'important'),
  ('jr_demo_interbank_legal_argument', 'job_demo_interbank_legal_001', 'sk_legal_argumentation', 3, 'important'),
  ('jr_demo_interbank_legal_english', 'job_demo_interbank_legal_001', 'sk_english', 2, 'optional'),
  ('jr_demo_izipay_data_sql', 'job_demo_izipay_data_001', 'sk_sql', 3, 'critical'),
  ('jr_demo_izipay_data_powerbi', 'job_demo_izipay_data_001', 'sk_powerbi', 3, 'critical'),
  ('jr_demo_izipay_data_python', 'job_demo_izipay_data_001', 'sk_python', 2, 'important'),
  ('jr_demo_izipay_data_bi', 'job_demo_izipay_data_001', 'sk_business_intelligence', 3, 'important'),
  ('jr_demo_izipay_data_comm', 'job_demo_izipay_data_001', 'sk_communication', 3, 'important'),
  ('jr_demo_izipay_product_marketing', 'job_demo_izipay_product_001', 'sk_marketing', 3, 'critical'),
  ('jr_demo_izipay_product_ba', 'job_demo_izipay_product_001', 'sk_business_analytics', 3, 'critical'),
  ('jr_demo_izipay_product_powerbi', 'job_demo_izipay_product_001', 'sk_powerbi', 3, 'important'),
  ('jr_demo_izipay_product_research', 'job_demo_izipay_product_001', 'sk_market_research', 3, 'important'),
  ('jr_demo_izipay_product_comm', 'job_demo_izipay_product_001', 'sk_communication', 3, 'important'),
  ('jr_demo_izipay_ops_ops', 'job_demo_izipay_ops_001', 'sk_operations_management', 3, 'critical'),
  ('jr_demo_izipay_ops_process', 'job_demo_izipay_ops_001', 'sk_process_management', 3, 'critical'),
  ('jr_demo_izipay_ops_excel', 'job_demo_izipay_ops_001', 'sk_excel', 3, 'important'),
  ('jr_demo_izipay_ops_powerbi', 'job_demo_izipay_ops_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_izipay_ops_problem', 'job_demo_izipay_ops_001', 'sk_problem_solving', 3, 'important'),
  ('jr_demo_inteligo_finance_finance', 'job_demo_inteligo_finance_001', 'sk_finance', 3, 'critical'),
  ('jr_demo_inteligo_finance_excel', 'job_demo_inteligo_finance_001', 'sk_excel', 3, 'critical'),
  ('jr_demo_inteligo_finance_powerbi', 'job_demo_inteligo_finance_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_inteligo_finance_comm', 'job_demo_inteligo_finance_001', 'sk_communication', 3, 'important'),
  ('jr_demo_inteligo_invest_finance', 'job_demo_inteligo_investment_001', 'sk_finance', 4, 'critical'),
  ('jr_demo_inteligo_invest_excel', 'job_demo_inteligo_investment_001', 'sk_excel', 3, 'critical'),
  ('jr_demo_inteligo_invest_research', 'job_demo_inteligo_investment_001', 'sk_market_research', 3, 'important'),
  ('jr_demo_inteligo_invest_english', 'job_demo_inteligo_investment_001', 'sk_english', 3, 'important'),
  ('jr_demo_interseguro_process_ops', 'job_demo_interseguro_process_001', 'sk_operations_management', 3, 'critical'),
  ('jr_demo_interseguro_process_process', 'job_demo_interseguro_process_001', 'sk_process_management', 3, 'critical'),
  ('jr_demo_interseguro_process_quality', 'job_demo_interseguro_process_001', 'sk_quality_management', 3, 'important'),
  ('jr_demo_interseguro_process_powerbi', 'job_demo_interseguro_process_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_interseguro_customer_comm', 'job_demo_interseguro_customer_001', 'sk_communication', 3, 'critical'),
  ('jr_demo_interseguro_customer_excel', 'job_demo_interseguro_customer_001', 'sk_excel', 3, 'important'),
  ('jr_demo_interseguro_customer_marketing', 'job_demo_interseguro_customer_001', 'sk_marketing', 2, 'important'),
  ('jr_demo_interseguro_customer_problem', 'job_demo_interseguro_customer_001', 'sk_problem_solving', 3, 'important'),
  ('jr_demo_plazavea_ops_ops', 'job_demo_plazavea_ops_001', 'sk_operations_management', 3, 'critical'),
  ('jr_demo_plazavea_ops_process', 'job_demo_plazavea_ops_001', 'sk_process_management', 3, 'critical'),
  ('jr_demo_plazavea_ops_excel', 'job_demo_plazavea_ops_001', 'sk_excel', 3, 'important'),
  ('jr_demo_plazavea_ops_powerbi', 'job_demo_plazavea_ops_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_plazavea_commercial_commercial', 'job_demo_plazavea_commercial_001', 'sk_commercial_management', 3, 'critical'),
  ('jr_demo_plazavea_commercial_sales', 'job_demo_plazavea_commercial_001', 'sk_sales_management', 3, 'important'),
  ('jr_demo_plazavea_commercial_excel', 'job_demo_plazavea_commercial_001', 'sk_excel', 3, 'critical'),
  ('jr_demo_plazavea_commercial_comm', 'job_demo_plazavea_commercial_001', 'sk_communication', 3, 'important'),
  ('jr_demo_plazavea_logistics_logistics', 'job_demo_plazavea_logistics_001', 'sk_logistics', 3, 'critical'),
  ('jr_demo_plazavea_logistics_supply', 'job_demo_plazavea_logistics_001', 'sk_supply_chain', 3, 'important'),
  ('jr_demo_plazavea_logistics_excel', 'job_demo_plazavea_logistics_001', 'sk_excel', 3, 'important'),
  ('jr_demo_plazavea_logistics_powerbi', 'job_demo_plazavea_logistics_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_mass_ops_ops', 'job_demo_mass_ops_001', 'sk_operations_management', 3, 'critical'),
  ('jr_demo_mass_ops_process', 'job_demo_mass_ops_001', 'sk_process_management', 3, 'critical'),
  ('jr_demo_mass_ops_quality', 'job_demo_mass_ops_001', 'sk_quality_management', 3, 'important'),
  ('jr_demo_mass_supply_logistics', 'job_demo_mass_supply_001', 'sk_logistics', 3, 'critical'),
  ('jr_demo_mass_supply_supply', 'job_demo_mass_supply_001', 'sk_supply_chain', 3, 'important'),
  ('jr_demo_mass_supply_excel', 'job_demo_mass_supply_001', 'sk_excel', 3, 'important'),
  ('jr_demo_makro_logistics_logistics', 'job_demo_makro_logistics_001', 'sk_logistics', 3, 'critical'),
  ('jr_demo_makro_logistics_supply', 'job_demo_makro_logistics_001', 'sk_supply_chain', 3, 'important'),
  ('jr_demo_makro_logistics_powerbi', 'job_demo_makro_logistics_001', 'sk_powerbi', 2, 'important'),
  ('jr_demo_makro_logistics_quality', 'job_demo_makro_logistics_001', 'sk_quality_management', 3, 'important'),
  ('jr_demo_oechsle_marketing_marketing', 'job_demo_oechsle_marketing_001', 'sk_marketing', 3, 'critical'),
  ('jr_demo_oechsle_marketing_research', 'job_demo_oechsle_marketing_001', 'sk_market_research', 3, 'important'),
  ('jr_demo_oechsle_marketing_excel', 'job_demo_oechsle_marketing_001', 'sk_excel', 3, 'important'),
  ('jr_demo_oechsle_marketing_english', 'job_demo_oechsle_marketing_001', 'sk_english', 2, 'optional'),
  ('jr_demo_oechsle_hr_talent', 'job_demo_oechsle_hr_001', 'sk_human_talent_management', 3, 'critical'),
  ('jr_demo_oechsle_hr_human', 'job_demo_oechsle_hr_001', 'sk_human_resources', 3, 'critical'),
  ('jr_demo_oechsle_hr_comm', 'job_demo_oechsle_hr_001', 'sk_communication', 3, 'important'),
  ('jr_demo_promart_operations_ops', 'job_demo_promart_operations_001', 'sk_operations_management', 3, 'critical'),
  ('jr_demo_promart_operations_process', 'job_demo_promart_operations_001', 'sk_process_management', 3, 'critical'),
  ('jr_demo_promart_operations_quality', 'job_demo_promart_operations_001', 'sk_quality_management', 3, 'important'),
  ('jr_demo_promart_safety_safety', 'job_demo_promart_safety_001', 'sk_occupational_safety', 3, 'critical'),
  ('jr_demo_promart_safety_process', 'job_demo_promart_safety_001', 'sk_process_management', 3, 'important'),
  ('jr_demo_promart_safety_excel', 'job_demo_promart_safety_001', 'sk_excel', 3, 'important'),
  ('jr_demo_inkafarma_hr_talent', 'job_demo_inkafarma_hr_001', 'sk_human_talent_management', 3, 'critical'),
  ('jr_demo_inkafarma_hr_interview', 'job_demo_inkafarma_hr_001', 'sk_psychological_interview', 3, 'important'),
  ('jr_demo_inkafarma_hr_groups', 'job_demo_inkafarma_hr_001', 'sk_group_dynamics', 3, 'important'),
  ('jr_demo_inkafarma_legal_labor', 'job_demo_inkafarma_legal_001', 'sk_labor_law', 3, 'critical'),
  ('jr_demo_inkafarma_legal_writing', 'job_demo_inkafarma_legal_001', 'sk_legal_writing', 3, 'critical'),
  ('jr_demo_inkafarma_legal_research', 'job_demo_inkafarma_legal_001', 'sk_legal_research', 3, 'important'),
  ('jr_demo_mifarma_selection_interview', 'job_demo_mifarma_selection_001', 'sk_psychological_interview', 3, 'critical'),
  ('jr_demo_mifarma_selection_human', 'job_demo_mifarma_selection_001', 'sk_human_resources', 3, 'critical'),
  ('jr_demo_mifarma_selection_comm', 'job_demo_mifarma_selection_001', 'sk_communication', 3, 'important'),
  ('jr_demo_realplaza_admin_excel', 'job_demo_realplaza_admin_001', 'sk_excel', 3, 'critical'),
  ('jr_demo_realplaza_admin_finance', 'job_demo_realplaza_admin_001', 'sk_finance', 3, 'important'),
  ('jr_demo_realplaza_admin_comm', 'job_demo_realplaza_admin_001', 'sk_communication', 3, 'important'),
  ('jr_demo_realplaza_legal_analysis', 'job_demo_realplaza_legal_001', 'sk_legal_analysis', 3, 'critical'),
  ('jr_demo_realplaza_legal_writing', 'job_demo_realplaza_legal_001', 'sk_legal_writing', 3, 'critical'),
  ('jr_demo_realplaza_legal_corporate', 'job_demo_realplaza_legal_001', 'sk_corporate_law', 3, 'important'),
  ('jr_demo_utp_it_itil', 'job_demo_utp_it_support_001', 'sk_it_service_management', 3, 'critical'),
  ('jr_demo_utp_it_comm', 'job_demo_utp_it_support_001', 'sk_communication', 3, 'critical'),
  ('jr_demo_utp_it_security', 'job_demo_utp_it_support_001', 'sk_cybersecurity', 2, 'important'),
  ('jr_demo_utp_hr_talent', 'job_demo_utp_hr_001', 'sk_human_talent_management', 3, 'critical'),
  ('jr_demo_utp_hr_human', 'job_demo_utp_hr_001', 'sk_human_resources', 3, 'critical'),
  ('jr_demo_utp_hr_comm', 'job_demo_utp_hr_001', 'sk_communication', 3, 'important'),
  ('jr_demo_innova_psy_interview', 'job_demo_innova_psychology_001', 'sk_psychological_interview', 3, 'critical'),
  ('jr_demo_innova_psy_educational', 'job_demo_innova_psychology_001', 'sk_educational_psychology', 3, 'important'),
  ('jr_demo_innova_psy_psychometrics', 'job_demo_innova_psychology_001', 'sk_psychometrics', 3, 'important'),
  ('jr_demo_idat_marketing_marketing', 'job_demo_idat_marketing_001', 'sk_marketing', 3, 'critical'),
  ('jr_demo_idat_marketing_research', 'job_demo_idat_marketing_001', 'sk_market_research', 3, 'important'),
  ('jr_demo_idat_marketing_comm', 'job_demo_idat_marketing_001', 'sk_communication', 3, 'important'),
  ('jr_demo_zegel_people_human', 'job_demo_zegel_people_analytics_001', 'sk_human_resources', 3, 'critical'),
  ('jr_demo_zegel_people_ba', 'job_demo_zegel_people_analytics_001', 'sk_business_analytics', 3, 'critical'),
  ('jr_demo_zegel_people_powerbi', 'job_demo_zegel_people_analytics_001', 'sk_powerbi', 3, 'important'),
  ('jr_demo_zegel_people_excel', 'job_demo_zegel_people_analytics_001', 'sk_excel', 3, 'important')
ON CONFLICT (job_id, skill_id) DO UPDATE SET
  required_level = EXCLUDED.required_level,
  importance = EXCLUDED.importance;

WITH role_gaps AS (
  SELECT
    'scg_demo_role_' || sg.student_id || '_' || rsr.role_id || '_' || rsr.skill_id AS id,
    sg.student_id,
    rsr.role_id,
    rsr.skill_id,
    CASE WHEN rsr.priority = 'critical' THEN 'critical' ELSE 'partial' END AS severity,
    rsr.reason
  FROM student_goals sg
  JOIN students st ON st.id = sg.student_id
  JOIN role_skill_requirements rsr ON rsr.role_id = sg.role_id
  LEFT JOIN student_skills ss
    ON ss.student_id = sg.student_id
   AND ss.skill_id = rsr.skill_id
  WHERE sg.student_id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}'
    AND sg.active = true
    AND rsr.required_level > COALESCE(ss.level, 0)
    AND NOT (st.career = 'Derecho' AND rsr.skill_id IN ('sk_python', 'sk_cloud_services', 'sk_git', 'sk_cicd', 'sk_sql'))
    AND NOT (st.career = 'Psicologia' AND rsr.skill_id IN ('sk_sql', 'sk_python', 'sk_cloud_services', 'sk_cicd') AND sg.role_id <> 'role_people_analytics')
    AND NOT (st.career = 'Administracion de Empresas' AND rsr.skill_id = 'sk_python' AND sg.role_id NOT IN ('role_data_intern', 'role_marketing_analytics'))
)
INSERT INTO student_critical_gaps (id, student_id, role_id, job_id, skill_id, severity, source, reason, status, updated_at)
SELECT id, student_id, role_id, NULL, skill_id, severity, 'role', reason, 'open', now()
FROM role_gaps
ON CONFLICT (student_id, role_id, skill_id)
  WHERE source = 'role' AND role_id IS NOT NULL
DO UPDATE SET
  severity = EXCLUDED.severity,
  reason = EXCLUDED.reason,
  status = 'open',
  updated_at = now();

WITH student_job_targets(student_id, job_id) AS (
  SELECT 'stu_sis_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (1,4,7,9) THEN 'job_demo_interbank_tech_001'
    WHEN n IN (3,6) THEN 'job_demo_utp_it_support_001'
    WHEN n IN (2,5,8,10) THEN 'job_demo_izipay_data_001'
  END FROM generate_series(1, 10) n
  UNION ALL
  SELECT 'stu_sis_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (1,4,7,9) THEN 'job_demo_utp_it_support_001'
    ELSE 'job_demo_interbank_data_001'
  END FROM generate_series(1, 10) n
  UNION ALL
  SELECT 'stu_adm_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (3,8) THEN 'job_demo_izipay_product_001'
    WHEN n = 5 THEN 'job_demo_interbank_data_001'
    WHEN n IN (2,6,10) THEN 'job_demo_oechsle_marketing_001'
    ELSE 'job_demo_plazavea_commercial_001'
  END FROM generate_series(1, 10) n
  UNION ALL
  SELECT 'stu_ind_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (1,4,8) THEN 'job_demo_promart_operations_001'
    WHEN n IN (2,7,10) THEN 'job_demo_makro_logistics_001'
    WHEN n IN (3,6) THEN 'job_demo_promart_safety_001'
    ELSE 'job_demo_interseguro_process_001'
  END FROM generate_series(1, 10) n
  UNION ALL
  SELECT 'stu_psi_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (3,6,9) THEN 'job_demo_zegel_people_analytics_001'
    WHEN n IN (1,4,8) THEN 'job_demo_innova_psychology_001'
    ELSE 'job_demo_mifarma_selection_001'
  END FROM generate_series(1, 10) n
  UNION ALL
  SELECT 'stu_der_' || lpad(n::text, 3, '0'), CASE
    WHEN n IN (1,2,4,6,8,10) THEN 'job_demo_interbank_legal_001'
    WHEN n IN (3,5,7,9) THEN 'job_demo_inkafarma_legal_001'
  END FROM generate_series(1, 10) n
), job_gaps AS (
  SELECT
    'scg_demo_job_' || sjt.student_id || '_' || sjt.job_id || '_' || jr.skill_id AS id,
    sjt.student_id,
    j.role_id,
    sjt.job_id,
    jr.skill_id,
    CASE WHEN jr.importance = 'critical' THEN 'critical' ELSE 'partial' END AS severity,
    'Brecha frente a vacante demo: ' || j.title AS reason
  FROM student_job_targets sjt
  JOIN students st ON st.id = sjt.student_id
  JOIN jobs j ON j.id = sjt.job_id
  JOIN job_requirements jr ON jr.job_id = sjt.job_id
  LEFT JOIN student_skills ss
    ON ss.student_id = sjt.student_id
   AND ss.skill_id = jr.skill_id
  WHERE jr.required_level > COALESCE(ss.level, 0)
    AND NOT (st.career = 'Derecho' AND jr.skill_id IN ('sk_python', 'sk_cloud_services', 'sk_git', 'sk_cicd', 'sk_sql'))
    AND NOT (st.career = 'Psicologia' AND jr.skill_id IN ('sk_sql', 'sk_python', 'sk_cloud_services', 'sk_cicd') AND j.role_id <> 'role_people_analytics')
    AND NOT (st.career = 'Administracion de Empresas' AND jr.skill_id = 'sk_python' AND j.role_id NOT IN ('role_data_intern', 'role_marketing_analytics'))
)
INSERT INTO student_critical_gaps (id, student_id, role_id, job_id, skill_id, severity, source, reason, status, updated_at)
SELECT id, student_id, role_id, job_id, skill_id, severity, 'job', reason, 'open', now()
FROM job_gaps
ON CONFLICT (student_id, job_id, skill_id)
  WHERE source = 'job' AND job_id IS NOT NULL
DO UPDATE SET
  role_id = EXCLUDED.role_id,
  severity = EXCLUDED.severity,
  reason = EXCLUDED.reason,
  status = 'open',
  updated_at = now();

-- ============================================================
-- 4. AUTH DEMO
-- Fuente: despega_auth_demo.sql
-- ============================================================

-- Setup de autenticacion demo para Despega UTP.
-- Contrasena demo universal: demo123.

ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash text;

UPDATE users
SET password_hash = 'demo123'
WHERE password_hash IS NULL
   OR password_hash = 'demo-password-hash';

COMMIT;

-- ============================================================
-- VALIDACIONES FINALES
-- ============================================================

SELECT 'usuarios_total' AS check_name, count(*) AS value FROM users;
SELECT 'estudiantes_total' AS check_name, count(*) AS value FROM students;
SELECT 'empresas_total' AS check_name, count(*) AS value FROM companies;
SELECT 'vacantes_total' AS check_name, count(*) AS value FROM jobs;
SELECT 'skills_total' AS check_name, count(*) AS value FROM skills;
SELECT 'critical_gaps_total' AS check_name, count(*) AS value FROM student_critical_gaps;

SELECT 'demo_students_total' AS check_name, count(*) AS value
FROM students
WHERE id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}';

SELECT career, count(*) AS total
FROM students
WHERE id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}'
GROUP BY career
ORDER BY career;

SELECT 'intercorp_companies_total' AS check_name, count(*) AS value
FROM companies
WHERE id IN (
  'comp_interbank', 'comp_interseguro', 'comp_inteligo', 'comp_izipay', 'comp_interfondos',
  'comp_plazavea', 'comp_makro', 'comp_mass', 'comp_realplaza', 'comp_oechsle', 'comp_promart',
  'comp_vivanda', 'comp_financiera_oh', 'comp_inkafarma', 'comp_mifarma', 'comp_clinica_aviva',
  'comp_quimica_suiza', 'comp_utp', 'comp_innova_schools', 'comp_idat', 'comp_zegel'
);

SELECT 'active_demo_jobs_total' AS check_name, count(*) AS value
FROM jobs
WHERE id LIKE 'job_demo_%'
  AND status = 'active';

SELECT skill_id, count(*) AS total
FROM student_critical_gaps
WHERE status = 'open'
GROUP BY skill_id
ORDER BY total DESC, skill_id;

SELECT 'admin_python_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students s ON s.id = scg.student_id
LEFT JOIN student_goals sg ON sg.student_id = scg.student_id AND sg.active = true
LEFT JOIN jobs j ON j.id = scg.job_id
WHERE s.career ILIKE '%Administracion%'
  AND scg.skill_id = 'sk_python'
  AND scg.status = 'open'
  AND COALESCE(j.role_id, sg.role_id, '') NOT IN ('role_data_intern', 'role_marketing_analytics');

SELECT 'derecho_forbidden_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students s ON s.id = scg.student_id
WHERE s.career ILIKE '%Derecho%'
  AND scg.skill_id IN ('sk_cloud_services', 'sk_cicd', 'sk_git', 'sk_python', 'sk_sql')
  AND scg.status = 'open';

SELECT 'psicologia_forbidden_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students s ON s.id = scg.student_id
LEFT JOIN student_goals sg ON sg.student_id = scg.student_id AND sg.active = true
LEFT JOIN jobs j ON j.id = scg.job_id
WHERE s.career ILIKE '%Psicologia%'
  AND scg.skill_id IN ('sk_sql', 'sk_python', 'sk_cloud_services', 'sk_cicd')
  AND scg.status = 'open'
  AND COALESCE(j.role_id, sg.role_id, '') <> 'role_people_analytics';
