import json
from functools import lru_cache
from pathlib import Path
from typing import Any


DATA_DIR = Path(__file__).resolve().parents[1] / "data"


@lru_cache
def load_json(filename: str) -> Any:
    path = DATA_DIR / filename
    return json.loads(path.read_text(encoding="utf-8-sig"))


def get_roles() -> list[dict]:
    return load_json("roles.json")


def get_challenges() -> list[dict]:
    return load_json("challenges.json")


def get_resources() -> list[dict]:
    return load_json("utp_resources.json")


def get_advisor_seed() -> dict:
    return load_json("advisor_metrics_seed.json")
