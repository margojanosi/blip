# Named Tables Specification

## tblRawBrightHRExport
Columns:
- Employee Name
- Employee ID
- Work Date
- Clock In
- Clock Out
- Break Start
- Break End
- Break Minutes
- Location
- Notes

## tblExceptionRules
Columns:
- Rule Key
- Rule Name
- Value
- Unit
- Severity
- Enabled
- Description

Expected rule keys:
- max_shift_hours_default
- min_shift_hours_default
- break_required_after_hours
- min_break_minutes
- max_break_minutes
- weekend_work_allowed_default
- duplicate_shift_detection_enabled
- overlap_detection_enabled
- missing_clock_in_enabled
- missing_clock_out_enabled
- missing_break_enabled
- long_shift_enabled
- short_shift_enabled
- short_break_enabled
- long_break_enabled
- weekend_entry_enabled

## tblEmployeeRules
Columns:
- Employee Name
- Employee ID
- Employee Type
- Expected Start Time
- Expected End Time
- Max Shift Hours Override
- Min Shift Hours Override
- Weekend Work Allowed
- Break Required After Hours Override
- Min Break Minutes Override
- Max Break Minutes Override
- Active
