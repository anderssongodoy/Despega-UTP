-- Demo Intercorp seed: students, companies, jobs, skills and critical gaps.
-- Safe to rerun. Preserves existing data.

BEGIN;

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

COMMIT;

SELECT 'demo_students_total' AS check_name, count(*) AS value
FROM students
WHERE id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}';

SELECT 'demo_students_by_career' AS check_name, career, count(*) AS value
FROM students
WHERE id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}'
GROUP BY career
ORDER BY career;

SELECT 'demo_companies_total' AS check_name, count(*) AS value
FROM companies
WHERE id IN (
  'comp_interbank', 'comp_interseguro', 'comp_inteligo', 'comp_izipay', 'comp_interfondos',
  'comp_plazavea', 'comp_makro', 'comp_mass', 'comp_realplaza', 'comp_oechsle', 'comp_promart',
  'comp_vivanda', 'comp_financiera_oh', 'comp_inkafarma', 'comp_mifarma', 'comp_clinica_aviva',
  'comp_quimica_suiza', 'comp_utp', 'comp_innova_schools', 'comp_idat', 'comp_zegel'
);

SELECT 'demo_jobs_total' AS check_name, count(*) AS value
FROM jobs
WHERE id LIKE 'job_demo_%';

SELECT 'open_gaps_by_career' AS check_name, st.career, count(*) AS value
FROM student_critical_gaps scg
JOIN students st ON st.id = scg.student_id
WHERE scg.student_id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}'
  AND scg.status = 'open'
GROUP BY st.career
ORDER BY st.career;

SELECT 'open_gaps_by_skill' AS check_name, scg.skill_id, count(*) AS value
FROM student_critical_gaps scg
WHERE scg.student_id SIMILAR TO 'stu_(sis|adm|ind|psi|der)_[0-9]{3}'
  AND scg.status = 'open'
GROUP BY scg.skill_id
ORDER BY value DESC, scg.skill_id;

SELECT 'admin_python_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students st ON st.id = scg.student_id
LEFT JOIN student_goals sg ON sg.student_id = scg.student_id AND sg.active = true
LEFT JOIN jobs j ON j.id = scg.job_id
WHERE st.career = 'Administracion de Empresas'
  AND scg.skill_id = 'sk_python'
  AND COALESCE(j.role_id, sg.role_id) NOT IN ('role_data_intern', 'role_marketing_analytics');

SELECT 'derecho_forbidden_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students st ON st.id = scg.student_id
WHERE st.career = 'Derecho'
  AND scg.skill_id IN ('sk_cloud_services', 'sk_cicd', 'sk_git', 'sk_python');

SELECT 'psicologia_forbidden_gap_violations' AS check_name, count(*) AS value
FROM student_critical_gaps scg
JOIN students st ON st.id = scg.student_id
LEFT JOIN student_goals sg ON sg.student_id = scg.student_id AND sg.active = true
LEFT JOIN jobs j ON j.id = scg.job_id
WHERE st.career = 'Psicologia'
  AND scg.skill_id IN ('sk_sql', 'sk_python', 'sk_cloud_services', 'sk_cicd')
  AND COALESCE(j.role_id, sg.role_id) <> 'role_people_analytics';
