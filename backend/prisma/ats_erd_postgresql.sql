-- =============================================================================
-- ATS (Applicant Tracking System) — modelo relacional PostgreSQL
-- Derivado del ERD proporcionado. Convención: tablas y columnas en snake_case.
-- =============================================================================

BEGIN;

-- -----------------------------------------------------------------------------
-- company
-- -----------------------------------------------------------------------------
CREATE TABLE companies (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    CONSTRAINT chk_companies_name_trimmed CHECK (char_length(trim(both from name)) > 0)
);

CREATE INDEX idx_companies_name ON companies (name);

COMMENT ON TABLE companies IS 'Organización que publica vacantes.';

-- -----------------------------------------------------------------------------
-- interview_flow (plantilla de proceso de entrevista)
-- -----------------------------------------------------------------------------
CREATE TABLE interview_flows (
    id          SERIAL PRIMARY KEY,
    description VARCHAR(512) NOT NULL,
    CONSTRAINT chk_interview_flows_description_trimmed CHECK (char_length(trim(both from description)) > 0)
);

COMMENT ON TABLE interview_flows IS 'Secuencia definida de etapas de entrevista.';

-- -----------------------------------------------------------------------------
-- interview_type
-- -----------------------------------------------------------------------------
CREATE TABLE interview_types (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    CONSTRAINT chk_interview_types_name_trimmed CHECK (char_length(trim(both from name)) > 0)
);

CREATE INDEX idx_interview_types_name ON interview_types (name);

COMMENT ON TABLE interview_types IS 'Tipo de entrevista (técnica, RRHH, etc.).';

-- -----------------------------------------------------------------------------
-- employee
-- -----------------------------------------------------------------------------
CREATE TABLE employees (
    id          SERIAL PRIMARY KEY,
    company_id  INTEGER NOT NULL REFERENCES companies (id) ON DELETE RESTRICT,
    name        VARCHAR(255) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    role        VARCHAR(128) NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT chk_employees_name_trimmed CHECK (char_length(trim(both from name)) > 0),
    CONSTRAINT chk_employees_email_trimmed CHECK (char_length(trim(both from email)) > 0),
    CONSTRAINT chk_employees_role_trimmed CHECK (char_length(trim(both from role)) > 0),
    CONSTRAINT uq_employees_company_email UNIQUE (company_id, email)
);

CREATE INDEX idx_employees_company_id ON employees (company_id);
CREATE INDEX idx_employees_is_active ON employees (is_active) WHERE is_active = TRUE;

COMMENT ON TABLE employees IS 'Usuario interno / entrevistador.';

-- -----------------------------------------------------------------------------
-- interview_step (etapa dentro de un flujo)
-- -----------------------------------------------------------------------------
CREATE TABLE interview_steps (
    id                 SERIAL PRIMARY KEY,
    interview_flow_id  INTEGER NOT NULL REFERENCES interview_flows (id) ON DELETE CASCADE,
    interview_type_id  INTEGER NOT NULL REFERENCES interview_types (id) ON DELETE RESTRICT,
    name               VARCHAR(255) NOT NULL,
    order_index        INTEGER NOT NULL,
    CONSTRAINT chk_interview_steps_name_trimmed CHECK (char_length(trim(both from name)) > 0),
    CONSTRAINT chk_interview_steps_order_non_negative CHECK (order_index >= 0),
    CONSTRAINT uq_interview_steps_flow_order UNIQUE (interview_flow_id, order_index)
);

CREATE INDEX idx_interview_steps_flow_id ON interview_steps (interview_flow_id);
CREATE INDEX idx_interview_steps_type_id ON interview_steps (interview_type_id);

COMMENT ON TABLE interview_steps IS 'Paso ordenado dentro de un interview_flow.';

-- -----------------------------------------------------------------------------
-- position (vacante)
-- -----------------------------------------------------------------------------
CREATE TABLE positions (
    id                    SERIAL PRIMARY KEY,
    company_id            INTEGER NOT NULL REFERENCES companies (id) ON DELETE RESTRICT,
    interview_flow_id     INTEGER NOT NULL REFERENCES interview_flows (id) ON DELETE RESTRICT,
    title                 VARCHAR(255) NOT NULL,
    description           TEXT,
    status                VARCHAR(64) NOT NULL,
    is_visible            BOOLEAN NOT NULL DEFAULT TRUE,
    location              VARCHAR(255),
    job_description       TEXT,
    requirements          TEXT,
    responsibilities      TEXT,
    salary_min            NUMERIC(12, 2),
    salary_max            NUMERIC(12, 2),
    employment_type       VARCHAR(64),
    benefits              TEXT,
    company_description   TEXT,
    application_deadline  DATE,
    contact_info          VARCHAR(512),
    CONSTRAINT chk_positions_title_trimmed CHECK (char_length(trim(both from title)) > 0),
    CONSTRAINT chk_positions_status_trimmed CHECK (char_length(trim(both from status)) > 0),
    CONSTRAINT chk_positions_salary_range CHECK (
        salary_min IS NULL OR salary_max IS NULL OR salary_min <= salary_max
    ),
    CONSTRAINT chk_positions_salary_non_negative CHECK (
        (salary_min IS NULL OR salary_min >= 0) AND (salary_max IS NULL OR salary_max >= 0)
    ),
    CONSTRAINT uq_positions_interview_flow UNIQUE (interview_flow_id)
);

