// Catálogo de skills — IDs reales del catálogo de la BD (tabla skills).
// Agrupado por área para que el alumno encuentre las suyas sin importar la carrera.

export type SkillOption = { id: string; name: string };

export const SKILL_GROUPS: { label: string; skills: SkillOption[] }[] = [
  {
    label: "Datos",
    skills: [
      { id: "sk_excel", name: "Excel" },
      { id: "sk_sql", name: "SQL" },
      { id: "sk_python", name: "Python" },
      { id: "sk_powerbi", name: "Power BI" },
      { id: "sk_business_intelligence", name: "Inteligencia de negocios" },
      { id: "sk_business_analytics", name: "Analitica de datos" },
      { id: "sk_database", name: "Bases de datos" },
    ],
  },
  {
    label: "Software",
    skills: [
      { id: "sk_programming", name: "Programacion" },
      { id: "sk_oop", name: "Programacion orientada a objetos" },
      { id: "sk_algorithms", name: "Algoritmos" },
      { id: "sk_web_development", name: "Desarrollo web" },
      { id: "sk_api", name: "APIs REST" },
      { id: "sk_javascript", name: "JavaScript" },
      { id: "sk_git", name: "Git" },
      { id: "sk_testing", name: "Pruebas unitarias" },
      { id: "sk_cybersecurity", name: "Seguridad informatica" },
    ],
  },
  {
    label: "Gestion y operaciones",
    skills: [
      { id: "sk_project_management", name: "Gestion de proyectos" },
      { id: "sk_process_management", name: "Gestion por procesos" },
      { id: "sk_operations_management", name: "Gestion de operaciones" },
      { id: "sk_strategic_management", name: "Direccion estrategica" },
      { id: "sk_logistics", name: "Logistica" },
      { id: "sk_supply_chain", name: "Cadena de abastecimiento" },
    ],
  },
  {
    label: "Negocios y finanzas",
    skills: [
      { id: "sk_finance", name: "Finanzas" },
      { id: "sk_accounting", name: "Contabilidad" },
      { id: "sk_costs_budgets", name: "Costos y presupuestos" },
      { id: "sk_business_management", name: "Gestion general" },
      { id: "sk_sales_management", name: "Gestion de ventas" },
      { id: "sk_human_resources", name: "Gestion humana" },
    ],
  },
  {
    label: "Marketing",
    skills: [
      { id: "sk_marketing", name: "Marketing" },
      { id: "sk_analytics_marketing", name: "Metricas digitales" },
      { id: "sk_market_research", name: "Investigacion de mercados" },
    ],
  },
  {
    label: "Derecho",
    skills: [
      { id: "sk_legal_analysis", name: "Analisis legal" },
      { id: "sk_corporate_law", name: "Derecho corporativo" },
      { id: "sk_labor_law", name: "Derecho laboral" },
      { id: "sk_legal_writing", name: "Redaccion juridica" },
      { id: "sk_oral_litigation", name: "Litigacion oral" },
      { id: "sk_legal_research", name: "Investigacion juridica" },
    ],
  },
  {
    label: "Psicologia",
    skills: [
      { id: "sk_psychological_interview", name: "Entrevista psicologica" },
      { id: "sk_psychometrics", name: "Psicometria" },
      { id: "sk_mental_health", name: "Salud mental" },
      { id: "sk_organizational_consulting", name: "Consultoria organizacional" },
      { id: "sk_vocational_diagnosis", name: "Diagnostico vocacional" },
    ],
  },
  {
    label: "Habilidades blandas",
    skills: [
      { id: "sk_communication", name: "Comunicacion" },
      { id: "sk_problem_solving", name: "Resolucion de problemas" },
      { id: "sk_teamwork", name: "Trabajo en equipo" },
      { id: "sk_leadership", name: "Liderazgo" },
      { id: "sk_english", name: "Ingles" },
    ],
  },
];

export const ALL_SKILLS: SkillOption[] = SKILL_GROUPS.flatMap((group) => group.skills);
