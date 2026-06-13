from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.routers import roles, companies, advisor, mock_routers

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
# CORS - permite cualquier origen en desarrollo
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
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
# Routers - Backend 3 (reales)
# ---------------------------------------------------------------------------
app.include_router(roles.router, prefix="/api", tags=["Config"])
app.include_router(companies.router, prefix="/api", tags=["Companies"])
app.include_router(advisor.router, prefix="/api", tags=["Advisor"])

# ---------------------------------------------------------------------------
# Routers - Backend 1 y 2 (mocks para integración completa)
# ---------------------------------------------------------------------------
app.include_router(mock_routers.router, prefix="/api", tags=["Students", "Jobs", "Challenges", "Auth"])


@app.get("/", include_in_schema=False)
def root():
    return {"message": "Despega UTP API corriendo. Visita /docs para Swagger."}
