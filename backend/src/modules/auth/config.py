from pathlib import Path
from pydantic_settings import BaseSettings
from pydantic import ConfigDict

class Settings(BaseSettings):
    # Security (Change these in production)
    SECRET_KEY: str = "CHANGE_THIS_TO_A_SECURE_RANDOM_STRING"
    ALGORITHM: str = "HS256"

    # Expiration Config
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    RESET_TOKEN_EXPIRE_MINUTES: int = 15
    VERIFY_TOKEN_EXPIRE_HOURS: int = 24

    # Database
    DB_NAME: str = "auth.db"

    @property
    def DATABASE_URL(self) -> str:
        # Dynamically resolves to the absolute path of auth/auth.db
        base_dir = Path(__file__).resolve().parent
        return f"sqlite+aiosqlite:///{base_dir}/{self.DB_NAME}"

    model_config = ConfigDict(env_file=".env", case_sensitive=True)

settings = Settings()

