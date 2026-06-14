"""Crea la base de datos y carga TODA la data de demo, sin necesidad de psql ni pgAdmin.

Uso (con el entorno virtual del backend activado):
    python setup_db.py

Requisitos:
    - PostgreSQL corriendo.
    - DATABASE_URL configurado en Backend/.env (usuario, clave, host, puerto).
    - Dependencias instaladas (pip install -r requirements.txt).
"""
import os
import sys
from pathlib import Path

import psycopg
from dotenv import load_dotenv

load_dotenv()

URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/despega_utp")
SQL_FILE = Path(__file__).with_name("despega_utp_demo.sql")

# Nombre de la base y conexión a la base de mantenimiento 'postgres' (para poder crearla).
DB_NAME = URL.rsplit("/", 1)[1].split("?")[0]
ADMIN_URL = URL.rsplit("/", 1)[0] + "/postgres"


def main() -> None:
    if not SQL_FILE.exists():
        print(f"[X] No se encontro {SQL_FILE.name} junto a este script.")
        sys.exit(1)
    sql = SQL_FILE.read_text(encoding="utf-8")

    # 1) Crear la base si no existe.
    try:
        admin = psycopg.connect(ADMIN_URL, autocommit=True)
    except Exception as exc:
        print("[X] No pude conectar a PostgreSQL.")
        print("    Revisa que el servidor este corriendo y que DATABASE_URL en .env sea correcto")
        print("    (usuario, clave, host y puerto).")
        print("    Detalle:", exc)
        sys.exit(1)

    exists = admin.execute("SELECT 1 FROM pg_database WHERE datname = %s", (DB_NAME,)).fetchone()
    if exists:
        print(f"[i] La base '{DB_NAME}' ya existe; se reutiliza (el script es idempotente).")
    else:
        admin.execute(f'CREATE DATABASE "{DB_NAME}"')
        print(f"[OK] Base '{DB_NAME}' creada.")
    admin.close()

    # 2) Ejecutar el script completo (multiples sentencias) sobre la base.
    conn = psycopg.connect(URL, autocommit=True)
    result = conn.pgconn.exec_(sql.encode("utf-8"))
    error = result.error_message.decode("utf-8", "replace") if result.error_message else ""
    if error:
        print("[X] Error al cargar el script SQL:")
        print(error[:1500])
        conn.close()
        sys.exit(1)

    # 3) Resumen rapido.
    cur = conn.cursor()
    cur.execute("SELECT count(*) FROM users")
    users = cur.fetchone()[0]
    cur.execute("SELECT count(*) FROM students")
    students = cur.fetchone()[0]
    cur.execute("SELECT count(*) FROM users WHERE onboarding_completed = false AND role = 'student'")
    sin_onboarding = cur.fetchone()[0]
    conn.close()

    print(f"[OK] Datos cargados en '{DB_NAME}': {users} usuarios, {students} estudiantes "
          f"({sin_onboarding} sin onboarding para probar el flujo de cero).")
    print("[i] Password de todos los usuarios demo: demo123")
    print("[OK] Listo. Ya puedes arrancar el backend: uvicorn app.main:app --reload --port 8000")


if __name__ == "__main__":
    main()
