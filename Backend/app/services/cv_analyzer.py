import json
import fitz
from io import BytesIO
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY") or "sk-not-configured")
MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def extract_pdf_text(file_bytes: bytes) -> str:
    text = ""
    pdf = fitz.open(stream=BytesIO(file_bytes), filetype="pdf")
    for page in pdf:
        text += page.get_text()
    pdf.close()
    return text


def analyze_cv(file_bytes: bytes) -> dict:
    text = extract_pdf_text(file_bytes)
    text = text[:12000]

    if len(text.strip()) == 0:
        return {"error": "No se pudo extraer texto del PDF."}

    # ── LLAMADA 1: Extracción de datos del CV ─────────────────────────────
    extraction_prompt = f"""
Extrae la información del siguiente CV. Devuelve SOLO un JSON válido.

REGLAS:
- NO inventes datos. Si no existe en el CV, usa null o [].
- Nunca omitas campos. Si no hay dato, pon null.

SCHEMA OBLIGATORIO:
{{
  "nombre": null,
  "apellido": null,
  "correo": null,
  "telefono": null,
  "linkedin": null,
  "github": null,
  "profesion": null,
  "años_experiencia_total": null,
  "resumen_perfil": null,

  "educacion": [
    {{
      "institucion": null,
      "carrera": null,
      "nivel": null,
      "estado": null,
      "ciclo_actual": null,
      "año_egreso": null
    }}
  ],

  "experiencia_laboral": [
    {{
      "empresa": null,
      "cargo": null,
      "area": null,
      "fecha_inicio": null,
      "fecha_fin": null,
      "duracion": null,
      "logros_principales": [],
      "tecnologias_usadas": []
    }}
  ],

  "habilidades_tecnicas": [
    {{
      "categoria": null,
      "habilidad": null,
      "nivel_autopercibido": null
    }}
  ],

  "idiomas": [
    {{
      "idioma": null,
      "nivel": null
    }}
  ],

  "certificaciones": [
    {{
      "nombre": null,
      "entidad": null,
      "año": null,
      "vigente": null
    }}
  ],

  "proyectos_destacados": [
    {{
      "nombre": null,
      "descripcion": null,
      "tecnologias": [],
      "url": null
    }}
  ]
}}

ACLARACIONES:
- educacion[].nivel              → "Técnico" | "Universitario" | "Maestría" | "Doctorado" | null
- educacion[].estado             → "En curso" | "Egresado" | "Titulado" | "Abandonado" | null
- educacion[].ciclo_actual       → Solo si está en curso (ej: "3er ciclo"). Si egresó → null
- educacion[].año_egreso         → Solo si ya terminó. Si está en curso → null
- experiencia_laboral[].empresa  → Si no figura el nombre, pon null. NO inventes.
- experiencia_laboral[].duracion → Calcula desde fechas (ej: "1 año 3 meses"). Si no hay → null
- experiencia_laboral[].logros_principales  → Logros concretos del CV. Si no hay → []
- experiencia_laboral[].tecnologias_usadas  → Tecnologías mencionadas en esa experiencia. Si no hay → []
- habilidades_tecnicas[].categoria          → "Lenguajes" | "Frameworks" | "Bases de Datos" | "Cloud" | "Herramientas" | "Redes" | "Hardware" | "Otros"
- habilidades_tecnicas[].nivel_autopercibido → Solo si el CV lo indica: "Básico" | "Intermedio" | "Avanzado" | null
- años_experiencia_total         → Suma total estimada (ej: "1 año 2 meses"). Si no se puede calcular → null
- proyectos_destacados           → Si no hay proyectos en el CV, devuelve []
- certificaciones[].vigente      → true si es reciente o no expira | false si es antigua | null si no se sabe

CV:
{text}
"""

    extraction_response = client.chat.completions.create(
        model=MODEL,
        temperature=0.1,
        messages=[
            {
                "role": "system",
                "content": (
                    "Extraes datos de CVs con precisión. "
                    "Respondes ÚNICAMENTE con JSON válido siguiendo el schema exacto. "
                    "Nunca omites campos. Si no hay dato usas null o []."
                )
            },
            {"role": "user", "content": extraction_prompt}
        ],
        response_format={"type": "json_object"}
    )

    try:
        extracted = json.loads(extraction_response.choices[0].message.content)
    except Exception:
        return {
            "success": False,
            "message": "Error en la extracción del CV.",
            "raw_response": extraction_response.choices[0].message.content
        }

    # ── LLAMADA 2: Evaluación para entrevista ─────────────────────────────
    evaluation_prompt = f"""
Eres un reclutador senior. Con los datos extraídos del CV, realiza una evaluación
completa para preparar una entrevista de trabajo.

DATOS DEL CANDIDATO:
{json.dumps(extracted, ensure_ascii=False, indent=2)}

Devuelve SOLO un JSON válido con esta estructura exacta:

{{
  "evaluacion_entrevistador": {{
    "puntos_fuertes": [],
    "puntos_debiles": [],
    "preguntas_sugeridas": [],
    "alertas": [],
    "cargo_ideal": null,
    "nivel_seniority": null,
    "disponibilidad_indicada": null,
    "pretension_salarial": null
  }},
  "score_general": null,
  "ats_score": null,
  "faltantes_importantes": [
    {{
      "seccion": null,
      "campo": null,
      "impacto": null,
      "sugerencia": null
    }}
  ]
}}

INSTRUCCIONES — completa TODOS los campos sin excepción:

puntos_fuertes (mínimo 3)
→ Aspectos positivos concretos del perfil.
  Ej: "Certificación AWS válida para roles cloud", "Experiencia práctica con Vue.js y PHP"

puntos_debiles (mínimo 3)
→ Brechas o debilidades reales detectadas en el CV.
  Ej: "No menciona nombre de empresas", "Sin proyectos personales documentados"

preguntas_sugeridas (exactamente 5)
→ Preguntas específicas para este candidato, basadas en su perfil real.
  Formato: "¿[pregunta]?"
  NO uses preguntas genéricas.

alertas
→ Red flags detectados.
  Ej: "Empresa no especificada en ambas experiencias", "Gap laboral sin explicación"
  Si no hay alertas reales → []

cargo_ideal
→ Puesto más adecuado para su perfil. Sé específico.
  Ej: "Desarrollador Web Junior (PHP/Vue.js)"

nivel_seniority → "Junior" | "Semi-Senior" | "Senior"

disponibilidad_indicada → Si el CV lo menciona. Si no → null
pretension_salarial     → Si el CV lo menciona. Si no → null

score_general (0-100)
→ Evalúa: completitud, claridad, logros documentados, habilidades relevantes, certificaciones.

ats_score (0-100)
→ Evalúa: palabras clave, formato limpio, secciones estándar, ausencia de tablas/columnas complejas.

faltantes_importantes
→ Lista DETALLADA de todo lo que falta o debería mejorar. Revisa cada sección:

  DATOS PERSONALES : ¿Falta github, dirección, pretensión salarial?
  PERFIL           : ¿Falta resumen profesional?
  EDUCACIÓN        : ¿Faltan fechas, año de egreso esperado, especialización?
  EXPERIENCIA      : ¿Falta nombre de empresa, logros con métricas, tecnologías?
  HABILIDADES      : ¿Le faltan skills relevantes para su perfil?
                     (ej: dev web sin Docker, testing, TypeScript, CI/CD)
  PROYECTOS        : ¿No tiene proyectos personales documentados con URL o descripción?
  CERTIFICACIONES  : ¿Le faltan certs relevantes para su área o faltan fechas/entidad?
  IDIOMAS          : ¿Solo habla español siendo perfil tech? ¿Falta nivel de inglés?
  ATS              : ¿Le faltan palabras clave importantes para su sector?

  Cada faltante debe tener:
  - seccion   → Sección del CV afectada (ej: "Experiencia", "Idiomas")
  - campo     → Qué dato específico falta (ej: "Nombre de empresa", "Nivel de inglés")
  - impacto   → "Alto" | "Medio" | "Bajo"
  - sugerencia → Recomendación concreta y accionable para el candidato
"""

    evaluation_response = client.chat.completions.create(
        model=MODEL,
        temperature=0.2,
        messages=[
            {
                "role": "system",
                "content": (
                    "Eres un reclutador senior experto en evaluación de perfiles. "
                    "Evalúas CVs con criterio real y detallado. "
                    "Respondes ÚNICAMENTE con JSON válido. "
                    "Nunca dejes arrays vacíos si hay información para completarlos."
                )
            },
            {"role": "user", "content": evaluation_prompt}
        ],
        response_format={"type": "json_object"}
    )

    try:
        evaluation = json.loads(evaluation_response.choices[0].message.content)
    except Exception:
        return {
            "success": False,
            "message": "Error en la evaluación del CV.",
            "raw_response": evaluation_response.choices[0].message.content
        }

    # ── Combinar y normalizar ─────────────────────────────────────────────
    result = {**extracted, **evaluation}
    result = normalize_cv_response(result)
    return result


