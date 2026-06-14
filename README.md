# Despega UTP

Plataforma de empleabilidad para estudiantes de la UTP. Convierte al estudiante en talento listo para la industria en tres pasos: **diagnostica brechas → convierte evidencia en perfil profesional → conecta con empresas.**

Tiene tres vistas (roles):

- **Estudiante** — onboarding/diagnóstico, ruta profesional, retos de práctica, oportunidades con match explicado, perfil con analizador de CV (IA) y coach de pitch (IA), y portafolio público.
- **Empresa** — dashboard de talento pre-filtrado y candidatos rankeados con evidencia.
- **Asesor UTP** — impacto institucional: brechas críticas reales, estudiantes por carrera y roles más buscados.

---

## Arquitectura

| Capa | Stack |
|------|-------|
| Frontend | React 19 + TypeScript + Vite (puerto **4200**) |
| Backend | FastAPI + psycopg 3 (puerto **8000**, API bajo `/api`) |
| Base de datos | PostgreSQL (base `despega_utp`) |
| IA (opcional) | OpenAI (análisis de CV en PDF y coach de pitch por audio) |

```
Despega-UTP/
├── Backend/                 # API FastAPI
│   ├── app/                 # código (api/, services/, core/, data/*.json)
│   ├── despega_utp_demo.sql # 👈 script ÚNICO: crea esquema + carga TODA la data
│   ├── requirements.txt
│   └── .env.example
├── Frontend/                # SPA React
│   ├── src/
│   ├── package.json
│   └── .env.example
└── README.md                # este archivo
```

---

## Requisitos previos

El jurado necesita instalar (una sola vez):

1. **PostgreSQL 14+** — https://www.postgresql.org/download/
2. **Python 3.11+** (probado en 3.12) — https://www.python.org/downloads/
3. **Node.js 18+** (incluye npm) — https://nodejs.org/

> No se necesita ninguna API key para que la app funcione. La key de OpenAI es **opcional** y solo habilita el análisis de CV y el coach de pitch.

---

## Puesta en marcha (paso a paso)

### 1) Base de datos — cargar `despega_utp_demo.sql`

Este único script **crea todas las tablas y carga todos los datos de demo** (estudiantes, empresas, vacantes, skills, brechas, evidencias y usuarios de prueba). Es idempotente: puedes correrlo varias veces sin duplicar nada.

**Opción A — con `psql` (terminal):**
```bash
# Crea la base
psql -U postgres -c "CREATE DATABASE despega_utp;"
# Carga el script
psql -U postgres -d despega_utp -f Backend/despega_utp_demo.sql
```

**Opción B — con pgAdmin (interfaz gráfica):**
1. Crea una base llamada `despega_utp`.
2. Clic derecho sobre la base → *Query Tool*.
3. Abre `Backend/despega_utp_demo.sql`, pégalo y ejecútalo (▶).

### 2) Backend (FastAPI)

```bash
cd Backend
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
# source .venv/bin/activate

pip install -r requirements.txt

copy .env.example .env        # Windows  (macOS/Linux: cp .env.example .env)
# Edita .env y ajusta DATABASE_URL con tu usuario/clave de PostgreSQL.

uvicorn app.main:app --reload --port 8000
```
API disponible en `http://localhost:8000` · docs interactivas en `http://localhost:8000/docs`.

### 3) Frontend (React)

```bash
cd Frontend
npm install

copy .env.example .env        # Windows  (macOS/Linux: cp .env.example .env)
# .env ya apunta al backend local (http://localhost:8000/api).

npm run dev
```
App disponible en `http://localhost:4200`.

---

## Usuarios de prueba

Contraseña universal para todos: **`demo123`**

**Con datos (onboarding completo):**

| Rol | Email |
|-----|-------|
| Estudiante (perfil completo) | `camila.torres@utp.edu.pe` |
| Estudiante | `andrea.salazar@utp.edu.pe`, `mateo.rivas@utp.edu.pe`, `lucia.herrera@utp.edu.pe`, `luis.mendoza@utp.edu.pe`, `diego.ramos@utp.edu.pe`, `renzo.castillo@utp.edu.pe`, `valeria.paredes@utp.edu.pe` |
| Empresa | `ana@retailandino.pe`, `paola@talentolab.pe` |
| Asesor | `asesor@utp.edu.pe` |

**Sin onboarding (para probar el flujo desde cero):**

`prueba1@utp.edu.pe` · `prueba2@utp.edu.pe` · `prueba3@utp.edu.pe` · `prueba4@utp.edu.pe` · `prueba5@utp.edu.pe`

> Estos 5 usuarios entran directo al **onboarding**: ideal para que el jurado pruebe el diagnóstico inicial como un estudiante nuevo.

---

## Empaquetar el proyecto (RAR/ZIP limpio)

Para enviar solo el proyecto, **no incluyas**: `Backend/.venv`, `Frontend/node_modules`, ni los `.env` reales.

La forma más limpia (excluye todo lo anterior automáticamente):
```bash
git archive -o despega-utp.zip HEAD
```

Si lo comprimes a mano, elimina/excluye antes: `.venv/`, `node_modules/`, `*.env` (deja los `*.env.example`).

---

## Notas

- Toda la app está en español.
- La data de demo vive en la base (cargada por el SQL) y en `Backend/app/data/*.json` (retos, roles, recursos).
- Detalles específicos en `Backend/README.md` y `Frontend/README.md`.
