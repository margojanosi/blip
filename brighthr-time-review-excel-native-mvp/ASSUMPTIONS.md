# Assumptions

1. BrightHR CSV exports can be mapped to the sample raw columns defined in `tblRawBrightHRExport`.
2. Missing or invalid date/time values are not auto-corrected; they are surfaced as warnings and exceptions where applicable.
3. Shift duration is calculated from `Clock In` and `Clock Out` on `Work Date`; if `Clock Out` is earlier than `Clock In`, shift is treated as overnight (+1 day).
4. Break minutes are treated as numeric input from source when provided; otherwise calculated values remain null-safe.
5. `tblExceptionRules` is the default rules authority; employee-specific overrides are optional and only used when active and populated.
6. The MVP supports manual review only and does not perform outbound updates to BrightHR/Dayforce.
7. Sample data is fake and for demonstration/testing only.
