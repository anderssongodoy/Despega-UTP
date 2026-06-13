"""
mock_routers.py - Endpoints de Backend 1 y Backend 2 con datos demo canónicos.
Permiten que el frontend navegue sin errores mientras los demás backends se completan.
"""
from fastapi import APIRouter, Path, Query
from app.services.config_service import get_challenges, get_challenge_by_id, get_roles

router = APIRouter()

# ---------------------------------------------------------------------------
# AUTH
# ---------------------------------------------------------------------------

@router.get("/auth/session")
def get_session(role: str = Query(default="student")):
    sessions = {
        "student": {
            "user": {"id": "stu_camila", "name": "Camila Torres",
                     "email": "camila.torres@utp.edu.pe", "role": "student"},
            "authProvider": "microsoft", "requiresOnboarding": False,
            "redirectTo": "/student/home",
        },
        "company": {
            "user": {"id": "usr_recruiter_ana", "name": "Ana Reclutadora",
                     "email": "ana@retailandino.pe", "role": "company"},
            "companyId": "comp_retail_andino",
            "authProvider": "credentials", "requiresOnboarding": False,
            "redirectTo": "/company/dashboard",
        },
        "advisor": {
            "user": {"id": "advisor_utp", "name": "Asesor Empleabilidad",
                     "email": "asesor@utp.edu.pe", "role": "advisor"},
            "authProvider": "microsoft", "requiresOnboarding": False,
            "redirectTo": "/advisor/impact",
        },
    }
    return sessions.get(role, sessions["student"])


# ---------------------------------------------------------------------------
# STUDENTS
# ---------------------------------------------------------------------------

@router.post("/students/{studentId}/onboarding")
def student_onboarding(studentId: str):
    return {
        "studentId": studentId,
        "onboardingCompleted": True,
        "goal": {"roleId": "role_data_intern", "roleName": "Practicante de Analisis de Datos"},
        "initialDiagnosis": {"readinessScore": 72, "status": "viable",
                             "criticalGaps": ["SQL", "Ingles", "Entrevista"]},
        "redirectTo": "/student/home",
    }


@router.get("/students/{studentId}/dashboard")
def student_dashboard(studentId: str):
    return {
        "student": {"id": studentId, "name": "Camila Torres",
                    "career": "Ingenieria de Sistemas e Informatica",
                    "cycle": 8, "modality": "Semipresencial"},
        "goal": {"roleId": "role_data_intern",
                 "roleName": "Practicante de Analisis de Datos",
                 "readinessScore": 72, "status": "viable"},
        "nextBestAction": {
            "title": "Completa una evidencia de SQL o dashboard",
            "description": "Tu perfil ya tiene base en Power BI, pero la vacante objetivo exige SQL intermedio.",
            "targetPage": "/student/profile?tab=evidence",
        },
        "criticalGaps": [
            {"skillName": "SQL", "severity": "partial",
             "message": "Te falta 1 nivel para vacantes de datos."},
            {"skillName": "Ingles", "severity": "critical",
             "message": "Limita vacantes con empresas regionales."},
        ],
        "recommendedJobs": [
            {"jobId": "job_data_retail", "title": "Practicante de Analisis de Datos",
             "companyName": "Retail Andino", "matchScore": 74, "status": "viable"},
        ],
        "recommendedResources": [
            {"resourceId": "res_ruta_laboral", "name": "Ruta Laboral Virtual",
             "reason": "Refuerza CV y marca personal antes de postular."},
        ],
        "progress": {"evidences": 2, "challengesCompleted": 1,
                     "applications": 2, "interviewPractice": 1},
    }


@router.post("/students/{studentId}/goal")
def update_goal(studentId: str):
    return {"studentId": studentId, "roleId": "role_data_intern",
            "message": "Meta laboral actualizada."}


@router.get("/students/{studentId}/diagnosis")
def student_diagnosis(studentId: str):
    return {
        "studentId": studentId,
        "role": {"id": "role_data_intern", "name": "Practicante de Analisis de Datos"},
        "readinessScore": 72,
        "dimensions": [
            {"name": "CV", "score": 60, "status": "partial"},
            {"name": "Habilidades tecnicas", "score": 68, "status": "partial"},
            {"name": "Evidencia", "score": 80, "status": "ready"},
            {"name": "Entrevista", "score": 55, "status": "partial"},
            {"name": "Ingles", "score": 35, "status": "critical"},
        ],
        "message": "Tu perfil tiene evidencia aplicable, pero necesita reforzar SQL e ingles.",
    }


