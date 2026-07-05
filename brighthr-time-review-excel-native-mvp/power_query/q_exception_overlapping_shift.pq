let
    // q_exception_overlapping_shift
    Logs = Table.SelectRows(q_normalized_time_logs, each [Clock In] <> null and [Clock Out] <> null and [Work Date] <> null),
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    EnabledByRule = let r = Table.SelectRows(Rules, each [Rule Key] = "overlap_detection_enabled") in if Table.RowCount(r)=0 then true else try Logical.From(r{0}[Value]) otherwise true,
    Severity = let r = Table.SelectRows(Rules, each [Rule Key] = "overlap_detection_enabled") in if Table.RowCount(r)=0 then "High" else try Text.From(r{0}[Severity]) otherwise "High",

    // Build DateTime helpers
    WithDateTimes = Table.AddColumn(
        Table.AddColumn(Logs, "Clock In DT", each DateTime.From([Work Date]) + #duration(0, Time.Hour([Clock In]), Time.Minute([Clock In]), Number.From(Time.Second([Clock In]))), type datetime),
        "Clock Out DT", each
            let base = DateTime.From([Work Date]) + #duration(0, Time.Hour([Clock Out]), Time.Minute([Clock Out]), Number.From(Time.Second([Clock Out])))
            in if [Clock Out] < [Clock In] then base + #duration(1,0,0,0) else base,
        type datetime
    ),

    Grouped = Table.Group(WithDateTimes, {"Employee ID", "Work Date"}, {{"Rows", each Table.Sort(_, {{"Clock In DT", Order.Ascending}}), type table}}),
    Marked = Table.TransformColumns(Grouped, {
        "Rows",
        each
            let
                t = Table.AddIndexColumn(_, "Idx", 0, 1, Int64.Type),
                withPrev = Table.AddColumn(t, "PrevClockOut", (r) => if r[Idx] = 0 then null else try t{r[Idx]-1}[Clock Out DT] otherwise null, type datetime),
                withOverlap = Table.AddColumn(withPrev, "IsOverlap", each [PrevClockOut] <> null and [Clock In DT] < [PrevClockOut], type logical)
            in withOverlap,
        type table
    }),
    Expanded = Table.ExpandTableColumn(Marked, "Rows", {"Employee Name", "Clock In", "Clock Out", "Break Minutes", "Calculated Shift Hours", "Source Row Number", "IsOverlap"}, {"Employee Name", "Clock In", "Clock Out", "Break Minutes", "Calculated Shift Hours", "Source Row Number", "IsOverlap"}),
    OverlapsOnly = if EnabledByRule then Table.SelectRows(Expanded, each [IsOverlap] = true) else #table(type table [], {}),

    Projected = Table.FromRecords(List.Transform(Table.ToRecords(OverlapsOnly), each [
        Employee Name = _[Employee Name],
        Employee ID = _[Employee ID],
        Work Date = _[Work Date],
        Exception Type = "Overlapping Shift",
        Severity = Severity,
        Clock In = _[Clock In],
        Clock Out = _[Clock Out],
        Total Shift Hours = _[Calculated Shift Hours],
        Break Minutes = _[Break Minutes],
        Rule Triggered = "overlap_detection_enabled",
        Suggested Action = "Review overlapping time entries and confirm correct timeline in BrightHR.",
        Source Row Number = _[Source Row Number],
        Status = "Open",
        Reviewer Notes = null
    ]))
in
    Projected
