# Normalization Notes — CodeJudge Platform

This document analyzes the raw CodeJudge dataset for normalization issues, explains how the design addresses 1NF, 2NF, and 3NF, and documents trade-offs made.

---

## Issues Found in the Raw Data

### 1. Repeated / Redundant Data

**Example 1: `batch_code` in `raw_student_import`**

The `raw_student_import` table stores `batch_code` (e.g. `CSE2025A`) as a plain string, not as a foreign key to `batches`. This means batch details like `program`, `start_date`, `end_date` would need to be repeated every time they are looked up. By keeping this as a staging table and separating batch identity into its own `batches` table, we avoid duplicating batch information across every student row.

**Example 2: `course_id` repeated in both `problems` and `contests`**

Both problems and contests belong to a course. If course details (title, credit hours, status) were embedded in those tables directly, any course update would require changes in multiple places. Keeping `courses` as a separate entity and referencing it by `course_id` ensures updates are made in one place only.

**Example 3: Student identity fields across `students` and `raw_student_import`**

`raw_student_import` holds `full_name`, `email`, `roll_number` separately from the `students` table. Once validated, student data is moved to `students`. Both tables are not meant to coexist permanently — the import table is a staging buffer, preventing dirty data from polluting the main entity.

---

### 2. Separating Data Into Tables Improves Design

**Example 1: `test_results` separated from `submissions`**

A single submission can be evaluated against many test cases. If test case results were stored as repeated columns or rows within `submissions`, the table would either be very wide (one column per test case) or have repeating groups. Extracting `test_results` into its own table with `(submission_id, test_case_id)` as a composite key achieves proper 1NF and 2NF.

**Example 2: `contest_problems` as a mapping table**

Contests have many problems, and problems can appear in many contests. Instead of storing a comma-separated list of problem IDs in `contests`, or repeating contest metadata in `problems`, a dedicated `contest_problems` bridge table resolves the many-to-many relationship into individual rows with a composite primary key.

---

### 3. Functional Dependencies and Normal Form Analysis

#### First Normal Form (1NF)
All tables in the design satisfy 1NF:
- Each column holds a single atomic value (no multi-valued columns or arrays).
- Each row is uniquely identifiable via a primary key.
- No repeating groups exist (e.g., test case results are not stored as JSON blobs inside `submissions`).

**Potential violation in raw data:** The `contest_id` column in `submissions` is empty for practice submissions. This is handled by allowing NULL for `contest_id`, which is acceptable in a normalized schema.

#### Second Normal Form (2NF)
2NF requires that every non-key attribute is fully functionally dependent on the entire primary key (applies to tables with composite keys).

**`contest_problems`:** The only non-key attribute is `problem_order`, which depends on both `contest_id` and `problem_id` together (the order of a problem is specific to a particular contest). This is fully in 2NF.

**`attendance`:** `attendance_status` and `marked_at` depend on both `session_id` and `student_id` together — not on either alone. Fully in 2NF.

**`test_results`:** All columns (`result_status`, `runtime_ms`, `memory_kb`, `awarded_points`) depend on the combination `(submission_id, test_case_id)`. Fully in 2NF.

#### Third Normal Form (3NF)
3NF requires no transitive dependencies (non-key attributes should not depend on other non-key attributes).

**`students` table:** `graduation_year` depends only on `student_id`, not transitively on `batch_id`. Even though batches have start/end dates, the graduation year is a student-level attribute. No transitive dependency.

**`submissions` table:** `score` and `status` depend on `submission_id` (the evaluation outcome of that specific submission). They do not transitively depend on `student_id` or `problem_id`. In 3NF.

**`enrollments` table:** `final_grade` depends on `enrollment_id` (i.e., on the specific student–course relationship), not on `student_id` or `course_id` independently. In 3NF.

**Potential 3NF issue — `problems.course_id` + `problems.difficulty`:** Difficulty is a property of the problem itself, not of the course. There is no transitive dependency here. However, if we were to store `course_title` directly in `problems`, that would be a transitive dependency (`problem_id` → `course_id` → `course_title`), which is why `courses` is kept as a separate table.

---

## Design Decisions and Trade-offs

### Trade-off 1: Surrogate keys vs. natural keys as primary keys

**Decision:** Use surrogate IDs (`student_id`, `course_id`, etc.) as primary keys throughout.

**Reasoning:** Natural keys like `roll_number` or `email` can change (e.g., a student changes their email). Surrogate keys are stable and simplify foreign key references. Candidate keys like `roll_number` and `email` are enforced as UNIQUE + NOT NULL instead.

### Trade-off 2: `raw_student_import` is intentionally not normalized

**Decision:** Keep `raw_student_import` as a flat staging table without foreign keys to `batches`.

**Reasoning:** During bulk import, the batch associated with a student may not yet exist in the database, or the batch code may be invalid. Enforcing a foreign key constraint at the staging stage would block valid imports pending batch creation. Validation and normalization happen downstream when records are promoted to `students`.

### Trade-off 3: `contest_id` is nullable in `submissions`

**Decision:** Allow `contest_id` to be NULL in `submissions`.

**Reasoning:** Students can practice problems outside of a contest context. A mandatory `contest_id` would prevent recording these practice attempts. NULL explicitly signals "this was a practice submission, not contest-linked."

### Trade-off 4: `operation_requests` has no FK to a users table

**Decision:** `requested_by` is stored as a plain text value rather than a foreign key.

**Reasoning:** The raw data does not include an `admin_users` or `instructors` table. Rather than create a placeholder, we store the identifier as a text field and note that in a production system, this should reference an `admins` or `users` table.

### Trade-off 5: Design is approximately in 3NF

The schema is designed to satisfy 3NF across all main tables. Full denormalization is only intentionally applied to `raw_student_import` for staging purposes. No further decomposition beyond 3NF (e.g. BCNF, 4NF) was pursued because:
- There are no multi-valued dependencies identified.
- Further decomposition would add complexity without meaningful data integrity benefit at this dataset scale.
