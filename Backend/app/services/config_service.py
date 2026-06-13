import json
import os

_BASE = os.path.join(os.path.dirname(__file__), "..", "..", "..", "data-config")

def _load(filename: str):
    path = os.path.normpath(os.path.join(_BASE, filename))
    with open(path, "r", encoding="utf-8-sig") as f:
        return json.load(f)


def get_roles():
    return _load("roles.json")


def get_utp_resources():
    return _load("utp_resources.json")


def get_challenges():
    return _load("challenges.json")


def get_advisor_metrics_seed():
    return _load("advisor_metrics_seed.json")


def get_role_by_id(role_id: str):
    roles = get_roles()
    return next((r for r in roles if r["id"] == role_id), None)


def get_challenge_by_id(challenge_id: str):
    challenges = get_challenges()
    return next((c for c in challenges if c["id"] == challenge_id), None)
