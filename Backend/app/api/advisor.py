from typing import Annotated

from fastapi import APIRouter, Depends

from app.core.db import fetch_all, fetch_one, get_connection
from app.core.json_loader import get_advisor_seed


router = APIRouter()


@router.get("/advisor/impact")
def get_advisor_impact(conn: Annotated[object, Depends(get_connection)]) -> dict:
    seed = get_advisor_seed()
    totals = {
        "students": fetch_one(conn, "SELECT count(*) AS total FROM students")["total"],
        "evidences": fetch_one(conn, "SELECT count(*) AS total FROM evidences")["total"],
        "applications": fetch_one(conn, "SELECT count(*) AS total FROM applications")["total"],
        "companies": fetch_one(conn, "SELECT count(*) AS total FROM companies")["total"],
        "activeJobs": fetch_one(conn, "SELECT count(*) AS total FROM jobs WHERE status = 'active'")["total"],
    }
    by_career = fetch_all(
        conn,
        """
        SELECT career, count(*) AS students
        FROM students
        GROUP BY career
        ORDER BY students DESC, career
        """,
    )
    top_roles = fetch_all(
        conn,
        """
        SELECT target_role_name AS role, count(*) AS students
        FROM student_goals
        WHERE active = true
        GROUP BY target_role_name
        ORDER BY students DESC, role
        """,
    )
    # Brechas criticas reales: skills que mas estudiantes tienen abiertas.
    critical_gaps = fetch_all(
        conn,
        """
        SELECT scg.skill_id AS "skillId", sk.name AS "skillName",
               count(DISTINCT scg.student_id) AS students
        FROM student_critical_gaps scg
        JOIN skills sk ON sk.id = scg.skill_id
        WHERE scg.status = 'open'
        GROUP BY scg.skill_id, sk.name
        ORDER BY students DESC, sk.name
        LIMIT 8
        """,
    )
    return {
        "totals": totals,
        "byCareer": by_career,
        "topRoles": top_roles,
        "seedMetrics": seed,
        "criticalGaps": critical_gaps,
        "topGaps": [gap["skillName"] for gap in critical_gaps[:5]],
    }
