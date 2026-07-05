# BrightHR Time Review Excel Native MVP

## What this project is
An **Excel-native MVP scaffold** for reviewing BrightHR/Blip time log CSV exports and flagging likely exceptions for human review.

## What this project is not
- Not a payroll approval system.
- Not an integration that edits BrightHR.
- Not a Dayforce submission tool.
- Not a Python/Node analysis app.

## Why analysis is Excel-native
The MVP keeps analysis in Excel using:
- workbook tables for inputs and rules,
- Power Query M for normalization and exception generation,
- Excel formatting, filtering, and summaries for reviewer workflows.

## Quick Start
1. Create a new blank workbook in Excel Desktop.
2. Run `office_scripts/scaffold_workbook.ts` (or optional VBA equivalent) to create tabs/tables.
3. Add each `.pq` file from `power_query/` into Power Query (Advanced Editor).
4. Load queries to the target sheets listed in `docs/build_workbook_from_repo.md`.
5. Import/paste BrightHR CSV data to `tblRawBrightHRExport`.
6. Refresh all queries.
7. Review `Exception Report` and update review statuses.

## How to paste/import BrightHR CSV data
- Open `Raw BrightHR Export` tab.
- Use Excel Data import or paste CSV rows into `tblRawBrightHRExport`.
- Keep the native BrightHR header row unchanged:
  `First Name | Last Name | Job Title | Team(s) | Blip Type | Clock In Date | Clock In Time | Clock In Location | Clock Out Date | Clock Out Time | Clock Out Location | Total Duration | Total Excluding Breaks | Notes | Payroll Number | SI Number | Employee Address`.

## How to refresh Power Query
- Excel Desktop: **Data > Refresh All**.
- Optional helper: run `office_scripts/refresh_and_format_workbook.ts`.

## How to review exceptions
- Open `Exception Report`.
- Filter by Severity, Exception Type, Employee, or Status.
- Add Reviewer Notes and update Status.
- Confirm/correct source records manually in BrightHR.

## How to update rules
- Open `Exception Rules` tab.
- Edit `tblExceptionRules` rows (Value, Severity, Enabled).
- Refresh queries.

## How to add employee-specific overrides
- Open `Employee Rules` tab.
- Add active rows in `tblEmployeeRules`.
- Leave blank if no overrides are needed (MVP works with empty table).

## MVP boundaries
- Flags possible issues only.
- Does not correct BrightHR.
- Does not approve payroll.
- Does not submit to Dayforce.
- Human reviewer must confirm each exception.
- BrightHR remains source of truth until formal integration approval.

## Known limitations
- Rule logic depends on imported CSV data quality.
- Overnight and malformed timestamps are handled conservatively and may need manual review.
- Employee override behavior is basic and intended for MVP iteration.

## Future enhancements
- SharePoint workbook storage.
- Power Automate refresh trigger.
- Teams notification when exceptions exist.
- BrightHR API integration if approved.
- Dayforce import preparation.
- Historical trend reporting.
- Manager sign-off workflow.
