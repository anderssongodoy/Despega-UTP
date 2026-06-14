from fastapi import APIRouter, HTTPException

from app.core.json_loader import get_challenges


router = APIRouter()


@router.get("/challenges")
def list_challenges(roleId: str | None = None) -> dict:
    challenges = get_challenges()
    if roleId:
        challenges = [challenge for challenge in challenges if challenge.get("roleId") == roleId]
    return {"challenges": challenges}


@router.get("/challenges/{challenge_id}")
def get_challenge(challenge_id: str) -> dict:
    for challenge in get_challenges():
        if challenge["id"] == challenge_id:
            return challenge
    raise HTTPException(status_code=404, detail="Challenge not found")
