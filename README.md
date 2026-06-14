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
│   ├── setup_db.py          # crea la BD y carga el SQL (sin psql ni pgAdmin)
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
2. **Python 3.12** — https://www.python.org/downloads/
   - Recomendado **3.12** (probado en 3.12.7). Sirve también 3.11.
   - ⚠️ Evita 3.13: algunas librerías (p. ej. PyMuPDF) aún no traen wheels para esa versión y la instalación puede fallar.
3. **Node.js 18+** (incluye npm) — https://nodejs.org/

> La key de OpenAI solo habilita el análisis de CV (PDF) y el coach de pitch (audio). Sin ella el resto de la app funciona igual.

---

## Puesta en marcha (paso a paso)

### 1) Backend — entorno e instalación

```bash
cd Backend

# Crea el entorno virtual (necesitas Python 3.12) y actívalo
python -m venv .venv              # opción normal
# Si da error o tu Python por defecto NO es 3.12, fuerza la versión:
#   py -3.12 -m venv .venv        # Windows
#   python3.12 -m venv .venv      # macOS/Linux
.venv\Scripts\activate            # Windows
# source .venv/bin/activate       # macOS/Linux

# Instala dependencias
pip install -r requirements.txt
```

**Configura `Backend/.env`:** el proyecto ya incluye un `.env`. Edita solo **`DATABASE_URL`** con el usuario/clave/puerto de TU PostgreSQL, por ejemplo:

```
DATABASE_URL=postgresql://postgres:TU_CLAVE@localhost:5432/despega_utp
```

> La `OPENAI_API_KEY` ya viene configurada en ese `.env`. Si no existiera, cópialo de `Backend/.env.example`.

### 2) Base de datos — crear y cargar todo

El script `despega_utp_demo.sql` **crea todas las tablas y carga todos los datos de demo** (estudiantes, empresas, vacantes, skills, brechas, evidencias y usuarios de prueba). Es idempotente: puedes correrlo varias veces sin duplicar nada.

**Opción A — recomendada, SIN psql ni pgAdmin** (usa el venv del paso 1):
```bash
# desde Backend, con el venv activado
python setup_db.py
```
Crea la base `despega_utp` (si no existe) y carga todos los datos automáticamente, leyendo la conexión desde `.env`.

**Opción B — con `psql`:**
```bash
psql -U postgres -c "CREATE DATABASE despega_utp;"
psql -U postgres -d despega_utp -f despega_utp_demo.sql
```

**Opción C — con pgAdmin:** crea la base `despega_utp`, abre *Query Tool*, carga `Backend/despega_utp_demo.sql` y ejecútalo (▶).

### 3) Arranca el backend

```bash
# desde Backend, con el venv activado
uvicorn app.main:app --reload --port 8000
#  (alternativa equivalente)  python run.py
```
API en `http://localhost:8000` · docs interactivas en `http://localhost:8000/docs`.

### 4) Frontend (React)

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

## Empaquetar el proyecto (RAR/ZIP)

El entregable es un `.zip`/`.rar` con las carpetas **`Backend/`** y **`Frontend/`** + este **`README.md`**.

**Antes de comprimir, elimina (pesan mucho y se reinstalan con los comandos de arriba):**

- `Backend/.venv/`
- `Frontend/node_modules/`

> Sí se incluye `Backend/.env` (con la `OPENAI_API_KEY`). El jurado solo debe editar `DATABASE_URL`.

---

## Notas

- Toda la app está en español.
- La data de demo vive en la base (cargada por el SQL) y en `Backend/app/data/*.json` (retos, roles, recursos).
- Detalles específicos en `Backend/README.md` y `Frontend/README.md`.
