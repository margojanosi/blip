# Conditional Formatting Specification

Apply to `tblExceptionReport` rows on `Exception Report` tab:

1. **High severity**
   - Formula/condition: `=[@Severity]="High"`
   - Fill: light red, bold dark red text

2. **Medium severity**
   - Formula/condition: `=[@Severity]="Medium"`
   - Fill: light orange

3. **Low severity**
   - Formula/condition: `=[@Severity]="Low"`
   - Fill: light yellow

Additional recommendations:
- Freeze top row.
- Keep table filters enabled.
- Highlight `Status="Open"` with subtle border/icon if desired.
