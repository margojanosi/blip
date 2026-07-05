let
    // q_review_log
    // Produces a compact refresh/audit log for reviewers.
    Raw = q_raw_bright_hr_export,
    Normalized = q_normalized_time_logs,
    Exceptions = q_exception_report,
    Rules = Excel.CurrentWorkbook(){[Name="tblExceptionRules"]}[Content],

    EnabledRules = Table.SelectRows(Rules, each try Logical.From([Enabled]) otherwise false),
    EnabledRuleKeys = Text.Combine(List.Transform(EnabledRules[Rule Key], each Text.From(_)), ", "),

    Notes = Text.Combine({
        "This workbook flags possible issues only.",
        "Corrections must be made manually in BrightHR.",
        "Dayforce submission is out of scope for this MVP."
    }, " "),

    ReviewLog = #table(
        type table [
            Workbook Refresh DateTime = datetime,
            Source Data Row Count = Int64.Type,
            Normalized Row Count = Int64.Type,
            Exception Count = Int64.Type,
            Enabled Rules Used = text,
            Notes = text
        ],
        {{
            DateTime.LocalNow(),
            Table.RowCount(Raw),
            Table.RowCount(Normalized),
            Table.RowCount(Exceptions),
            EnabledRuleKeys,
            Notes
        }}
    )
in
    ReviewLog
