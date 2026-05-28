# Entity-Relationship Diagram — CodeJudge Platform

## Text ERD (Markdown Format)

```
BATCHES
  - batch_id (PK)
  - batch_code (UNIQUE)
  - program
  - start_date
  - end_date
  - batch_status
       |
       | 1
       |
       * (many students per batch)
STUDENTS
  - student_id (PK)
  - roll_number (UNIQUE)
  - full_name
  - email (UNIQUE)
  - batch_id (FK → batches)
  - admission_date
  - enrollment_status
  - graduation_year
       |                          \
       | (via enrollments)         \ (via submissions)
       *                            *
ENROLLMENTS ——————————— COURSES      SUBMISSIONS ————————— PROBLEMS
  - enrollment_id (PK)   - course_id (PK)  - submission_id (PK)  - problem_id (PK)
  - student_id (FK)      - course_code     - student_id (FK)     - course_id (FK)
  - course_id (FK)       - course_title    - problem_id (FK)     - problem_code
  - enrolled_on          - course_status   - contest_id (FK,NULL)- title
  - enrollment_status    - credit_hours    - language            - difficulty
  - final_grade               |            - submitted_at        - max_score
                              |            - status              - is_active
                    ┌─────────┴──────────┐ - score                    |
                    |                    |                             |
                 SESSIONS            CONTESTS                   TEST_CASES
               - session_id (PK)   - contest_id (PK)           - test_case_id (PK)
               - course_id (FK)    - course_id (FK)            - problem_id (FK)
               - session_title     - contest_title             - case_no
               - session_date      - start_time                - points
               - session_type      - end_time                  - is_hidden
                    |              - contest_status                   |
                    |                    |                            |
                ATTENDANCE        CONTEST_PROBLEMS            TEST_RESULTS
              - attendance_id     - contest_id (FK) ←PK       - result_id (PK)
              - session_id (FK)   - problem_id (FK) ←PK       - submission_id (FK)
              - student_id (FK)   - problem_order             - test_case_id (FK)
              - status                                        - result_status
              - marked_at                                     - awarded_points


SUBMISSIONS also linked to:
  ├── REGRADE_REQUESTS
  │     - request_id (PK)
  │     - submission_id (FK)
  │     - student_id (FK)
  │     - reason, status
  │
  └── PLAGIARISM_FLAGS
        - flag_id (PK)
        - submission_id (FK)
        - matched_submission_id (FK → submissions)
        - similarity_score
        - flag_status

STANDALONE / AUDIT:
  OPERATION_REQUESTS           RAW_STUDENT_IMPORT
  - operation_id (PK)          - raw_row_id (PK)
  - requested_by               - roll_number
  - operation_type             - full_name
  - target_table               - email
  - approval_status            - batch_code (text, not FK)
                               - import_status
```

---

## Relationship Summary

| From | Relationship | To | Via |
|---|---|---|---|
| batches | 1 → many | students | `students.batch_id` |
| students | many ↔ many | courses | `enrollments` |
| courses | 1 → many | sessions | `sessions.course_id` |
| students | many ↔ many | sessions | `attendance` |
| courses | 1 → many | problems | `problems.course_id` |
| courses | 1 → many | contests | `contests.course_id` |
| contests | many ↔ many | problems | `contest_problems` |
| students | 1 → many | submissions | `submissions.student_id` |
| problems | 1 → many | submissions | `submissions.problem_id` |
| problems | 1 → many | test_cases | `test_cases.problem_id` |
| submissions | many ↔ many | test_cases | `test_results` |
| submissions | 1 → many | regrade_requests | `regrade_requests.submission_id` |
| submissions | 1 → many | plagiarism_flags | `plagiarism_flags.submission_id` |
