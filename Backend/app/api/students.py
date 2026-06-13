from typing import Annotated, Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException

from app.core.db import execute, fetch_all, fetch_one, get_connection
from app.core.json_loader import get_roles
from app.services.matching import calculate_match, get_active_goal, get_recommended_resources


# ---------------------------------------------------------------------------
# Helpers internos – no exponer como endpoints
# ---------------------------------------------------------------------------

SKILL_NAME_MAP: dict[str, str] = {
    "sk_sql": "SQL",
    "sk_english": "Ingles",
    "sk_interview": "Entrevista",
    "sk_excel": "Excel",
    "sk_powerbi": "Power BI",
    "sk_communication": "Comunicacion",
    "sk_python": "Python",
    "sk_git": "Git",
    "sk_problem_solving": "Resolucion de problemas",
    "sk_organization": "Organizacion",
    "sk_digital_marketing": "Marketing Digital",
    "sk_writing": "Redaccion",
    "sk_process_management": "Gestion de procesos",
    "sk_critical_thinking": "Pensamiento critico",
}


def _skill_id_to_name(skill_id: str) -> str:
    """Convierte un skill ID tecnico en un nombre legible."""
    return SKILL_NAME_MAP.get(skill_id, skill_id.replace("sk_", "").replace("_", " ").title())


def _dim_status(score: int) -> str:
    """Convierte un score numerico al status de una dimension de diagnostico."""
    if score >= 75:
        return "ready"
    if score >= 55:
        return "partial"
    return "critical"


def _safe_count(conn, table: str, student_id: str) -> int:
    """Ejecuta un COUNT(*) en la tabla dada y devuelve 0 si la tabla no existe aun."""
    try:
        row = fetch_one(conn, f"SELECT count(*) AS total FROM {table} WHERE student_id = %s", (student_id,))
        return row["total"] if row else 0
    except Exception:
        return 0


def _gap_recommended_action(skill_name: str, current_level: int, required_level: int) -> str:
    return f"Refuerza {skill_name}: estas en nivel {current_level} y el objetivo requiere nivel {required_level}."


def _role_match_score(conn, student_id: str, role_id: str) -> int:
    row = fetch_one(
        conn,
        """
        SELECT COALESCE(
          ROUND(AVG(
            CASE
              WHEN rsr.required_level = 0 THEN 100
              ELSE LEAST(COALESCE(ss.level, 0)::numeric / rsr.required_level, 1) * 100
            END
          )),
          0
        )::int AS score
        FROM role_skill_requirements rsr
        LEFT JOIN student_skills ss
          ON ss.student_id = %s
         AND ss.skill_id = rsr.skill_id
        WHERE rsr.role_id = %s
        """,
        (student_id, role_id),
    )
    return row["score"] if row else 0


