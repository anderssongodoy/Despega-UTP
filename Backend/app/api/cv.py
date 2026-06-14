from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.cv_analyzer import analyze_cv

router = APIRouter()


@router.post("/cv/analyze")
async def analyze_cv_endpoint(file: UploadFile = File(...)):
    """
    Analiza un CV en formato PDF utilizando IA.
    """

    # Validar tipo de archivo
    if file.content_type != "application/pdf":
        raise HTTPException(
            status_code=400,
            detail="Solo se permiten archivos PDF."
        )

    try:
        pdf_bytes = await file.read()

        result = analyze_cv(pdf_bytes)

        return {
            "success": True,
            "data": result
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )