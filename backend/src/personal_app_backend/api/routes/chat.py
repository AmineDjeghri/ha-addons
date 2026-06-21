from fastapi import APIRouter
from pydantic import BaseModel


router = APIRouter()


class ChatResponse(BaseModel):
    response: str


@router.post("/api/hello")
async def post_hello_message():
    return ChatResponse(response="hello")
