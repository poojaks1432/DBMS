# CodeJudge Database — Part 1: Relational Design, Keys & Normalization

## Overview

This repository contains the relational database design for the **CodeJudge** platform — an online coding assessment system used by educational institutions to manage students, courses, contests, submissions, and grading.

The raw data was provided as a SQLite database (`codejudge_raw.db`) containing 16 tables with real-world educational data.

## Repository Structure

```
.
├── README.md                    # This file
├── schema.sql                   # SQL DDL to create the normalized database
├── schema_explanation.md        # What each table/column means
├── keys_and_relationships.md    # Primary, foreign, candidate, composite keys
├── normalization_notes.md       # 1NF, 2NF, 3NF analysis and design decisions
├── erd.md                       # Entity-Relationship Diagram (text format)
└── assumptions.md               # Assumptions made during design
```

## Quick Summary

| Table | Rows | Purpose |
|---|---|---|
| students | 320 | Registered students |
| batches | 6 | Academic cohorts |
| courses | 10 | Subjects offered |
| enrollments | 719 | Student–course registrations |
| sessions | 48 | Lecture/lab sessions per course |
| attendance | 2352 | Per-student session attendance |
| problems | 67 | Coding problems |
| test_cases | 330 | Input/output test cases per problem |
| contests | 12 | Timed coding contests |
| contest_problems | 63 | Problems assigned to contests |
| submissions | 2501 | Student code submissions |
| test_results | 9673 | Per-test-case evaluation results |
| regrade_requests | 80 | Student-raised re-evaluation requests |
| plagiarism_flags | 60 | Similarity detection records |
| operation_requests | 35 | Admin data change audit log |
| raw_student_import | 80 | Staging table for bulk student imports |
