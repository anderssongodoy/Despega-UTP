from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException

from app.core.db import fetch_all, fetch_one, get_connection
from app.services.matching import calculate_match


router = APIRouter()


@router.get("/companies/{company_id}/dashboard")
def get_company_dashboard(company_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    company = fetch_one(conn, "SELECT * FROM companies WHERE id = %s", (company_id,))
    if not company:
        raise HTTPException(status_code=404, detail="Company not found")
    jobs = get_company_jobs(company_id, conn)["jobs"]
    all_candidates = []
    preview = []
    for job in jobs:
        job_candidates = get_job_candidates(company_id, job["jobId"], conn)["candidates"]
        all_candidates.extend(job_candidates)
        preview.extend(job_candidates[:2])

    avg_match = round(sum(c["matchScore"] for c in preview) / len(preview)) if preview else 0

    # Brechas mas frecuentes calculadas a partir de las brechas reales de los candidatos.
    gap_counts: dict[str, int] = {}
    for candidate in all_candidates:
        for gap in candidate.get("gaps", []):
            name = gap.get("skillName")
            if name:
                gap_counts[name] = gap_counts.get(name, 0) + 1
    top_gaps = [name for name, _ in sorted(gap_counts.items(), key=lambda kv: kv[1], reverse=True)][:5]

    return {
        "company": company,
        "activeJobs": len(jobs),
        "recommendedCandidates": len(preview),
        "averageMatch": avg_match,
        "estimatedHoursSaved": len(preview) * 2,
        "topGaps": top_gaps,
        "jobs": jobs,
        "candidatePreview": preview[:6],
    }


@router.get("/companies/{company_id}/jobs")
def get_company_jobs(company_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    jobs = fetch_all(
        conn,
        """
        SELECT id AS "jobId", title, role_id AS "roleId", modality, location, hours, status
        FROM jobs
        WHERE company_id = %s
        ORDER BY created_at
        """,
        (company_id,),
    )
    enriched = []
    for job in jobs:
        candidates = get_job_candidates(company_id, job["jobId"], conn)["candidates"]
        average = round(sum(c["matchScore"] for c in candidates) / len(candidates)) if candidates else 0
        enriched.append({**job, "recommendedCandidates": len(candidates), "averageMatch": average})
    return {"jobs": enriched}


@router.get("/companies/{company_id}/jobs/{job_id}/candidates")
def get_job_candidates(company_id: str, job_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    job = fetch_one(conn, "SELECT id FROM jobs WHERE id = %s AND company_id = %s", (job_id, company_id))
    if not job:
        raise HTTPException(status_code=404, detail="Job not found for company")
    students = fetch_all(
        conn,
        """
        SELECT s.id AS student_id, u.name, s.career, s.cycle, s.modality
        FROM students s
        JOIN users u ON u.id = s.id
        ORDER BY s.cycle DESC, u.name
        """,
    )
    candidates = []
    for student in students:
        match = calculate_match(conn, student["student_id"], job_id)
        if match["matchScore"] >= 45:
            candidates.append({**student, **match})
    candidates.sort(key=lambda row: row["matchScore"], reverse=True)
    return {"jobId": job_id, "candidates": candidates}


@router.get("/companies/{company_id}/candidates/{student_id}")
def get_candidate_detail(
    company_id: str,
    student_id: str,
    conn: Annotated[object, Depends(get_connection)],
    jobId: str = "job_data_retail",
) -> dict:
    candidate = fetch_one(
        conn,
        """
        SELECT s.id, u.name, u.email, s.career, s.cycle, s.modality, s.cv_status
        FROM students s
        JOIN users u ON u.id = s.id
        WHERE s.id = %s
        """,
        (student_id,),
    )
    if not candidate:
        raise HTTPException(status_code=404, detail="Candidate not found")
    evidences = fetch_all(conn, "SELECT id, title, cv_bullet FROM evidences WHERE student_id = %s", (student_id,))
    match = calculate_match(conn, student_id, jobId)
    return {"candidate": candidate, "jobId": jobId, "match": match, "evidences": evidences}
