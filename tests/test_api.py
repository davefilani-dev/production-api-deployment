from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "message": "API is running"
    }


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {
        "message": "healthy"
    }


def test_me():
    response = client.get("/me")

    assert response.status_code == 200

    data = response.json()

    assert "name" in data
    assert "email" in data
    assert "github" in data