def normalize_cv_response(data: dict) -> dict:

    # Campos raíz
    root_fields = [
        "nombre", "apellido", "correo", "telefono", "linkedin", "github",
        "profesion", "años_experiencia_total", "resumen_perfil",
        "score_general", "ats_score"
    ]
    for f in root_fields:
        if f not in data:
            data[f] = None

    # Educacion
    edu_fields = ["institucion", "carrera", "nivel", "estado", "ciclo_actual", "año_egreso"]
    data["educacion"] = [
        {f: item.get(f) for f in edu_fields}
        for item in (data.get("educacion") or [])
    ]

    # Experiencia laboral
    exp_fields = ["empresa", "cargo", "area", "fecha_inicio", "fecha_fin", "duracion"]
    data["experiencia_laboral"] = [
        {
            **{f: item.get(f) for f in exp_fields},
            "logros_principales": item.get("logros_principales") or [],
            "tecnologias_usadas": item.get("tecnologias_usadas") or []
        }
        for item in (data.get("experiencia_laboral") or [])
    ]

    # Habilidades técnicas
    skill_fields = ["categoria", "habilidad", "nivel_autopercibido"]
    data["habilidades_tecnicas"] = [
        {f: item.get(f) for f in skill_fields}
        for item in (data.get("habilidades_tecnicas") or [])
    ]

    # Idiomas
    data["idiomas"] = [
        {"idioma": i.get("idioma"), "nivel": i.get("nivel")}
        for i in (data.get("idiomas") or [])
    ]

    # Certificaciones
    cert_fields = ["nombre", "entidad", "año", "vigente"]
    data["certificaciones"] = [
        {f: item.get(f) for f in cert_fields}
        for item in (data.get("certificaciones") or [])
    ]

    # Proyectos destacados (filtra objetos completamente vacíos)
    data["proyectos_destacados"] = [
        {
            "nombre":      item.get("nombre"),
            "descripcion": item.get("descripcion"),
            "tecnologias": item.get("tecnologias") or [],
            "url":         item.get("url")
        }
        for item in (data.get("proyectos_destacados") or [])
        if any([item.get("nombre"), item.get("descripcion"), item.get("url")])
    ]

    # Evaluacion entrevistador
    ev = data.get("evaluacion_entrevistador") or {}
    data["evaluacion_entrevistador"] = {
        "puntos_fuertes":        ev.get("puntos_fuertes") or [],
        "puntos_debiles":        ev.get("puntos_debiles") or [],
        "preguntas_sugeridas":   ev.get("preguntas_sugeridas") or [],
        "alertas":               ev.get("alertas") or [],
        "cargo_ideal":           ev.get("cargo_ideal"),
        "nivel_seniority":       ev.get("nivel_seniority"),
        "disponibilidad_indicada": ev.get("disponibilidad_indicada"),
        "pretension_salarial":   ev.get("pretension_salarial")
    }

    # Faltantes importantes
    faltantes_fields = ["seccion", "campo", "impacto", "sugerencia"]
    data["faltantes_importantes"] = [
        {f: item.get(f) for f in faltantes_fields}
        for item in (data.get("faltantes_importantes") or [])
        if isinstance(item, dict) and any(item.get(f) for f in faltantes_fields)
    ]

    return data