-- Despega UTP - PostgreSQL MVP demo seed
-- Uso:
--   psql -U postgres -d despega_utp -f database/init_postgres_demo.sql
--
-- Este script es destructivo para las tablas del MVP: borra y recrea el modelo.
-- Los catalogos estables (roles, recursos UTP, retos) viven en data-config/*.json.

BEGIN;

DROP TABLE IF EXISTS challenge_submissions CASCADE;
DROP TABLE IF EXISTS applications CASCADE;
DROP TABLE IF EXISTS job_requirements CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS evidence_skills CASCADE;
DROP TABLE IF EXISTS evidences CASCADE;
DROP TABLE IF EXISTS student_skills CASCADE;
DROP TABLE IF EXISTS skills CASCADE;
DROP TABLE IF EXISTS student_goals CASCADE;
DROP TABLE IF EXISTS company_users CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
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

CREATE TABLE students (
  id varchar PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
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

CREATE TABLE companies (
  id varchar PRIMARY KEY,
  name varchar NOT NULL,
  sector varchar NOT NULL,
  description text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE company_users (
  id varchar PRIMARY KEY,
  user_id varchar NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  company_id varchar NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  position varchar,
  UNIQUE (user_id, company_id)
);

CREATE TABLE student_goals (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  role_id varchar NOT NULL,
  target_role_name varchar NOT NULL,
  availability varchar,
  preferred_work_mode varchar,
  application_timeframe varchar,
  active boolean NOT NULL DEFAULT true,
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE TABLE skills (
  id varchar PRIMARY KEY,
  name varchar NOT NULL,
  type varchar NOT NULL CHECK (type IN ('technical', 'soft', 'language')),
  category varchar,
  active boolean NOT NULL DEFAULT true
);

CREATE TABLE student_skills (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  skill_id varchar NOT NULL REFERENCES skills(id),
  level int NOT NULL CHECK (level BETWEEN 0 AND 5),
  source varchar NOT NULL CHECK (source IN ('self_reported', 'evidence', 'challenge', 'advisor')),
  updated_at timestamp NOT NULL DEFAULT now(),
  UNIQUE (student_id, skill_id)
);

CREATE TABLE evidences (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
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

CREATE TABLE evidence_skills (
  id varchar PRIMARY KEY,
  evidence_id varchar NOT NULL REFERENCES evidences(id) ON DELETE CASCADE,
  skill_id varchar NOT NULL REFERENCES skills(id),
  confidence int CHECK (confidence BETWEEN 0 AND 100),
  UNIQUE (evidence_id, skill_id)
);

CREATE TABLE jobs (
  id varchar PRIMARY KEY,
  company_id varchar NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
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

CREATE TABLE job_requirements (
  id varchar PRIMARY KEY,
  job_id varchar NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  skill_id varchar NOT NULL REFERENCES skills(id),
  required_level int NOT NULL CHECK (required_level BETWEEN 0 AND 5),
  importance varchar NOT NULL CHECK (importance IN ('critical', 'important', 'optional')),
  UNIQUE (job_id, skill_id)
);

CREATE TABLE applications (
  id varchar PRIMARY KEY,
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  job_id varchar NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  status varchar NOT NULL CHECK (status IN ('prepared', 'applied', 'interviewing', 'rejected', 'accepted')),
  notes text,
  created_at timestamp NOT NULL DEFAULT now(),
  updated_at timestamp NOT NULL DEFAULT now(),
  UNIQUE (student_id, job_id)
);

CREATE TABLE challenge_submissions (
  id varchar PRIMARY KEY,
  challenge_id varchar NOT NULL,
  student_id varchar NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  answers_json jsonb NOT NULL,
  score int NOT NULL CHECK (score BETWEEN 0 AND 100),
  feedback text,
  generated_evidence_id varchar REFERENCES evidences(id),
  created_at timestamp NOT NULL DEFAULT now()
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_students_career_cycle ON students(career, cycle);
CREATE INDEX idx_student_goals_student_active ON student_goals(student_id, active);
CREATE INDEX idx_student_skills_student ON student_skills(student_id);
CREATE INDEX idx_evidences_student ON evidences(student_id);
CREATE INDEX idx_jobs_company_status ON jobs(company_id, status);
CREATE INDEX idx_job_requirements_job ON job_requirements(job_id);
CREATE INDEX idx_applications_student ON applications(student_id);
CREATE INDEX idx_applications_job ON applications(job_id);

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
  ('advisor_utp', 'Asesor Empleabilidad', 'asesor@utp.edu.pe', 'advisor', 'microsoft', NULL, true);

INSERT INTO students (id, career, cycle, campus, modality, availability, english_level, linkedin_url, cv_status) VALUES
  ('stu_camila', 'Ingenieria de Sistemas e Informatica', 8, 'Lima Centro', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', 'https://linkedin.com/in/camila-torres-utp', 'incomplete'),
  ('stu_diego', 'Administracion', 7, 'Lima Norte', 'Presencial', 'Medio tiempo', 'Basico', NULL, 'incomplete'),
  ('stu_valeria', 'Marketing', 6, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/valeria-paredes-utp', 'updated'),
  ('stu_luis', 'Ingenieria Industrial', 9, 'Lima Sur', 'Semipresencial', 'Practicas preprofesionales - 30h', 'Basico', NULL, 'updated'),
  ('stu_andrea', 'Psicologia', 8, 'Lima Centro', 'A distancia', 'Medio tiempo', 'Basico', NULL, 'incomplete'),
  ('stu_renzo', 'Ingenieria de Sistemas e Informatica', 10, 'Lima Norte', 'Semipresencial', 'Tiempo completo', 'Intermedio', 'https://linkedin.com/in/renzo-castillo-utp', 'updated'),
  ('stu_mateo', 'Ingenieria de Software', 9, 'Lima Centro', 'Presencial', 'Practicas preprofesionales - 30h', 'Intermedio', 'https://linkedin.com/in/mateo-rivas-utp', 'updated'),
  ('stu_lucia', 'Comunicaciones', 7, 'Lima Centro', 'Semipresencial', 'Medio tiempo', 'Intermedio', NULL, 'incomplete');

INSERT INTO companies (id, name, sector, description) VALUES
  ('comp_retail_andino', 'Retail Andino', 'Retail', 'Cadena retail con operaciones comerciales y analitica de ventas.'),
  ('comp_finanzas_nova', 'Finanzas Nova', 'Servicios financieros', 'Fintech local con foco en reportes y eficiencia financiera.'),
  ('comp_logisur', 'Logisur', 'Logistica', 'Operador logistico con procesos de almacen y distribucion.'),
  ('comp_talentolab', 'TalentoLab', 'Consultoria RRHH', 'Consultora de talento, clima laboral y seleccion.'),
  ('comp_datamarket', 'DataMarket Peru', 'Tecnologia / datos', 'Empresa de soluciones de datos y software interno.');

INSERT INTO company_users (id, user_id, company_id, position) VALUES
  ('cu_retail_ana', 'usr_recruiter_ana', 'comp_retail_andino', 'Reclutadora'),
  ('cu_talentolab_paola', 'usr_recruiter_talento', 'comp_talentolab', 'People Partner');

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
  ('sk_process_analysis', 'Analisis de procesos', 'technical', 'operations');

INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active) VALUES
  ('goal_camila_data', 'stu_camila', 'role_data_intern', 'Practicante de Analisis de Datos', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true),
  ('goal_diego_commercial', 'stu_diego', 'role_commercial_analyst', 'Asistente Comercial Junior', 'Medio tiempo', 'Hibrido', 'Este mes', true),
  ('goal_valeria_marketing', 'stu_valeria', 'role_marketing_assistant', 'Asistente de Marketing Digital', 'Practicas preprofesionales - 30h', 'Hibrido', 'Este mes', true),
  ('goal_luis_ops', 'stu_luis', 'role_operations_intern', 'Practicante de Operaciones', 'Practicas preprofesionales - 30h', 'Presencial', 'Este mes', true),
  ('goal_andrea_people', 'stu_andrea', 'role_people_analytics', 'Practicante de People Analytics', 'Medio tiempo', 'Remoto', 'En las proximas 4 semanas', true),
  ('goal_renzo_support', 'stu_renzo', 'role_it_support', 'Soporte TI Junior', 'Tiempo completo', 'Presencial', 'Este mes', true),
  ('goal_mateo_dev', 'stu_mateo', 'role_software_intern', 'Practicante de Desarrollo de Software', 'Practicas preprofesionales - 30h', 'Hibrido', 'En las proximas 2 semanas', true),
  ('goal_lucia_mkt_analytics', 'stu_lucia', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Medio tiempo', 'Hibrido', 'En las proximas 4 semanas', true);

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
  ('ss_lucia_powerbi', 'stu_lucia', 'sk_powerbi', 1, 'self_reported');

INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source) VALUES
  ('ev_camila_dashboard', 'stu_camila', 'Dashboard de ventas para curso de BI', 'academic_project', 'Proyecto final de curso', 'Limpie datos en Excel y cree un dashboard en Power BI para analizar ventas.', 'El equipo identifico productos con mayor margen y presento recomendaciones.', 'Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel, identificando productos de mayor margen para apoyar decisiones comerciales.', 'Situacion: proyecto final de BI. Tarea: convertir una base desordenada en insight. Accion: limpie datos, modele indicadores y cree dashboard. Resultado: el equipo priorizo productos de mayor margen.', 'onboarding'),
  ('ev_camila_family', 'stu_camila', 'Atencion al cliente en negocio familiar', 'family_business', 'Apoyo operativo en tienda familiar', 'Registre pedidos, ordene incidencias y respondi consultas de clientes.', 'Se redujeron errores de pedido usando una lista de control.', 'Gestione atencion a clientes y registro de pedidos, reduciendo errores mediante una lista de control.', 'Situacion: tienda familiar con errores frecuentes. Accion: cree checklist y seguimiento. Resultado: menos reclamos y mejor orden.', 'manual'),
  ('ev_mateo_api', 'stu_mateo', 'API de reservas con Python', 'academic_project', 'Curso de arquitectura de software', 'Construyo endpoints REST, modelo de datos y pruebas unitarias para reservas.', 'El prototipo permitio registrar y consultar reservas sin errores criticos.', 'Construyo una API REST en Python con pruebas unitarias para gestionar reservas academicas.', 'Situacion: proyecto de curso. Accion: diseno endpoints y pruebas. Resultado: API funcional para demo tecnica.', 'onboarding'),
  ('ev_andrea_clima', 'stu_andrea', 'Encuesta de clima para proyecto academico', 'academic_project', 'Curso de psicologia organizacional', 'Diseno encuesta, aplico entrevistas y sintetizo hallazgos de clima.', 'Se identificaron factores de motivacion y riesgo para el equipo analizado.', 'Disene y analice una encuesta de clima organizacional, sintetizando hallazgos accionables para mejorar motivacion del equipo.', 'Situacion: diagnostico de clima. Accion: encuesta y entrevistas. Resultado: hallazgos priorizados.', 'onboarding'),
  ('ev_lucia_campaign', 'stu_lucia', 'Campana de contenidos para emprendimiento', 'academic_project', 'Proyecto de comunicacion digital', 'Planifico calendario, redacto piezas y midio engagement de publicaciones.', 'El reporte identifico formatos con mayor interaccion.', 'Planifique y analice una campana de contenidos, usando metricas de engagement para recomendar formatos con mejor desempeno.', 'Situacion: emprendimiento sin lectura de metricas. Accion: calendario y reporte. Resultado: formatos priorizados.', 'onboarding'),
  ('ev_renzo_support', 'stu_renzo', 'Documentacion de incidencias TI', 'work_experience', 'Apoyo a laboratorio de computo', 'Registro incidencias, clasifico causas y documento soluciones frecuentes.', 'Se redujo el tiempo de respuesta para incidencias repetidas.', 'Documente incidencias TI y soluciones frecuentes, reduciendo tiempos de atencion para problemas repetidos.', 'Situacion: incidencias recurrentes. Accion: registro y documentacion. Resultado: respuesta mas rapida.', 'manual'),
  ('ev_luis_process', 'stu_luis', 'Analisis de tiempos de proceso', 'academic_project', 'Curso de gestion de operaciones', 'Medi tiempos, identifique cuellos de botella y propuse redistribucion de tareas.', 'La propuesta reducia tiempos estimados en el flujo simulado.', 'Analice tiempos de proceso e identifique cuellos de botella para proponer mejoras operativas.', 'Situacion: flujo lento. Accion: medicion y analisis. Resultado: propuesta de mejora.', 'onboarding'),
  ('ev_valeria_social', 'stu_valeria', 'Reporte de redes para marca local', 'academic_project', 'Curso de marketing digital', 'Compare publicaciones por alcance, interaccion y conversion estimada.', 'Se priorizaron formatos cortos con mayor engagement.', 'Analice metricas de redes sociales y recomende formatos de contenido con mayor engagement.', 'Situacion: marca sin analisis. Accion: reporte de metricas. Resultado: recomendacion de formatos.', 'manual');

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
  ('esk_valeria_metrics', 'ev_valeria_social', 'sk_analytics_marketing', 85);

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
  ('job_marketing_analytics_talentolab', 'comp_talentolab', 'role_marketing_analytics', 'Asistente de Marketing Analytics', 'Hibrido', 'Lima', 'Medio tiempo', 'Leer metricas digitales y proponer mejoras de contenido.', 'active');

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
  ('jr_mkt_analytics_copy', 'job_marketing_analytics_talentolab', 'sk_copywriting', 3, 'important');

INSERT INTO applications (id, student_id, job_id, status, notes) VALUES
  ('app_camila_data_retail', 'stu_camila', 'job_data_retail', 'prepared', 'CV ajustado pendiente de enviar.'),
  ('app_camila_bi_finanzas', 'stu_camila', 'job_bi_finanzas', 'prepared', 'Aspiracional: reforzar SQL antes de postular.'),
  ('app_mateo_dev', 'stu_mateo', 'job_dev_datamarket', 'prepared', 'Buen fit tecnico; practicar pitch tecnico.'),
  ('app_andrea_people', 'stu_andrea', 'job_people_analytics_talentolab', 'prepared', 'Reforzar Python basico.'),
  ('app_lucia_marketing_analytics', 'stu_lucia', 'job_marketing_analytics_talentolab', 'prepared', 'Completar evidencia de metricas.');

INSERT INTO challenge_submissions (id, challenge_id, student_id, answers_json, score, feedback, generated_evidence_id) VALUES
  ('sub_camila_sales_insight', 'cha_sales_insight', 'stu_camila', '{"summary":"Mayor margen en categorias de baja rotacion","recommendation":"Priorizar surtido y seguimiento semanal"}', 82, 'Buen analisis comercial; falta explicar supuestos.', NULL),
  ('sub_mateo_soft_story', 'cha_soft_skills_technical_story', 'stu_mateo', '{"technicalDecision":"API REST con capas","businessExplanation":"Separar capas facilita mantenimiento y reduce errores"}', 74, 'La explicacion es clara, puede cerrar con impacto de negocio.', NULL),
  ('sub_andrea_people_python', 'cha_people_analytics_python', 'stu_andrea', '{"dataset":"encuesta clima","finding":"satisfaccion menor en comunicacion interna"}', 71, 'Buen enfoque humano; falta detalle tecnico de analisis.', NULL);

COMMIT;

