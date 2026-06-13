# Despega UTP Backend

Base FastAPI para el MVP de Hackathon UTP+.

## Stack

- FastAPI
- PostgreSQL
- psycopg 3
- JSON/config para catalogos estables

## Estructura

```text
app/
  main.py
  api/
    auth.py
    students.py
    jobs.py
    challenges.py
    companies.py
    advisor.py
  core/
    config.py
    db.py
    json_loader.py
  services/
    matching.py
  data/
    roles.json
    utp_resources.json
    challenges.json
    advisor_metrics_seed.json
init_postgres_demo.sql
openapi.yaml
requirements.txt
```

## Instalacion

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Editar `.env` si tu PostgreSQL usa otro usuario/password.

## Crear BD demo

```bash
createdb despega_utp
psql -U postgres -d despega_utp -f init_postgres_demo.sql
```

Si la BD ya existe, basta con volver a correr el script `init_postgres_demo.sql`; recrea las tablas MVP.

## Ejecutar

```bash
uvicorn app.main:app --reload --port 8000
```

Swagger:

```text
http://localhost:8000/docs
```

Health:

```text
http://localhost:8000/health
```

## Usuarios demo

- Estudiante listo: `stu_camila`
- Estudiante sin onboarding: `stu_nuevo`
- Empresa: `usr_recruiter_ana`
- Asesor: `advisor_utp`

Ejemplos:

```text
GET /api/auth/session?userId=stu_camila
GET /api/auth/session?userId=stu_nuevo
GET /api/students/stu_camila/dashboard
GET /api/companies/comp_retail_andino/dashboard
GET /api/advisor/impact
```

## Nota para el equipo

La arquitectura es intencionalmente simple para 2 dias:

- Routers por dominio.
- SQL directo con `psycopg`.
- Servicios calculados solo donde aporta: match, brechas y recursos.
- Sin SQLAlchemy/Alembic para evitar curva extra durante la hackathon.

Si cambian campos de respuesta, actualicen `openapi.yaml`.

Guia de trabajo para desarrolladores:

```text
GUIA_TRABAJO_BACKEND.md
```
