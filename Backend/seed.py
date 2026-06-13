"""
seed.py - Inicializa la base de datos despega_utp y carga el schema + datos demo.
Uso: python seed.py
"""
import os
import sys
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

DB_USER = "postgres"
DB_PASSWORD = "Manuelito55"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "despega_utp"

# Ruta al SQL del equipo (relativa a este archivo)
SQL_FILE = os.path.join(os.path.dirname(__file__), "init_postgres_demo.sql")


def create_database():
    """Crea la base de datos si no existe."""
    conn = psycopg2.connect(
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        dbname="postgres"
    )
    conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (DB_NAME,))
    exists = cur.fetchone()
    if not exists:
        cur.execute(f"CREATE DATABASE {DB_NAME}")
        print(f"[seed] Base de datos '{DB_NAME}' creada.")
    else:
        print(f"[seed] Base de datos '{DB_NAME}' ya existe.")
    cur.close()
    conn.close()


def run_sql():
    """Ejecuta init_postgres_demo.sql contra la base despega_utp."""
    if not os.path.exists(SQL_FILE):
        print(f"[seed] ERROR: No se encontro {SQL_FILE}")
        sys.exit(1)

    with open(SQL_FILE, "r", encoding="utf-8") as f:
        sql = f.read()

    conn = psycopg2.connect(
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME
    )
    cur = conn.cursor()
    try:
        cur.execute(sql)
        conn.commit()
        print("[seed] Tablas y datos demo cargados correctamente.")
    except Exception as e:
        conn.rollback()
        print(f"[seed] ERROR al ejecutar SQL: {e}")
        sys.exit(1)
    finally:
        cur.close()
        conn.close()


if __name__ == "__main__":
    print("[seed] Iniciando setup de base de datos...")
    create_database()
    run_sql()
    print("[seed] Listo. La base de datos esta lista para usar.")
