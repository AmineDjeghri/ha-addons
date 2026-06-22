"""Settings and logging configuration for personal_app_backend."""

from __future__ import annotations

import ast
import sys
import timeit

from loguru import logger as _loguru_logger
from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class BaseEnvironmentSettings(BaseSettings):
    """Base settings for environment configuration."""

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


class APIEnvironmentVariables(BaseEnvironmentSettings):
    BACKEND_HOST: str = "0.0.0.0"
    BACKEND_PORT: str = "8000"


class ApplicationSettings(
    APIEnvironmentVariables,
):
    """Configuration for personal-app-backend.

    Values are read from environment variables and optionally
    overridden by a ``.env`` file.
    """

    logging_level: str = Field(
        default="DEBUG",
        validation_alias=AliasChoices("LOGGING_LEVEL", "logging_level"),
        description="Log level (TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL)",
    )

    def model_post_init(self, __context):
        """Called after model initialization."""
        pass


def _initialize_logger(settings: ApplicationSettings):
    """Initialize the loguru logger with app-specific configuration."""
    level = settings.logging_level

    try:
        _loguru_logger.remove(0)
    except ValueError:
        pass

    _loguru_logger.add(
        sys.stderr,
        level=level,
        filter=lambda record: record["extra"].get("name") == "personal-app-backend",
    )

    return _loguru_logger.bind(name="personal-app-backend")


def safe_eval(x):
    try:
        return ast.literal_eval(x)
    except:
        return []


def time_function(func):
    def wrapper(*args, **kwargs):
        start_time = timeit.default_timer()
        result = func(*args, **kwargs)

        end_time = timeit.default_timer()
        execution_time = round(end_time - start_time, 2)

        logger.debug(f"Function {func.__name__} took {execution_time} seconds to execute.")

        return result

    return wrapper


settings = ApplicationSettings()
logger = _initialize_logger(settings)
