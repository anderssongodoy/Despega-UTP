from sqlalchemy.orm import Session
from app.db.models import Student, Evidence, Application, Job
from app.services.config_service import get_advisor_metrics_seed, get_utp_resources


def get_advisor_impact(db: Session) -> dict:
    """
    Calcula métricas de impacto institucional del asesor UTP.
    Combina datos reales de la BD con la semilla de advisor_metrics_seed.json.
    """
    seed = get_advisor_metrics_seed()

    # Conteos reales desde la BD
    real_students = db.query(Student).count()
    real_evidences = db.query(Evidence).count()
    real_applications = db.query(Application).filter(
        Application.status.in_(["prepared", "applied", "interviewing"])
    ).count()
    real_jobs = db.query(Job).filter(Job.status == "active").count()

    # Combinamos datos reales + semilla para dar escala institucional
    seed_metrics = seed.get("metrics", {})

    metrics = {
        "activeStudents": max(real_students, seed_metrics.get("activeStudents", 0)),
        "generatedEvidences": max(real_evidences, seed_metrics.get("generatedEvidences", 0)),
        "preparedApplications": max(real_applications, seed_metrics.get("preparedApplications", 0)),
        "companiesActive": max(real_jobs, seed_metrics.get("companiesActive", 0)),
        "studentsReadyForInterview": seed_metrics.get("studentsReadyForInterview", 390),
        "averageMatchImprovement": seed_metrics.get("averageMatchImprovement", 18),
    }

    # Recursos UTP disponibles
    resources = get_utp_resources()
    resource_recommendations = [
        {"resourceName": r["name"], "recommendations": 0}
        for r in resources
    ]
    # Fusionar con semilla
    seed_resources = {
        item["resourceName"]: item["recommendations"]
        for item in seed.get("resourceRecommendations", [])
    }
    for item in resource_recommendations:
        item["recommendations"] = seed_resources.get(item["resourceName"], 0)

    return {
        "metrics": metrics,
        "topGaps": seed.get("topGaps", []),
        "topRoles": seed.get("topRoles", []),
        "resourceRecommendations": resource_recommendations,
    }
