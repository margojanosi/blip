# Workbook Tab Specification

## 1) Instructions
Contains usage steps:
1. Paste/import BrightHR CSV.
2. Refresh workbook queries.
3. Review Exception Report.
4. Confirm/correct records in BrightHR manually.
5. Save reviewed workbook for audit trail.

Warning text must state workbook does not approve payroll, edit BrightHR, or submit to Dayforce.

## 2) Raw BrightHR Export
- Table: `tblRawBrightHRExport`
- Includes sample fake data and required columns.

## 3) Exception Rules
- Table: `tblExceptionRules`
- Stores editable thresholds and on/off controls.

## 4) Employee Rules
- Table: `tblEmployeeRules`
- Optional overrides; can remain empty.

## 5) Normalized Time Logs
- Loaded from `q_normalized_time_logs`.
- Displays cleaned fields + calculated shift/paid hours + warnings.

## 6) Exception Report
- Loaded from `q_exception_report`.
- Default status `Open`.
- Conditional formatting by severity (High/Medium/Low).

## 7) Summary
- Aggregates counts by status, severity, type, employee.
- Designed for non-technical reviewers.

## 8) Review Log
- Loaded from `q_review_log`.
- Captures refresh timestamp, counts, enabled rules, and assumptions notes.
