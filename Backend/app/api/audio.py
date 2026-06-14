from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import tempfile
import os
import json
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

router = APIRouter()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

ALLOWED_EXTENSIONS = {"mp3", "wav", "m4a", "ogg"}
MAX_SIZE_MB = 25


@router.post("/audio/analyze")
async def analyze_audio(file: UploadFile = File(...)):
    """
    Analiza un audio de presentación del candidato.
    
    - Sube un archivo de audio (MP3, WAV, M4A, OGG)
    - Transcribe con Whisper de OpenAI
    - Analiza claridad, estructura, vocabulario, confianza y fluidez
    - Detecta palabras clave técnicas
    - Genera recomendaciones personalizadas
    """
    
    # Validar extensión
    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else ""
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Formato no soportado: .{ext}. Usa: mp3, wav, m4a, ogg"
        )

    # Leer audio
    audio_bytes = await file.read()
    size_mb = len(audio_bytes) / (1024 * 1024)

    if size_mb > MAX_SIZE_MB:
        raise HTTPException(
            status_code=413,
            detail=f"El audio es muy grande ({size_mb:.1f} MB). Máximo: {MAX_SIZE_MB} MB."
        )

    if len(audio_bytes) == 0:
        raise HTTPException(status_code=400, detail="El archivo está vacío.")

    # Transcribir con Whisper
    try:
        with tempfile.NamedTemporaryFile(suffix=f".{ext}", delete=False) as audio_file:
            audio_file.write(audio_bytes)
            audio_path = audio_file.name

        with open(audio_path, "rb") as f:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=f,
                language="es",
                response_format="verbose_json",
                timestamp_granularities=["segment"]
            )

        segments = []
        if hasattr(response, "segments") and response.segments:
            for seg in response.segments:
                segments.append({
                    "inicio": round(seg.start if hasattr(seg, 'start') else 0, 1),
                    "fin": round(seg.end if hasattr(seg, 'end') else 0, 1),
                    "texto": seg.text.strip() if hasattr(seg, 'text') else ""
                })

        transcripcion = response.text.strip()
        duracion = segments[-1]["fin"] if segments else 0
        
        os.remove(audio_path)
        
    except Exception as e:
        if 'audio_path' in locals() and os.path.exists(audio_path):
            os.remove(audio_path)
        raise HTTPException(status_code=500, detail=f"Error transcribiendo: {str(e)}")

    if not transcripcion:
        raise HTTPException(status_code=422, detail="El audio no contiene voz detectable.")

    # Analizar con GPT
    try:
        prompt = f"""
Analiza esta transcripción de un candidato presentándose (duración: {round(duracion/60, 1)} min).

TRANSCRIPCIÓN:
{transcripcion}

Devuelve SOLO JSON:
{{
  "resumen_general": "",
  "evaluacion_discurso": {{
    "claridad": {{"puntaje": 0, "observacion": ""}},
    "estructura": {{"puntaje": 0, "observacion": ""}},
    "vocabulario": {{"puntaje": 0, "observacion": ""}},
    "confianza": {{"puntaje": 0, "observacion": ""}},
    "fluidez": {{"puntaje": 0, "observacion": ""}},
    "puntaje_total": 0
  }},
  "palabras_clave_tecnicas": [],
  "fortalezas_comunicacion": [],
  "areas_de_mejora": [],
  "recomendaciones": [],
  "apto_para_entrevista": true,
  "nivel_comunicacion": "Intermedio"
}}

Califica del 1-10 cada dimensión. Puntaje total: promedio 0-100.
"""

        gpt_response = client.chat.completions.create(
            model=MODEL,
            temperature=0.2,
            messages=[
                {"role": "system", "content": "Eres un evaluador experto. Respondes SOLO JSON válido."},
                {"role": "user", "content": prompt}
            ],
            response_format={"type": "json_object"}
        )

        analisis = json.loads(gpt_response.choices[0].message.content)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error analizando: {str(e)}")

    return JSONResponse(content={
        "success": True,
        "data": {
            "transcripcion": {
                "transcripcion_completa": transcripcion,
                "segmentos": segments,
                "duracion_segundos": duracion
            },
            "analisis": analisis
        }
    })
