let
    // q_raw_bright_hr_export
    // Reads the raw BrightHR export table from workbook and standardizes column names.
    // Supports native BrightHR export headers and legacy scaffold headers.
    Source = Excel.CurrentWorkbook(){[Name="tblRawBrightHRExport"]}[Content],
    TrimmedColumnNames = Table.TransformColumnNames(Source, each Text.Trim(_)),

    ValueAsTextOrNull = (value as any) as nullable text =>
        let
            textValue = try Text.Trim(Text.From(value)) otherwise null
        in
            if textValue = null or textValue = "" then null else textValue,

    GetFirstValue = (row as record, columnNames as list) as any =>
        let
            values = List.Transform(columnNames, each try Record.Field(row, _) otherwise null),
            nonNull = List.RemoveNulls(values)
        in
            if List.Count(nonNull) = 0 then null else nonNull{0},

    ParseDurationMinutes = (value as any) as nullable number =>
        let
            fromDuration = try Duration.TotalMinutes(Duration.From(value)) otherwise null,
            fromTime = if fromDuration <> null then fromDuration else try Duration.TotalMinutes(Time.From(value) - #time(0, 0, 0)) otherwise null,
            textValue = if fromTime <> null then null else ValueAsTextOrNull(value),
            fromColonText =
                if fromTime <> null or textValue = null or not Text.Contains(textValue, ":") then
                    null
                else
                    let
                        parts = Text.Split(textValue, ":"),
                        hh = if List.Count(parts) > 0 then try Number.From(parts{0}) otherwise null else null,
                        mm = if List.Count(parts) > 1 then try Number.From(parts{1}) otherwise null else null
                    in
                        if hh = null or mm = null then null else (hh * 60) + mm,
            fromNumberText =
                if fromTime <> null or fromColonText <> null or textValue = null then
                    null
                else
                    try Number.From(textValue) otherwise null,
            resolved =
                if fromDuration <> null then fromDuration
                else if fromTime <> null then fromTime
                else if fromColonText <> null then fromColonText
                else fromNumberText
        in
            if resolved = null then null else Number.Round(resolved, 6),

    AddEmployeeName = Table.AddColumn(
        TrimmedColumnNames,
        "Employee Name",
        each
            let
                existing = ValueAsTextOrNull(GetFirstValue(_, {"Employee Name"})),
                firstName = ValueAsTextOrNull(GetFirstValue(_, {"First Name"})),
                lastName = ValueAsTextOrNull(GetFirstValue(_, {"Last Name"}))
            in
                if existing <> null then existing else Text.Combine(List.RemoveNulls({firstName, lastName}), " "),
        type text
    ),
    AddEmployeeID = Table.AddColumn(
        AddEmployeeName,
        "Employee ID",
        each ValueAsTextOrNull(GetFirstValue(_, {"Employee ID", "Payroll Number", "SI Number"})),
        type text
    ),
    AddWorkDate = Table.AddColumn(
        AddEmployeeID,
        "Work Date",
        each GetFirstValue(_, {"Work Date", "Clock In Date"}),
        type any
    ),
    AddClockIn = Table.AddColumn(
        AddWorkDate,
        "Clock In",
        each GetFirstValue(_, {"Clock In", "Clock In Time"}),
        type any
    ),
    AddClockOut = Table.AddColumn(
        AddClockIn,
        "Clock Out",
        each GetFirstValue(_, {"Clock Out", "Clock Out Time"}),
        type any
    ),
    AddClockOutDate = Table.AddColumn(
        AddClockOut,
        "Clock Out Date",
        each GetFirstValue(_, {"Clock Out Date"}),
        type any
    ),
    AddBreakStart = Table.AddColumn(
        AddClockOutDate,
        "Break Start",
        each GetFirstValue(_, {"Break Start"}),
        type any
    ),
    AddBreakEnd = Table.AddColumn(
        AddBreakStart,
        "Break End",
        each GetFirstValue(_, {"Break End"}),
        type any
    ),
    AddBreakMinutes = Table.AddColumn(
        AddBreakEnd,
        "Break Minutes",
        each
            let
                existingBreak = try Number.From(GetFirstValue(_, {"Break Minutes"})) otherwise null,
                totalMins = ParseDurationMinutes(GetFirstValue(_, {"Total Duration"})),
                excludingBreakMins = ParseDurationMinutes(GetFirstValue(_, {"Total Excluding Breaks"}))
            in
                if existingBreak <> null then existingBreak
                else if totalMins = null or excludingBreakMins = null then null
                else Number.Max(0, totalMins - excludingBreakMins),
        type number
    ),
    AddLocation = Table.AddColumn(
        AddBreakMinutes,
        "Location",
        each ValueAsTextOrNull(GetFirstValue(_, {"Location", "Clock In Location", "Clock Out Location"})),
        type text
    ),
    AddNotes = Table.AddColumn(
        AddLocation,
        "Notes",
        each ValueAsTextOrNull(GetFirstValue(_, {"Notes"})),
        type text
    ),

    Buffered = Table.Buffer(AddNotes)
in
    Buffered
