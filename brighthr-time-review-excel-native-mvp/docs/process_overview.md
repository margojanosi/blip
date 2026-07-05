# Process Overview

1. Load raw BrightHR CSV data into `tblRawBrightHRExport`.
2. Refresh Power Query queries.
3. Review `Exception Report` records sorted by severity and status.
4. Validate each flagged record manually in BrightHR.
5. Update review statuses and notes.
6. Save workbook copy for audit trail.

Key control: this workbook is review-only and never writes back to BrightHR or payroll systems.
