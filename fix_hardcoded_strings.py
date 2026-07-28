import json

files = [
    ("Garten_Simulation/Views/Profile/WeeklyReportDashboardView.swift",
     [
         ('value: "\\(report.totalFocusMinutes) Min"', 'value: String(format: String(localized: "weekly_report.card.focus_time.value", defaultValue: "%lld Min"), report.totalFocusMinutes)'),
         ('Text("\\(selected.minutes) Min")', 'Text(String(format: String(localized: "weekly_report.chart.focus_time.value", defaultValue: "%lld Min"), selected.minutes))'),
         ('? "Grovy_Wochenbericht" : pdfFileName', '? String(localized: "weekly_report.pdf.default_filename", defaultValue: "Grovy_Wochenbericht") : pdfFileName')
     ]),
    ("Garten_Simulation/Views/Profile/PDFExportConfigView.swift",
     [
         ('? "Garten_Bericht" : pdfFileName', '? String(localized: "export.pdf.default_filename", defaultValue: "Garten_Bericht") : pdfFileName')
     ])
]

for filepath, replacements in files:
    with open(filepath, 'r') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)
print("Replaced strings in Swift files.")
