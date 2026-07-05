let
    // q_exception_missing_clock_out
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleEnabled = let r = Table.SelectRows(Rules, each [Rule Key] = "missing_clock_out_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "missing_clock_out_enabled") in if Table.RowCount(r)=0 then "High" else try Text.From(r{0}[Severity]) otherwise "High",
    Filtered = if RuleEnabled then Table.SelectRows(Logs, each [Has Clock In] = true and [Has Clock Out] = false) else #table(type table [], {}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Missing Clock Out",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "missing_clock_out_enabled",
        Suggested Action = "Confirm actual shift end in BrightHR and correct if missing.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
