# Keys and Relationships — CodeJudge Platform

This document identifies the primary keys, candidate keys, alternate keys, foreign keys, composite keys, and important constraints for every main table.

---

## 1. `students`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `student_id` | Surrogate ID, uniquely identifies each student |
| **Candidate Key** | `roll_number` | Institutionally unique; could serve as PK |
| **Candidate Key** | `email` | Globally unique per student |
| **Alternate Keys** | `roll_number`, `email` | Both are unique but not chosen as PK |
| **Foreign Key** | `batch_id` → `batches(batch_id)` | Links student to their academic cohort |
| **NOT NULL** | `student_id`, `roll_number`, `full_name`, `email`, `batch_id` | Core identity fields must always be present |
| **UNIQUE** | `roll_number`, `email` | Prevents duplicate registrations |
| **CHECK** | `enrollment_status IN ('active','graduated','dropped','suspended')` | Restricts to known status values |

---

## 2. `batches`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `batch_id` | Surrogate ID |
| **Candidate Key** | `batch_code` | Human-readable unique code like `CSE2025A` |
| **Alternate Key** | `batch_code` | Unique but not chosen as PK |
| **NOT NULL** | `batch_id`, `batch_code`, `program`, `start_date` | Required to define a batch |
| **UNIQUE** | `batch_code` | No two batches with the same code |
| **CHECK** | `batch_status IN ('active','completed','cancelled')` | Valid lifecycle states only |

---

## 3. `courses`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `course_id` | Surrogate ID |
| **Candidate Key** | `course_code` | e.g. `CS101`; unique per course |
| **Alternate Key** | `course_code` | Not chosen as PK but must be unique |
| **NOT NULL** | `course_id`, `course_code`, `course_title` | A course must have identity and name |
| **UNIQUE** | `course_code` | No duplicate course codes |
| **CHECK** | `course_status IN ('active','inactive','archived')` | Only known statuses |

---

## 4. `enrollments`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `enrollment_id` | Surrogate ID |
| **Composite Candidate Key** | `(student_id, course_id)` | A student can only be enrolled in a course once |
| **Foreign Key** | `student_id` → `students(student_id)` | Must refer to a real student |
| **Foreign Key** | `course_id` → `courses(course_id)` | Must refer to a real course |
| **NOT NULL** | `enrollment_id`, `student_id`, `course_id`, `enrolled_on` | Core enrollment data |
| **UNIQUE** | `(student_id, course_id)` | Prevents duplicate enrollments |
| **CHECK** | `enrollment_status IN ('active','dropped','completed')` | Valid states |

---

## 5. `sessions`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `session_id` | Surrogate ID |
| **Foreign Key** | `course_id` → `courses(course_id)` | Every session belongs to a course |
| **NOT NULL** | `session_id`, `course_id`, `session_date` | Must know when and for which course |
| **CHECK** | `session_type IN ('lecture','lab','workshop','quiz')` | Controlled vocabulary |

---

## 6. `attendance`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `attendance_id` | Surrogate ID |
| **Composite Candidate Key** | `(session_id, student_id)` | One record per student per session |
| **Foreign Key** | `session_id` → `sessions(session_id)` | Must refer to a real session |
| **Foreign Key** | `student_id` → `students(student_id)` | Must refer to a real student |
| **NOT NULL** | `attendance_id`, `session_id`, `student_id`, `attendance_status` | All fields are essential |
| **UNIQUE** | `(session_id, student_id)` | No duplicate entries |
| **CHECK** | `attendance_status IN ('present','absent','late','excused')` | Known statuses only |

---

## 7. `problems`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `problem_id` | Surrogate ID |
| **Candidate Key** | `problem_code` | e.g. `CS101_P01`; unique per problem |
| **Alternate Key** | `problem_code` | Unique but not the PK |
| **Foreign Key** | `course_id` → `courses(course_id)` | Problem belongs to a course |
| **NOT NULL** | `problem_id`, `course_id`, `problem_code`, `title`, `max_score` | Required to define a problem |
| **UNIQUE** | `problem_code` | Prevents duplicate problem codes |
| **CHECK** | `difficulty IN ('Easy','Medium','Hard')` | Controlled difficulty levels |
| **CHECK** | `max_score > 0` | Score must be positive |

---

## 8. `test_cases`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `test_case_id` | Surrogate ID |
| **Composite Candidate Key** | `(problem_id, case_no)` | Case numbers are unique within a problem |
| **Foreign Key** | `problem_id` → `problems(problem_id)` | Every test case belongs to a problem |
| **NOT NULL** | `test_case_id`, `problem_id`, `case_no`, `points` | Core evaluation data |
| **UNIQUE** | `(problem_id, case_no)` | No duplicate case numbers per problem |
| **CHECK** | `points >= 0` | Points cannot be negative |

