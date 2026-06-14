from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
import tempfile
import os
import json
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

router = APIRouter()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY") or "sk-not-configured")
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

ALLOWED_EXTENSIONS = {"mp3", "wav", "m4a", "ogg", "webm"}
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

    # Transcripcion con OpenAI Whisper.
    audio_path = None
    try:
        with tempfile.NamedTemporaryFile(suffix=f".{ext}", delete=False) as audio_file:
            audio_file.write(audio_bytes)
            audio_path = audio_file.name
        with open(audio_path, "rb") as f:
            response = client.audio.transcriptions.create(
                model="whisper-1",
                file=f,
                language="es",
                prompt="Pitch de presentacion profesional de un estudiante: nombre, carrera, habilidades, propuesta de valor y experiencia.",
                response_format="json",
                temperature=0,
            )
        transcripcion = response.text.strip()
        segments = []
        duracion = 0
        os.remove(audio_path)
        audio_path = None

    except Exception as e:
        if audio_path and os.path.exists(audio_path):
            os.remove(audio_path)
        raise HTTPException(status_code=500, detail=f"Error transcribiendo: {str(e)}")

    if not transcripcion:
        raise HTTPException(status_code=422, detail="El audio no contiene voz detectable.")

    # Analizar con GPT
    try:
        prompt = f"""
Eres coach de empleabilidad de la Ruta Laboral UTP. Evalua el pitch de presentacion profesional (elevator pitch, ~1 min) de un estudiante.

TRANSCRIPCIÓN:
{transcripcion}

Marco UTP (referencia para evaluar):
- Elevator pitch: presentacion (nombre, carrera, especialidad) -> propuesta de valor (que ofreces) -> problema/necesidad que atiendes -> solucion/aporte (idealmente con un ejemplo concreto en formato STAR: situacion, tarea, accion, resultado) -> beneficios (impacto medible) -> por que tu (que te diferencia) -> llamado a la accion.
- Propuesta de valor = quien soy + que ofrezco + que impacto genero.

Devuelve SOLO JSON con esta estructura exacta:
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
  "estructura_pitch": {{
    "presentacion": false,
    "propuesta_valor": false,
    "problema_o_necesidad": false,
    "solucion_o_aporte": false,
    "beneficios": false,
    "por_que_tu": false,
    "llamado_a_accion": false
  }},
  "palabras_clave_tecnicas": [],
  "fortalezas_comunicacion": [],
  "areas_de_mejora": [],
  "recomendaciones": [],
  "apto_para_entrevista": true,
  "nivel_comunicacion": "Intermedio"
}}

Reglas:
- evaluacion_discurso: califica cada dimension de 1 a 10 (1-3 deficiente, 4-6 regular, 7-8 bueno, 9-10 excelente) con una observacion breve y ESPECIFICA al pitch.
- estructura_pitch: marca true/false segun el pitch incluya REALMENTE cada elemento (basate solo en lo dicho, no asumas).
- fortalezas_comunicacion y areas_de_mejora: especificas al contenido del pitch, no genericas.
- recomendaciones: acciones concretas y accionables; prioriza los elementos del elevator pitch que falten y como comunicar mejor la propuesta de valor.
- resumen_general: 1-2 frases constructivas y motivadoras.
- nivel_comunicacion: "Basico", "Intermedio" o "Avanzado".
- No inventes datos que no esten en la transcripcion.
"""

        gpt_response = client.chat.completions.create(
            model=MODEL,
            temperature=0.2,
            messages=[
                {"role": "system", "content": "Eres un coach de empleabilidad de la Ruta Laboral UTP, experto en elevator pitch y propuesta de valor profesional. Respondes SOLO con JSON valido."},
                {"role": "user", "content": prompt}
            ],
            response_format={"type": "json_object"}
        )

        analisis = json.loads(gpt_response.choices[0].message.content)

        # puntaje_total determinista: promedio de las 5 dimensiones (1-10) escalado a 0-100.
        ev = analisis.get("evaluacion_discurso", {})
        dims = [
            ev.get(k, {}).get("puntaje")
            for k in ("claridad", "estructura", "vocabulario", "confianza", "fluidez")
        ]
        dims = [d for d in dims if isinstance(d, (int, float))]
        if dims:
            ev["puntaje_total"] = round(sum(dims) / len(dims) * 10)
            analisis["evaluacion_discurso"] = ev

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
