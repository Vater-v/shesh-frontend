import uvicorn
from fastapi import FastAPI

app = FastAPI(title="Shesh Backend")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=5006, reload=True)