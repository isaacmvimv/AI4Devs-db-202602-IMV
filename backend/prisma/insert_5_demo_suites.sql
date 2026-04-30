-- =============================================================================
-- Datos demo: 5 suites completas (company → flow → steps → position →
-- employee → candidate → application → interviews).
-- Tablas alineadas con ats_erd_postgresql.sql / schema.prisma.
--
-- Requisitos: esquema ya creado. Si la base tiene datos en conflicto con los
-- IDs fijos, vacía antes (descomenta el bloque siguiente) o adapta los IDs.
-- =============================================================================

-- Opcional: vaciar todas las tablas ATS y reiniciar secuencias (CUIDADO).
-- TRUNCATE TABLE
--   interviews,
--   applications,
--   positions,
--   interview_steps,
--   employees,
--   candidates,
--   interview_flows,
--   interview_types,
--   companies
-- RESTART IDENTITY CASCADE;

BEGIN;

-- -----------------------------------------------------------------------------
-- Catálogo compartido: tipos de entrevista (4 tipos, reutilizados en los pasos)
-- -----------------------------------------------------------------------------
INSERT INTO interview_types (id, name, description) VALUES
    (1, 'Filtrado RRHH', 'Primera toma de contacto y encaje cultural.'),
    (2, 'Entrevista técnica', 'Validación de stack y resolución de problemas.'),
    (3, 'Pair programming', 'Sesión práctica con el equipo.'),
    (4, 'Oferta y cierre', 'Negociación y condiciones finales.');

-- -----------------------------------------------------------------------------
-- 5 empresas (suite 1..5)
-- -----------------------------------------------------------------------------
INSERT INTO companies (id, name) VALUES
    (1, 'Suite Demo — Acme Robotics'),
    (2, 'Suite Demo — Blue Harbor Labs'),
    (3, 'Suite Demo — Northwind Analytics'),
    (4, 'Suite Demo — Contoso Mobility'),
    (5, 'Suite Demo — Fabrikam Health');

-- -----------------------------------------------------------------------------
-- 5 flujos de entrevista (1:1 con cada posición; obligatorio por restricción)
-- -----------------------------------------------------------------------------
INSERT INTO interview_flows (id, description) VALUES
    (1, 'Flujo suite 1: RRHH → técnica → cierre.'),
    (2, 'Flujo suite 2: RRHH → técnica → pair → cierre.'),
    (3, 'Flujo suite 3: RRHH → técnica.'),
    (4, 'Flujo suite 4: RRHH → pair → técnica.'),
    (5, 'Flujo suite 5: RRHH → técnica → pair.');

-- -----------------------------------------------------------------------------
-- Empleados / entrevistadores (uno por empresa; emails únicos por company_id)
-- -----------------------------------------------------------------------------
INSERT INTO employees (id, company_id, name, email, role, is_active) VALUES
    (1, 1, 'Laura Méndez', 'laura.mendez@acme-demo.local', 'Talent Lead', TRUE),
    (2, 2, 'Carlos Vega', 'carlos.vega@blueharbor-demo.local', 'Engineering Manager', TRUE),
    (3, 3, 'Ana Ruiz', 'ana.ruiz@northwind-demo.local', 'Head of Data', TRUE),
    (4, 4, 'Diego Soto', 'diego.soto@contoso-demo.local', 'HR Business Partner', TRUE),
    (5, 5, 'Elena Prieto', 'elena.prieto@fabrikam-demo.local', 'Tech Recruiter', TRUE);

-- -----------------------------------------------------------------------------
-- Pasos por flujo (order_index único por flujo). IDs 1..12 para cubrir los 5 flujos
-- -----------------------------------------------------------------------------
INSERT INTO interview_steps (id, interview_flow_id, interview_type_id, name, order_index) VALUES
    (1,  1, 1, 'Screening RRHH',           0),
    (2,  1, 2, 'Técnica backend',          1),
    (3,  1, 4, 'Propuesta y cierre',       2),
    (4,  2, 1, 'Screening RRHH',           0),
    (5,  2, 2, 'Técnica plataforma',       1),
    (6,  2, 3, 'Pair programming',         2),
    (7,  2, 4, 'Oferta',                   3),
    (8,  3, 1, 'Llamada inicial',          0),
    (9,  3, 2, 'Deep dive analítico',      1),
    (10, 4, 1, 'Intro RRHH',               0),
    (11, 4, 3, 'Pair datos',               1),
    (12, 4, 2, 'Arquitectura y diseño',    2),
    (13, 5, 1, 'Screening',                0),
    (14, 5, 2, 'Técnica mobile',           1),
    (15, 5, 3, 'Pair con equipo producto', 2);

