let
    // q_normalized_time_logs
    // Normalizes raw time logs, computes durations, and applies optional employee overrides.
    Raw = q_raw_bright_hr_export,

    // Ensure deterministic row traceability
    WithRowNumber = Table.AddIndexColumn(Raw, "Source Row Number", 1, 1, Int64.Type),

    // Normalize data types and tolerate malformed values with try/otherwise
    Typed = Table.TransformColumns(
        WithRowNumber,
        {
            {"Employee Name", each try Text.Trim(Text.From(_)) otherwise null, type text},
            {"Employee ID", each try Text.Trim(Text.From(_)) otherwise null, type text},
            {"Work Date", each try Date.From(_) otherwise null, type date},
            {"Clock In", each try Time.From(_) otherwise null, type time},
            {"Clock Out", each try Time.From(_) otherwise null, type time},
            {"Clock Out Date", each try Date.From(_) otherwise null, type date},
            {"Break Start", each try Time.From(_) otherwise null, type time},
            {"Break End", each try Time.From(_) otherwise null, type time},
            {"Break Minutes", each try Number.From(_) otherwise null, type number},
            {"Location", each try Text.From(_) otherwise null, type text},
            {"Notes", each try Text.From(_) otherwise null, type text}
        }
    ),

    // Day / weekend helpers
    AddDayOfWeek = Table.AddColumn(Typed, "Day of Week", each if [Work Date] <> null then Date.DayOfWeekName([Work Date]) else null, type text),
    AddIsWeekend = Table.AddColumn(AddDayOfWeek, "Is Weekend", each if [Work Date] = null then null else Date.DayOfWeek([Work Date], Day.Monday) >= 5, type logical),

    // Presence flags
    AddHasClockIn = Table.AddColumn(AddIsWeekend, "Has Clock In", each [Clock In] <> null, type logical),
    AddHasClockOut = Table.AddColumn(AddHasClockIn, "Has Clock Out", each [Clock Out] <> null, type logical),
    AddHasBreak = Table.AddColumn(AddHasClockOut, "Has Break", each [Break Start] <> null or [Break End] <> null or ([Break Minutes] <> null and [Break Minutes] > 0), type logical),

    // Shift hours (supports overnight if Clock Out < Clock In)
    AddShiftHours = Table.AddColumn(
        AddHasBreak,
        "Calculated Shift Hours",
        each
            let
                d = [Work Date],
                cin = [Clock In],
                cout = [Clock Out],
                outDate = [Clock Out Date],
                shift = if d = null or cin = null or cout = null then null else
                    let
                        startDT = DateTime.From(d) + #duration(0, Time.Hour(cin), Time.Minute(cin), Number.From(Time.Second(cin))),
                        endBaseDate = if outDate <> null then outDate else d,
                        endBase = DateTime.From(endBaseDate) + #duration(0, Time.Hour(cout), Time.Minute(cout), Number.From(Time.Second(cout))),
                        endDT = if outDate = null and cout < cin then endBase + #duration(1,0,0,0) else endBase,
                        dur = endDT - startDT
                    in Duration.TotalHours(dur)
            in shift,
        type number
    ),

    AddPaidHours = Table.AddColumn(
        AddShiftHours,
        "Calculated Paid Hours",
        each if [Calculated Shift Hours] = null then null else [Calculated Shift Hours] - (if [Break Minutes] = null then 0 else [Break Minutes] / 60),
        type number
    ),

    // Employee override table is optional; keep schema-safe even when empty
    EmployeeRulesRaw = try Excel.CurrentWorkbook(){[Name="tblEmployeeRules"]}[Content] otherwise #table(
        type table [
            Employee Name = text,
            Employee ID = text,
            Employee Type = text,
            Expected Start Time = time,
            Expected End Time = time,
            Max Shift Hours Override = number,
            Min Shift Hours Override = number,
            Weekend Work Allowed = logical,
            Break Required After Hours Override = number,
            Min Break Minutes Override = number,
            Max Break Minutes Override = number,
            Active = logical
        ],
        {}
    ),
    EmployeeRulesTyped = Table.TransformColumns(
        EmployeeRulesRaw,
        {
            {"Employee ID", each try Text.Trim(Text.From(_)) otherwise null, type text},
            {"Max Shift Hours Override", each try Number.From(_) otherwise null, type number},
            {"Min Shift Hours Override", each try Number.From(_) otherwise null, type number},
            {"Weekend Work Allowed", each try Logical.From(_) otherwise null, type logical},
            {"Break Required After Hours Override", each try Number.From(_) otherwise null, type number},
            {"Min Break Minutes Override", each try Number.From(_) otherwise null, type number},
            {"Max Break Minutes Override", each try Number.From(_) otherwise null, type number},
            {"Active", each try Logical.From(_) otherwise false, type logical}
        }
    ),
    EmployeeRulesActive = Table.SelectRows(EmployeeRulesTyped, each [Active] = true and [Employee ID] <> null),

    // Default rules
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],
    RuleGetNumber = (ruleKey as text, defaultValue as number) as number =>
        let
            row = Table.SelectRows(Rules, each [Rule Key] = ruleKey and ([Enabled] = true or [Enabled] = "TRUE" or [Enabled] = 1)),
            value = if Table.RowCount(row) = 0 then defaultValue else try Number.From(row{0}[Value]) otherwise defaultValue
        in
            value,
    RuleGetBool = (ruleKey as text, defaultValue as logical) as logical =>
        let
            row = Table.SelectRows(Rules, each [Rule Key] = ruleKey),
            value = if Table.RowCount(row) = 0 then defaultValue else try Logical.From(row{0}[Value]) otherwise defaultValue
        in
            value,

    DefaultMaxShiftHours = RuleGetNumber("max_shift_hours_default", 12),
    DefaultMinShiftHours = RuleGetNumber("min_shift_hours_default", 2),
    DefaultBreakRequiredAfter = RuleGetNumber("break_required_after_hours", 6),
    DefaultMinBreakMins = RuleGetNumber("min_break_minutes", 30),
    DefaultMaxBreakMins = RuleGetNumber("max_break_minutes", 90),
    DefaultWeekendAllowed = RuleGetBool("weekend_work_allowed_default", false),

    // Join and derive effective rule values
    MergeRules = Table.NestedJoin(AddPaidHours, {"Employee ID"}, EmployeeRulesActive, {"Employee ID"}, "EmployeeRule", JoinKind.LeftOuter),
    ExpandRules = Table.ExpandTableColumn(
        MergeRules,
        "EmployeeRule",
        {
            "Max Shift Hours Override",
            "Min Shift Hours Override",
            "Weekend Work Allowed",
            "Break Required After Hours Override",
            "Min Break Minutes Override",
            "Max Break Minutes Override"
        },
        {
            "Max Shift Hours Override",
            "Min Shift Hours Override",
            "Weekend Work Allowed Override",
            "Break Required After Hours Override",
            "Min Break Minutes Override",
            "Max Break Minutes Override"
        }
    ),

    EffectiveRules = Table.TransformColumns(
        Table.AddColumn(
            Table.AddColumn(
                Table.AddColumn(
                    Table.AddColumn(
                        Table.AddColumn(
                            Table.AddColumn(
                                ExpandRules,
                                "Effective Max Shift Hours", each if [Max Shift Hours Override] <> null then [Max Shift Hours Override] else DefaultMaxShiftHours, type number
                            ),
                            "Effective Min Shift Hours", each if [Min Shift Hours Override] <> null then [Min Shift Hours Override] else DefaultMinShiftHours, type number
                        ),
                        "Effective Break Required After Hours", each if [Break Required After Hours Override] <> null then [Break Required After Hours Override] else DefaultBreakRequiredAfter, type number
                    ),
                    "Effective Min Break Minutes", each if [Min Break Minutes Override] <> null then [Min Break Minutes Override] else DefaultMinBreakMins, type number
                ),
                "Effective Max Break Minutes", each if [Max Break Minutes Override] <> null then [Max Break Minutes Override] else DefaultMaxBreakMins, type number
            ),
            "Effective Weekend Work Allowed", each if [Weekend Work Allowed Override] <> null then [Weekend Work Allowed Override] else DefaultWeekendAllowed, type logical
        ),
        {}
    ),

    AddNormalizationWarning = Table.AddColumn(
        EffectiveRules,
        "Normalization Warning",
        each Text.Combine(
            List.RemoveNulls({
                if [Work Date] = null then "Missing/invalid Work Date" else null,
                if [Has Clock In] = false then "Missing Clock In" else null,
                if [Has Clock Out] = false then "Missing Clock Out" else null,
                if [Break Minutes] <> null and [Break Minutes] < 0 then "Negative Break Minutes" else null
            }),
            "; "
        ),
        type text
    ),

    Selected = Table.SelectColumns(
        AddNormalizationWarning,
        {
            "Employee Name",
            "Employee ID",
            "Work Date",
            "Day of Week",
            "Is Weekend",
            "Clock In",
            "Clock Out",
            "Break Start",
            "Break End",
            "Break Minutes",
            "Calculated Shift Hours",
            "Calculated Paid Hours",
            "Has Clock In",
            "Has Clock Out",
            "Has Break",
            "Source Row Number",
            "Normalization Warning",
            "Effective Max Shift Hours",
            "Effective Min Shift Hours",
            "Effective Break Required After Hours",
            "Effective Min Break Minutes",
            "Effective Max Break Minutes",
            "Effective Weekend Work Allowed"
        }
    )
in
    Selected
