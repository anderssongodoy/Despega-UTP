from typing import Annotated, Any
from uuid import uuid4

from fastapi import APIRouter, Depends

from app.api.students import get_job_matches as student_job_matches
from app.core.db import execute, fetch_all, fetch_one, get_connection
from app.services.matching import calculate_match


router = APIRouter()


@router.get("/jobs")
def list_jobs(conn: Annotated[object, Depends(get_connection)], companyId: str | None = None) -> dict:
    params: tuple = ()
    where = "WHERE j.status = 'active'"
    if companyId:
        where += " AND j.company_id = %s"
        params = (companyId,)
    jobs = fetch_all(
        conn,
        f"""
        SELECT j.id AS job_id, j.title, j.role_id, j.modality, j.location, j.hours, j.description,
               c.id AS company_id, c.name AS company_name
        FROM jobs j
        JOIN companies c ON c.id = j.company_id
        {where}
        ORDER BY j.created_at
        """,
        params,
    )
    return {"jobs": jobs}


@router.get("/students/{student_id}/job-matches")
def get_job_matches(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    return student_job_matches(student_id, conn)


@router.get("/students/{student_id}/jobs/{job_id}/application-kit")
def get_application_kit(student_id: str, job_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    job = fetch_one(
        conn,
        """
        SELECT j.id, j.title, j.description, c.name AS company_name
        FROM jobs j
        JOIN companies c ON c.id = j.company_id
        WHERE j.id = %s
        """,
        (job_id,),
    )
    match = calculate_match(conn, student_id, job_id)
    return {
        "studentId": student_id,
        "job": job,
        "match": match,
        "cvTips": [f"Evidencia {skill} con un resultado medible." for skill in match["strengths"][:3]],
        "coverMessage": f"Me interesa {job['title']} en {job['company_name']} porque puedo aportar evidencias concretas y seguir cerrando brechas.",
        "nextAction": "Enviar CV ajustado" if match["matchScore"] >= 65 else "Cerrar brecha principal antes de postular",
    }


@router.get("/students/{student_id}/applications")
def list_applications(student_id: str, conn: Annotated[object, Depends(get_connection)]) -> dict:
    rows = fetch_all(
        conn,
        """
        SELECT a.id, a.status, a.notes, a.created_at, j.id AS job_id, j.title, c.name AS company_name
        FROM applications a
        JOIN jobs j ON j.id = a.job_id
        JOIN companies c ON c.id = j.company_id
        WHERE a.student_id = %s
        ORDER BY a.created_at DESC
        """,
        (student_id,),
    )
    return {"applications": rows}


@router.post("/students/{student_id}/applications")
def create_application(student_id: str, payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    app_id = f"app_{student_id}_{uuid4().hex[:8]}"
    execute(
        conn,
        """
        INSERT INTO applications (id, student_id, job_id, status, notes)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (student_id, job_id) DO UPDATE SET status = EXCLUDED.status, notes = EXCLUDED.notes, updated_at = now()
        """,
        (app_id, student_id, payload.get("jobId"), payload.get("status", "prepared"), payload.get("notes", "")),
    )
    return {"id": app_id, "studentId": student_id, "jobId": payload.get("jobId"), "status": payload.get("status", "prepared")}
