-- ============================================================
-- Roshetta AI — Pharmacy AI Assistant
-- PostgreSQL Schema
-- ============================================================

CREATE TYPE user_role AS ENUM ('admin', 'pharmacist', 'customer');
CREATE TYPE prescription_status AS ENUM ('pending', 'analyzed', 'reviewed', 'dispensed', 'rejected');
CREATE TYPE alert_type AS ENUM ('low_stock', 'expiry', 'duplicate_medication', 'drug_interaction', 'allergy', 'special_population');
CREATE TYPE alert_severity AS ENUM ('info', 'warning', 'critical');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');
CREATE TYPE chat_role AS ENUM ('user', 'assistant', 'system');

-- ------------------------------------------------------------
-- USERS & PROFILES
-- ------------------------------------------------------------
CREATE TABLE users (
    id              SERIAL PRIMARY KEY,
    full_name       VARCHAR(150) NOT NULL,
    email           VARCHAR(150) UNIQUE NOT NULL,
    phone           VARCHAR(30) UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    role            user_role NOT NULL DEFAULT 'customer',
    date_of_birth   DATE,
    is_pregnant     BOOLEAN DEFAULT FALSE,           -- used only to drive safety warnings, never diagnosis
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE customer_allergies (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    substance_name  VARCHAR(150) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE customer_chronic_conditions (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    condition_name  VARCHAR(150) NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- MEDICATION CATALOG
-- ------------------------------------------------------------
CREATE TABLE active_ingredients (
    id              SERIAL PRIMARY KEY,
    name_en         VARCHAR(150) NOT NULL,
    name_ar         VARCHAR(150) NOT NULL,
    UNIQUE(name_en)
);

CREATE TABLE medications (
    id                      SERIAL PRIMARY KEY,
    name_en                 VARCHAR(200) NOT NULL,
    name_ar                 VARCHAR(200) NOT NULL,
    active_ingredient_id    INTEGER REFERENCES active_ingredients(id),
    dosage_form             VARCHAR(50),   -- tablet, syrup, injection, cream...
    strength                VARCHAR(50),   -- e.g. "500mg"
    manufacturer            VARCHAR(150),
    requires_prescription   BOOLEAN DEFAULT TRUE,
    price                   NUMERIC(10,2) NOT NULL DEFAULT 0,
    general_usage           TEXT,          -- general informational text only
    general_warnings        TEXT,
    pregnancy_warning       TEXT,
    pediatric_warning       TEXT,
    elderly_warning         TEXT,
    is_active               BOOLEAN DEFAULT TRUE,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_medications_name_en ON medications (LOWER(name_en));
CREATE INDEX idx_medications_name_ar ON medications (name_ar);

-- Substitutes: symmetrical many-to-many between medications (usually same active ingredient)
CREATE TABLE medication_substitutes (
    medication_id           INTEGER NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    substitute_medication_id INTEGER NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    PRIMARY KEY (medication_id, substitute_medication_id),
    CHECK (medication_id <> substitute_medication_id)
);

-- Known interaction pairs (simplified reference table — for demo / starter purposes)
CREATE TABLE drug_interactions (
    id                          SERIAL PRIMARY KEY,
    ingredient_a_id             INTEGER NOT NULL REFERENCES active_ingredients(id),
    ingredient_b_id             INTEGER NOT NULL REFERENCES active_ingredients(id),
    severity                    alert_severity NOT NULL DEFAULT 'warning',
    description_ar              TEXT NOT NULL,
    CHECK (ingredient_a_id <> ingredient_b_id)
);

-- Cross-sell suggestions: non-medical / allowed supplementary products linked to an ingredient
CREATE TABLE related_products (
    id                  SERIAL PRIMARY KEY,
    active_ingredient_id INTEGER REFERENCES active_ingredients(id),
    product_name_ar     VARCHAR(200) NOT NULL,
    product_name_en     VARCHAR(200),
    category            VARCHAR(100),  -- e.g. "supplement", "hygiene", "device"
    price               NUMERIC(10,2) DEFAULT 0,
    note_ar             TEXT
);

-- ------------------------------------------------------------
-- INVENTORY
-- ------------------------------------------------------------
CREATE TABLE inventory (
    id                  SERIAL PRIMARY KEY,
    medication_id       INTEGER NOT NULL REFERENCES medications(id) ON DELETE CASCADE,
    quantity            INTEGER NOT NULL DEFAULT 0,
    reorder_threshold   INTEGER NOT NULL DEFAULT 10,
    batch_no            VARCHAR(80),
    expiry_date         DATE,
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE(medication_id, batch_no)
);

-- ------------------------------------------------------------
-- PRESCRIPTIONS (OCR / AI ANALYSIS)
-- ------------------------------------------------------------
CREATE TABLE prescriptions (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES users(id),
    pharmacist_id   INTEGER REFERENCES users(id),
    image_path      VARCHAR(500) NOT NULL,
    raw_ocr_text    TEXT,
    status          prescription_status NOT NULL DEFAULT 'pending',
    pharmacist_notes TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    reviewed_at     TIMESTAMP
);

CREATE TABLE prescription_items (
    id                          SERIAL PRIMARY KEY,
    prescription_id             INTEGER NOT NULL REFERENCES prescriptions(id) ON DELETE CASCADE,
    extracted_medication_name   VARCHAR(200) NOT NULL,
    matched_medication_id       INTEGER REFERENCES medications(id),
    dosage_text                 VARCHAR(100),     -- as written, never altered by the system
    frequency_text              VARCHAR(100),
    duration_text               VARCHAR(100),
    confidence_score            NUMERIC(4,3) DEFAULT 0,  -- 0..1 OCR/AI confidence
    pharmacist_confirmed         BOOLEAN DEFAULT FALSE
);

-- ------------------------------------------------------------
-- SAFETY ALERTS
-- ------------------------------------------------------------
CREATE TABLE alerts (
    id                  SERIAL PRIMARY KEY,
    type                alert_type NOT NULL,
    severity            alert_severity NOT NULL DEFAULT 'info',
    related_medication_id INTEGER REFERENCES medications(id),
    related_prescription_id INTEGER REFERENCES prescriptions(id),
    customer_id         INTEGER REFERENCES users(id),
    message_ar          TEXT NOT NULL,
    is_resolved         BOOLEAN DEFAULT FALSE,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- ORDERS / SALES
-- ------------------------------------------------------------
CREATE TABLE orders (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER NOT NULL REFERENCES users(id),
    pharmacist_id   INTEGER REFERENCES users(id),
    prescription_id INTEGER REFERENCES prescriptions(id),
    status          order_status NOT NULL DEFAULT 'pending',
    total_amount    NUMERIC(10,2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id              SERIAL PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    medication_id   INTEGER REFERENCES medications(id),
    related_product_id INTEGER REFERENCES related_products(id),
    quantity        INTEGER NOT NULL DEFAULT 1,
    unit_price      NUMERIC(10,2) NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------
-- REMINDERS (refill reminders, chronic medication tracking)
-- ------------------------------------------------------------
CREATE TABLE reminders (
    id                  SERIAL PRIMARY KEY,
    customer_id         INTEGER NOT NULL REFERENCES users(id),
    medication_id       INTEGER NOT NULL REFERENCES medications(id),
    frequency_days      INTEGER NOT NULL DEFAULT 30,
    next_reminder_date  DATE NOT NULL,
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- LOYALTY PROGRAM
-- ------------------------------------------------------------
CREATE TABLE loyalty_accounts (
    id              SERIAL PRIMARY KEY,
    customer_id     INTEGER UNIQUE NOT NULL REFERENCES users(id),
    points          INTEGER NOT NULL DEFAULT 0,
    tier            VARCHAR(30) NOT NULL DEFAULT 'bronze'
);

CREATE TABLE loyalty_transactions (
    id                  SERIAL PRIMARY KEY,
    loyalty_account_id  INTEGER NOT NULL REFERENCES loyalty_accounts(id) ON DELETE CASCADE,
    points_change       INTEGER NOT NULL,
    reason              VARCHAR(200),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- AI CHAT
-- ------------------------------------------------------------
CREATE TABLE chat_sessions (
    id              SERIAL PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(id),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE chat_messages (
    id              SERIAL PRIMARY KEY,
    session_id      INTEGER NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role            chat_role NOT NULL,
    content         TEXT NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- USEFUL INDEXES
-- ------------------------------------------------------------
CREATE INDEX idx_inventory_medication ON inventory(medication_id);
CREATE INDEX idx_prescriptions_customer ON prescriptions(customer_id);
CREATE INDEX idx_alerts_unresolved ON alerts(is_resolved) WHERE is_resolved = FALSE;
CREATE INDEX idx_reminders_due ON reminders(next_reminder_date) WHERE is_active = TRUE;