CREATE INDEX idx_positions_company_id ON positions (company_id);
CREATE INDEX idx_positions_status ON positions (status);
CREATE INDEX idx_positions_is_visible ON positions (is_visible) WHERE is_visible = TRUE;
CREATE INDEX idx_positions_application_deadline ON positions (application_deadline);

COMMENT ON TABLE positions IS 'Oferta de empleo; 1:1 con interview_flow vía interview_flow_id único.';
COMMENT ON CONSTRAINT uq_positions_interview_flow ON positions IS 'Cada flujo se asigna como máximo a una posición (relación 1:1 del ERD).';

-- -----------------------------------------------------------------------------
-- candidate
-- -----------------------------------------------------------------------------
CREATE TABLE candidates (
    id          SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(255) NOT NULL,
    phone       VARCHAR(32),
    address     VARCHAR(512),
    CONSTRAINT chk_candidates_first_name_trimmed CHECK (char_length(trim(both from first_name)) > 0),
    CONSTRAINT chk_candidates_last_name_trimmed CHECK (char_length(trim(both from last_name)) > 0),
    CONSTRAINT chk_candidates_email_trimmed CHECK (char_length(trim(both from email)) > 0),
    CONSTRAINT uq_candidates_email UNIQUE (email)
);

CREATE INDEX idx_candidates_last_name_first_name ON candidates (last_name, first_name);

COMMENT ON TABLE candidates IS 'Persona que aplica a vacantes.';

-- -----------------------------------------------------------------------------
-- application
-- -----------------------------------------------------------------------------
CREATE TABLE applications (
    id                SERIAL PRIMARY KEY,
    position_id       INTEGER NOT NULL REFERENCES positions (id) ON DELETE CASCADE,
    candidate_id      INTEGER NOT NULL REFERENCES candidates (id) ON DELETE RESTRICT,
    application_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    status            VARCHAR(64) NOT NULL,
    notes             TEXT,
    CONSTRAINT chk_applications_status_trimmed CHECK (char_length(trim(both from status)) > 0),
    CONSTRAINT uq_applications_position_candidate UNIQUE (position_id, candidate_id)
);

CREATE INDEX idx_applications_position_id ON applications (position_id);
CREATE INDEX idx_applications_candidate_id ON applications (candidate_id);
CREATE INDEX idx_applications_application_date ON applications (application_date);
CREATE INDEX idx_applications_status ON applications (status);

COMMENT ON TABLE applications IS 'Candidatura de un candidato a una posición.';
COMMENT ON CONSTRAINT uq_applications_position_candidate ON applications IS 'Un candidato no duplica solicitud a la misma vacante.';

-- -----------------------------------------------------------------------------
-- interview (ocurrencia de una etapa para una candidatura)
-- -----------------------------------------------------------------------------
CREATE TABLE interviews (
    id                 SERIAL PRIMARY KEY,
    application_id     INTEGER NOT NULL REFERENCES applications (id) ON DELETE CASCADE,
    interview_step_id  INTEGER NOT NULL REFERENCES interview_steps (id) ON DELETE RESTRICT,
    employee_id        INTEGER NOT NULL REFERENCES employees (id) ON DELETE RESTRICT,
    interview_date     DATE NOT NULL,
    result             VARCHAR(128),
    score              INTEGER,
    notes              TEXT,
    CONSTRAINT chk_interviews_result_trimmed CHECK (result IS NULL OR char_length(trim(both from result)) > 0),
    CONSTRAINT chk_interviews_score_range CHECK (score IS NULL OR (score >= 0 AND score <= 100))
);

CREATE INDEX idx_interviews_application_id ON interviews (application_id);
CREATE INDEX idx_interviews_interview_step_id ON interviews (interview_step_id);
CREATE INDEX idx_interviews_employee_id ON interviews (employee_id);
CREATE INDEX idx_interviews_interview_date ON interviews (interview_date);

COMMENT ON TABLE interviews IS 'Entrevista concreta ligada a application, step y entrevistador.';

COMMIT;
