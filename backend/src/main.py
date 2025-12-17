# backend/src/main.py
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

app = FastAPI(title="Shesh Backend")

# --- Настройка путей ---
# Определяем путь к корню проекта (backend) относительно текущего файла (backend/src/main.py)
BASE_DIR = Path(__file__).resolve().parent.parent
PUBLIC_DIR = BASE_DIR / "public"

# --- Монтирование статики ---
# index.html запрашивает ресурсы по путям "css/..." и "js/..."
# Поэтому мы монтируем соответствующие папки из public
app.mount("/css", StaticFiles(directory=PUBLIC_DIR / "css"), name="css")

# Если/когда вы добавите JS файлы в backend/public/js:
# app.mount("/js", StaticFiles(directory=PUBLIC_DIR / "js"), name="js")

# --- Главный роут ---
@app.get("/")
async def read_index():
    # Возвращаем сам файл index.html
    return FileResponse(PUBLIC_DIR / "index.html")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=5006, reload=True)