@router.get("/students/{studentId}/gaps")
def student_gaps(studentId: str, jobId: str = Query(default="job_data_retail")):
    return {
        "studentId": studentId,
        "jobId": jobId,
        "matchScore": 74,
        "gaps": [
            {"skillId": "sk_sql", "skillName": "SQL", "currentLevel": 2,
             "requiredLevel": 3, "severity": "partial",
             "recommendedAction": "Practica consultas SELECT, JOIN y filtros con una base simple."},
            {"skillId": "sk_english", "skillName": "Ingles", "currentLevel": 1,
             "requiredLevel": 3, "severity": "critical",
             "recommendedAction": "Inscribete en English Discoveries UTP."},
        ],
        "canApplyToday": True,
        "applyAdvice": "Puedes postular ajustando tu CV y explicando tu proyecto de BI como evidencia.",
    }


@router.get("/students/{studentId}/action-plan")
def action_plan(studentId: str):
    return {
        "studentId": studentId,
        "days": [
            {"day": 1, "title": "Ajustar CV para Analisis de Datos",
             "type": "cv", "minutes": 45, "resourceId": None},
            {"day": 2, "title": "Completar practica rapida de SQL",
             "type": "skill", "minutes": 60, "resourceId": None},
            {"day": 4, "title": "Revisar modulo de Ruta Laboral Virtual sobre CV",
             "type": "utp_resource", "minutes": 45, "resourceId": "res_ruta_laboral"},
        ],
    }


@router.get("/students/{studentId}/evidences")
def student_evidences(studentId: str):
    return {
        "evidences": [
            {"id": "ev_camila_dashboard", "title": "Dashboard de ventas para curso de BI",
             "type": "academic_project", "skills": ["Excel", "Power BI", "Comunicacion"],
             "cvBullet": "Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel."},
            {"id": "ev_camila_family", "title": "Atencion al cliente en negocio familiar",
             "type": "family_business", "skills": ["Comunicacion", "Resolucion de problemas"],
             "cvBullet": "Gestione atencion a clientes y registro de pedidos, reduciendo errores mediante una lista de control."},
        ]
    }


@router.post("/students/{studentId}/evidences", status_code=201)
def create_evidence(studentId: str):
    return {
        "id": "ev_new_001",
        "studentId": studentId,
        "title": "Nueva evidencia",
        "cvBullet": "Bullet generado automaticamente.",
        "starStory": "Historia STAR generada.",
        "skillsMapped": [],
    }


@router.get("/students/{studentId}/cv")
def student_cv(studentId: str, roleId: str = Query(default="role_data_intern")):
    return {
        "studentId": studentId,
        "targetRole": "Practicante de Analisis de Datos",
        "summary": "Estudiante de Ingenieria de Sistemas con interes en analisis de datos y dashboards.",
        "bullets": [
            {"evidenceId": "ev_camila_dashboard",
             "text": "Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel.",
             "recommended": True},
        ],
        "missingSections": ["LinkedIn", "Ingles", "Certificaciones"],
    }


@router.get("/students/{studentId}/passport")
def student_passport(studentId: str):
    return {
        "studentId": studentId,
        "competencies": [
            {"name": "Tecnologia", "level": 3, "evidenceCount": 2,
             "evidences": ["Dashboard de ventas", "Micro-reto de insights"]},
            {"name": "Comunicacion", "level": 3, "evidenceCount": 2,
             "evidences": ["Presentacion de proyecto", "Atencion al cliente"]},
        ],
    }


@router.get("/students/{studentId}/interview-kit")
def interview_kit(studentId: str, jobId: str = Query(default="job_data_retail")):
    return {
        "pitch": "Soy estudiante de Ingenieria de Sistemas de 8vo ciclo, con experiencia academica en dashboards.",
        "questions": [
            {"question": "Cuentame de un proyecto donde usaste datos.",
             "suggestedAnswer": "Use el proyecto de dashboard de ventas con estructura STAR."},
            {"question": "Que harias si encuentras datos incompletos?",
             "suggestedAnswer": "Explicar limpieza, validacion y comunicacion de supuestos."},
        ],
    }


# ---------------------------------------------------------------------------
# JOBS
# ---------------------------------------------------------------------------

