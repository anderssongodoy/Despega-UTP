# Despega UTP — Backend (API)

API REST en **FastAPI** + **psycopg 3** sobre **PostgreSQL**. Toda la API vive bajo el prefijo `/api`.

> Para la guía completa del proyecto (incluyendo cómo cargar la base y los usuarios de prueba) revisa el `README.md` de la raíz.

## Stack

- FastAPI + Uvicorn
- psycopg 3 (SQL directo, sin ORM)
- PostgreSQL
- OpenAI (opcional: análisis de CV y coach de pitch)

## Estructura

```text
app/
  main.py            # arranque FastAPI, monta routers bajo /api
  api/               # endpoints por dominio
    auth.py          # login/registro (password demo: demo123)
    students.py      # dashboard, onboarding, diagnóstico, brechas, evidencias, CV
    jobs.py
    challenges.py    # catálogo de retos de práctica
    companies.py     # dashboard de empresa y talento
    advisor.py       # impacto institucional (asesor)
    cv.py            # análisis de CV en PDF (IA)
    audio.py         # análisis de pitch por audio (IA)
  services/          # lógica calculada: matching, cv_analyzer, audio_analyzer, cv_bullet
  core/              # config, conexión db, carga de JSON
  data/              # catálogos: roles, retos, recursos, métricas (JSON)
despega_utp_demo.sql # script único: esquema + toda la data de demo
requirements.txt
.env.example
```

## Instalación

```bash
python -m venv .venv
.venv\Scripts\activate            # Windows  (macOS/Linux: source .venv/bin/activate)
pip install -r requirements.txt
copy .env.example .env            # macOS/Linux: cp .env.example .env
```

Edita `.env` y ajusta `DATABASE_URL` con tu usuario/clave de PostgreSQL.

| Variable | Descripción |
|----------|-------------|
| `DATABASE_URL` | Conexión a PostgreSQL. La base debe llamarse `despega_utp`. |
| `CORS_ORIGINS` | Orígenes permitidos (ya incluye el frontend en `:4200`). |
| `OPENAI_API_KEY` | **Opcional.** Habilita análisis de CV y coach de pitch. Vacío = el backend arranca igual. |
| `OPENAI_MODEL` | Modelo OpenAI (por defecto `gpt-4o-mini`). |

## Base de datos

Crea la base y carga el **script único** (crea el esquema y toda la data de demo; es idempotente):

```bash
psql -U postgres -c "CREATE DATABASE despega_utp;"
psql -U postgres -d despega_utp -f despega_utp_demo.sql
```

(También puedes correrlo desde pgAdmin con el *Query Tool*.)

## Ejecutar

```bash
uvicorn app.main:app --reload --port 8000
# alternativa equivalente:
python run.py
```

- Docs interactivas (Swagger): `http://localhost:8000/docs`
- Ejemplos:
  - `GET /api/students/stu_camila/dashboard`
  - `GET /api/companies/comp_retail_andino/dashboard`
  - `GET /api/advisor/impact`

## Notas de diseño

- Routers por dominio, SQL directo con `psycopg` (sin SQLAlchemy/Alembic).
- Servicios calculados solo donde aportan: match, brechas críticas y recomendaciones.
- Los catálogos estables (roles, retos, recursos) viven como JSON en `app/data/`.
- Las funciones con IA degradan con un error claro si no hay `OPENAI_API_KEY`; el resto de la app no se ve afectado.
