from uuid import UUID

import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from pony.orm.core import TransactionIntegrityError
from starlette.responses import RedirectResponse

from app.db import dal
from app.models import User

app = FastAPI(title="Vibeeng", description="Vibeeng FastAPI Application")

load_dotenv()


@app.get("/user/{uuid}")
async def get_user(uuid: UUID):
    return dal.get_user(uuid)


@app.post("/user")
async def create_user(user: User):
    try:
        return dal.create_user(user.username, user.password)
    except TransactionIntegrityError:
        raise HTTPException(status_code=403, detail="Username already exists.")


@app.get("/")
async def index_route():
    return RedirectResponse(url="/index.html")


app.mount("/", StaticFiles(directory="app/build"), name="static")
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
