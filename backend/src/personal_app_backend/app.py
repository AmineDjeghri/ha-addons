import uvicorn
from fastapi import FastAPI
from fastapi import APIRouter
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from starlette.requests import Request
import os

from fastapi.responses import Response

from contextlib import asynccontextmanager

from personal_app_backend.api.routes import metrics
from personal_app_backend.api.routes.metrics import record_request
from personal_app_backend.backend_settings import settings, logger


@asynccontextmanager
async def lifespan(app: FastAPI):
    """This function is called when the server starts."""
    # Startup logic
    logger.info("Application startup: Initializing resources concurrently...")

    yield
    # Shutdown logic
    logger.info("Application shutdown.")


app = FastAPI(lifespan=lifespan)


# Add CORS middleware to allow requests from the frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_middleware(
    SessionMiddleware,
    secret_key=os.environ.get("SESSION_SECRET", "change_this_secret"),
    session_cookie="personal_app_session",
    https_only=False,  # Set to True in production with HTTPS
)


@app.middleware("http")
async def track_requests(request: Request, call_next):
    response = await call_next(request)
    record_request(response.status_code)
    return response


router = APIRouter()


# Root endpoint for "/"
@app.get("/")
async def root_index():
    return {"message": f"Personal App backend is running. Swagger UI available at /docs"}


# Endpoint for favicon.ico to avoid 404
@app.get("/favicon.ico")
async def favicon():
    return Response(content=b"", media_type="image/x-icon")


@router.get("/api/")
async def root():
    return {"message": f"API is running."}


app.include_router(router, prefix="/api", tags=["root"])
app.include_router(metrics.router, tags=["metrics"])


if __name__ == "__main__":
    uvicorn.run(
        f"app:app",
        port=int(settings.BACKEND_PORT),
        host=settings.BACKEND_HOST,
        reload=settings.logging_level == "DEBUG",
    )