-- -----------------------------------------------------------------------------
-- Posiciones (cada interview_flow_id es único en toda la tabla)
-- -----------------------------------------------------------------------------
INSERT INTO positions (
    id, company_id, interview_flow_id, title, description, status, is_visible,
    location, job_description, requirements, responsibilities,
    salary_min, salary_max, employment_type, benefits, company_description,
    application_deadline, contact_info
) VALUES
    (1, 1, 1, 'Backend Engineer (Node)',
        'APIs y microservicios para plataforma ATS.',
        'open', TRUE, 'Madrid (híbrido)',
        'Diseño e implementación de servicios REST, Prisma/PostgreSQL.',
        '3+ años Node.js, SQL, tests.',
        'Mentoría, code reviews, documentación.',
        48000.00, 62000.00, 'full-time',
        'Seguro médico, ticket restaurante.',
        'Acme Robotics impulsa automatización industrial.',
        DATE '2026-06-30', 'talent@acme-demo.local'),

    (2, 2, 2, 'Platform Engineer',
        'Infra como código y observabilidad.',
        'open', TRUE, 'Barcelona',
        'Kubernetes, CI/CD, SRE practices.',
        'Cloud (AWS/GCP), Terraform, monitoring.',
        'Guardias rotativas compensadas.',
        55000.00, 72000.00, 'full-time',
        'Remote friendly 3 días/semana.',
        'Blue Harbor Labs, producto SaaS B2B.',
        DATE '2026-07-15', 'jobs@blueharbor-demo.local'),

    (3, 3, 3, 'Data Analyst',
        'BI y modelos predictivos para retail.',
        'open', TRUE, 'Valencia',
        'SQL, dashboards, experimentación A/B.',
        'Python o R, dbt, Looker/Metabase.',
        'Stakeholder management, storytelling con datos.',
        40000.00, 52000.00, 'full-time',
        'Formación continua, bonus anual.',
        'Northwind Analytics, consultoría de datos.',
        DATE '2026-05-20', 'careers@northwind-demo.local'),

    (4, 4, 4, 'Senior Mobile Developer (React Native)',
        'App consumer para movilidad urbana.',
        'open', TRUE, 'Sevilla / remoto',
        'Performance, offline-first, publicación stores.',
        'RN/TypeScript, testing, App Store / Play Console.',
        'Colaboración con UX y backend.',
        50000.00, 68000.00, 'full-time',
        'Equipo multidisciplinar, stock options.',
        'Contoso Mobility, MaaS en crecimiento.',
        DATE '2026-08-01', 'people@contoso-demo.local'),

    (5, 5, 5, 'Product Engineer',
        'Full stack orientado a producto en salud digital.',
        'open', TRUE, 'Bilbao (híbrido)',
        'Features end-to-end, calidad y compliance básico.',
        'TypeScript, React, APIs; nociones HIPAA/GDPR deseable.',
        'Discovery con PM, métricas de uso.',
        45000.00, 60000.00, 'full-time',
        'Chequeo médico anual, gimnasio.',
        'Fabrikam Health, telemedicina.',
        DATE '2026-06-01', 'hiring@fabrikam-demo.local');

-- -----------------------------------------------------------------------------
-- Candidatos (emails únicos globalmente)
-- -----------------------------------------------------------------------------
INSERT INTO candidates (id, first_name, last_name, email, phone, address) VALUES
    (1, 'Isaac',    'Martín',    'candidate.suite01@demo.local', '+34 600 111 001', 'Calle Uno 1, Madrid'),
    (2, 'María',    'García',    'candidate.suite02@demo.local', '+34 600 222 002', 'Av. Dos 2, Barcelona'),
    (3, 'Javier',   'López',     'candidate.suite03@demo.local', '+34 600 333 003', 'Plaza Tres 3, Valencia'),
    (4, 'Lucía',    'Fernández', 'candidate.suite04@demo.local', '+34 600 444 004', 'Calle Cuatro 4, Sevilla'),
    (5, 'Andrés',   'Torres',    'candidate.suite05@demo.local', '+34 600 555 005', 'Calle Cinco 5, Bilbao');

