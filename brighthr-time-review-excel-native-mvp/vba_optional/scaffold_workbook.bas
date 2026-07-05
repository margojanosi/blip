Attribute VB_Name = "scaffold_workbook"
Option Explicit

Public Sub ScaffoldWorkbook()
    Dim ws As Worksheet
    Dim tabNames As Variant
    Dim i As Long

    tabNames = Array("Instructions", "Raw BrightHR Export", "Exception Rules", "Employee Rules", "Normalized Time Logs", "Exception Report", "Summary", "Review Log")

    For i = LBound(tabNames) To UBound(tabNames)
        On Error Resume Next
        Set ws = ThisWorkbook.Worksheets(tabNames(i))
        On Error GoTo 0
        If ws Is Nothing Then
            Set ws = ThisWorkbook.Worksheets.Add(After:=ThisWorkbook.Worksheets(ThisWorkbook.Worksheets.Count))
            ws.Name = tabNames(i)
        End If
        Set ws = Nothing
    Next i

    With Worksheets("Instructions")
        .Range("A1").Value = "BrightHR Time Review Excel Native MVP"
        .Range("A3").Value = "Step 1: Paste or import BrightHR CSV export."
        .Range("A4").Value = "Step 2: Refresh workbook queries."
        .Range("A5").Value = "Step 3: Review Exception Report."
        .Range("A6").Value = "Step 4: Confirm/correct records in BrightHR manually."
        .Range("A7").Value = "Step 5: Save reviewed workbook for audit trail."
        .Range("A9").Value = "WARNING: Workbook does not approve payroll, update BrightHR, or submit to Dayforce."
    End With

    MsgBox "Workbook scaffolding complete.", vbInformation
End Sub
