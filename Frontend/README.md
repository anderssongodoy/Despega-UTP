# Despega UTP — Frontend (SPA)

Single Page App en **React 19 + TypeScript + Vite**. Consume la API del backend (`/api`).

> Para la guía completa del proyecto (base de datos y usuarios de prueba) revisa el `README.md` de la raíz.

## Stack

- React 19 + TypeScript
- Vite
- React Router
- Lucide React (iconos)
- CSS global con tokens de marca UTP (sin modo oscuro)

## Estructura

```text
src/
  features/        # vistas por dominio
    student/       # onboarding, ruta, retos, oportunidades, perfil (CV + pitch), portafolio
    company/       # dashboard y talento
    advisor/       # impacto institucional
    public/        # landing, login
  shared/          # api/, components/, config/, auth/, styles/
  routes.tsx       # rutas
```

## Instalar y ejecutar

```bash
npm install
copy .env.example .env     # macOS/Linux: cp .env.example .env
npm run dev
```

- App: `http://localhost:4200`
- Requiere el backend corriendo en `http://localhost:8000/api`.

El `.env` apunta al backend local. Si cambia la URL, edítalo:

```text
VITE_API_BASE_URL=http://localhost:8000/api
```

## Scripts

```bash
npm run dev        # servidor local (puerto 4200)
npm run build      # typecheck + build de producción
npm run preview    # preview del build
npm run typecheck  # solo TypeScript
```

## Acceso

Contraseña universal de demo: **`demo123`**. La lista de usuarios de prueba está en el `README.md` de la raíz.
