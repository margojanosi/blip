let
    // q_exception_short_break
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleEnabled = let r = Table.SelectRows(Rules, each [Rule Key] = "short_break_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "short_break_enabled") in if Table.RowCount(r)=0 then "Medium" else try Text.From(r{0}[Severity]) otherwise "Medium",
    Filtered = if RuleEnabled then Table.SelectRows(Logs, each [Break Minutes] <> null and [Break Minutes] < [Effective Min Break Minutes]) else #table(type table [], {}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Break Too Short",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "short_break_enabled",
        Suggested Action = "Review break length against policy and verify correction in BrightHR.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