def recalculate_student_critical_gaps(
    conn,
    student_id: str,
    role_id: str | None = None,
    job_id: str | None = None,
) -> list[dict]:
    current_rows = fetch_all(
        conn,
        "SELECT skill_id, level FROM student_skills WHERE student_id = %s",
        (student_id,),
    )
    current_levels = {row["skill_id"]: row["level"] for row in current_rows}

    if job_id:
        requirements = fetch_all(
            conn,
            """
            SELECT
              j.role_id,
              jr.job_id,
              jr.skill_id,
              s.name AS skill_name,
              jr.required_level,
              jr.importance AS priority,
              NULL::text AS reason
            FROM job_requirements jr
            JOIN jobs j ON j.id = jr.job_id
            JOIN skills s ON s.id = jr.skill_id
            WHERE jr.job_id = %s
            """,
            (job_id,),
        )
        source = "job"
        if requirements and not role_id:
            role_id = requirements[0]["role_id"]
    else:
        if not role_id:
            goal = get_active_goal(conn, student_id)
            role_id = goal["role_id"] if goal else "role_data_intern"
        requirements = fetch_all(
            conn,
            """
            SELECT
              rsr.role_id,
              NULL::varchar AS job_id,
              rsr.skill_id,
              s.name AS skill_name,
              rsr.required_level,
              rsr.priority,
              rsr.reason
            FROM role_skill_requirements rsr
            JOIN skills s ON s.id = rsr.skill_id
            WHERE rsr.role_id = %s
            """,
            (role_id,),
        )
        source = "role"

    gaps: list[dict] = []
    open_skill_ids: list[str] = []

    for req in requirements:
        current_level = current_levels.get(req["skill_id"], 0)
        required_level = req["required_level"]
        if current_level >= required_level:
            continue

        severity = "critical" if req["priority"] == "critical" else "partial"
        recommended_action = req["reason"] or _gap_recommended_action(req["skill_name"], current_level, required_level)
        gap = {
            "skillId": req["skill_id"],
            "skillName": req["skill_name"],
            "currentLevel": current_level,
            "requiredLevel": required_level,
            "severity": severity,
            "recommendedAction": recommended_action,
            "message": recommended_action,
        }
        gaps.append(gap)
        open_skill_ids.append(req["skill_id"])

        gap_id = f"scg_{student_id}_{source}_{job_id or role_id}_{req['skill_id']}"
        if source == "job":
            execute(
                conn,
                """
                INSERT INTO student_critical_gaps
                  (id, student_id, role_id, job_id, skill_id, severity, source, reason, status, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, 'job', %s, 'open', now())
                ON CONFLICT (student_id, job_id, skill_id)
                  WHERE source = 'job' AND job_id IS NOT NULL
                DO UPDATE SET
                  role_id = EXCLUDED.role_id,
                  severity = EXCLUDED.severity,
                  reason = EXCLUDED.reason,
                  status = 'open',
                  updated_at = now()
                """,
                (
                    gap_id,
                    student_id,
                    role_id,
                    job_id,
                    req["skill_id"],
                    severity,
                    recommended_action,
                ),
            )
        else:
            execute(
                conn,
                """
                INSERT INTO student_critical_gaps
                  (id, student_id, role_id, job_id, skill_id, severity, source, reason, status, updated_at)
                VALUES (%s, %s, %s, NULL, %s, %s, 'role', %s, 'open', now())
                ON CONFLICT (student_id, role_id, skill_id)
                  WHERE source = 'role' AND role_id IS NOT NULL
                DO UPDATE SET
                  severity = EXCLUDED.severity,
                  reason = EXCLUDED.reason,
                  status = 'open',
                  updated_at = now()
                """,
                (
                    gap_id,
                    student_id,
                    role_id,
                    req["skill_id"],
                    severity,
                    recommended_action,
                ),
            )

    if source == "job":
        execute(
            conn,
            """
            UPDATE student_critical_gaps
            SET status = 'resolved', updated_at = now()
            WHERE student_id = %s
              AND source = 'job'
              AND job_id = %s
              AND status = 'open'
              AND skill_id <> ALL(%s::varchar[])
            """,
            (student_id, job_id, open_skill_ids),
        )
    else:
        execute(
            conn,
            """
            UPDATE student_critical_gaps
            SET status = 'resolved', updated_at = now()
            WHERE student_id = %s
              AND source = 'role'
              AND role_id = %s
              AND status = 'open'
              AND skill_id <> ALL(%s::varchar[])
            """,
            (student_id, role_id, open_skill_ids),
        )

    gaps.sort(key=lambda item: (0 if item["severity"] == "critical" else 1, item["skillName"]))
    return gaps


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
    goal_role_id = goal.get("targetRoleId", "role_data_intern")
    goal_role_name = goal.get("targetRoleName", "Practicante de Analisis de Datos")

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
            goal_role_id,
            goal_role_name,
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

    critical_gaps = recalculate_student_critical_gaps(conn, student_id, role_id=goal_role_id)

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
        "goal": {"roleId": goal_role_id, "roleName": goal_role_name},
        "initialDiagnosis": {
            "readinessScore": 65,
            "status": "viable",
            # criticalGaps debe ser array de nombres legibles, no IDs tecnicos
            "criticalGaps": [g["skillName"] for g in critical_gaps],
        },
        "redirectTo": "/student/home",
    }


