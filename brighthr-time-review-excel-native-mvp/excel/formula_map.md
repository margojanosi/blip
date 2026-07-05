# Formula Map

> Main analytics are Power Query based. Formulas below are optional workbook helpers.

## Instructions tab
- Static instructional text only.

## Summary tab (example formulas)
- Total raw records: `=ROWS(tblRawBrightHRExport[Employee ID])`
- Total clean records: `=MAX(0,ROWS(tblRawBrightHRExport[Employee ID])-ROWS(tblExceptionReport[Employee ID]))`
- Total flagged records: `=COUNTA(UNIQUE(tblExceptionReport[Source Row Number]))`
- Total exceptions: `=ROWS(tblExceptionReport[Employee ID])`
- Open exceptions: `=COUNTIF(tblExceptionReport[Status],"Open")`
- Closed exceptions: `=COUNTIF(tblExceptionReport[Status],"Closed")`

## Exception Report tab
- Status defaults to `Open` via query output.
- Data validation list (optional):
  `Open,Confirmed Correct,Corrected in BrightHR,Payroll Adjustment Needed,Escalated,Closed`
