# main.py
import uvicorn
from fastapi import FastAPI
from contextlib import asynccontextmanager
from auth.database import init_db
from auth.router import router as auth_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialise the DB on startup
    await init_db()
    yield

app = FastAPI(lifespan=lifespan)

app.include_router(auth_router)

if __name__ == "__main__":
    # Access docs at http://127.0.0.1:8000/docs
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)
