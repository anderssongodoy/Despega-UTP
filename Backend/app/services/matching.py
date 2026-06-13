from app.core.db import fetch_all, fetch_one
from app.core.json_loader import get_resources


def readiness_status(score: int) -> str:
    if score >= 85:
        return "ready"
    if score >= 65:
        return "viable"
    if score >= 50:
        return "aspirational"
    return "not_recommended"


def get_student_skill_levels(conn, student_id: str) -> dict[str, int]:
    rows = fetch_all(
        conn,
        """
        SELECT skill_id, level
        FROM student_skills
        WHERE student_id = %s
        """,
        (student_id,),
    )
    return {row["skill_id"]: row["level"] for row in rows}


def get_job_requirements(conn, job_id: str) -> list[dict]:
    return fetch_all(
        conn,
        """
        SELECT jr.skill_id, s.name AS skill_name, jr.required_level, jr.importance
        FROM job_requirements jr
        JOIN skills s ON s.id = jr.skill_id
        WHERE jr.job_id = %s
        ORDER BY
          CASE jr.importance
            WHEN 'critical' THEN 1
            WHEN 'important' THEN 2
            ELSE 3
          END,
          s.name
        """,
        (job_id,),
    )


def calculate_match(conn, student_id: str, job_id: str) -> dict:
    levels = get_student_skill_levels(conn, student_id)
    requirements = get_job_requirements(conn, job_id)
    if not requirements:
        return {"matchScore": 0, "status": "not_recommended", "gaps": [], "strengths": []}

    weights = {"critical": 2.0, "important": 1.0, "optional": 0.5}
    points = 0.0
    total = 0.0
    gaps: list[dict] = []
    strengths: list[str] = []

    for req in requirements:
        current = levels.get(req["skill_id"], 0)
        required = req["required_level"]
        weight = weights.get(req["importance"], 1.0)
        total += required * weight
        points += min(current, required) * weight

        if current >= required:
            strengths.append(req["skill_name"])
        else:
            gap = required - current
            gaps.append(
                {
                    "skillId": req["skill_id"],
                    "skillName": req["skill_name"],
                    "currentLevel": current,
                    "requiredLevel": required,
                    "severity": "critical" if req["importance"] == "critical" and gap >= 2 else "partial",
                    "message": f"Falta {gap} nivel(es) para llegar al requerimiento.",
                }
            )

    score = round((points / total) * 100) if total else 0
    return {
        "matchScore": score,
        "status": readiness_status(score),
        "gaps": gaps,
        "strengths": strengths[:4],
    }


def get_active_goal(conn, student_id: str) -> dict | None:
    return fetch_one(
        conn,
        """
        SELECT id, role_id, target_role_name, availability, preferred_work_mode, application_timeframe
        FROM student_goals
        WHERE student_id = %s AND active = true
        ORDER BY created_at DESC
        LIMIT 1
        """,
        (student_id,),
    )


def get_recommended_resources(gaps: list[dict]) -> list[dict]:
    resources = get_resources()
    gap_names = {gap["skillName"].lower() for gap in gaps}
    selected: list[dict] = []

    for resource in resources:
        reasons = resource.get("recommendedWhen", [])
        if "Ingles".lower() in gap_names and "english_gap" in reasons:
            selected.append({**resource, "reason": "Recomendado por brecha de ingles."})
        elif "Entrevista".lower() in gap_names and "interview_gap" in reasons:
            selected.append({**resource, "reason": "Recomendado para practicar entrevista."})
        elif "cv_gap" in reasons:
            selected.append({**resource, "reason": "Refuerza CV y marca profesional."})

    return selected[:3]
