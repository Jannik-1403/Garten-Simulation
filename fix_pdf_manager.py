import re

path = "Garten_Simulation/Models/PDFExportManager.swift"
with open(path, "r") as f:
    content = f.read()

# 1. Insert locale
content = content.replace("let pdfMetaData =", "let locale = Locale(identifier: settings.appLanguage)\n        let pdfMetaData =")

# 2. Add locale to String(localized: ..., defaultValue: ...)
# Be careful with nested parentheses. Let's do a simple replace since it's predictable.
content = re.sub(
    r'String\(localized: ("[^"]+"), defaultValue: ("[^"]+")\)',
    r'String(localized: \1, defaultValue: \2, locale: locale)',
    content
)

# Fix the ones with string interpolation in defaultValue:
# String(localized: "stats.max_streak", defaultValue: "Höchster Streak (Tage): \(streakStore.bestStreak)")
content = re.sub(
    r'String\(localized: ("[^"]+"), defaultValue: ("[^"]+"[^)]+)\)',
    r'String(localized: \1, defaultValue: \2, locale: locale)',
    content
)

# 3. Replace NSLocalizedString with String(localized: String.LocalizationValue(...), locale: locale)
# example: NSLocalizedString(plant.displayedHabitName, comment: "")
content = re.sub(
    r'NSLocalizedString\(([^,]+),\s*comment:\s*""\)',
    r'String(localized: String.LocalizationValue(\1), locale: locale)',
    content
)

# 4. Fix hardcoded formats
content = content.replace(
    'drawText("• \\(dateStr) - \\(session.durationMinutes) Min (\\(isRoutineStr))", attributes: boldTextAttributes, yPos: &currentY, offset: 15)',
    'drawText(String(format: String(localized: "export.pdf.focus.session_format", defaultValue: "• %@ - %d Min (%@)", locale: locale), dateStr, session.durationMinutes, isRoutineStr), attributes: boldTextAttributes, yPos: &currentY, offset: 15)'
)

content = content.replace(
    'drawText("  Routine: \\(String(localized: String.LocalizationValue(rNameKey), locale: locale))", attributes: textAttributes, yPos: &currentY, offset: 15)',
    'drawText(String(format: String(localized: "export.pdf.focus.routine_format", defaultValue: "  Routine: %@", locale: locale), String(localized: String.LocalizationValue(rNameKey), locale: locale)), attributes: textAttributes, yPos: &currentY, offset: 15)'
)

content = content.replace(
    'drawText("  - \\(cDate) (\\(c.durationMinutes) Min)", attributes: textAttributes, yPos: &currentY, offset: 15)',
    'drawText(String(format: String(localized: "export.pdf.routines.history_format", defaultValue: "  - %@ (%d Min)", locale: locale), cDate, c.durationMinutes), attributes: textAttributes, yPos: &currentY, offset: 15)'
)

content = content.replace(
    'drawText("  • \\(localizedCat): \\(catWatered)x", attributes: textAttributes, yPos: &currentY, offset: 15)',
    'drawText(String(format: String(localized: "stats.categories_watered_format", defaultValue: "  • %@: %dx", locale: locale), localizedCat, catWatered), attributes: textAttributes, yPos: &currentY, offset: 15)'
)

content = content.replace(
    'drawText("• \\(name)", attributes: textAttributes, yPos: &currentY, offset: 15)',
    'drawText("• \\(name)", attributes: textAttributes, yPos: &currentY, offset: 15)' # Not needing translation, just a bullet
)

content = content.replace(
    'formatter.timeStyle = .short',
    'formatter.timeStyle = .short\n            formatter.locale = locale'
)

with open(path, "w") as f:
    f.write(content)

