import json
import os
import tempfile
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def transcribe_audio(audio_bytes: bytes, audio_ext: str = "mp3") -> dict:
    """Transcribe el audio con Whisper."""
    with tempfile.NamedTemporaryFile(suffix=f".{audio_ext}", delete=False) as audio_file:
        audio_file.write(audio_bytes)
        audio_path = audio_file.name

    try:
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
                    "inicio": round(seg.get("start", 0), 1),
                    "fin": round(seg.get("end", 0), 1),
                    "texto": seg.get("text", "").strip()
                })

        return {
            "transcripcion_completa": response.text.strip(),
            "segmentos": segments,
            "duracion_segundos": segments[-1]["fin"] if segments else None
        }
    finally:
        if os.path.exists(audio_path):
            os.remove(audio_path)


def analyze_presentation(transcripcion: str, duracion_segundos: float | None) -> dict:
    """Analiza el discurso del candidato."""

    duracion_info = (
        f"{round(duracion_segundos / 60, 1)} minutos"
        if duracion_segundos else "desconocida"
    )

    prompt = f"""
Eres un evaluador experto en comunicación profesional.
Analiza la siguiente transcripción de un candidato presentándose.

DURACIÓN: {duracion_info}

TRANSCRIPCIÓN:
{transcripcion}

Devuelve SOLO un JSON válido con esta estructura:

{{
  "resumen_general": "",
  "evaluacion_discurso": {{
    "claridad": {{ "puntaje": 0, "observacion": "" }},
    "estructura": {{ "puntaje": 0, "observacion": "" }},
    "vocabulario": {{ "puntaje": 0, "observacion": "" }},
    "confianza": {{ "puntaje": 0, "observacion": "" }},
    "fluidez": {{ "puntaje": 0, "observacion": "" }},
    "puntaje_total": 0
  }},
  "palabras_clave_tecnicas": [],
  "fortalezas_comunicacion": [],
  "areas_de_mejora": [],
  "recomendaciones": [],
  "apto_para_entrevista": true,
  "nivel_comunicacion": "Intermedio"
}}

INSTRUCCIONES:

- resumen_general: Resumen breve de qué habló (2-3 oraciones)
- evaluacion_discurso: Califica cada dimensión del 1 al 10
  - claridad: ¿Se entiende bien?
  - estructura: ¿Tiene intro, desarrollo, cierre?
  - vocabulario: ¿Usa términos apropiados?
  - confianza: ¿Suena seguro?
  - fluidez: ¿Habla con naturalidad?
  - puntaje_total: Promedio de los 5 anteriores (0-100)
- palabras_clave_tecnicas: Lista de términos técnicos mencionados (tecnologías, metodologías, herramientas)
- fortalezas_comunicacion: Mínimo 2 aspectos positivos
- areas_de_mejora: Mínimo 2 aspectos a mejorar
- recomendaciones: Mínimo 3 consejos accionables
- apto_para_entrevista: true/false según su nivel de comunicación
- nivel_comunicacion: "Básico", "Intermedio" o "Avanzado"
"""

    response = client.chat.completions.create(
        model=MODEL,
        temperature=0.2,
        messages=[
            {
                "role": "system",
                "content": "Eres un evaluador experto. Respondes ÚNICAMENTE con JSON válido."
            },
            {"role": "user", "content": prompt}
        ],
        response_format={"type": "json_object"}
    )

    try:
        return json.loads(response.choices[0].message.content)
    except Exception:
        return {
            "error": "No se pudo analizar la transcripción.",
            "raw": response.choices[0].message.content
        }


def analyze_audio_presentation(audio_bytes: bytes, audio_ext: str = "mp3") -> dict:
    """Pipeline completo: audio → transcripción → análisis."""

    # Paso 1: Transcribir
    try:
        transcription_data = transcribe_audio(audio_bytes, audio_ext)
    except Exception as e:
        return {"error": f"No se pudo transcribir el audio: {str(e)}"}

    if not transcription_data.get("transcripcion_completa"):
        return {"error": "El audio no contiene voz detectable."}

    # Paso 2: Analizar
    analysis = analyze_presentation(
        transcripcion=transcription_data["transcripcion_completa"],
        duracion_segundos=transcription_data.get("duracion_segundos")
    )

    return {
        "transcripcion": transcription_data,
        "analisis": analysis
    }
