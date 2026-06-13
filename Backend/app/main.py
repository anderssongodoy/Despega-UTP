from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

# Routers existentes — SQLAlchemy + lógica de negocio completa
from app.routers import roles, companies, advisor, mock_routers

# Routers del remote — psycopg v3, arquitectura app/api/
from app.api import advisor as advisor_api, auth, challenges
from app.api import companies as companies_api, jobs, students

from app.core.config import get_settings

settings = get_settings()

app = FastAPI(
    title="Despega UTP API",
    version="0.1.0",
    description=(
        "Contrato API para el MVP de Despega UTP. Cubre login/session, "
        "onboarding de estudiante, dashboard, diagnostico, evidencias, CV, "
        "oportunidades, retos, empresa y asesor UTP."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# ---------------------------------------------------------------------------
# CORS
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------------------------
# Manejador global de errores con formato canónico
# ---------------------------------------------------------------------------
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"error": {"code": "INTERNAL_ERROR", "message": str(exc)}},
    )

# ---------------------------------------------------------------------------
# Routers — app/routers/ (SQLAlchemy, lógica real con ORM)
# ---------------------------------------------------------------------------
app.include_router(roles.router, prefix="/api", tags=["Config"])
app.include_router(companies.router, prefix="/api", tags=["Companies"])
app.include_router(advisor.router, prefix="/api", tags=["Advisor"])

# Mocks para integración completa (Backend 1 y 2)
app.include_router(mock_routers.router, prefix="/api", tags=["Students", "Jobs", "Challenges", "Auth"])

# ---------------------------------------------------------------------------
# Routers — app/api/ (psycopg v3, arquitectura del remote)
# Montados bajo /v2 para evitar colisión de rutas hasta que se unifique
# ---------------------------------------------------------------------------
app.include_router(auth.router, prefix="/v2/api", tags=["Auth v2"])
app.include_router(students.router, prefix="/v2/api", tags=["Students v2"])
app.include_router(jobs.router, prefix="/v2/api", tags=["Jobs v2"])
app.include_router(challenges.router, prefix="/v2/api", tags=["Challenges v2"])
app.include_router(companies_api.router, prefix="/v2/api", tags=["Companies v2"])
app.include_router(advisor_api.router, prefix="/v2/api", tags=["Advisor v2"])


@app.get("/", include_in_schema=False)
def root():
    return {"message": "Despega UTP API corriendo. Visita /docs para Swagger."}


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "app": settings.app_name, "env": settings.app_env}
