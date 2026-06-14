import json
import fitz
from io import BytesIO
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY")
)

MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def extract_pdf_text(file_bytes: bytes):

    text = ""

    pdf = fitz.open(stream=BytesIO(file_bytes), filetype="pdf")

    for page in pdf:
        text += page.get_text()

    pdf.close()

    return text


def analyze_cv(file_bytes: bytes):

    text = extract_pdf_text(file_bytes)
    # Evita enviar demasiados tokens
    text = text[:12000]

    if len(text.strip()) == 0:
        return {
            "error": "No se pudo extraer texto del PDF."
        }

    prompt = f"""
Eres un reclutador senior especializado en perfiles profesionales.

Analiza el siguiente CV.

Extrae TODA la información disponible.

Devuelve EXCLUSIVAMENTE un JSON válido con esta estructura:

{{
    "nombre": "",
    "apellido": "",
    "edad": "",
    "correo": "",
    "telefono": "",
    "linkedin": "",
    "github": "",
    "direccion": "",
    "profesion": "",
    "resumen": "",
    "educacion": [],
    "experiencia": [],
    "certificaciones": [],
    "idiomas": [],
    "skills_tecnicas": [],
    "skills_blandas": [],
    "fortalezas": [],
    "faltantes": [],
    "recomendaciones": [],
    "score": 0,
    "ats_score": 0
}}

Reglas:

- No inventes información.
- Si un dato no existe usa null o [].
- El score debe ser entre 0 y 100.
- Evalúa si el CV es ATS Friendly.
- Detecta información faltante.
- Sugiere habilidades o mejoras.
- Responde únicamente JSON.

CV:

{text}
"""

    response = client.chat.completions.create(
        model=MODEL,
        temperature=0.2,
        messages=[
            {
                "role": "system",
                "content": "Eres un experto en reclutamiento y análisis de CV."
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        response_format={
            "type": "json_object"
        }
    )

    content = response.choices[0].message.content

    try:
        return json.loads(content)
    except Exception:
        return {
            "success": False,
            "message": "La IA devolvió una respuesta inválida.",
            "raw_response": content
        }
    