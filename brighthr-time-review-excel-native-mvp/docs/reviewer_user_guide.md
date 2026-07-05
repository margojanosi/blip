# Reviewer User Guide (Non-Technical)

## Goal
Use this workbook to quickly find likely time log issues that need manual confirmation.

## What to do each cycle
1. Open workbook.
2. Go to **Raw BrightHR Export** and paste latest BrightHR CSV rows.
3. Refresh data (Data > Refresh All).
4. Open **Exception Report**.
5. Filter `Status = Open`.
6. Review each row and check BrightHR.
7. Update `Status` and `Reviewer Notes`.

## Status values
- Open
- Confirmed Correct
- Corrected in BrightHR
- Payroll Adjustment Needed
- Escalated
- Closed

## Important controls
- Workbook flags possible issues only.
- Workbook does **not** change BrightHR.
- Workbook does **not** approve payroll.
- Workbook does **not** submit data to Dayforce.
- Human review is required for every exception.

## Tips
- Start with `High` severity rows.
- Use employee/date filters to batch-review quickly.
- Save reviewed copy as audit evidence.
