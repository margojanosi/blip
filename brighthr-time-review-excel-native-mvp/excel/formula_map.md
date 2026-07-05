# Formula Map

> Main analytics are Power Query based. Formulas below are optional workbook helpers.

## Instructions tab
- Static instructional text only.

## Summary tab (example formulas)
- Total raw records: `=ROWS(tblRawBrightHRExport[Payroll Number])`
- Total clean records: `=COUNTA(FILTER(tblNormalizedTimeLogs[Source Row Number],ISNA(MATCH(tblNormalizedTimeLogs[Source Row Number],tblExceptionReport[Source Row Number],0))))`
  - Counts normalized source rows that do not appear in exception source rows.
- Total flagged records: `=COUNTA(UNIQUE(tblExceptionReport[Source Row Number]))`
- Total exceptions: `=ROWS(tblExceptionReport[Employee ID])`
- Open exceptions: `=COUNTIF(tblExceptionReport[Status],"Open")`
- Closed exceptions: `=COUNTIF(tblExceptionReport[Status],"Closed")`

## Exception Report tab
- Status defaults to `Open` via query output.
- Data validation list (optional):
  `Open,Confirmed Correct,Corrected in BrightHR,Payroll Adjustment Needed,Escalated,Closed`
