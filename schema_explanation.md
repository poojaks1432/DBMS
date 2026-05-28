# Schema Explanation — CodeJudge Platform

This document explains each table in the CodeJudge relational database: what it represents, what each column stores, and which columns identify records or link tables together.

---

## 1. `students`
Represents individual learners registered on the platform.

| Column | Meaning |
|---|---|
| `student_id` | Unique identifier for each student (e.g. `S0001`). Primary key. |
| `roll_number` | Institutional roll number (e.g. `CJ250001`). Must be unique. |
| `full_name` | Student's full name. |
| `email` | Contact email. Must be unique. |
| `batch_id` | Which batch the student belongs to. Foreign key → `batches`. |
| `admission_date` | Date the student was admitted. |
| `enrollment_status` | Current status: `active`, `graduated`, `dropped`, etc. |
| `graduation_year` | Expected or actual graduation year. |

**Normalization note:** Student data is fully separated from batch details, avoiding repeated batch info per student.

---

## 2. `batches`
Represents academic cohorts (groups of students admitted together).

| Column | Meaning |
|---|---|
| `batch_id` | Unique batch identifier (e.g. `B001`). Primary key. |
| `batch_code` | Human-readable code (e.g. `CSE2025A`). Candidate key. |
| `program` | Degree program (e.g. `B.Tech CSE`, `B.Tech AIML`). |
| `start_date` | Batch start date. |
| `end_date` | Batch end date. |
| `batch_status` | Current status: `active`, `completed`, etc. |

---

## 3. `courses`
Represents academic subjects or modules taught on the platform.

| Column | Meaning |
|---|---|
| `course_id` | Unique course identifier (e.g. `C001`). Primary key. |
| `course_code` | Short code (e.g. `CS101`). Candidate key. |
| `course_title` | Full course name (e.g. `Programming Fundamentals`). |
| `course_status` | Whether the course is `active` or `inactive`. |
| `credit_hours` | Number of academic credits. |

---

## 4. `enrollments`
Maps students to courses. Each row is one student registered in one course.

| Column | Meaning |
|---|---|
| `enrollment_id` | Unique enrollment record identifier. Primary key. |
| `student_id` | Which student. Foreign key → `students`. |
| `course_id` | Which course. Foreign key → `courses`. |
| `enrolled_on` | Date of enrollment. |
| `enrollment_status` | `active`, `dropped`, `completed`, etc. |
| `final_grade` | Grade assigned at the end of the course (may be NULL mid-course). |

**Note:** The combination `(student_id, course_id)` should be unique — a student should not be enrolled in the same course twice at the same time.

---

## 5. `sessions`
Represents individual lecture or lab sessions scheduled under a course.

| Column | Meaning |
|---|---|
| `session_id` | Unique session identifier. Primary key. |
| `course_id` | Which course this session belongs to. Foreign key → `courses`. |
| `session_title` | Name or topic of the session. |
| `session_date` | Date the session is held. |
| `session_type` | `lecture`, `lab`, `workshop`, etc. |

---

## 6. `attendance`
Records whether each student attended each session.

| Column | Meaning |
|---|---|
| `attendance_id` | Unique attendance record. Primary key. |
| `session_id` | Which session. Foreign key → `sessions`. |
| `student_id` | Which student. Foreign key → `students`. |
| `attendance_status` | `present`, `absent`, `late`, etc. |
| `marked_at` | Timestamp when attendance was marked. |

**Note:** `(session_id, student_id)` should be unique — one attendance record per student per session.

---

## 7. `problems`
Represents coding problems available on the platform.

| Column | Meaning |
|---|---|
| `problem_id` | Unique problem identifier (e.g. `P0001`). Primary key. |
| `course_id` | Course this problem belongs to. Foreign key → `courses`. |
| `problem_code` | Short code (e.g. `CS101_P01`). Candidate key. |
| `title` | Problem title. |
| `difficulty` | `Easy`, `Medium`, or `Hard`. |
| `max_score` | Maximum points a student can earn. |
| `created_at` | Date the problem was created. |
| `is_active` | Whether the problem is visible/active (`1`/`0`). |

---

## 8. `test_cases`
Defines the input/output test cases used to evaluate a submission for a given problem.

| Column | Meaning |
|---|---|
| `test_case_id` | Unique test case identifier. Primary key. |
| `problem_id` | Which problem this test case belongs to. Foreign key → `problems`. |
| `case_no` | Ordering number of the test case within the problem. |
| `input_label` | Label/name for the input. |
| `expected_output_label` | Label/name for the expected output. |
| `points` | Points awarded if the test case passes. |
| `is_hidden` | Whether this test case is hidden from students (`1`/`0`). |

---

## 9. `contests`
Represents a timed coding event containing multiple problems.

