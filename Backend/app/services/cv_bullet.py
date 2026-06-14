"""Generacion de un bullet de CV profesional a partir de una evidencia (STAR).

Usa OpenAI si esta disponible; si falla o tarda, cae a un template limpio.
Nunca lanza excepcion: el onboarding no debe romperse por esto.
"""
import os

from dotenv import load_dotenv

load_dotenv()

_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")


def _clean(value: str) -> str:
    return (value or "").strip().rstrip(".")


def _fallback_bullet(title: str, actions: str, result: str) -> str:
    """Template decente cuando no hay IA (mejor que concatenar crudo)."""
    actions = _clean(actions)
    result = _clean(result)
    title = _clean(title)

    parts = []
    if actions:
        parts.append(actions)
    if result:
        parts.append(f"logrando {result}")
    body = ", ".join(parts) if parts else "desarrolle una experiencia relevante"
    body = body[0].upper() + body[1:]
    return f"{title}: {body}." if title else f"{body}."


def generate_cv_bullet(
    title: str = "",
    context: str = "",
    actions: str = "",
    result: str = "",
    skills: list[str] | None = None,
) -> str:
    skills = skills or []
    if not (_clean(actions) or _clean(result) or _clean(title)):
        return "Evidencia inicial registrada."

    try:
        from openai import OpenAI

        client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"), timeout=12.0)
        prompt = (
            "Redacta UN bullet de CV profesional en espanol, en una sola linea (max 28 palabras), "
            "en pasado, orientado a logro y con metricas si aparecen. No inventes datos ni agregues "
            "habilidades que no esten. Devuelve SOLO el bullet, sin comillas ni vinetas.\n\n"
            f"Titulo: {title}\nContexto: {context}\nAcciones: {actions}\nResultado: {result}\n"
            f"Habilidades: {', '.join(skills)}"
        )
        response = client.chat.completions.create(
            model=_MODEL,
            temperature=0.4,
            messages=[
                {"role": "system", "content": "Eres un experto en redaccion de CV para practicantes universitarios."},
                {"role": "user", "content": prompt},
            ],
        )
        bullet = (response.choices[0].message.content or "").strip()
        bullet = bullet.strip('"').lstrip("-•").strip()
        return bullet or _fallback_bullet(title, actions, result)
    except Exception:
        return _fallback_bullet(title, actions, result)
