from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.db.models import Company, Job, Student, User, Evidence
from app.services.company_dashboard_service import get_company_dashboard
from app.services.candidate_matching_service import get_candidates_for_job, calculate_match

router = APIRouter()


def _company_or_404(company_id: str, db: Session):
    company = db.query(Company).filter(Company.id == company_id).first()
    if not company:
        raise HTTPException(status_code=404, detail={
            "error": {"code": "NOT_FOUND", "message": f"Empresa '{company_id}' no encontrada."}
        })
    return company


# GET /companies/{companyId}/dashboard
@router.get("/companies/{companyId}/dashboard")
def company_dashboard(companyId: str, db: Session = Depends(get_db)):
    _company_or_404(companyId, db)
    data = get_company_dashboard(companyId, db)
    return data


# GET /companies/{companyId}/jobs
@router.get("/companies/{companyId}/jobs")
def company_jobs(companyId: str, db: Session = Depends(get_db)):
    _company_or_404(companyId, db)
    jobs = db.query(Job).filter(Job.company_id == companyId).all()
    return {
        "jobs": [
            {"id": j.id, "title": j.title, "status": j.status}
            for j in jobs
        ]
    }


# GET /companies/{companyId}/jobs/{jobId}/candidates
@router.get("/companies/{companyId}/jobs/{jobId}/candidates")
def job_candidates(companyId: str, jobId: str, db: Session = Depends(get_db)):
    _company_or_404(companyId, db)
    job = db.query(Job).filter(Job.id == jobId, Job.company_id == companyId).first()
    if not job:
        raise HTTPException(status_code=404, detail={
            "error": {"code": "NOT_FOUND", "message": f"Vacante '{jobId}' no encontrada para esta empresa."}
        })
    candidates = get_candidates_for_job(jobId, companyId, db)
    return {
        "job": {"id": job.id, "title": job.title},
        "candidates": candidates,
    }


# GET /companies/{companyId}/candidates/{studentId}?jobId=...
@router.get("/companies/{companyId}/candidates/{studentId}")
def candidate_detail(
    companyId: str,
    studentId: str,
    jobId: str = Query(...),
    db: Session = Depends(get_db),
):
    _company_or_404(companyId, db)
    student = db.query(Student).filter(Student.id == studentId).first()
    if not student:
        raise HTTPException(status_code=404, detail={
            "error": {"code": "NOT_FOUND", "message": f"Estudiante '{studentId}' no encontrado."}
        })
    user = db.query(User).filter(User.id == studentId).first()
    evidences = db.query(Evidence).filter(Evidence.student_id == studentId).all()
    match_data = calculate_match(studentId, jobId, db)

    return {
        "student": {
            "id": student.id,
            "name": user.name if user else studentId,
            "career": student.career,
            "cycle": student.cycle,
            "availability": student.availability,
        },
        "match": {
            "score": match_data["matchScore"],
            "technicalMatch": match_data["technicalMatch"],
            "softMatch": match_data["softMatch"],
            "summary": f"Candidato con match {match_data['status']} para esta vacante.",
        },
        "evidences": [
            {
                "title": e.title,
                "skills": [es.skill.name for es in e.skills if es.skill],
                "cvBullet": e.cv_bullet or "",
            }
            for e in evidences
        ],
        "risks": [
            f"{g['skillName']} {g['severity']}"
            for g in match_data["gaps"]
            if g["severity"] in ("partial", "critical")
        ],
        "suggestedInterviewQuestions": match_data["interviewQuestions"],
    }
