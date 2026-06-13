from typing import Annotated, Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException

from app.core.db import execute, fetch_all, fetch_one, get_connection
from app.core.json_loader import get_roles
from app.services.matching import calculate_match, get_active_goal, get_recommended_resources


router = APIRouter()


def _student_or_404(conn, student_id: str) -> dict:
    student = fetch_one(
        conn,
        """
        SELECT s.*, u.name, u.email
        FROM students s
        JOIN users u ON u.id = s.id
        WHERE s.id = %s
        """,
        (student_id,),
    )
    if not student:
        raise HTTPException(status_code=404, detail="Student not found")
    return student


def _first_recommended_job(conn, student_id: str) -> dict | None:
    jobs = fetch_all(
        conn,
        """
        SELECT id, title, company_id
        FROM jobs
        WHERE status = 'active'
        ORDER BY created_at
        """,
    )
    scored = []
    for job in jobs:
        match = calculate_match(conn, student_id, job["id"])
        scored.append({**job, **match})
    scored.sort(key=lambda item: item["matchScore"], reverse=True)
    return scored[0] if scored else None


@router.get("/roles")
def list_roles() -> dict:
    return {"roles": get_roles()}


@router.post("/students/{student_id}/onboarding")
def complete_onboarding(
    student_id: str,
    payload: dict[str, Any],
    conn: Annotated[object, Depends(get_connection)],
) -> dict:
    user = fetch_one(conn, "SELECT id FROM users WHERE id = %s AND role = 'student'", (student_id,))
    if not user:
        raise HTTPException(status_code=404, detail="Student user not found")

    academic = payload.get("academicProfile", {})
    goal = payload.get("employmentGoal", {})
    evidence = payload.get("initialEvidence", {})
    self_assessment = payload.get("selfAssessment", {})

    execute(
        conn,
        """
        INSERT INTO students (id, career, cycle, campus, modality, availability, english_level, linkedin_url, cv_status)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (id) DO UPDATE SET
          career = EXCLUDED.career,
          cycle = EXCLUDED.cycle,
          campus = EXCLUDED.campus,
          modality = EXCLUDED.modality,
          availability = EXCLUDED.availability,
          linkedin_url = EXCLUDED.linkedin_url,
          cv_status = EXCLUDED.cv_status,
          updated_at = now()
        """,
        (
            student_id,
            academic.get("career", "Pendiente"),
            academic.get("cycle", 7),
            academic.get("campus", "Lima Centro"),
            academic.get("modality", "Presencial"),
            goal.get("availability"),
            self_assessment.get("englishLevel", "Basico"),
            self_assessment.get("linkedinUrl", ""),
            self_assessment.get("cvStatus", "incomplete"),
        ),
    )

    execute(conn, "UPDATE student_goals SET active = false WHERE student_id = %s", (student_id,))
    execute(
        conn,
        """
        INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active)
        VALUES (%s, %s, %s, %s, %s, %s, %s, true)
        """,
        (
            f"goal_{student_id}_{uuid4().hex[:8]}",
            student_id,
            goal.get("targetRoleId", "role_data_intern"),
            goal.get("targetRoleName", "Practicante de Analisis de Datos"),
            goal.get("availability"),
            goal.get("preferredWorkMode"),
            goal.get("applicationTimeframe"),
        ),
    )

    for skill_id in self_assessment.get("knownSkills", []):
        execute(
            conn,
            """
            INSERT INTO student_skills (id, student_id, skill_id, level, source)
            VALUES (%s, %s, %s, 3, 'self_reported')
            ON CONFLICT (student_id, skill_id) DO UPDATE SET level = GREATEST(student_skills.level, 3), updated_at = now()
            """,
            (f"ss_{student_id}_{skill_id}", student_id, skill_id),
        )

    evidence_id = f"ev_{student_id}_{uuid4().hex[:8]}"
    cv_bullet = (
        f"{evidence.get('actions', 'Desarrollo una experiencia relevante')} "
        f"para lograr: {evidence.get('result', 'un resultado concreto')}."
    )
    execute(
        conn,
        """
        INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'onboarding')
        """,
        (
            evidence_id,
            student_id,
            evidence.get("title", "Evidencia inicial"),
            evidence.get("type", "academic_project"),
            evidence.get("context", ""),
            evidence.get("actions", "Acciones pendientes de detallar"),
            evidence.get("result", "Resultado pendiente de detallar"),
            cv_bullet,
            f"Situacion: {evidence.get('context', '')}. Accion: {evidence.get('actions', '')}. Resultado: {evidence.get('result', '')}.",
        ),
    )

    for skill_id in evidence.get("skills", []):
        execute(
            conn,
            """
            INSERT INTO evidence_skills (id, evidence_id, skill_id, confidence)
            VALUES (%s, %s, %s, 70)
            ON CONFLICT (evidence_id, skill_id) DO NOTHING
            """,
            (f"esk_{evidence_id}_{skill_id}", evidence_id, skill_id),
        )

    execute(conn, "UPDATE users SET onboarding_completed = true, updated_at = now() WHERE id = %s", (student_id,))

    return {
        "studentId": student_id,
        "onboardingCompleted": True,
        "createdEvidence": {"id": evidence_id, "title": evidence.get("title", "Evidencia inicial"), "cvBullet": cv_bullet},
        "goal": {"roleId": goal.get("targetRoleId", "role_data_intern"), "roleName": goal.get("targetRoleName", "Practicante de Analisis de Datos")},
        "initialDiagnosis": {"readinessScore": 65, "status": "viable", "criticalGaps": self_assessment.get("perceivedGaps", [])},
        "redirectTo": "/student/home",
    }


