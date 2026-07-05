# Exception Rule Definitions

| Exception Type | Trigger | Typical Severity | Suggested Reviewer Action |
|---|---|---|---|
| Missing Clock Out | Clock in exists, clock out missing | High | Confirm actual end time and correct in BrightHR |
| Missing Clock In | Clock out exists, clock in missing | High | Confirm actual start time and correct in BrightHR |
| Missing Break | Shift exceeds break-required threshold but no break recorded | Medium | Confirm if break was taken and captured |
| Break Too Short | Break minutes below minimum threshold | Medium | Validate against policy |
| Break Too Long | Break minutes above max threshold | Low | Verify if valid/approved |
| Shift Too Long | Shift hours exceed max threshold | High | Check overtime validity |
| Shift Too Short | Shift hours below minimum threshold | Medium | Verify incomplete/incorrect entry |
| Duplicate Shift | Identical employee/date/in/out appears multiple times | High | Remove/resolve duplicate record |
| Overlapping Shift | Shift starts before prior shift ended for same employee/date | High | Verify timeline and correct entries |
| Weekend Entry | Weekend record when weekend not allowed | Low | Confirm weekend approval |