@router.get("/students/{student_id}/dashboard")
def get_student_dashboard(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    student = _student_or_404(conn, student_id)
    goal = get_active_goal(conn, student_id)
    best_job = _first_recommended_job(conn, student_id)
    role_id = goal["role_id"] if goal else "role_data_intern"
    gaps = recalculate_student_critical_gaps(conn, student_id, role_id=role_id)
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
        # CriticalGap schema: {skillName, severity, message}
        "criticalGaps": [
            {"skillName": g["skillName"], "severity": g["severity"], "message": g["message"]}
            for g in gaps[:3]
        ],
        # RecommendedJob schema: {jobId, title, companyName, matchScore, status}
        "recommendedJobs": [
            {
                "jobId": j["job_id"],
                "title": j["title"],
                "companyName": j["company_name"],
                "matchScore": j["matchScore"],
                "status": j["status"],
            }
            for j in get_job_matches(student_id, conn)["jobs"][:3]
        ],
        # RecommendedResource schema: {resourceId, name, reason}
        "recommendedResources": [
            {"resourceId": r["id"], "name": r["name"], "reason": r["reason"]}
            for r in resources
        ],
        "progress": {
            "evidences": fetch_one(conn, "SELECT count(*) AS total FROM evidences WHERE student_id = %s", (student_id,))["total"],
            # challenge_submissions puede no existir aun – protegido contra crash
            "challengesCompleted": _safe_count(conn, "challenge_submissions", student_id),
            "applications": fetch_one(conn, "SELECT count(*) AS total FROM applications WHERE student_id = %s", (student_id,))["total"],
            "interviewPractice": 1,
        },
    }


