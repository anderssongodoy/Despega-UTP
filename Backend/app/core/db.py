from collections.abc import Generator

import psycopg
from psycopg.rows import dict_row

from app.core.config import get_settings


def get_connection() -> Generator[psycopg.Connection, None, None]:
    conn = psycopg.connect(get_settings().database_url, row_factory=dict_row)
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def fetch_one(conn: psycopg.Connection, query: str, params: tuple = ()) -> dict | None:
    with conn.cursor() as cur:
        cur.execute(query, params)
        return cur.fetchone()


def fetch_all(conn: psycopg.Connection, query: str, params: tuple = ()) -> list[dict]:
    with conn.cursor() as cur:
        cur.execute(query, params)
        return list(cur.fetchall())


def execute(conn: psycopg.Connection, query: str, params: tuple = ()) -> None:
    with conn.cursor() as cur:
        cur.execute(query, params)
