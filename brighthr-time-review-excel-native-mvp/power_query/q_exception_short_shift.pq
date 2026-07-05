let
    // q_exception_short_shift
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleEnabled = let r = Table.SelectRows(Rules, each [Rule Key] = "short_shift_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "short_shift_enabled") in if Table.RowCount(r)=0 then "Medium" else try Text.From(r{0}[Severity]) otherwise "Medium",
    Filtered = if RuleEnabled then Table.SelectRows(Logs, each [Calculated Shift Hours] <> null and [Calculated Shift Hours] < [Effective Min Shift Hours]) else #table(type table [], {}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Shift Too Short",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "short_shift_enabled",
        Suggested Action = "Check whether shift was incomplete or entered incorrectly.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