@router.post("/students/{student_id}/goal")
def update_goal(student_id: str, payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    execute(conn, "UPDATE student_goals SET active = false WHERE student_id = %s", (student_id,))
    goal_id = f"goal_{student_id}_{uuid4().hex[:8]}"
    role_id = payload.get("roleId", "role_data_intern")
    execute(
        conn,
        """
        INSERT INTO student_goals (id, student_id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe, active)
        VALUES (%s, %s, %s, %s, %s, %s, %s, true)
        """,
        (
            goal_id,
            student_id,
            role_id,
            payload.get("targetRoleName", "Practicante de Analisis de Datos"),
            payload.get("availability"),
            payload.get("preferredWorkMode"),
            payload.get("applicationTimeframe"),
        ),
    )
    recalculate_student_critical_gaps(conn, student_id, role_id=role_id)
    # Respuesta exacta del contrato: {studentId, roleId, message}
    return {
        "studentId": student_id,
        "roleId": role_id,
        "message": "Meta laboral actualizada.",
    }


@router.get("/students/{student_id}/diagnosis")
def get_diagnosis(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    goal = get_active_goal(conn, student_id)
    role_id = goal["role_id"] if goal else "role_data_intern"
    score = _role_match_score(conn, student_id, role_id)
    gaps = recalculate_student_critical_gaps(conn, student_id, role_id=role_id)

    # Detectar brechas especificas para ajustar dimensiones
    has_english_gap = any(g["skillId"] == "sk_english" for g in gaps)
    has_interview_gap = any(g["skillId"] == "sk_interview" for g in gaps)

    # Dimensions: 5 dimensiones con scores deterministas basados en el match
    dimensions = [
        {"name": "CV", "score": max(score - 10, 0), "status": _dim_status(max(score - 10, 0))},
        {"name": "Habilidades tecnicas", "score": score, "status": _dim_status(score)},
        {"name": "Evidencia", "score": min(score + 10, 100), "status": _dim_status(min(score + 10, 100))},
        {
            "name": "Entrevista",
            "score": 50 if has_interview_gap else min(score + 5, 100),
            "status": "partial" if has_interview_gap else _dim_status(min(score + 5, 100)),
        },
        {
            "name": "Ingles",
            "score": 35 if has_english_gap else score,
            "status": "critical" if has_english_gap else _dim_status(score),
        },
    ]

    gap_names = [g["skillName"] for g in gaps[:2]]
    if gap_names:
        message = f"Tu perfil tiene evidencia aplicable, pero necesita reforzar {' e '.join(gap_names)} para ampliar opciones."
    else:
        message = "Tu perfil esta listo para postular a vacantes viables."

    # Respuesta exacta del contrato Diagnosis: {studentId, role, readinessScore, dimensions, message}
    return {
        "studentId": student_id,
        "role": {
            "roleId": goal["role_id"] if goal else "role_data_intern",
            "roleName": goal["target_role_name"] if goal else "Practicante de Analisis de Datos",
        },
        "readinessScore": score,
        "dimensions": dimensions,
        "message": message,
    }


@router.get("/students/{student_id}/gaps")
def get_gaps(student_id: str, conn: Annotated[object, Depends(get_connection)], jobId: str | None = None) -> dict:
    _student_or_404(conn, student_id)
    goal = get_active_goal(conn, student_id)
    role_id = goal["role_id"] if goal else "role_data_intern"
    if jobId:
        match_score = calculate_match(conn, student_id, jobId)["matchScore"]
        gaps = recalculate_student_critical_gaps(conn, student_id, role_id=role_id, job_id=jobId)
    else:
        match_score = _role_match_score(conn, student_id, role_id)
        gaps = recalculate_student_critical_gaps(conn, student_id, role_id=role_id)
    # GapItem schema: {skillId, skillName, currentLevel, requiredLevel, severity, recommendedAction}
    mapped_gaps = [
        {
            "skillId": g["skillId"],
            "skillName": g["skillName"],
            "currentLevel": g["currentLevel"],
            "requiredLevel": g["requiredLevel"],
            "severity": g["severity"],
            "recommendedAction": g["recommendedAction"],
        }
        for g in gaps
    ]
    can_apply = match_score >= 65
    return {
        "studentId": student_id,
        "jobId": jobId,
        "matchScore": match_score,
        "gaps": mapped_gaps,
        "canApplyToday": can_apply,
        "applyAdvice": (
            "Puedes postular hoy. Ajusta tu CV y destaca tu experiencia mas relevante."
            if can_apply
            else "Refuerza tus brechas criticas antes de postular para mejorar tus chances."
        ),
    }


@router.get("/students/{student_id}/action-plan")
def get_action_plan(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    _student_or_404(conn, student_id)
    goal = get_active_goal(conn, student_id)
    role_id = goal["role_id"] if goal else "role_data_intern"
    gaps = recalculate_student_critical_gaps(conn, student_id, role_id=role_id)

    # ActionPlan schema: {studentId, days: [ActionPlanDay]}
    # ActionPlanDay: {day, title, type, minutes, resourceId (nullable)}
    days: list[dict] = []
    for idx, gap in enumerate(gaps[:4], start=1):
        skill_id = gap.get("skillId", "")
        resource_id: str | None = None
        if skill_id == "sk_english":
            resource_id = "res_english_discoveries"
        elif gap["severity"] == "critical":
            resource_id = "res_ruta_laboral"
        days.append({
            "day": idx * 2 - 1,
            "title": f"Reforzar {gap['skillName']}",
            "type": "utp_resource" if resource_id else "skill",
            "minutes": 45,
            "resourceId": resource_id,
        })

    if not days:
        days.append({
            "day": 1,
            "title": "Preparar postulacion",
            "type": "cv",
            "minutes": 45,
            "resourceId": "res_ruta_laboral",
        })

    return {"studentId": student_id, "days": days}


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
