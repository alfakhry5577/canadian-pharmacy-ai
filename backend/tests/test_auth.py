def test_register_and_login(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Test Customer",
        "email": "test@example.com",
        "password": "StrongPass123",
        "role": "customer",
    })
    assert resp.status_code == 201
    body = resp.json()
    assert body["user"]["email"] == "test@example.com"
    assert "access_token" in body

    resp = client.post("/api/auth/login", json={
        "email": "test@example.com",
        "password": "StrongPass123",
    })
    assert resp.status_code == 200
    assert resp.json()["user"]["role"] == "customer"


def test_login_wrong_password(client):
    client.post("/api/auth/register", json={
        "full_name": "Test User", "email": "u2@example.com", "password": "StrongPass123",
    })
    resp = client.post("/api/auth/login", json={"email": "u2@example.com", "password": "wrong"})
    assert resp.status_code == 401


def test_customer_cannot_create_medication(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Customer Only", "email": "c@example.com", "password": "StrongPass123", "role": "customer",
    })
    token = resp.json()["access_token"]

    resp = client.post(
        "/api/medications",
        json={"name_en": "Test Med", "name_ar": "دواء تجريبي", "price": 5},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 403  # RBAC: customers cannot add catalog items


def test_pharmacist_can_create_medication(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Pharm", "email": "ph@example.com", "password": "StrongPass123", "role": "pharmacist",
    })
    token = resp.json()["access_token"]

    resp = client.post(
        "/api/medications",
        json={"name_en": "Test Med", "name_ar": "دواء تجريبي", "price": 5},
        headers={"Authorization": f"Bearer {token}"},
    )
    assert resp.status_code == 201
    assert resp.json()["name_ar"] == "دواء تجريبي"