-- -----------------------------------------------------------------------------
-- Candidaturas (único par position_id + candidate_id)
-- -----------------------------------------------------------------------------
INSERT INTO applications (id, position_id, candidate_id, application_date, status, notes) VALUES
    (1, 1, 1, DATE '2026-04-01', 'in_process', 'Suite 1: pipeline activo.'),
    (2, 2, 2, DATE '2026-04-02', 'in_process', 'Suite 2: varias etapas.'),
    (3, 3, 3, DATE '2026-04-03', 'screening',  'Suite 3: en fase inicial.'),
    (4, 4, 4, DATE '2026-04-04', 'in_process', 'Suite 4: orden pair antes de técnica profunda.'),
    (5, 5, 5, DATE '2026-04-05', 'in_process', 'Suite 5: producto + mobile stack.');

-- -----------------------------------------------------------------------------
-- Entrevistas: una fila por cada paso del flujo de la candidatura correspondiente
-- (employee_id pertenece a la misma company que la posición)
-- -----------------------------------------------------------------------------
INSERT INTO interviews (id, application_id, interview_step_id, employee_id, interview_date, result, score, notes) VALUES
    -- Application 1 → flow 1 → steps 1,2,3 → employee 1
    (1,  1,  1, 1, DATE '2026-04-10', 'Positive',  82, 'Buen encaje cultural.'),
    (2,  1,  2, 1, DATE '2026-04-12', 'Positive',  88, 'Sólido en Node y SQL.'),
    (3,  1,  3, 1, DATE '2026-04-18', NULL,        NULL, 'Pendiente de feedback económico.'),

    -- Application 2 → flow 2 → steps 4,5,6,7 → employee 2
    (4,  2,  4, 2, DATE '2026-04-09', 'Positive',  79, NULL),
    (5,  2,  5, 2, DATE '2026-04-11', 'Positive',  91, 'Excelente en cloud.'),
    (6,  2,  6, 2, DATE '2026-04-14', 'Positive',  85, 'Buena comunicación en pair.'),
    (7,  2,  7, 2, DATE '2026-04-20', NULL,        NULL, 'Negociación en curso.'),

    -- Application 3 → flow 3 → steps 8,9 → employee 3
    (8,  3,  8, 3, DATE '2026-04-08', 'Positive',  76, NULL),
    (9,  3,  9, 3, DATE '2026-04-15', NULL,        NULL, 'Segunda ronda programada.'),

    -- Application 4 → flow 4 → steps 10,11,12 → employee 4
    (10, 4, 10, 4, DATE '2026-04-07', 'Positive',  80, NULL),
    (11, 4, 11, 4, DATE '2026-04-13', 'Positive',  84, 'Muy buen dominio RN.'),
    (12, 4, 12, 4, DATE '2026-04-16', 'Positive',  87, 'Arquitectura clara.'),

    -- Application 5 → flow 5 → steps 13,14,15 → employee 5
    (13, 5, 13, 5, DATE '2026-04-06', 'Positive',  78, NULL),
    (14, 5, 14, 5, DATE '2026-04-12', 'Positive',  83, NULL),
    (15, 5, 15, 5, DATE '2026-04-17', NULL,        NULL, 'Última fase; sin resultado aún.');

-- -----------------------------------------------------------------------------
-- Sincronizar secuencias SERIAL tras inserciones con ID explícito
-- -----------------------------------------------------------------------------
SELECT setval(pg_get_serial_sequence('companies',         'id'), COALESCE((SELECT MAX(id) FROM companies),         1), true);
SELECT setval(pg_get_serial_sequence('interview_flows',   'id'), COALESCE((SELECT MAX(id) FROM interview_flows),   1), true);
SELECT setval(pg_get_serial_sequence('interview_types',   'id'), COALESCE((SELECT MAX(id) FROM interview_types),   1), true);
SELECT setval(pg_get_serial_sequence('employees',         'id'), COALESCE((SELECT MAX(id) FROM employees),         1), true);
SELECT setval(pg_get_serial_sequence('interview_steps',   'id'), COALESCE((SELECT MAX(id) FROM interview_steps),   1), true);
SELECT setval(pg_get_serial_sequence('positions',         'id'), COALESCE((SELECT MAX(id) FROM positions),         1), true);
SELECT setval(pg_get_serial_sequence('candidates',        'id'), COALESCE((SELECT MAX(id) FROM candidates),        1), true);
SELECT setval(pg_get_serial_sequence('applications',      'id'), COALESCE((SELECT MAX(id) FROM applications),      1), true);
SELECT setval(pg_get_serial_sequence('interviews',        'id'), COALESCE((SELECT MAX(id) FROM interviews),        1), true);

COMMIT;
