from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/despega_utp"
    DATA_CONFIG_PATH: str = "../data-config"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
