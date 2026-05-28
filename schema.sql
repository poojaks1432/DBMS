-- ============================================================
-- CodeJudge Platform — Normalized SQL DDL Schema
-- ============================================================

-- ------------------------------------------------------------
-- 1. BATCHES
-- Academic cohorts (groups of students)
-- ------------------------------------------------------------
CREATE TABLE batches (
    batch_id     TEXT PRIMARY KEY,
    batch_code   TEXT NOT NULL UNIQUE,
    program      TEXT NOT NULL,
    start_date   DATE NOT NULL,
    end_date     DATE,
    batch_status TEXT NOT NULL DEFAULT 'active',
    CHECK (batch_status IN ('active', 'completed', 'cancelled')),
    CHECK (end_date IS NULL OR end_date > start_date)
);

-- ------------------------------------------------------------
-- 2. STUDENTS
-- Registered learners on the platform
-- ------------------------------------------------------------
CREATE TABLE students (
    student_id        TEXT PRIMARY KEY,
    roll_number       TEXT NOT NULL UNIQUE,
    full_name         TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    batch_id          TEXT NOT NULL,
    admission_date    DATE NOT NULL,
    enrollment_status TEXT NOT NULL DEFAULT 'active',
    graduation_year   INTEGER,
    FOREIGN KEY (batch_id) REFERENCES batches(batch_id),
    CHECK (enrollment_status IN ('active', 'graduated', 'dropped', 'suspended'))
);

-- ------------------------------------------------------------
-- 3. COURSES
-- Academic subjects/modules taught on the platform
-- ------------------------------------------------------------
CREATE TABLE courses (
    course_id     TEXT PRIMARY KEY,
    course_code   TEXT NOT NULL UNIQUE,
    course_title  TEXT NOT NULL,
    course_status TEXT NOT NULL DEFAULT 'active',
    credit_hours  INTEGER NOT NULL DEFAULT 3,
    CHECK (course_status IN ('active', 'inactive', 'archived')),
    CHECK (credit_hours > 0)
);

-- ------------------------------------------------------------
-- 4. ENROLLMENTS
-- Maps students to courses (many-to-many)
-- ------------------------------------------------------------
CREATE TABLE enrollments (
    enrollment_id     TEXT PRIMARY KEY,
    student_id        TEXT NOT NULL,
    course_id         TEXT NOT NULL,
    enrolled_on       DATE NOT NULL,
    enrollment_status TEXT NOT NULL DEFAULT 'active',
    final_grade       TEXT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    UNIQUE (student_id, course_id),
    CHECK (enrollment_status IN ('active', 'dropped', 'completed'))
);

-- ------------------------------------------------------------
-- 5. SESSIONS
-- Individual lecture/lab sessions scheduled under a course
-- ------------------------------------------------------------
CREATE TABLE sessions (
    session_id    TEXT PRIMARY KEY,
    course_id     TEXT NOT NULL,
    session_title TEXT,
    session_date  DATE NOT NULL,
    session_type  TEXT NOT NULL DEFAULT 'lecture',
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CHECK (session_type IN ('lecture', 'lab', 'workshop', 'quiz'))
);