@router.get("/students/{student_id}/dashboard")
def get_student_dashboard(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    student = _student_or_404(conn, student_id)
    goal = get_active_goal(conn, student_id)
    best_job = _first_recommended_job(conn, student_id)
    gaps = best_job["gaps"] if best_job else []
    resources = get_recommended_resources(gaps)

    return {
        "student": {
            "id": student["id"],
            "name": student["name"],
            "career": student["career"],
            "cycle": student["cycle"],
            "modality": student["modality"],
        },
        "goal": {
            "roleId": goal["role_id"] if goal else None,
            "roleName": goal["target_role_name"] if goal else None,
            "readinessScore": best_job["matchScore"] if best_job else 0,
            "status": best_job["status"] if best_job else "not_recommended",
        },
        "nextBestAction": {
            "title": "Completa una evidencia o cierra tu brecha principal",
            "description": gaps[0]["message"] if gaps else "Tu perfil ya tiene una vacante viable.",
            "targetPage": "/student/profile?tab=evidence",
        },
        "criticalGaps": gaps[:3],
        "recommendedJobs": get_job_matches(student_id, conn)["jobs"][:3],
        "recommendedResources": resources,
        "progress": {
            "evidences": fetch_one(conn, "SELECT count(*) AS total FROM evidences WHERE student_id = %s", (student_id,))["total"],
            "challengesCompleted": fetch_one(conn, "SELECT count(*) AS total FROM challenge_submissions WHERE student_id = %s", (student_id,))["total"],
            "applications": fetch_one(conn, "SELECT count(*) AS total FROM applications WHERE student_id = %s", (student_id,))["total"],
            "interviewPractice": 1,
        },
    }


@router.post("/students/{student_id}/goal")
def update_goal(student_id: str, payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    execute(conn, "UPDATE student_goals SET active = false WHERE student_id = %s", (student_id,))
    goal_id = f"goal_{student_id}_{uuid4().hex[:8]}"
    execute(
        conn,
        """
        INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active)
        VALUES (%s, %s, %s, %s, %s, %s, %s, true)
        """,
        (
            goal_id,
            student_id,
            payload.get("roleId", "role_data_intern"),
            payload.get("targetRoleName", "Practicante de Analisis de Datos"),
            payload.get("availability"),
            payload.get("preferredWorkMode"),
            payload.get("applicationTimeframe"),
        ),
    )
    return {"id": goal_id, "active": True}


@router.get("/students/{student_id}/diagnosis")
def get_diagnosis(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    best_job = _first_recommended_job(conn, student_id)
    return {
        "studentId": student_id,
        "readinessScore": best_job["matchScore"] if best_job else 0,
        "status": best_job["status"] if best_job else "not_recommended",
        "strengths": best_job["strengths"] if best_job else [],
        "criticalGaps": best_job["gaps"][:4] if best_job else [],
    }


@router.get("/students/{student_id}/gaps")
def get_gaps(student_id: str, conn: Annotated[object, Depends(get_connection)], jobId: str = "job_data_retail") -> dict:
    _student_or_404(conn, student_id)
    match = calculate_match(conn, student_id, jobId)
    return {"studentId": student_id, "jobId": jobId, "matchScore": match["matchScore"], "gaps": match["gaps"], "strengths": match["strengths"]}


@router.get("/students/{student_id}/action-plan")
def get_action_plan(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    diagnosis = get_diagnosis(student_id, conn)
    gaps = diagnosis["criticalGaps"]
    actions = []
    for idx, gap in enumerate(gaps[:4], start=1):
        actions.append(
            {
                "day": idx * 2,
                "title": f"Reforzar {gap['skillName']}",
                "description": gap["message"],
                "targetPage": "/student/challenges" if gap["severity"] == "critical" else "/student/profile",
            }
        )
    if not actions:
        actions.append({"day": 1, "title": "Preparar postulacion", "description": "Tu perfil ya esta listo para una vacante viable.", "targetPage": "/student/opportunities"})
    return {"studentId": student_id, "durationDays": 14, "actions": actions}


@router.get("/students/{student_id}/evidences")
def get_evidences(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    evidences = fetch_all(conn, "SELECT * FROM evidences WHERE student_id = %s ORDER BY created_at DESC", (student_id,))
    return {"evidences": evidences}


@router.post("/students/{student_id}/evidences")
def create_evidence(student_id: str, payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    evidence_id = f"ev_{student_id}_{uuid4().hex[:8]}"
    cv_bullet = f"{payload.get('actions', 'Desarrollo acciones relevantes')} para lograr {payload.get('result', 'un resultado concreto')}."
    execute(
        conn,
        """
        INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'manual')
        """,
        (
            evidence_id,
            student_id,
            payload.get("title", "Nueva evidencia"),
            payload.get("type", "academic_project"),
            payload.get("context", ""),
            payload.get("actions", ""),
            payload.get("result", ""),
            cv_bullet,
            f"Situacion: {payload.get('context', '')}. Accion: {payload.get('actions', '')}. Resultado: {payload.get('result', '')}.",
        ),
    )
    return {"id": evidence_id, "cvBullet": cv_bullet}


@router.post("/evidences/{evidence_id}/generate-cv-bullet")
def generate_cv_bullet(evidence_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    evidence = fetch_one(conn, "SELECT * FROM evidences WHERE id = %s", (evidence_id,))
    if not evidence:
        raise HTTPException(status_code=404, detail="Evidence not found")
    bullet = f"{evidence['actions']} Resultado: {evidence['result']}"
    execute(conn, "UPDATE evidences SET cv_bullet = %s, updated_at = now() WHERE id = %s", (bullet, evidence_id))
    return {"evidenceId": evidence_id, "cvBullet": bullet}


@router.get("/students/{student_id}/cv")
def get_cv(student_id: str, conn: Annotated[object, Depends(get_connection)], roleId: str = "role_data_intern") -> dict:
    student = _student_or_404(conn, student_id)
    bullets = fetch_all(conn, "SELECT cv_bullet FROM evidences WHERE student_id = %s AND cv_bullet IS NOT NULL", (student_id,))
    return {
        "studentId": student_id,
        "roleId": roleId,
        "summary": f"Estudiante de {student['career']} de {student['cycle']} ciclo con evidencias orientadas al rol objetivo.",
        "bullets": [row["cv_bullet"] for row in bullets],
    }


@router.get("/students/{student_id}/passport")
def get_passport(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    student = _student_or_404(conn, student_id)
    skills = fetch_all(
        conn,
        """
        SELECT s.id, s.name, ss.level
        FROM student_skills ss
        JOIN skills s ON s.id = ss.skill_id
        WHERE ss.student_id = %s
        ORDER BY ss.level DESC, s.name
        """,
        (student_id,),
    )
    evidences = fetch_all(conn, "SELECT id, title, cv_bullet FROM evidences WHERE student_id = %s", (student_id,))
    return {"student": student, "skills": skills, "evidences": evidences}


@router.get("/students/{student_id}/interview-kit")
def get_interview_kit(student_id: str, conn: Annotated[object, Depends(get_connection)], jobId: str = "job_data_retail") -> dict:
    _student_or_404(conn, student_id)
    match = calculate_match(conn, student_id, jobId)
    return {
        "studentId": student_id,
        "jobId": jobId,
        "pitch": "Soy estudiante UTP con evidencias concretas y foco en aprender rapido en un entorno real.",
        "questions": [
            "Cuentame sobre una evidencia donde aplicaste tus habilidades.",
            "Como cerrarias tu principal brecha para esta vacante?",
            "Por que te interesa este rol?",
        ],
        "risksToAddress": match["gaps"][:3],
    }


def get_job_matches(student_id: str, conn) -> dict:
    _student_or_404(conn, student_id)
    jobs = fetch_all(
        conn,
        """
        SELECT j.id AS job_id, j.title, j.modality, j.location, j.hours, c.name AS company_name
        FROM jobs j
        JOIN companies c ON c.id = j.company_id
        WHERE j.status = 'active'
        """,
    )
    result = []
    for job in jobs:
        match = calculate_match(conn, student_id, job["job_id"])
        result.append({**job, **match})
    result.sort(key=lambda row: row["matchScore"], reverse=True)
    return {"studentId": student_id, "jobs": result}
