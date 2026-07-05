let
    // q_exception_long_break
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleEnabled = let r = Table.SelectRows(Rules, each [Rule Key] = "long_break_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "long_break_enabled") in if Table.RowCount(r)=0 then "Low" else try Text.From(r{0}[Severity]) otherwise "Low",
    Filtered = if RuleEnabled then Table.SelectRows(Logs, each [Break Minutes] <> null and [Break Minutes] > [Effective Max Break Minutes]) else #table(type table [], {}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Break Too Long",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "long_break_enabled",
        Suggested Action = "Confirm break duration and adjust in BrightHR if entry is inaccurate.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
