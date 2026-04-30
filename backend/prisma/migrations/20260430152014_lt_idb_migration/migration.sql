-- CreateTable
CREATE TABLE "companies" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,

    CONSTRAINT "companies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "employees" (
    "id" SERIAL NOT NULL,
    "company_id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "role" VARCHAR(128) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "employees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interview_flows" (
    "id" SERIAL NOT NULL,
    "description" VARCHAR(512) NOT NULL,

    CONSTRAINT "interview_flows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interview_types" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,

    CONSTRAINT "interview_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interview_steps" (
    "id" SERIAL NOT NULL,
    "interview_flow_id" INTEGER NOT NULL,
    "interview_type_id" INTEGER NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "order_index" INTEGER NOT NULL,

    CONSTRAINT "interview_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "positions" (
    "id" SERIAL NOT NULL,
    "company_id" INTEGER NOT NULL,
    "interview_flow_id" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "status" VARCHAR(64) NOT NULL,
    "is_visible" BOOLEAN NOT NULL DEFAULT true,
    "location" VARCHAR(255),
    "job_description" TEXT,
    "requirements" TEXT,
    "responsibilities" TEXT,
    "salary_min" DECIMAL(12,2),
    "salary_max" DECIMAL(12,2),
    "employment_type" VARCHAR(64),
    "benefits" TEXT,
    "company_description" TEXT,
    "application_deadline" DATE,
    "contact_info" VARCHAR(512),

    CONSTRAINT "positions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "candidates" (
    "id" SERIAL NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(32),
    "address" VARCHAR(512),

    CONSTRAINT "candidates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "applications" (
    "id" SERIAL NOT NULL,
    "position_id" INTEGER NOT NULL,
    "candidate_id" INTEGER NOT NULL,
    "application_date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" VARCHAR(64) NOT NULL,
    "notes" TEXT,

    CONSTRAINT "applications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "interviews" (
    "id" SERIAL NOT NULL,
    "application_id" INTEGER NOT NULL,
    "interview_step_id" INTEGER NOT NULL,
    "employee_id" INTEGER NOT NULL,
    "interview_date" DATE NOT NULL,
    "result" VARCHAR(128),
    "score" INTEGER,
    "notes" TEXT,

    CONSTRAINT "interviews_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_companies_name" ON "companies"("name");

-- CreateIndex
CREATE INDEX "idx_employees_company_id" ON "employees"("company_id");

-- CreateIndex
CREATE INDEX "idx_employees_is_active" ON "employees"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "uq_employees_company_email" ON "employees"("company_id", "email");

-- CreateIndex
CREATE INDEX "idx_interview_types_name" ON "interview_types"("name");

-- CreateIndex
CREATE INDEX "idx_interview_steps_flow_id" ON "interview_steps"("interview_flow_id");

-- CreateIndex
CREATE INDEX "idx_interview_steps_type_id" ON "interview_steps"("interview_type_id");

-- CreateIndex
CREATE UNIQUE INDEX "uq_interview_steps_flow_order" ON "interview_steps"("interview_flow_id", "order_index");

-- CreateIndex
CREATE UNIQUE INDEX "positions_interview_flow_id_key" ON "positions"("interview_flow_id");

-- CreateIndex
CREATE INDEX "idx_positions_company_id" ON "positions"("company_id");

-- CreateIndex
CREATE INDEX "idx_positions_status" ON "positions"("status");

-- CreateIndex
CREATE INDEX "idx_positions_is_visible" ON "positions"("is_visible");

-- CreateIndex
CREATE INDEX "idx_positions_application_deadline" ON "positions"("application_deadline");

-- CreateIndex
CREATE UNIQUE INDEX "candidates_email_key" ON "candidates"("email");

-- CreateIndex
CREATE INDEX "idx_candidates_last_name_first_name" ON "candidates"("last_name", "first_name");

-- CreateIndex
CREATE INDEX "idx_applications_position_id" ON "applications"("position_id");

-- CreateIndex
CREATE INDEX "idx_applications_candidate_id" ON "applications"("candidate_id");

-- CreateIndex
CREATE INDEX "idx_applications_application_date" ON "applications"("application_date");

-- CreateIndex
CREATE INDEX "idx_applications_status" ON "applications"("status");

-- CreateIndex
CREATE UNIQUE INDEX "uq_applications_position_candidate" ON "applications"("position_id", "candidate_id");

-- CreateIndex
CREATE INDEX "idx_interviews_application_id" ON "interviews"("application_id");

-- CreateIndex
CREATE INDEX "idx_interviews_interview_step_id" ON "interviews"("interview_step_id");

-- CreateIndex
CREATE INDEX "idx_interviews_employee_id" ON "interviews"("employee_id");

-- CreateIndex
CREATE INDEX "idx_interviews_interview_date" ON "interviews"("interview_date");

-- AddForeignKey
ALTER TABLE "employees" ADD CONSTRAINT "employees_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flows"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interview_steps" ADD CONSTRAINT "interview_steps_interview_type_id_fkey" FOREIGN KEY ("interview_type_id") REFERENCES "interview_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "positions" ADD CONSTRAINT "positions_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "companies"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "positions" ADD CONSTRAINT "positions_interview_flow_id_fkey" FOREIGN KEY ("interview_flow_id") REFERENCES "interview_flows"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_position_id_fkey" FOREIGN KEY ("position_id") REFERENCES "positions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "applications" ADD CONSTRAINT "applications_candidate_id_fkey" FOREIGN KEY ("candidate_id") REFERENCES "candidates"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "applications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_interview_step_id_fkey" FOREIGN KEY ("interview_step_id") REFERENCES "interview_steps"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "interviews" ADD CONSTRAINT "interviews_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES "employees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
