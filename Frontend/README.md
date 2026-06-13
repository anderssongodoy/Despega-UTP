# Despega UTP Frontend

Frontend React + Vite para el MVP de Despega UTP.

## Stack

- React
- Vite
- TypeScript
- React Router
- Lucide React
- CSS global simple con tokens UTP

## Instalar

```bash
npm install
copy .env.example .env
```

## Ejecutar

```bash
npm run dev
```

URL local:

```text
http://localhost:4200
```

El backend debe estar en:

```text
http://localhost:8000/api
```

Si cambia, editar `.env`:

```text
VITE_API_BASE_URL=http://localhost:8000/api
```

## Scripts

```bash
npm run dev        # servidor local
npm run build      # typecheck + build
npm run preview    # preview del build
npm run typecheck  # solo TypeScript
```

## Guia para desarrolladores

Leer:

```text
GUIA_TRABAJO_FRONTEND.md
```
