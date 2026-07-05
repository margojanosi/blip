let
    // q_exception_report
    // Appends all exception-specific queries into one reviewer-facing report.
    Combined = Table.Combine({
        q_exception_missing_clock_out,
        q_exception_missing_clock_in,
        q_exception_missing_break,
        q_exception_short_break,
        q_exception_long_break,
        q_exception_long_shift,
        q_exception_short_shift,
        q_exception_duplicate_shift,
        q_exception_overlapping_shift,
        q_exception_weekend_entry
    }),
    Reordered = Table.ReorderColumns(
        Combined,
        {
            "Employee Name",
            "Employee ID",
            "Work Date",
            "Exception Type",
            "Severity",
            "Clock In",
            "Clock Out",
            "Total Shift Hours",
            "Break Minutes",
            "Rule Triggered",
            "Suggested Action",
            "Source Row Number",
            "Status",
            "Reviewer Notes"
        }
    )
in
    Reordered
