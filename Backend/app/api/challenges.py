from typing import Annotated, Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException
from psycopg.types.json import Jsonb

from app.core.db import execute, get_connection
from app.core.json_loader import get_challenges


router = APIRouter()


@router.get("/challenges")
def list_challenges(roleId: str | None = None) -> dict:
    challenges = get_challenges()
    if roleId:
        challenges = [challenge for challenge in challenges if challenge.get("roleId") == roleId]
    return {"challenges": challenges}


@router.get("/challenges/{challenge_id}")
def get_challenge(challenge_id: str) -> dict:
    for challenge in get_challenges():
        if challenge["id"] == challenge_id:
            return challenge
    raise HTTPException(status_code=404, detail="Challenge not found")


@router.post("/challenges/{challenge_id}/submit")
def submit_challenge(
    challenge_id: str,
    payload: dict[str, Any],
    conn: Annotated[object, Depends(get_connection)],
) -> dict:
    challenge = get_challenge(challenge_id)
    student_id = payload.get("studentId", "stu_camila")
    submission_id = f"sub_{student_id}_{uuid4().hex[:8]}"
    score = payload.get("score", 75)

    evidence_id = f"ev_{student_id}_{challenge_id}_{uuid4().hex[:6]}"
    execute(
        conn,
        """
        INSERT INTO evidences (id, student_id, title, type, context, actions, result, cv_bullet, star_story, source)
        VALUES (%s, %s, %s, 'challenge', %s, %s, %s, %s, %s, 'challenge')
        """,
        (
            evidence_id,
            student_id,
            challenge["title"],
            challenge["brief"],
            "Resolvio micro-reto de empleabilidad con respuestas estructuradas.",
            "Genero evidencia para reforzar su perfil profesional.",
            f"Resolvio el reto '{challenge['title']}' con score {score}/100, generando evidencia aplicable al CV.",
            f"Situacion: {challenge['brief']}. Accion: resolvio el reto. Resultado: score {score}/100.",
        ),
    )
    execute(
        conn,
        """
        INSERT INTO challenge_submissions (id, challenge_id, student_id, answers_json, score, feedback, generated_evidence_id)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        """,
        (
            submission_id,
            challenge_id,
            student_id,
            Jsonb(payload.get("answers", {})),
            score,
            payload.get("feedback", "Buen avance; usar esta evidencia en el CV."),
            evidence_id,
        ),
    )
    return {"id": submission_id, "score": score, "generatedEvidenceId": evidence_id}
