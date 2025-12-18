import uvicorn
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path

from modules.auth.router import router as auth_router
from modules.auth.database import init_db
# Пути к папкам
BASE_DIR = Path(__file__).resolve().parent
PUBLIC_DIR = BASE_DIR.parent / "public"

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Инициализация БД при старте приложения
    await init_db()
    yield

app = FastAPI(title="SHESH SYSTEM", lifespan=lifespan)

# --- CORS (Разрешаем запросы с браузера) ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # В реальном проде укажите конкретный домен, например ["https://shesh.io"]
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Подключение API ---
app.include_router(auth_router)

# --- Раздача статики (CSS, JS) ---
app.mount("/css", StaticFiles(directory=PUBLIC_DIR / "css"), name="css")
app.mount("/js", StaticFiles(directory=PUBLIC_DIR / "js"), name="js")

# --- HTML Страницы ---
@app.get("/")
async def read_index():
    return FileResponse(PUBLIC_DIR / "index.html")

@app.get("/register")
@app.get("/register.html")
async def read_register():
    return FileResponse(PUBLIC_DIR / "register.html")

@app.get("/login")
@app.get("/login.html")
async def read_login():
    return FileResponse(PUBLIC_DIR / "login.html")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=5006, reload=True)