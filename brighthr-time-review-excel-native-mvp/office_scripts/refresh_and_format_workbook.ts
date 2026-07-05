function main(workbook: ExcelScript.Workbook) {
  // Refresh workbook connections/queries where supported.
  try {
    workbook.refreshAllDataConnections();
  } catch (e) {
    // Ignore in environments that don't support refresh for this workbook context.
  }

  const exceptionSheet = workbook.getWorksheet("Exception Report");
  if (!exceptionSheet) return;

  // Freeze top row and ensure filters/table formatting.
  exceptionSheet.getFreezePanes().freezeRows(1);

  const exceptionTable = workbook.getTable("tblExceptionReport");
  if (exceptionTable) {
    exceptionTable.setShowFilterButton(true);

    // Severity highlighting
    const severityRange = exceptionTable.getColumnByName("Severity")?.getRangeBetweenHeaderAndTotal();
    if (severityRange) {
      const high = severityRange.addConditionalFormat(ExcelScript.ConditionalFormatType.containsText);
      high.getTextComparison().setRule({operator: ExcelScript.ConditionalTextOperator.contains, text: "High"});
      high.getTextComparison().getFormat().getFill().setColor("#F8CBAD");

      const medium = severityRange.addConditionalFormat(ExcelScript.ConditionalFormatType.containsText);
      medium.getTextComparison().setRule({operator: ExcelScript.ConditionalTextOperator.contains, text: "Medium"});
      medium.getTextComparison().getFormat().getFill().setColor("#FFE699");

      const low = severityRange.addConditionalFormat(ExcelScript.ConditionalFormatType.containsText);
      low.getTextComparison().setRule({operator: ExcelScript.ConditionalTextOperator.contains, text: "Low"});
      low.getTextComparison().getFormat().getFill().setColor("#FFF2CC");
    }

    // Status dropdown/data validation where supported.
    const statusRange = exceptionTable.getColumnByName("Status")?.getRangeBetweenHeaderAndTotal();
    if (statusRange) {
      statusRange.getDataValidation().setRule({
        list: {
          inCellDropDown: true,
          source: "Open,Confirmed Correct,Corrected in BrightHR,Payroll Adjustment Needed,Escalated,Closed"
        }
      });
    }
  }

  exceptionSheet.getUsedRange()?.getFormat().autofitColumns();
  exceptionSheet.getUsedRange()?.getFormat().autofitRows();
}
