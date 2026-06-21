import pytest
from fastapi.testclient import TestClient

from personal_app_backend.app import app


@pytest.fixture
def client():
    """Create a TestClient instance for the FastAPI app."""
    return TestClient(app)


def test_metrics_summary_status(client):
    """GET /api/metrics/summary returns 200 with expected fields."""
    response = client.get("/api/metrics/summary")

    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert isinstance(data["uptime_seconds"], float)
    assert data["uptime_seconds"] >= 0
    assert isinstance(data["cpu_percent"], float)
    assert isinstance(data["memory_used_mb"], float)
    assert isinstance(data["memory_percent"], float)


def test_metrics_request_counters_increment(client):
    """Each request to the metrics endpoint increments the request counters."""
    before = client.get("/api/metrics/summary").json()

    client.get("/api/metrics/summary")
    client.get("/api/metrics/summary")

    after = client.get("/api/metrics/summary").json()

    assert after["requests_total"] > before["requests_total"]
    assert after["requests_2xx"] > before["requests_2xx"]


def test_metrics_fields_are_non_negative(client):
    """All numeric metric fields must be >= 0."""
    data = client.get("/api/metrics/summary").json()

    for field in ("requests_total", "requests_2xx", "requests_4xx", "requests_5xx"):
        assert data[field] >= 0, f"{field} should be non-negative"
