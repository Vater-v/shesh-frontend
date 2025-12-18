# backend/src/main.py
import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

# --- Импорты модуля Auth ---
# Предполагается, что папка modules лежит рядом с main.py
from modules.auth.router import router as auth_router
from modules.auth.database import init_db

# --- Настройка путей ---
BASE_DIR = Path(__file__).resolve().parent.parent
PUBLIC_DIR = BASE_DIR / "public"

# --- Lifespan (События жизненного цикла) ---
# Эта функция запустится перед стартом приложения и создаст таблицы БД
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Создаем таблицы (users, sessions), если их нет
    await init_db()
    yield
    # Здесь можно добавить логику закрытия соединений при остановке сервера (если нужно)

# --- Инициализация приложения ---
app = FastAPI(title="Shesh Backend", lifespan=lifespan)

# --- Подключение роутеров ---
app.include_router(auth_router)

# --- Монтирование статики ---
app.mount("/css", StaticFiles(directory=PUBLIC_DIR / "css"), name="css")
app.mount("/js", StaticFiles(directory=PUBLIC_DIR / "js"), name="js")

@app.get("/register")
@app.get("/register.html")
async def read_register():
    return FileResponse(PUBLIC_DIR / "register.html")

@app.get("/login")
@app.get("/login.html")
async def read_login():
    return FileResponse(PUBLIC_DIR / "login.html")

# --- Главный роут ---
@app.get("/")
async def read_index():
    return FileResponse(PUBLIC_DIR / "index.html")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=5006, reload=True)