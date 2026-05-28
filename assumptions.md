# Assumptions — CodeJudge Platform Design

This document records the assumptions made while designing the relational schema from the raw CodeJudge dataset.

---

## 1. Primary Key Strategy

**Assumption:** Surrogate text IDs (e.g. `S0001`, `C001`, `SUB000001`) are used as primary keys throughout.

**Reason:** Natural keys like `roll_number` and `email` can change over a student's lifetime. Surrogate keys are immutable and safe for foreign key references. Natural keys are enforced as UNIQUE + NOT NULL constraints (acting as alternate keys).

---

## 2. `contest_id` is Optional in `submissions`

**Assumption:** A submission with an empty `contest_id` in the raw data is a **practice submission** — a student solving a problem outside a formal contest.

**Reason:** Several rows in the raw `submissions` table have an empty `contest_id`. This is meaningful, not an error — students can attempt problems for practice. The column is NULLable with a foreign key constraint applied only when a value is present.

---

## 3. `raw_student_import` is a Staging Table

**Assumption:** This table is not a production entity. It represents a data intake buffer used for bulk imports before validation.

**Reason:** The `batch_code` in `raw_student_import` does not match any `batch_id` in `batches` (it uses codes like `BCA2025A` which aren't in the batch table). `import_status` values (`new`, `rejected`) confirm this is a pre-processing stage. No foreign key constraints are applied to this table.

---

## 4. `operation_requests.requested_by` References No Users Table

**Assumption:** The platform likely has an admin/instructor user system, but no such table exists in the raw data.

**Reason:** `requested_by` is stored as a text identifier. In a full production system, this should be a foreign key to an `admin_users` or `staff` table. For this design, it is treated as a text audit field.

---

## 5. Difficulty Values Are Fixed

**Assumption:** Problem difficulty is restricted to `Easy`, `Medium`, `Hard`.

**Reason:** All rows observed in the raw `problems` table use only these three values. A CHECK constraint is applied to enforce this.

---

## 6. A Student May Be Enrolled in Multiple Courses

**Assumption:** A student can be enrolled in many courses simultaneously, and the `enrollments` table tracks each enrollment independently.

**Reason:** 719 enrollment records exist for 320 students and 10 courses, which implies multiple enrollments per student. The unique constraint on `(student_id, course_id)` prevents a student from enrolling in the same course twice at the same time.

---

## 7. Submissions Outside Contests Are Valid

**Assumption:** Submissions that do not reference any contest are valid practice attempts and should be stored and evaluated normally.

**Reason:** The raw data has submissions with empty `contest_id`. Excluding these would lose meaningful student activity data.

---

## 8. `plagiarism_flags` Compares Two Submissions Unidirectionally

**Assumption:** The pair `(submission_id, matched_submission_id)` is directional — we do not enforce that the reverse pair also exists.

**Reason:** The raw data shows single-direction flag records. Deduplication and bidirectional handling would be an application-level concern, not a schema constraint.

---

## 9. `final_grade` May Be NULL

**Assumption:** `final_grade` in `enrollments` is NULL for students who have not yet completed the course.

**Reason:** Grading happens at the end of a course. Students currently enrolled would have no grade yet. This is expected and not a data quality issue.

---

## 10. All IDs Are Text, Not Auto-increment Integers

**Assumption:** All primary keys are stored as TEXT (matching the raw data format like `S0001`, `CT011`).

**Reason:** The raw database uses text IDs consistently. Converting to integers would break compatibility with the existing dataset and any application code relying on the original ID format.
