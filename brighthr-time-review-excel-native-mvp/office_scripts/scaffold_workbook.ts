function main(workbook: ExcelScript.Workbook) {
  // Create/ensure sheets
  const sheetNames = [
    "Instructions",
    "Raw BrightHR Export",
    "Exception Rules",
    "Employee Rules",
    "Normalized Time Logs",
    "Exception Report",
    "Summary",
    "Review Log"
  ];

  const getOrCreateSheet = (name: string): ExcelScript.Worksheet => {
    const existing = workbook.getWorksheet(name);
    return existing ?? workbook.addWorksheet(name);
  };

  const sheets = sheetNames.map(getOrCreateSheet);

  // Instructions tab
  const instructions = sheets[0];
  instructions.getRange("A1").setValue("BrightHR Time Review Excel Native MVP");
  instructions.getRange("A3").setValue("Step 1: Paste or import BrightHR CSV export into Raw BrightHR Export.");
  instructions.getRange("A4").setValue("Step 2: Refresh workbook queries (Data > Refresh All or helper script).");
  instructions.getRange("A5").setValue("Step 3: Review Exception Report.");
  instructions.getRange("A6").setValue("Step 4: Confirm/correct records in BrightHR manually.");
  instructions.getRange("A7").setValue("Step 5: Save reviewed workbook for audit trail.");
  instructions.getRange("A9").setValue("WARNING: This workbook does not approve payroll, does not update BrightHR, and does not submit to Dayforce.");
  instructions.getRange("A1:A1").getFormat().getFont().setBold(true);
  instructions.getRange("A9:A9").getFormat().getFont().setColor("#9C0006");

  // Raw BrightHR Export table with fake sample data
  const rawSheet = sheets[1];
  const rawHeaders = [[
    "Employee Name", "Employee ID", "Work Date", "Clock In", "Clock Out", "Break Start", "Break End", "Break Minutes", "Location", "Notes"
  ]];
  rawSheet.getRange("A1:J1").setValues(rawHeaders);
  const rawSample = [
    ["Alex Green", "E100", "2026-06-30", "09:00", "17:30", "13:00", "13:30", 30, "HQ", "Clean record"],
    ["Bailey Stone", "E101", "2026-06-30", "09:00", "", "13:00", "13:30", 30, "HQ", "Missing clock out"],
    ["Casey Hall", "E102", "2026-06-30", "", "17:00", "12:00", "12:30", 30, "Remote", "Missing clock in"],
    ["Drew Lane", "E103", "2026-06-30", "08:00", "17:00", "", "", "", "HQ", "Missing break"],
    ["Evan Cole", "E104", "2026-06-30", "08:00", "17:00", "12:00", "12:10", 10, "Site A", "Short break"],
    ["Flynn Reed", "E105", "2026-06-30", "08:00", "18:00", "12:00", "13:45", 105, "Site B", "Long break"],
    ["Gray Kim", "E106", "2026-06-30", "06:00", "22:00", "12:00", "12:30", 30, "HQ", "Very long shift"],
    ["Harper Lee", "E107", "2026-06-30", "09:00", "10:00", "", "", 0, "HQ", "Very short shift"],
    ["Indy Ray", "E108", "2026-06-30", "09:00", "17:00", "12:00", "12:30", 30, "HQ", "Duplicate row 1"],
    ["Indy Ray", "E108", "2026-06-30", "09:00", "17:00", "12:00", "12:30", 30, "HQ", "Duplicate row 2"],
    ["Jules Park", "E109", "2026-06-30", "08:00", "12:00", "", "", 0, "HQ", "Overlap row 1"],
    ["Jules Park", "E109", "2026-06-30", "11:00", "16:00", "", "", 0, "HQ", "Overlap row 2"],
    ["Kai Moss", "E110", "2026-07-04", "09:00", "13:00", "", "", 0, "HQ", "Weekend shift"]
  ];
  rawSheet.getRange(`A2:J${rawSample.length + 1}`).setValues(rawSample);

  let rawTable = workbook.getTable("tblRawBrightHRExport");
  if (!rawTable) {
    rawTable = workbook.addTable("'Raw BrightHR Export'!A1:J" + (rawSample.length + 1), true);
    rawTable.setName("tblRawBrightHRExport");
  }

  // Exception Rules table
  const rulesSheet = sheets[2];
  const rulesHeaders = [["Rule Key", "Rule Name", "Value", "Unit", "Severity", "Enabled", "Description"]];
  rulesSheet.getRange("A1:G1").setValues(rulesHeaders);
  const rulesRows = [
    ["max_shift_hours_default", "Max Shift Hours", 12, "hours", "High", true, "Default max shift length"],
    ["min_shift_hours_default", "Min Shift Hours", 2, "hours", "Medium", true, "Default minimum shift length"],
    ["break_required_after_hours", "Break Required After", 6, "hours", "Medium", true, "Break expected after threshold"],
    ["min_break_minutes", "Min Break Minutes", 20, "minutes", "Medium", true, "Minimum break duration"],
    ["max_break_minutes", "Max Break Minutes", 90, "minutes", "Low", true, "Maximum break duration"],
    ["weekend_work_allowed_default", "Weekend Work Allowed", false, "boolean", "Low", true, "Default weekend policy"],
    ["duplicate_shift_detection_enabled", "Duplicate Shift Detection", true, "boolean", "High", true, "Enable duplicate detection"],
    ["overlap_detection_enabled", "Overlap Detection", true, "boolean", "High", true, "Enable overlap detection"],
    ["missing_clock_in_enabled", "Missing Clock In", true, "boolean", "High", true, "Enable missing clock in exception"],
    ["missing_clock_out_enabled", "Missing Clock Out", true, "boolean", "High", true, "Enable missing clock out exception"],
    ["missing_break_enabled", "Missing Break", true, "boolean", "Medium", true, "Enable missing break exception"],
    ["long_shift_enabled", "Long Shift", true, "boolean", "High", true, "Enable long shift exception"],
    ["short_shift_enabled", "Short Shift", true, "boolean", "Medium", true, "Enable short shift exception"],
    ["short_break_enabled", "Short Break", true, "boolean", "Medium", true, "Enable short break exception"],
    ["long_break_enabled", "Long Break", true, "boolean", "Low", true, "Enable long break exception"],
    ["weekend_entry_enabled", "Weekend Entry", true, "boolean", "Low", true, "Enable weekend exception"],
  ];
  rulesSheet.getRange(`A2:G${rulesRows.length + 1}`).setValues(rulesRows);

  let rulesTable = workbook.getTable("tblExceptionRules");
  if (!rulesTable) {
    rulesTable = workbook.addTable("'Exception Rules'!A1:G" + (rulesRows.length + 1), true);
    rulesTable.setName("tblExceptionRules");
  }

  // Employee rules table scaffold
  const employeeSheet = sheets[3];
  const employeeHeaders = [[
    "Employee Name", "Employee ID", "Employee Type", "Expected Start Time", "Expected End Time", "Max Shift Hours Override", "Min Shift Hours Override", "Weekend Work Allowed", "Break Required After Hours Override", "Min Break Minutes Override", "Max Break Minutes Override", "Active"
  ]];
  employeeSheet.getRange("A1:L1").setValues(employeeHeaders);
  let employeeTable = workbook.getTable("tblEmployeeRules");
  if (!employeeTable) {
    employeeTable = workbook.addTable("'Employee Rules'!A1:L2", true);
    employeeTable.setName("tblEmployeeRules");
    employeeTable.addRow(-1, ["", "", "", "", "", "", "", "", "", "", "", false]);
  }

  // Basic formatting
  for (const ws of sheets) {
    ws.getUsedRange()?.getFormat().autofitColumns();
    ws.getUsedRange()?.getFormat().autofitRows();
  }
}
