from typing import Annotated, Any
from uuid import uuid4

from fastapi import APIRouter, Depends, HTTPException, Query

from app.core.db import execute, fetch_all, fetch_one, get_connection


router = APIRouter()

# Demo password that unlocks every pre-seeded account (students/advisor have no
# password in the seed). Newly registered users can also use their own password.
DEMO_PASSWORD = "demo123"

REDIRECT_BY_ROLE = {
    "student": "/student/home",
    "company": "/company/dashboard",
    "advisor": "/advisor/impact",
}


def _build_session(conn, user: dict) -> dict:
    """Build the SessionResponse contract from a users row."""
    needs_onboarding = user["role"] == "student" and not user["onboarding_completed"]
    redirect_to = "/onboarding" if needs_onboarding else REDIRECT_BY_ROLE[user["role"]]

    response: dict[str, Any] = {
        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
        },
        "authProvider": user["auth_provider"],
        "requiresOnboarding": needs_onboarding,
        "redirectTo": redirect_to,
    }

    if user["role"] == "company":
        company = fetch_one(conn, "SELECT company_id FROM company_users WHERE user_id = %s LIMIT 1", (user["id"],))
        response["companyId"] = company["company_id"] if company else None

    return response


@router.get("/auth/session")
def get_session(
    conn: Annotated[object, Depends(get_connection)],
    user_id: str = Query("stu_camila", alias="userId"),
) -> dict:
    user = fetch_one(
        conn,
        "SELECT id, name, email, role, auth_provider, onboarding_completed FROM users WHERE id = %s",
        (user_id,),
    )
    if not user:
        user = fetch_one(
            conn,
            "SELECT id, name, email, role, auth_provider, onboarding_completed FROM users WHERE id = 'stu_camila'",
        )
    return _build_session(conn, user)


@router.get("/auth/users")
def list_users(conn: Annotated[object, Depends(get_connection)]) -> dict:
    """Lista de cuentas disponibles (para accesos demo en el login)."""
    users = fetch_all(conn, "SELECT id, name, email, role FROM users ORDER BY role, name")
    return {"users": users, "demoPassword": DEMO_PASSWORD}


@router.post("/auth/login")
def login(payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    email = (payload.get("email") or "").strip().lower()
    password = payload.get("password") or ""

    user = fetch_one(
        conn,
        """
        SELECT id, name, email, role, auth_provider, onboarding_completed, password_hash
        FROM users
        WHERE lower(email) = %s
        """,
        (email,),
    )
    if not user:
        raise HTTPException(status_code=401, detail="Email o contrasena incorrectos.")

    stored = user.get("password_hash")
    # Seed accounts (NULL or the placeholder hash) accept the demo password.
    # Registered accounts also accept their own stored password.
    valid = password == DEMO_PASSWORD or (stored not in (None, "demo-password-hash") and password == stored)
    if not valid:
        raise HTTPException(status_code=401, detail="Email o contrasena incorrectos.")

    return _build_session(conn, user)


@router.post("/auth/register")
def register(payload: dict[str, Any], conn: Annotated[object, Depends(get_connection)]) -> dict:
    name = (payload.get("name") or "").strip()
    email = (payload.get("email") or "").strip().lower()
    password = payload.get("password") or ""
    role = payload.get("role") or "student"

    if not name or not email or not password:
        raise HTTPException(status_code=400, detail="Nombre, email y contrasena son obligatorios.")
    if role not in REDIRECT_BY_ROLE:
        raise HTTPException(status_code=400, detail="Rol invalido.")

    existing = fetch_one(conn, "SELECT id FROM users WHERE lower(email) = %s", (email,))
    if existing:
        raise HTTPException(status_code=409, detail="Ese email ya esta registrado.")

    user_id = f"usr_{uuid4().hex[:10]}"
    onboarding_completed = role != "student"
    execute(
        conn,
        """
        INSERT INTO users (id, name, email, role, auth_provider, password_hash, onboarding_completed)
        VALUES (%s, %s, %s, %s, 'credentials', %s, %s)
        """,
        (user_id, name, email, role, password, onboarding_completed),
    )

    user = {
        "id": user_id,
        "name": name,
        "email": email,
        "role": role,
        "auth_provider": "credentials",
        "onboarding_completed": onboarding_completed,
    }
    return _build_session(conn, user)
