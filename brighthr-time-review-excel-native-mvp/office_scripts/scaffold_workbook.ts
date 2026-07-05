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
    "First Name", "Last Name", "Job Title", "Team(s)", "Blip Type", "Clock In Date", "Clock In Time", "Clock In Location", "Clock Out Date", "Clock Out Time", "Clock Out Location", "Total Duration", "Total Excluding Breaks", "Notes", "Payroll Number", "SI Number", "Employee Address"
  ]];
  rawSheet.getRange("A1:Q1").setValues(rawHeaders);
  const rawSample = [
    ["Alex", "Green", "Advisor", "Support", "Clocked", "2026-06-30", "09:00", "HQ", "2026-06-30", "17:30", "HQ", "08:30", "08:00", "Clean record", "E100", "SI100", "1 Demo Street"],
    ["Bailey", "Stone", "Advisor", "Support", "Clocked", "2026-06-30", "09:00", "HQ", "", "", "", "", "", "Missing clock out", "E101", "SI101", "2 Demo Street"],
    ["Casey", "Hall", "Advisor", "Remote", "Clocked", "2026-06-30", "", "Remote", "2026-06-30", "17:00", "Remote", "", "", "Missing clock in", "E102", "SI102", "3 Demo Street"],
    ["Drew", "Lane", "Advisor", "Support", "Clocked", "2026-06-30", "08:00", "HQ", "2026-06-30", "17:00", "HQ", "09:00", "09:00", "Missing break", "E103", "SI103", "4 Demo Street"],
    ["Evan", "Cole", "Advisor", "Field", "Clocked", "2026-06-30", "08:00", "Site A", "2026-06-30", "17:00", "Site A", "09:00", "08:50", "Short break", "E104", "SI104", "5 Demo Street"],
    ["Flynn", "Reed", "Advisor", "Field", "Clocked", "2026-06-30", "08:00", "Site B", "2026-06-30", "18:00", "Site B", "10:00", "08:15", "Long break", "E105", "SI105", "6 Demo Street"],
    ["Gray", "Kim", "Supervisor", "Support", "Clocked", "2026-06-30", "06:00", "HQ", "2026-06-30", "22:00", "HQ", "16:00", "15:30", "Very long shift", "E106", "SI106", "7 Demo Street"],
    ["Harper", "Lee", "Advisor", "Support", "Clocked", "2026-06-30", "09:00", "HQ", "2026-06-30", "10:00", "HQ", "01:00", "01:00", "Very short shift", "E107", "SI107", "8 Demo Street"],
    ["Indy", "Ray", "Advisor", "Support", "Clocked", "2026-06-30", "09:00", "HQ", "2026-06-30", "17:00", "HQ", "08:00", "07:30", "Duplicate row 1", "E108", "SI108", "9 Demo Street"],
    ["Indy", "Ray", "Advisor", "Support", "Clocked", "2026-06-30", "09:00", "HQ", "2026-06-30", "17:00", "HQ", "08:00", "07:30", "Duplicate row 2", "E108", "SI108", "9 Demo Street"],
    ["Jules", "Park", "Advisor", "Support", "Clocked", "2026-06-30", "08:00", "HQ", "2026-06-30", "12:00", "HQ", "04:00", "04:00", "Overlap row 1", "E109", "SI109", "10 Demo Street"],
    ["Jules", "Park", "Advisor", "Support", "Clocked", "2026-06-30", "11:00", "HQ", "2026-06-30", "16:00", "HQ", "05:00", "05:00", "Overlap row 2", "E109", "SI109", "10 Demo Street"],
    ["Kai", "Moss", "Advisor", "Support", "Clocked", "2026-07-04", "09:00", "HQ", "2026-07-04", "13:00", "HQ", "04:00", "04:00", "Weekend shift", "E110", "SI110", "11 Demo Street"]
  ];
  rawSheet.getRange(`A2:Q${rawSample.length + 1}`).setValues(rawSample);

  let rawTable = workbook.getTable("tblRawBrightHRExport");
  if (!rawTable) {
    rawTable = workbook.addTable("'Raw BrightHR Export'!A1:Q" + (rawSample.length + 1), true);
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