---

## 9. `contests`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `contest_id` | Surrogate ID |
| **Foreign Key** | `course_id` → `courses(course_id)` | Contest is tied to a course |
| **NOT NULL** | `contest_id`, `course_id`, `contest_title`, `start_time`, `end_time` | All required |
| **CHECK** | `end_time > start_time` | Contest must end after it starts |
| **CHECK** | `contest_status IN ('upcoming','live','completed','cancelled')` | Known states |

---

## 10. `contest_problems`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key (Composite)** | `(contest_id, problem_id)` | A problem appears in a contest only once |
| **Foreign Key** | `contest_id` → `contests(contest_id)` | Must link to a real contest |
| **Foreign Key** | `problem_id` → `problems(problem_id)` | Must link to a real problem |
| **NOT NULL** | Both FK columns | Required to define the mapping |

---

## 11. `submissions`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `submission_id` | Surrogate ID |
| **Foreign Key** | `student_id` → `students(student_id)` | Submission belongs to a student |
| **Foreign Key** | `problem_id` → `problems(problem_id)` | Submission targets a problem |
| **Foreign Key** | `contest_id` → `contests(contest_id)` | Optional; NULL for practice submissions |
| **NOT NULL** | `submission_id`, `student_id`, `problem_id`, `language`, `submitted_at` | Required fields |
| **CHECK** | `score >= 0` | No negative scores |
| **CHECK** | `status IN ('Accepted','Wrong Answer','TLE','Runtime Error','Compilation Error')` | Evaluation outcomes |

---

## 12. `test_results`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `result_id` | Surrogate ID |
| **Composite Candidate Key** | `(submission_id, test_case_id)` | Each test case evaluated once per submission |
| **Foreign Key** | `submission_id` → `submissions(submission_id)` | Result tied to a submission |
| **Foreign Key** | `test_case_id` → `test_cases(test_case_id)` | Result tied to a specific test case |
| **NOT NULL** | `result_id`, `submission_id`, `test_case_id`, `result_status` | All required |
| **UNIQUE** | `(submission_id, test_case_id)` | One result per test case per submission |

---

## 13. `regrade_requests`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `request_id` | Surrogate ID |
| **Foreign Key** | `submission_id` → `submissions(submission_id)` | Links to the submission under review |
| **Foreign Key** | `student_id` → `students(student_id)` | Who raised the request |
| **NOT NULL** | `request_id`, `submission_id`, `student_id`, `requested_at` | Required |
| **CHECK** | `request_status IN ('pending','approved','rejected','cancelled')` | Known states |

---

## 14. `plagiarism_flags`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `flag_id` | Surrogate ID |
| **Foreign Key** | `submission_id` → `submissions(submission_id)` | First submission in the pair |
| **Foreign Key** | `matched_submission_id` → `submissions(submission_id)` | Second submission in the pair |
| **NOT NULL** | `flag_id`, `submission_id`, `matched_submission_id`, `similarity_score` | All needed to record a flag |
| **CHECK** | `similarity_score BETWEEN 0 AND 100` | Valid percentage range |
| **CHECK** | `submission_id <> matched_submission_id` | A submission can't be flagged against itself |

---

## 15. `operation_requests`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `operation_id` | Surrogate ID |
| **NOT NULL** | `operation_id`, `requested_by`, `operation_type`, `target_table`, `target_record_id`, `requested_at` | Required for audit completeness |
| **CHECK** | `approval_status IN ('pending','approved','rejected')` | Known states |

---

## 16. `raw_student_import`

| Key Type | Column(s) | Justification |
|---|---|---|
| **Primary Key** | `raw_row_id` | Surrogate ID for the staging row |
| **CHECK** | `import_status IN ('new','processed','rejected')` | Import lifecycle |

> Note: No foreign keys in this table — it is a raw staging buffer and data may not yet match production records.

---

## Entity Relationships Summary

| Relationship | Type | Via |
|---|---|---|
| students — batches | Many-to-One | `students.batch_id` |
| students — courses | Many-to-Many | `enrollments` |
| courses — sessions | One-to-Many | `sessions.course_id` |
| students — sessions | Many-to-Many | `attendance` |
| courses — problems | One-to-Many | `problems.course_id` |
| problems — test_cases | One-to-Many | `test_cases.problem_id` |
| courses — contests | One-to-Many | `contests.course_id` |
| contests — problems | Many-to-Many | `contest_problems` |
| students — problems | Many-to-Many | `submissions` |
| submissions — test_cases | Many-to-Many | `test_results` |
| students — submissions | One-to-Many | `submissions.student_id` |
| submissions — regrade_requests | One-to-Many | `regrade_requests.submission_id` |
| submissions — plagiarism_flags | One-to-Many | `plagiarism_flags.submission_id` |
