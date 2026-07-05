Attribute VB_Name = "refresh_and_format_workbook"
Option Explicit

Public Sub RefreshAndFormatWorkbook()
    On Error Resume Next
    ThisWorkbook.RefreshAll
    On Error GoTo 0

    Dim ws As Worksheet
    Set ws = Nothing
    On Error Resume Next
    Set ws = ThisWorkbook.Worksheets("Exception Report")
    On Error GoTo 0

    If Not ws Is Nothing Then
        ws.Activate
        ActiveWindow.SplitRow = 1
        ActiveWindow.FreezePanes = True
        ws.Cells.EntireColumn.AutoFit
    End If

    MsgBox "Refresh and basic formatting complete.", vbInformation
End Sub
