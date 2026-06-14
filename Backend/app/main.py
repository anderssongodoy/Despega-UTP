from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Backend canónico de la demo: app/api/ (psycopg v3, SQL directo vía app/core/db.py).
# NOTA: app/routers/ (SQLAlchemy + mocks) quedó deprecado; el frontend consume /api.
from app.api import advisor, auth, challenges, companies, jobs, students
from app.api import advisor, auth, challenges, companies, jobs, students, cv
from app.core.config import get_settings


settings = get_settings()

app = FastAPI(
    title="Despega UTP API",
    version="0.1.0",
    description="Backend FastAPI MVP para Hackathon UTP+ (psycopg v3).",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api", tags=["Auth"])
app.include_router(students.router, prefix="/api", tags=["Students"])
app.include_router(jobs.router, prefix="/api", tags=["Jobs"])
app.include_router(challenges.router, prefix="/api", tags=["Challenges"])
app.include_router(companies.router, prefix="/api", tags=["Companies"])
app.include_router(advisor.router, prefix="/api", tags=["Advisor"])


@app.get("/", include_in_schema=False)
def root() -> dict:
    return {"message": "Despega UTP API corriendo. Visita /docs para Swagger."}
app.include_router(cv.router, prefix="/api", tags=["CV Analyzer"])


@app.get("/health")
def health() -> dict:
    return {"status": "ok", "app": settings.app_name, "env": settings.app_env}
