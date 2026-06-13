from fastapi import APIRouter
from app.services.config_service import get_roles

router = APIRouter()


@router.get("/roles")
def list_roles():
    roles = get_roles()
    # Devolver sólo los campos del contrato OpenAPI
    return {
        "roles": [
            {
                "id": r["id"],
                "name": r["name"],
                "family": r["family"],
                "recommendedCycleMin": r["recommendedCycleMin"],
            }
            for r in roles
        ]
    }
