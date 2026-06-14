from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Despega UTP API"
    app_env: str = "local"

    # Conexión DB — accesible tanto en minúsculas (app/api/ con psycopg v3)
    # como en mayúsculas (app/db/session.py con SQLAlchemy)
    database_url: str = "postgresql://postgres:postgres@localhost:5432/despega_utp"

    # Ruta a archivos de configuración JSON
    DATA_CONFIG_PATH: str = "../data-config"

    # CORS — lista separada por comas
    cors_origins: str = "http://localhost:4200,http://localhost:5173"
    # Opcional: sin key el backend arranca igual; solo las funciones de IA
    # (análisis de CV y coach de pitch) quedan deshabilitadas.
    openai_api_key: str = ""
    openai_model: str = "gpt-4o-mini"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    @property
    def DATABASE_URL(self) -> str:
        """Alias en mayúsculas para compatibilidad con app/db/session.py (SQLAlchemy)."""
        return self.database_url

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


# Instancia global — compatible con `from app.core.config import settings`
settings = get_settings()
