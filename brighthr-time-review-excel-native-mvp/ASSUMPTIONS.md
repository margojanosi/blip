# Assumptions

1. BrightHR CSV exports are expected to use native BrightHR headers in `tblRawBrightHRExport` (First Name, Last Name, Job Title, Team(s), Blip Type, Clock In Date, Clock In Time, Clock In Location, Clock Out Date, Clock Out Time, Clock Out Location, Total Duration, Total Excluding Breaks, Notes, Payroll Number, SI Number, Employee Address).
2. Missing or invalid date/time values are not auto-corrected; they are surfaced as warnings and exceptions where applicable.
3. Shift duration is calculated from `Clock In` and `Clock Out`; `Clock Out Date` is used when present, otherwise overnight shifts are inferred only when `Clock Out` is earlier than `Clock In`.
4. Break minutes are derived from `Total Duration - Total Excluding Breaks` when explicit break fields are not present; negative results are preserved as data quality signals.
5. `tblExceptionRules` is the default rules authority; employee-specific overrides are optional and only used when active and populated.
6. The MVP supports manual review only and does not perform outbound updates to BrightHR/Dayforce.
7. Sample data is fake and for demonstration/testing only.
