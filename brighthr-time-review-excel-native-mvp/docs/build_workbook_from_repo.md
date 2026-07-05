# Build Workbook From Repository

## 1) Create a blank workbook
1. Open Excel Desktop.
2. Create a new blank workbook.
3. Save as `BrightHR_Time_Review_MVP.xlsx`.

## 2) Run Office Script scaffold
1. Open Automate tab.
2. Create a new script and paste `office_scripts/scaffold_workbook.ts`.
3. Run script to create tabs, tables, sample data, and instructions.

## 3) Add Power Query scripts
For each file in `power_query/`:
1. Go to **Data > Get Data > Launch Power Query Editor**.
2. Create a new blank query.
3. Open Advanced Editor.
4. Paste script content from repository file.
5. Name the query exactly as the filename (without `.pq`).

## 4) Load queries to worksheets
Recommended loads:
- `q_raw_bright_hr_export` -> Connection only (optional table load to Raw tab for debugging)
- `q_normalized_time_logs` -> Table to `Normalized Time Logs`
- `q_exception_report` -> Table to `Exception Report` (name table `tblExceptionReport`)
- `q_review_log` -> Table to `Review Log`
- Individual exception queries -> Connection only (or separate tabs during testing)

## 5) Test with sample CSV
1. Open `sample_data/sample_bright_hr_export.csv`.
2. Paste rows into `tblRawBrightHRExport`.
3. Refresh all queries.
4. Confirm expected exceptions appear in `Exception Report`.

## 6) Save reusable template
1. Remove sensitive/non-demo data if present.
2. Save as `BrightHR_Time_Review_MVP_Template.xltx`.
3. Share template with reviewers.
