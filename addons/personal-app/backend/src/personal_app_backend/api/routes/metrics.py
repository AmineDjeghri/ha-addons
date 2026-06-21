import time
from collections import defaultdict

import psutil
from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

_start_time = time.time()
_request_counts: dict = defaultdict(int)


class MetricsSummary(BaseModel):
    status: str
    uptime_seconds: float
    cpu_percent: float
    memory_used_mb: float
    memory_percent: float
    requests_total: int
    requests_2xx: int
    requests_4xx: int
    requests_5xx: int


def record_request(status_code: int) -> None:
    _request_counts["total"] += 1
    group = f"{status_code // 100}xx"
    _request_counts[group] += 1


@router.get("/api/metrics/summary", response_model=MetricsSummary)
async def get_metrics_summary() -> MetricsSummary:
    process = psutil.Process()
    return MetricsSummary(
        status="ok",
        uptime_seconds=round(time.time() - _start_time, 1),
        cpu_percent=psutil.cpu_percent(interval=0.1),
        memory_used_mb=round(process.memory_info().rss / 1024 / 1024, 1),
        memory_percent=round(process.memory_percent(), 1),
        requests_total=_request_counts["total"],
        requests_2xx=_request_counts["2xx"],
        requests_4xx=_request_counts["4xx"],
        requests_5xx=_request_counts["5xx"],
    )
