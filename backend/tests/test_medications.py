def _register_pharmacist(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Pharm", "email": "ph_med@example.com", "password": "StrongPass123", "role": "pharmacist",
    })
    return resp.json()["access_token"]


def test_search_finds_medication_by_arabic_name(client):
    token = _register_pharmacist(client)
    client.post(
        "/api/medications",
        json={"name_en": "Panadol 500mg", "name_ar": "بنادول 500 ملغ", "price": 3.5},
        headers={"Authorization": f"Bearer {token}"},
    )
    resp = client.get("/api/medications/search", params={"q": "بنادول"})
    assert resp.status_code == 200
    results = resp.json()
    assert len(results) == 1
    assert results[0]["medication"]["name_ar"] == "بنادول 500 ملغ"
    # No inventory rows were added for it -> should report out of stock
    assert results[0]["in_stock"] is False
    assert results[0]["quantity_available"] == 0


def test_search_requires_min_length(client):
    resp = client.get("/api/medications/search", params={"q": "a"})
    assert resp.status_code == 422