| Column | Meaning |
|---|---|
| `contest_id` | Unique contest identifier (e.g. `CT001`). Primary key. |
| `course_id` | Course the contest is part of. Foreign key → `courses`. |
| `contest_title` | Name of the contest. |
| `start_time` | Contest start datetime. |
| `end_time` | Contest end datetime. |
| `contest_status` | `upcoming`, `live`, `completed`, etc. |

---

## 10. `contest_problems`
Mapping table that assigns problems to contests (many-to-many relationship).

| Column | Meaning |
|---|---|
| `contest_id` | Which contest. Foreign key → `contests`. |
| `problem_id` | Which problem. Foreign key → `problems`. |
| `problem_order` | Display order of the problem within the contest. |

**Composite primary key:** `(contest_id, problem_id)`.

---

## 11. `submissions`
Records each time a student submits code for a problem, optionally within a contest.

| Column | Meaning |
|---|---|
| `submission_id` | Unique submission identifier (e.g. `SUB000001`). Primary key. |
| `student_id` | Who submitted. Foreign key → `students`. |
| `problem_id` | Which problem. Foreign key → `problems`. |
| `contest_id` | Which contest (may be empty for practice submissions). Foreign key → `contests`. |
| `language` | Programming language used (e.g. `Python`, `C`, `JavaScript`). |
| `submitted_at` | Timestamp of submission. |
| `status` | Evaluation result: `Accepted`, `Wrong Answer`, `TLE`, etc. |
| `score` | Points earned for this submission. |
| `runtime_ms` | Total execution time in milliseconds. |

---

## 12. `test_results`
Stores the per-test-case evaluation outcome for each submission.

| Column | Meaning |
|---|---|
| `result_id` | Unique result record. Primary key. |
| `submission_id` | Which submission. Foreign key → `submissions`. |
| `test_case_id` | Which test case was run. Foreign key → `test_cases`. |
| `result_status` | `Passed`, `Failed`, `TLE`, `Runtime Error`, etc. |
| `runtime_ms` | Time taken for this specific test case. |
| `memory_kb` | Memory used in kilobytes. |
| `awarded_points` | Points given for this test case. |

**Note:** `(submission_id, test_case_id)` should be unique.

---

## 13. `regrade_requests`
Records requests by students to have a submission re-evaluated.

| Column | Meaning |
|---|---|
| `request_id` | Unique request identifier. Primary key. |
| `submission_id` | Which submission is being disputed. Foreign key → `submissions`. |
| `student_id` | Who raised the request. Foreign key → `students`. |
| `requested_at` | When the request was raised. |
| `reason` | Student's stated reason. |
| `request_status` | `pending`, `approved`, `rejected`, etc. |
| `resolved_at` | When the request was resolved (NULL if pending). |

---

## 14. `plagiarism_flags`
Tracks pairs of submissions flagged for high similarity (potential plagiarism).

| Column | Meaning |
|---|---|
| `flag_id` | Unique flag identifier. Primary key. |
| `submission_id` | First submission in the pair. Foreign key → `submissions`. |
| `matched_submission_id` | Second submission in the pair. Foreign key → `submissions`. |
| `similarity_score` | Computed similarity percentage. |
| `flag_status` | `open`, `resolved`, `dismissed`, etc. |
| `created_at` | When the flag was created. |

---

## 15. `operation_requests`
An audit log for admin-level operations that modify sensitive data (e.g. grade changes).

| Column | Meaning |
|---|---|
| `operation_id` | Unique operation record. Primary key. |
| `requested_by` | User who requested the change. |
| `operation_type` | Type of action (e.g. `UPDATE`, `DELETE`). |
| `target_table` | Which table is being modified. |
| `target_record_id` | ID of the affected record. |
| `requested_at` | When the request was made. |
| `reason` | Justification for the operation. |
| `approval_status` | `pending`, `approved`, `rejected`. |
| `executed_at` | When it was actually executed (NULL if not yet). |

---

## 16. `raw_student_import`
A staging table used to hold bulk-imported student records before they are validated and moved to the `students` table.

| Column | Meaning |
|---|---|
| `raw_row_id` | Unique staging row identifier. Primary key. |
| `roll_number` | Imported roll number (may be invalid). |
| `full_name` | Student's name as imported. |
| `email` | Email as imported. |
| `batch_code` | Batch code string (not yet linked to `batches` table). |
| `admission_date` | Admission date as imported. |
| `import_status` | `new`, `processed`, `rejected`. |
| `import_notes` | Notes on why a record was rejected or flagged. |

**Design note:** This table is intentionally denormalized — it is a raw intake buffer, not a production table. Once validated, records are promoted to `students` and linked via `batch_id`.
