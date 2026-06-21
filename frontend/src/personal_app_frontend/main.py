"""Main entry point for the application."""

from nicegui import ui, app
from starlette.responses import FileResponse, PlainTextResponse

from personal_app_frontend.components.metrics import Metrics


@app.get("/favicon.ico")
async def favicon():
    favicon_path = "resources/images/gradwave.ico"
    return FileResponse(favicon_path)


@app.get("/robots.txt")
async def robots():
    return PlainTextResponse("User-agent: *\nDisallow:\n")


@ui.page("/")
async def metrics_page():
    with ui.column().classes("w-full min-h-screen items-center q-pa-md bg-grey-2"):
        Metrics().build()


if __name__ in {"__main__", "__mp_main__"}:
    ui.run(title="Personal App", show=False)
