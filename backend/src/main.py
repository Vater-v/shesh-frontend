import uvicorn
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager

# Убедитесь, что эти модули доступны в вашем проекте
from app.db.session import engine, Base
from app.api.v1.endpoints.router import api_router
from app.core.config import settings

# For MVP, create tables on startup.
# In production, use Alembic.
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create DB tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    # Create photo directory if missing
    if not os.path.exists(settings.UPLOAD_DIR):
        os.makedirs(settings.UPLOAD_DIR)
        print(f"Created directory: {settings.UPLOAD_DIR}")
        
    yield

app = FastAPI(title="Android MVP Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключаем основной API
app.include_router(api_router, prefix="/api/v1")

# Подключаем раздачу статики (фотографий)
# Файлы из папки settings.UPLOAD_DIR будут доступны по URL /images/...
app.mount("/images", StaticFiles(directory=settings.UPLOAD_DIR), name="images")


if __name__ == "__main__":
    # Если файл называется main.py и лежит в корне модуля backend,
    # строка импорта может зависеть от того, как вы запускаете проект.
    # Для прямого запуска 'python main.py' часто используется "main:app".
    uvicorn.run("main:app", host="0.0.0.0", port=5006, reload=True)