from sqlalchemy.orm import Session
from app.db.models import Company, Job, Student, Application
from app.services.candidate_matching_service import get_candidates_for_job


def get_company_dashboard(company_id: str, db: Session) -> dict:
    company = db.query(Company).filter(Company.id == company_id).first()
    if not company:
        return None

    active_jobs = (
        db.query(Job)
        .filter(Job.company_id == company_id, Job.status == "active")
        .all()
    )

    jobs_summary = []
    total_candidates = 0
    total_match_sum = 0
    total_match_count = 0

    for job in active_jobs:
        candidates = get_candidates_for_job(job.id, company_id, db)
        job_avg = round(sum(c["matchScore"] for c in candidates) / len(candidates)) if candidates else 0
        jobs_summary.append({
            "jobId": job.id,
            "title": job.title,
            "recommendedCandidates": len(candidates),
            "averageMatch": job_avg,
        })
        total_candidates += len(candidates)
        if candidates:
            total_match_sum += job_avg
            total_match_count += 1

    avg_match = round(total_match_sum / total_match_count) if total_match_count else 0
    # Estimacion: 30 min ahorrados por candidato recomendado vs revision manual
    time_saved = round(total_candidates * 0.5, 1)

    return {
        "company": {
            "id": company.id,
            "name": company.name,
            "sector": company.sector,
        },
        "metrics": {
            "activeJobs": len(active_jobs),
            "recommendedCandidates": total_candidates,
            "averageMatch": avg_match,
            "estimatedReviewTimeSavedHours": time_saved,
        },
        "activeJobs": jobs_summary,
        "commonGaps": ["SQL", "Ingles", "Entrevista"],  # Top brechas canonicas
    }