@router.get("/jobs")
def list_jobs(roleId: str = Query(default=None), status: str = Query(default="active")):
    return {
        "jobs": [
            {"id": "job_data_retail", "title": "Practicante de Analisis de Datos",
             "companyName": "Retail Andino", "modality": "Hibrido",
             "location": "Lima", "hours": "30h semanales"},
            {"id": "job_bi_finanzas", "title": "Practicante BI Junior",
             "companyName": "Finanzas Nova", "modality": "Remoto",
             "location": "Lima", "hours": "30h semanales"},
            {"id": "job_operations_logisur", "title": "Practicante de Operaciones",
             "companyName": "Logisur", "modality": "Presencial",
             "location": "Lima", "hours": "30h semanales"},
            {"id": "job_marketing_talentolab", "title": "Asistente de Marketing Digital",
             "companyName": "TalentoLab", "modality": "Hibrido",
             "location": "Lima", "hours": "Medio tiempo"},
        ]
    }


@router.get("/students/{studentId}/job-matches")
def job_matches(studentId: str):
    return {
        "matches": [
            {"jobId": "job_data_retail", "title": "Practicante de Analisis de Datos",
             "companyName": "Retail Andino", "matchScore": 74, "status": "viable",
             "summary": "Buen ajuste, reforzar SQL.",
             "topStrengths": ["Power BI", "Excel", "Proyecto academico"],
             "criticalGaps": ["SQL"]},
            {"jobId": "job_bi_finanzas", "title": "Practicante BI Junior",
             "companyName": "Finanzas Nova", "matchScore": 58, "status": "aspirational",
             "summary": "Interesante, pero pide SQL e ingles intermedio.",
             "topStrengths": ["Power BI"],
             "criticalGaps": ["SQL", "Ingles"]},
        ]
    }


@router.get("/students/{studentId}/jobs/{jobId}/application-kit")
def application_kit(studentId: str, jobId: str):
    return {
        "jobId": jobId,
        "matchScore": 74,
        "cvBullets": [
            "Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel.",
        ],
        "pitch": "Soy estudiante de Ingenieria de Sistemas de 8vo ciclo con base en Excel, Power BI.",
        "interviewQuestions": [
            "Cuentame de un proyecto donde transformaste datos en una recomendacion.",
            "Como validarias una base con datos incompletos?",
        ],
        "risks": ["SQL aparece como brecha parcial. Preparar ejemplo de aprendizaje."],
        "applyRecommendation": "Postular hoy con CV ajustado y compromiso de reforzar SQL.",
    }


@router.get("/students/{studentId}/applications")
def student_applications(studentId: str):
    return {
        "applications": [
            {"id": "app_camila_data_retail", "jobTitle": "Practicante de Analisis de Datos",
             "companyName": "Retail Andino", "matchScore": 74, "status": "prepared",
             "nextAction": "Enviar postulacion y practicar entrevista."},
        ]
    }


@router.post("/students/{studentId}/applications", status_code=201)
def create_application(studentId: str):
    return {
        "id": "app_new_001",
        "studentId": studentId,
        "jobId": "job_data_retail",
        "status": "prepared",
        "createdAt": "2026-06-13T00:00:00Z",
    }


# ---------------------------------------------------------------------------
# CHALLENGES
# ---------------------------------------------------------------------------

@router.get("/challenges")
def list_challenges(roleId: str = Query(default=None)):
    challenges = get_challenges()
    filtered = [c for c in challenges if not roleId or c.get("roleId") == roleId]
    return {
        "challenges": [
            {"id": c["id"], "title": c["title"],
             "difficulty": c["difficulty"],
             "durationMinutes": c["durationMinutes"],
             "skills": c.get("skills", [])}
            for c in filtered
        ]
    }


@router.get("/challenges/{challengeId}")
def get_challenge(challengeId: str):
    challenge = get_challenge_by_id(challengeId)
    if not challenge:
        return {"error": {"code": "NOT_FOUND", "message": "Reto no encontrado."}}
    return challenge


@router.post("/challenges/{challengeId}/submit")
def submit_challenge(challengeId: str):
    return {
        "submissionId": "sub_demo_001",
        "score": 78,
        "feedback": "Buen analisis inicial. Tu recomendacion conecta ventas y margen.",
        "generatedEvidence": {
            "id": "ev_challenge_001",
            "title": "Micro-reto de analisis de ventas",
            "cvBullet": "Analice una tabla de ventas para identificar oportunidades comerciales.",
        },
    }


# ---------------------------------------------------------------------------
# EVIDENCES (generate-cv-bullet)
# ---------------------------------------------------------------------------

@router.post("/evidences/{evidenceId}/generate-cv-bullet")
def generate_cv_bullet(evidenceId: str):
    return {
        "evidenceId": evidenceId,
        "cvBullet": "Desarrolle un dashboard de ventas en Power BI a partir de datos limpiados en Excel.",
        "tone": "professional",
        "source": "template",
    }