-- ------------------------------------------------------------
-- 6. ATTENDANCE
-- Per-student attendance record for each session
-- ------------------------------------------------------------
CREATE TABLE attendance (
    attendance_id     TEXT PRIMARY KEY,
    session_id        TEXT NOT NULL,
    student_id        TEXT NOT NULL,
    attendance_status TEXT NOT NULL,
    marked_at         DATETIME,
    FOREIGN KEY (session_id) REFERENCES sessions(session_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    UNIQUE (session_id, student_id),
    CHECK (attendance_status IN ('present', 'absent', 'late', 'excused'))
);

-- ------------------------------------------------------------
-- 7. PROBLEMS
-- Coding problems available on the platform
-- ------------------------------------------------------------
CREATE TABLE problems (
    problem_id   TEXT PRIMARY KEY,
    course_id    TEXT NOT NULL,
    problem_code TEXT NOT NULL UNIQUE,
    title        TEXT NOT NULL,
    difficulty   TEXT NOT NULL DEFAULT 'Medium',
    max_score    INTEGER NOT NULL,
    created_at   DATE,
    is_active    INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CHECK (difficulty IN ('Easy', 'Medium', 'Hard')),
    CHECK (max_score > 0),
    CHECK (is_active IN (0, 1))
);

-- ------------------------------------------------------------
-- 8. TEST_CASES
-- Input/output test cases used to evaluate a problem submission
-- ------------------------------------------------------------
CREATE TABLE test_cases (
    test_case_id           TEXT PRIMARY KEY,
    problem_id             TEXT NOT NULL,
    case_no                INTEGER NOT NULL,
    input_label            TEXT,
    expected_output_label  TEXT,
    points                 INTEGER NOT NULL DEFAULT 0,
    is_hidden              INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (problem_id) REFERENCES problems(problem_id),
    UNIQUE (problem_id, case_no),
    CHECK (points >= 0),
    CHECK (is_hidden IN (0, 1))
);

-- ------------------------------------------------------------
-- 9. CONTESTS
-- Timed coding events containing multiple problems
-- ------------------------------------------------------------
CREATE TABLE contests (
    contest_id     TEXT PRIMARY KEY,
    course_id      TEXT NOT NULL,
    contest_title  TEXT NOT NULL,
    start_time     DATETIME NOT NULL,
    end_time       DATETIME NOT NULL,
    contest_status TEXT NOT NULL DEFAULT 'upcoming',
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    CHECK (end_time > start_time),
    CHECK (contest_status IN ('upcoming', 'live', 'completed', 'cancelled'))
);

-- ------------------------------------------------------------
-- 10. CONTEST_PROBLEMS
-- Mapping table: problems assigned to contests (many-to-many)
-- ------------------------------------------------------------
CREATE TABLE contest_problems (
    contest_id     TEXT NOT NULL,
    problem_id     TEXT NOT NULL,
    problem_order  INTEGER,
    PRIMARY KEY (contest_id, problem_id),
    FOREIGN KEY (contest_id) REFERENCES contests(contest_id),
    FOREIGN KEY (problem_id) REFERENCES problems(problem_id)
);

-- ------------------------------------------------------------
-- 11. SUBMISSIONS
-- Student code submissions for problems (optionally in a contest)
-- ------------------------------------------------------------
CREATE TABLE submissions (
    submission_id TEXT PRIMARY KEY,
    student_id    TEXT NOT NULL,
    problem_id    TEXT NOT NULL,
    contest_id    TEXT,                  -- NULL for practice submissions
    language      TEXT NOT NULL,
    submitted_at  DATETIME NOT NULL,
    status        TEXT NOT NULL,
    score         INTEGER NOT NULL DEFAULT 0,
    runtime_ms    INTEGER,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (problem_id) REFERENCES problems(problem_id),
    FOREIGN KEY (contest_id) REFERENCES contests(contest_id),
    CHECK (score >= 0),
    CHECK (status IN ('Accepted', 'Wrong Answer', 'TLE', 'Runtime Error', 'Compilation Error', 'Partial'))
);

-- ------------------------------------------------------------
-- 12. TEST_RESULTS
-- Per-test-case evaluation result for each submission
-- ------------------------------------------------------------
CREATE TABLE test_results (
    result_id      TEXT PRIMARY KEY,
    submission_id  TEXT NOT NULL,
    test_case_id   TEXT NOT NULL,
    result_status  TEXT NOT NULL,
    runtime_ms     INTEGER,
    memory_kb      INTEGER,
    awarded_points INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (test_case_id) REFERENCES test_cases(test_case_id),
    UNIQUE (submission_id, test_case_id),
    CHECK (awarded_points >= 0)
);

-- ------------------------------------------------------------
-- 13. REGRADE_REQUESTS
-- Requests by students to re-evaluate a submission
-- ------------------------------------------------------------
CREATE TABLE regrade_requests (
    request_id     TEXT PRIMARY KEY,
    submission_id  TEXT NOT NULL,
    student_id     TEXT NOT NULL,
    requested_at   DATETIME NOT NULL,
    reason         TEXT,
    request_status TEXT NOT NULL DEFAULT 'pending',
    resolved_at    DATETIME,
    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    CHECK (request_status IN ('pending', 'approved', 'rejected', 'cancelled'))
);

-- ------------------------------------------------------------
-- 14. PLAGIARISM_FLAGS
-- Pairs of submissions flagged for high code similarity
-- ------------------------------------------------------------
CREATE TABLE plagiarism_flags (
    flag_id               TEXT PRIMARY KEY,
    submission_id         TEXT NOT NULL,
    matched_submission_id TEXT NOT NULL,
    similarity_score      REAL NOT NULL,
    flag_status           TEXT NOT NULL DEFAULT 'open',
    created_at            DATETIME NOT NULL,
    FOREIGN KEY (submission_id) REFERENCES submissions(submission_id),
    FOREIGN KEY (matched_submission_id) REFERENCES submissions(submission_id),
    CHECK (similarity_score BETWEEN 0 AND 100),
    CHECK (submission_id <> matched_submission_id),
    CHECK (flag_status IN ('open', 'resolved', 'dismissed'))
);

-- ------------------------------------------------------------
-- 15. OPERATION_REQUESTS
-- Audit log for admin-level data modification requests
-- ------------------------------------------------------------
CREATE TABLE operation_requests (
    operation_id      TEXT PRIMARY KEY,
    requested_by      TEXT NOT NULL,
    operation_type    TEXT NOT NULL,
    target_table      TEXT NOT NULL,
    target_record_id  TEXT NOT NULL,
    requested_at      DATETIME NOT NULL,
    reason            TEXT,
    approval_status   TEXT NOT NULL DEFAULT 'pending',
    executed_at       DATETIME,
    CHECK (approval_status IN ('pending', 'approved', 'rejected')),
    CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- ------------------------------------------------------------
-- 16. RAW_STUDENT_IMPORT
-- Staging table for bulk student imports (intentionally flat)
-- ------------------------------------------------------------
CREATE TABLE raw_student_import (
    raw_row_id      TEXT PRIMARY KEY,
    roll_number     TEXT,
    full_name       TEXT,
    email           TEXT,
    batch_code      TEXT,           -- Not FK; may not yet exist in batches
    admission_date  TEXT,
    import_status   TEXT NOT NULL DEFAULT 'new',
    import_notes    TEXT,
    CHECK (import_status IN ('new', 'processed', 'rejected'))
);
