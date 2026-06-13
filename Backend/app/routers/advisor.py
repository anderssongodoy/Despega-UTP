from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.advisor_metrics_service import get_advisor_impact

router = APIRouter()


@router.get("/advisor/impact")
def advisor_impact(db: Session = Depends(get_db)):
    return get_advisor_impact(db)
