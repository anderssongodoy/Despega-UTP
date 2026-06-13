from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import advisor, auth, challenges, companies, jobs, students, cv
from app.core.config import get_settings

settings = get_settings()

app = FastAPI(
    title="Despega UTP API",
    version="0.1.0",
    description="Backend FastAPI MVP para Hackathon UTP+.",
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

app.include_router(cv.router, prefix="/api", tags=["CV Analyzer"])

@app.get("/health")
def health() -> dict:
    return {"status": "ok", "app": settings.app_name, "env": settings.app_env}
