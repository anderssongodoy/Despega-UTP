from typing import Annotated

from fastapi import APIRouter, Depends, Query

from app.core.db import fetch_one, get_connection


router = APIRouter()


@router.get("/auth/session")
def get_session(
    conn: Annotated[object, Depends(get_connection)],
    user_id: str = Query("stu_camila", alias="userId"),
) -> dict:
    user = fetch_one(
        conn,
        """
        SELECT id, name, email, role, auth_provider, onboarding_completed
        FROM users
        WHERE id = %s
        """,
        (user_id,),
    )

    if not user:
        user = fetch_one(
            conn,
            """
            SELECT id, name, email, role, auth_provider, onboarding_completed
            FROM users
            WHERE id = 'stu_camila'
            """,
        )

    redirect_by_role = {
        "student": "/student/home",
        "company": "/company/dashboard",
        "advisor": "/advisor/impact",
    }
    redirect_to = "/onboarding" if user["role"] == "student" and not user["onboarding_completed"] else redirect_by_role[user["role"]]

    response = {
        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
        },
        "authProvider": user["auth_provider"],
        "requiresOnboarding": user["role"] == "student" and not user["onboarding_completed"],
        "redirectTo": redirect_to,
    }

    if user["role"] == "company":
        company = fetch_one(conn, "SELECT company_id FROM company_users WHERE user_id = %s LIMIT 1", (user["id"],))
        response["companyId"] = company["company_id"] if company else None

    return response
