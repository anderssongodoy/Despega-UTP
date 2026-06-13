from sqlalchemy.orm import Session
from app.db.models import Student, StudentSkill, StudentGoal, Evidence, JobRequirement, Skill

# Preguntas sugeridas de entrevista por brecha de habilidad
_INTERVIEW_QUESTIONS = {
    "sk_sql": "¿Cómo manejarías una consulta que une varias tablas con condiciones complejas?",
    "sk_python": "Describe un proyecto donde usaste Python para resolver un problema real.",
    "sk_english": "¿Puedes describirme tu experiencia laboral más relevante en inglés?",
    "sk_excel": "¿Qué funciones avanzadas de Excel has utilizado en proyectos?",
    "sk_powerbi": "¿Cómo construirías un dashboard para monitorear ventas mensuales?",
    "sk_communication": "¿Cómo explicarías un hallazgo técnico a un área no técnica?",
    "sk_interview": "¿Cómo te preparas normalmente para una entrevista de trabajo?",
    "sk_process_analysis": "¿Qué metodología usarías para identificar cuellos de botella en un proceso?",
    "sk_git": "¿Cómo gestionas conflictos en un repositorio colaborativo?",
    "sk_api": "Describe cómo diseñarías una API REST para un sistema de reservas.",
    "sk_copywriting": "¿Cómo adaptas el tono de un texto según el canal de comunicación?",
    "sk_analytics_marketing": "¿Qué métricas usarías para evaluar el rendimiento de una campaña digital?",
    "sk_hr_interviews": "¿Qué técnicas de entrevista por competencias conoces?",
}

_DEFAULT_QUESTION = "¿Cómo enfrentarías los primeros 30 días en este puesto?"


def _severity(current: int, required: int) -> str:
    diff = required - current
    if diff <= 0:
        return "ready"
    elif diff == 1:
        return "partial"
    else:
        return "critical"


def calculate_match(student_id: str, job_id: str, db: Session) -> dict:
    """
    Calcula matchScore, technicalMatch, softMatch, gaps y preguntas de entrevista
    para un par (estudiante, vacante).
    """
    # Cargar requisitos de la vacante
    requirements = (
        db.query(JobRequirement)
        .filter(JobRequirement.job_id == job_id)
        .all()
    )
    if not requirements:
        return {"matchScore": 0, "technicalMatch": 0, "softMatch": 0,
                "status": "not_recommended", "gaps": [], "interviewQuestions": []}

    # Cargar habilidades del estudiante
    student_skills = (
        db.query(StudentSkill)
        .filter(StudentSkill.student_id == student_id)
        .all()
    )
    skill_map = {ss.skill_id: ss.level for ss in student_skills}

    # Pesos según importancia
    importance_weights = {"critical": 3, "important": 2, "optional": 1}

    tech_skills = db.query(Skill).filter(Skill.type == "technical").all()
    tech_ids = {s.id for s in tech_skills}

    total_weight = 0
    earned_weight = 0
    tech_total = 0
    tech_earned = 0
    soft_total = 0
    soft_earned = 0
    gaps = []

    for req in requirements:
        w = importance_weights.get(req.importance, 1)
        current = skill_map.get(req.skill_id, 0)
        required = req.required_level
        contribution = min(current / required, 1.0) * w if required > 0 else w

        total_weight += w
        earned_weight += contribution

        is_tech = req.skill_id in tech_ids
        if is_tech:
            tech_total += w
            tech_earned += contribution
        else:
            soft_total += w
            soft_earned += contribution

        sev = _severity(current, required)
        if sev != "ready":
            skill = db.query(Skill).filter(Skill.id == req.skill_id).first()
            gaps.append({
                "skillId": req.skill_id,
                "skillName": skill.name if skill else req.skill_id,
                "currentLevel": current,
                "requiredLevel": required,
                "severity": sev,
            })

    match_score = round((earned_weight / total_weight) * 100) if total_weight else 0
    tech_match = round((tech_earned / tech_total) * 100) if tech_total else 100
    soft_match = round((soft_earned / soft_total) * 100) if soft_total else 100

    # Status
    if match_score >= 80:
        status = "ready"
    elif match_score >= 65:
        status = "viable"
    elif match_score >= 50:
        status = "aspirational"
    else:
        status = "not_recommended"

    # Preguntas sugeridas basadas en brechas críticas/parciales
    interview_questions = []
    for gap in gaps:
        q = _INTERVIEW_QUESTIONS.get(gap["skillId"], _DEFAULT_QUESTION)
        if q not in interview_questions:
            interview_questions.append(q)
    if not interview_questions:
        interview_questions.append(_DEFAULT_QUESTION)

    return {
        "matchScore": match_score,
        "technicalMatch": tech_match,
        "softMatch": soft_match,
        "status": status,
        "gaps": gaps,
        "interviewQuestions": interview_questions[:3],
    }


def get_candidates_for_job(job_id: str, company_id: str, db: Session) -> list:
    """
    Devuelve lista de candidatos rankeados para una vacante de empresa.
    Usa todos los estudiantes en la BD y calcula match para cada uno.
    """
    from app.db.models import Job, Student, User, Evidence

    job = db.query(Job).filter(Job.id == job_id, Job.company_id == company_id).first()
    if not job:
        return []

    students = db.query(Student).all()
    results = []

    for student in students:
        match_data = calculate_match(student.id, job_id, db)
        if match_data["matchScore"] < 40:
            continue  # Filtrar candidatos con match muy bajo

        user = db.query(User).filter(User.id == student.id).first()
        evidences = db.query(Evidence).filter(Evidence.student_id == student.id).all()
        evidence_highlights = [e.title for e in evidences[:2]]

        results.append({
            "studentId": student.id,
            "name": user.name if user else student.id,
            "career": student.career,
            "cycle": student.cycle,
            "matchScore": match_data["matchScore"],
            "technicalMatch": match_data["technicalMatch"],
            "softMatch": match_data["softMatch"],
            "status": match_data["status"],
            "evidenceHighlights": evidence_highlights,
            "gaps": [
                {"skillName": g["skillName"], "severity": g["severity"]}
                for g in match_data["gaps"]
            ],
            "interviewQuestions": match_data["interviewQuestions"],
        })

    # Ordenar por matchScore descendente
    results.sort(key=lambda x: x["matchScore"], reverse=True)
    return results
