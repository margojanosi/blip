let
    // q_exception_duplicate_shift
    Logs = q_normalized_time_logs,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    EnabledByRule = let r = Table.SelectRows(Rules, each [Rule Key] = "duplicate_shift_detection_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "duplicate_shift_detection_enabled") in if Table.RowCount(r)=0 then "High" else try Text.From(r{0}[Severity]) otherwise "High",
    Grouped = Table.Group(Logs, {"Employee ID", "Work Date", "Clock In", "Clock Out"}, {{"Rows", each _, type table}, {"Count", each Table.RowCount(_), Int64.Type}}),
    DuplicatesOnly = if EnabledByRule then Table.SelectRows(Grouped, each [Count] > 1) else #table(type table [], {}),
    Expanded = Table.ExpandTableColumn(DuplicatesOnly, "Rows", {"Employee Name", "Break Minutes", "Calculated Shift Hours", "Source Row Number"}, {"Employee Name", "Break Minutes", "Calculated Shift Hours", "Source Row Number"}),
    Projected = Table.FromRecords(List.Transform(Table.ToRecords(Expanded), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Duplicate Shift",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "duplicate_shift_detection_enabled",
        Suggested Action = "Verify duplicate entries and keep only correct record(s) in BrightHR.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
