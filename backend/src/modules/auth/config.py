from pathlib import Path
from pydantic_settings import BaseSettings
from pydantic import ConfigDict, Field

class Settings(BaseSettings):
    # Теперь SECRET_KEY будет подтягиваться из .env. 
    # Если ключа там нет, Pydantic выдаст ошибку при запуске.
    SECRET_KEY: str = Field(description="Secure random string for JWT")
    ALGORITHM: str = "HS256"

    # Конфигурация времени жизни токенов
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    RESET_TOKEN_EXPIRE_MINUTES: int = 15
    VERIFY_TOKEN_EXPIRE_HOURS: int = 24

    # База данных
    DB_NAME: str = "auth.db"

    @property
    def DATABASE_URL(self) -> str:
        base_dir = Path(__file__).resolve().parent
        return f"sqlite+aiosqlite:///{base_dir}/{self.DB_NAME}"

    # Указываем Pydantic искать файл .env в корне проекта
    model_config = ConfigDict(env_file=".env", case_sensitive=True)

settings = Settings()