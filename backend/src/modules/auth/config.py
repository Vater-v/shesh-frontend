from pathlib import Path
from pydantic_settings import BaseSettings
from pydantic import ConfigDict, Field

# Определяем путь к папке, в которой находится этот файл (backend/src/modules/auth/)
CURRENT_DIR = Path(__file__).resolve().parent

class Settings(BaseSettings):
    # Теперь SECRET_KEY будет подтягиваться из .env по абсолютному пути. 
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
        # Используем заранее вычисленный CURRENT_DIR
        return f"sqlite+aiosqlite:///{CURRENT_DIR}/{self.DB_NAME}"

    # Указываем Pydantic искать файл .env именно в папке модуля auth
    model_config = ConfigDict(
        env_file=CURRENT_DIR / ".env", 
        case_sensitive=True
    )

settings = Settings()