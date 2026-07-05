# Workbook Design

## Tabs
1. Instructions
2. Raw BrightHR Export
3. Exception Rules
4. Employee Rules
5. Normalized Time Logs
6. Exception Report
7. Summary
8. Review Log

## Data flow
1. User imports/pastes CSV rows into `tblRawBrightHRExport`.
2. Power Query `q_raw_bright_hr_export` reads source table.
3. `q_normalized_time_logs` cleans and calculates fields.
4. Exception queries derive issue-specific records.
5. `q_exception_report` appends all exceptions.
6. `q_review_log` provides refresh/audit context.
7. Summary tab reads exception and normalized outputs via pivot/formula tables.

## Security and control model
- Read/flag only: no external writeback actions.
- Human approval required for any corrections.
- BrightHR remains source of truth.
