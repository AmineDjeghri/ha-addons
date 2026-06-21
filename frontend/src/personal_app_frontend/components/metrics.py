import asyncio
import datetime

import requests
from nicegui import ui

from personal_app_frontend.frontend_settings import settings, logger


class Metrics:
    def __init__(self):
        self._data: dict = {}
        self._render_fn = None
        self._last_updated: str = "Never"

    def _fetch(self) -> dict | None:
        try:
            response = requests.get(f"{settings.BACKEND_URL}/api/metrics/summary", timeout=3)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            logger.error(f"Could not fetch metrics: {e}")
            return None

    async def _refresh(self):
        data = await asyncio.to_thread(self._fetch)
        if data:
            self._data = data
            self._last_updated = datetime.datetime.now().strftime("%H:%M:%S")
        self._render_fn.refresh()

    @staticmethod
    def _format_uptime(seconds: float) -> str:
        h = int(seconds // 3600)
        m = int((seconds % 3600) // 60)
        s = int(seconds % 60)
        parts = []
        if h:
            parts.append(f"{h}h")
        if m or h:
            parts.append(f"{m}m")
        parts.append(f"{s}s")
        return " ".join(parts)

    def build(self):
        with ui.column().classes("w-full max-w-2xl mx-auto gap-4"):
            with ui.row().classes("w-full items-center justify-between"):
                ui.label("System Metrics").classes("text-h6 text-weight-bold")
                ui.button(icon="refresh", on_click=self._refresh).props(
                    "flat round dense color=primary"
                )

            @ui.refreshable
            def render_metrics():
                if not self._data:
                    with ui.card().classes("w-full"):
                        with ui.row().classes("items-center gap-2 q-pa-sm"):
                            ui.spinner(size="sm")
                            ui.label("Fetching metrics...").classes("text-grey-6")
                    return

                d = self._data
                is_ok = d.get("status") == "ok"

                # ── Status bar ────────────────────────────────────────────────
                with ui.card().classes("w-full"):
                    with ui.row().classes("items-center gap-4 q-pa-sm flex-wrap"):
                        ui.badge(
                            "● Online" if is_ok else "● Offline",
                            color="green" if is_ok else "red",
                        ).props("rounded")
                        ui.label(
                            f"Uptime: {self._format_uptime(d.get('uptime_seconds', 0))}"
                        ).classes("text-body2")
                        ui.space()
                        ui.label(f"Updated: {self._last_updated}").classes(
                            "text-caption text-grey-6"
                        )

                # ── Resources ─────────────────────────────────────────────────
                with ui.card().classes("w-full q-pa-sm"):
                    ui.label("Resources").classes("text-subtitle2 text-weight-bold q-mb-sm")
                    with ui.column().classes("w-full gap-3"):
                        cpu = d.get("cpu_percent", 0.0)
                        cpu_color = "red-5" if cpu > 80 else "orange-5" if cpu > 50 else "blue-5"
                        with ui.row().classes("w-full items-center gap-2"):
                            ui.label("CPU").classes("text-caption w-16")
                            ui.linear_progress(
                                value=cpu / 100, size="12px", color=cpu_color
                            ).classes("flex-grow")
                            ui.label(f"{cpu:.1f}%").classes("text-caption w-12 text-right")

                        mem_pct = d.get("memory_percent", 0.0)
                        mem_mb = d.get("memory_used_mb", 0.0)
                        mem_color = "red-5" if mem_pct > 80 else "orange-5"
                        with ui.row().classes("w-full items-center gap-2"):
                            ui.label("Memory").classes("text-caption w-16")
                            ui.linear_progress(
                                value=mem_pct / 100, size="12px", color=mem_color
                            ).classes("flex-grow")
                            ui.label(f"{mem_mb:.0f} MB").classes("text-caption w-12 text-right")

                # ── HTTP Request counters ──────────────────────────────────────
                with ui.card().classes("w-full q-pa-sm"):
                    ui.label("HTTP Requests").classes("text-subtitle2 text-weight-bold q-mb-sm")
                    with ui.row().classes("w-full justify-around"):
                        for label, value, color in [
                            ("Total", d.get("requests_total", 0), "grey-7"),
                            ("2xx", d.get("requests_2xx", 0), "green-7"),
                            ("4xx", d.get("requests_4xx", 0), "orange-7"),
                            ("5xx", d.get("requests_5xx", 0), "red-7"),
                        ]:
                            with ui.column().classes("items-center gap-1"):
                                ui.label(str(value)).classes(
                                    f"text-h5 text-{color} text-weight-bold"
                                )
                                ui.label(label).classes("text-caption text-grey-6")

            self._render_fn = render_metrics
            render_metrics()

            ui.timer(5.0, self._refresh)
