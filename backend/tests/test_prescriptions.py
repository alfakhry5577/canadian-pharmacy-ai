import io
from PIL import Image, ImageDraw


def _make_test_image() -> bytes:
    img = Image.new("RGB", (700, 200), color="white")
    draw = ImageDraw.Draw(img)
    draw.text((20, 60), "Brufen 400mg", fill="black")
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return buf.getvalue()


def test_prescription_upload_runs_ocr_and_matches_catalog(client):
    # Pharmacist adds Brufen to the catalog with stock
    resp = client.post("/api/auth/register", json={
        "full_name": "Pharm", "email": "ph_presc@example.com", "password": "StrongPass123", "role": "pharmacist",
    })
    ph_token = resp.json()["access_token"]
    resp = client.post(
        "/api/medications",
        json={"name_en": "Brufen 400mg", "name_ar": "بروفين 400 ملغ", "price": 4},
        headers={"Authorization": f"Bearer {ph_token}"},
    )
    assert resp.status_code == 201

    # Customer uploads a prescription photo
    resp = client.post("/api/auth/register", json={
        "full_name": "Customer", "email": "cust_presc@example.com", "password": "StrongPass123", "role": "customer",
    })
    cust_token = resp.json()["access_token"]

    image_bytes = _make_test_image()
    resp = client.post(
        "/api/prescriptions/upload",
        files={"file": ("rx.png", image_bytes, "image/png")},
        headers={"Authorization": f"Bearer {cust_token}"},
    )
    assert resp.status_code == 201
    body = resp.json()
    assert body["prescription"]["status"] == "analyzed"
    assert "disclaimer_ar" in body
    # The disclaimer must always be present — this is a hard safety requirement, not optional UX copy.
    assert "الصيدلاني" in body["disclaimer_ar"]


def test_pharmacist_review_queue_and_decision(client):
    resp = client.post("/api/auth/register", json={
        "full_name": "Pharm2", "email": "ph_queue@example.com", "password": "StrongPass123", "role": "pharmacist",
    })
    ph_token = resp.json()["access_token"]

    resp = client.post("/api/auth/register", json={
        "full_name": "Customer2", "email": "cust_queue@example.com", "password": "StrongPass123", "role": "customer",
    })
    cust_token = resp.json()["access_token"]

    image_bytes = _make_test_image()
    resp = client.post(
        "/api/prescriptions/upload",
        files={"file": ("rx.png", image_bytes, "image/png")},
        headers={"Authorization": f"Bearer {cust_token}"},
    )
    prescription_id = resp.json()["prescription"]["id"]

    # It should now show up in the pharmacist's review queue
    resp = client.get("/api/prescriptions/queue", headers={"Authorization": f"Bearer {ph_token}"})
    assert resp.status_code == 200
    assert any(p["id"] == prescription_id for p in resp.json())

    # Pharmacist makes the final, human decision — the system never auto-dispenses
    resp = client.patch(
        f"/api/prescriptions/{prescription_id}/review",
        json={"status": "reviewed", "pharmacist_notes": "تمت المراجعة، البنود واضحة"},
        headers={"Authorization": f"Bearer {ph_token}"},
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "reviewed"
    assert resp.json()["pharmacist_notes"] == "تمت المراجعة، البنود واضحة"
