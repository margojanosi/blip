let
    // q_raw_bright_hr_export
    // Reads the raw BrightHR export table from workbook and standardizes column names.
    Source = Excel.CurrentWorkbook(){[Name="tblRawBrightHRExport"]}[Content],
    TrimmedColumnNames = Table.TransformColumnNames(Source, each Text.Trim(_)),
    Buffered = Table.Buffer(TrimmedColumnNames)
in
    Buffered
