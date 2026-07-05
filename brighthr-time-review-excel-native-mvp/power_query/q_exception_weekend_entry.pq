let
    // q_exception_weekend_entry
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleEnabled = let r = Table.SelectRows(Rules, each [Rule Key] = "weekend_entry_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "weekend_entry_enabled") in if Table.RowCount(r)=0 then "Low" else try Text.From(r{0}[Severity]) otherwise "Low",
    Filtered = if RuleEnabled then Table.SelectRows(Logs, each [Is Weekend] = true and [Effective Weekend Work Allowed] = false) else #table(type table [], {}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Filtered), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Weekend Entry",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "weekend_entry_enabled",
        Suggested Action = "Confirm weekend approval/policy exception before payroll processing.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
