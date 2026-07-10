import Foundation
import UIKit
import PDFKit
import SwiftUI

class PDFExportManager {
    static let shared = PDFExportManager()

    @MainActor
    func generatePDF(
        fileName: String = "Garten_Bericht",
        for plantIds: Set<String>? = nil,
        badHabitIds: Set<String>? = nil,
        gardenStore: GardenStore,
        settings: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore,
        includeGoodHabits: Bool = false,
        includeNotes: Bool = true,
        includeTimer: Bool = false,
        includeStatistics: Bool = false,
        includeQuizResults: Bool = false,
        includeBadHabits: Bool = false,
        includeRoutines: Bool = false
    ) -> URL? {
        
        let locale = Locale(identifier: settings.appLanguage)
        let pdfMetaData = [
            kCGPDFContextCreator: "Garten Simulation",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 format
        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            UIColor.white.setFill()
            context.cgContext.fill(pageRect)
            
            // Reusable Attributes
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let subheaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            let boldTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            
            var currentY: CGFloat = 40.0
            
            // Helper function
            func drawText(_ text: String, attributes: [NSAttributedString.Key: Any], yPos: inout CGFloat, offset: CGFloat = 20, addSpace: CGFloat = 0) {
                let textRect = CGRect(x: 40, y: yPos, width: pageWidth - 80, height: 1000)
                let nsText = text as NSString
                let boundingRect = nsText.boundingRect(with: CGSize(width: pageWidth - 80, height: .greatestFiniteMagnitude),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: attributes,
                                                     context: nil)
                
                nsText.draw(in: textRect, withAttributes: attributes)
                yPos += boundingRect.height + offset + addSpace
                
                if yPos > pageHeight - 50 {
                    context.beginPage()
                    UIColor.white.setFill()
                    context.cgContext.fill(pageRect)
                    yPos = 40.0
                }
            }
            
            // Title
            let title = String(localized: "export.pdf.title", defaultValue: "Dein Garten Bericht", locale: locale)
            let titleRect = CGRect(x: 40, y: currentY, width: pageWidth - 80, height: 50)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .black)
            ]
            (title as NSString).draw(in: titleRect, withAttributes: titleAttributes)
            currentY += 40
            
            // Date
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            formatter.locale = locale
            drawText(String(localized: "export.pdf.date", defaultValue: "Erstellt am \(formatter.string(from: Date()))", locale: locale), attributes: textAttributes, yPos: &currentY, addSpace: 20)
            
            // 1. Gute Gewohnheiten & Notizen (Optional)
            if includeGoodHabits {
                drawText(String(localized: "export.good_habits.title", defaultValue: "Gute Gewohnheiten & Notizen", locale: locale), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                let plantsToExport = gardenStore.pflanzen.filter { plantIds == nil || plantIds!.contains($0.id) }
                
                for plant in plantsToExport {
                    let titleStr = settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(plant.displayedHabitName), locale: locale) : String(localized: String.LocalizationValue(plant.name), locale: locale)
                    drawText(titleStr, attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                    
                    if includeNotes {
                        let notes = plant.notizen
                        if notes.isEmpty {
                            drawText(String(localized: "export.notes.empty", defaultValue: "Keine Notizen vorhanden.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                        } else {
                            for (index, note) in notes.enumerated() {
                                drawText("\(index + 1). \(note)", attributes: textAttributes, yPos: &currentY, offset: 15)
                            }
                        }
                    }
                    currentY += 10
                }
            }
            
            // 2. Statistiken
            if includeStatistics {
                currentY += 20
                drawText(String(localized: "export.stats.title", defaultValue: "Allgemeine Statistiken", locale: locale), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                drawText(String(localized: "stats.max_streak", defaultValue: "Höchster Streak (Tage): \(streakStore.bestStreak)", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                drawText(String(localized: "stats.current_streak", defaultValue: "Aktueller Streak: \(streakStore.currentStreak)", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                
                let challengeText = String(localized: "stats.completed_challenges", defaultValue: "Abgeschlossene 90-Tage Challenges: \(gardenStore.completed90DayChallenges)", locale: locale)
                drawText(challengeText, attributes: textAttributes, yPos: &currentY, offset: 15)
                
                currentY += 10
                drawText(String(localized: "stats.categories_watered", defaultValue: "Gegossen pro Kategorie:", locale: locale), attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                for category in HabitCategory.allCases.filter({ $0 != .seeds }) {
                    let catWatered = gardenStore.pflanzen.filter { $0.habitCategory == category }.reduce(0) { $0 + $1.wateringDates.count }
                    if catWatered > 0 {
                        let localizedCat = String(localized: String.LocalizationValue(category.localizationKey), locale: locale)
                        drawText(String(format: String(localized: "stats.categories_watered_format", defaultValue: "  • %@: %dx", locale: locale), localizedCat, catWatered), attributes: textAttributes, yPos: &currentY, offset: 15)
                    }
                }
            }
            
            // 3. Timer / Fokus Zeit
            if includeTimer {
                currentY += 20
                drawText(String(localized: "export.timer.title", defaultValue: "Fokus Zeit Statistiken", locale: locale), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                let totalMinutes = gardenStore.focusSessions.reduce(0) { $0 + $1.durationMinutes }
                drawText(String(localized: "stats.total_focus", defaultValue: "Gesamte Fokus Zeit: \(totalMinutes / 60)h \(totalMinutes % 60)m", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                
                let sessions = gardenStore.focusSessions.sorted { $0.date > $1.date }.prefix(20) // Letzte 20 Sessions
                if sessions.isEmpty {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                } else {
                    for session in sessions {
                        let dateStr = formatter.string(from: session.date)
                        let isRoutineStr = (session.isRoutine == true) ? String(localized: "export.pdf.focus.type_routine", defaultValue: "Routine", locale: locale) : String(localized: "export.pdf.focus.type_habit", defaultValue: "Gewohnheit", locale: locale)
                        drawText(String(format: String(localized: "export.pdf.focus.session_format", defaultValue: "• %@ - %d Min (%@)", locale: locale), dateStr, session.durationMinutes, isRoutineStr), attributes: boldTextAttributes, yPos: &currentY, offset: 15)
                        
                        if session.isRoutine == true, let rNameKey = session.routineNameKey {
                            drawText(String(format: String(localized: "export.pdf.focus.routine_format", defaultValue: "  Routine: %@", locale: locale), String(localized: String.LocalizationValue(rNameKey), locale: locale)), attributes: textAttributes, yPos: &currentY, offset: 15)
                        } else if let hName = session.habitName {
                            let habitTitle = settings.showHabitInsteadOfName ? (gardenStore.pflanzen.first(where: { $0.id == session.habitId })?.displayedHabitName ?? hName) : hName
                            drawText("  " + String(format: String(localized: "export.pdf.focus.habit_name", defaultValue: "Gewohnheit: %@", locale: locale), String(localized: String.LocalizationValue(habitTitle), locale: locale)), attributes: textAttributes, yPos: &currentY, offset: 15)
                        }
                        
                        if let tasks = session.tasks, !tasks.isEmpty {
                            drawText("  " + String(localized: "export.pdf.focus.tasks", defaultValue: "Aufgaben:", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                            for task in tasks {
                                drawText("    - \(task)", attributes: textAttributes, yPos: &currentY, offset: 15)
                            }
                        }
                    }
                }
            }
            
            // 4. Schlechte Gewohnheiten & Rückfälle
            if includeBadHabits {
                currentY += 20
                drawText(String(localized: "export.bad_habits.title", defaultValue: "Schlechte Gewohnheiten & Rückfälle", locale: locale), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                var exportedAny = false
                
                for (id, executions) in gardenStore.badHabitExecutions {
                    if let filter = badHabitIds, !filter.contains(id) { continue }
                    exportedAny = true
                    
                    let itemNameKey: String
                    if let badHabit = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                        itemNameKey = settings.showHabitInsteadOfName ? badHabit.habitNameKey : badHabit.objectNameKey
                    } else {
                        itemNameKey = id
                    }
                    
                    let title = String(localized: String.LocalizationValue(itemNameKey), locale: locale)
                    drawText(title, attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                    
                    let sortedExecutions = executions.sorted { $0.date < $1.date }
                    
                    // Calculate longest streak (time between executions)
                    var maxStreakDays = 0
                    if !sortedExecutions.isEmpty {
                        // We don't have createdAt, so we start counting from the first execution if there are any.
                        // Or maybe we just calculate intervals between executions, and between last execution and now.
                        var previousDate = sortedExecutions.first!.date
                        for exec in sortedExecutions.dropFirst() {
                            let days = Calendar.current.dateComponents([.day], from: previousDate, to: exec.date).day ?? 0
                            if days > maxStreakDays { maxStreakDays = days }
                            previousDate = exec.date
                        }
                        let daysUntilNow = Calendar.current.dateComponents([.day], from: previousDate, to: Date()).day ?? 0
                        if daysUntilNow > maxStreakDays { maxStreakDays = daysUntilNow }
                    } else {
                        // Empty executions? Shouldn't happen since it's only in dict if executed, but fallback just in case
                    }
                    
                    let streakText = String(localized: "export.bad_habits.max_streak", defaultValue: "Längster Streak ohne Rückfall: \(maxStreakDays) Tage", locale: locale)
                    drawText(streakText, attributes: textAttributes, yPos: &currentY, offset: 15)
                    
                    if sortedExecutions.isEmpty {
                        drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                    } else {
                        for execution in sortedExecutions {
                            let dateStr = formatter.string(from: execution.date)
                            drawText("• \(dateStr)", attributes: textAttributes, yPos: &currentY, offset: 15)
                            // If BadHabitExecution had notes we'd show them, but it only has 'triggers' (and coinsLost)
                            if let triggers = execution.triggers, !triggers.isEmpty {
                                let triggersStr = triggers.joined(separator: ", ")
                                drawText(String(localized: "export.bad_habits.triggers", defaultValue: "  Auslöser: \(triggersStr)", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                            }
                        }
                    }
                    currentY += 10
                }
                
                if !exportedAny {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                }
            }
            
            // 5. Quiz Ergebnisse als Screenshot
            if includeQuizResults {
                currentY += 20
                
                // Draw ImageRenderer snapshot
                let quizView = QuizScreenshotView(assessmentStore: assessmentStore).environment(\.locale, locale)
                let imageRenderer = ImageRenderer(content: quizView)
                imageRenderer.scale = 2.0 // Retain some quality
                
                if let uiImage = imageRenderer.uiImage {
                    // Check if it fits on the page
                    let imageWidth = pageWidth - 80
                    let imageHeight = (imageWidth / uiImage.size.width) * uiImage.size.height
                    
                    if currentY + imageHeight > pageHeight - 50 {
                        context.beginPage()
                        currentY = 40.0
                    }
                    
                    let imageRect = CGRect(x: 40, y: currentY, width: imageWidth, height: imageHeight)
                    uiImage.draw(in: imageRect)
                    
                    currentY += imageHeight + 20
                }
            }
            
            // 6. Routinen
            if includeRoutines {
                currentY += 20
                drawText(String(localized: "export.routines.title", defaultValue: "Routinen", locale: locale), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                if let data = SharedUserDefaults.suite.data(forKey: "customRoutinesData") {
                    struct MinimalRoutine: Codable {
                        var titleKey: String
                        var assignedHabitIDs: [String]
                    }
                    if let saved = try? JSONDecoder().decode([MinimalRoutine].self, from: data), !saved.isEmpty {
                        for routine in saved {
                            drawText(String(localized: String.LocalizationValue(routine.titleKey), locale: locale), attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                            
                            if routine.assignedHabitIDs.isEmpty {
                                drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                            } else {
                                for hid in routine.assignedHabitIDs {
                                    if let p = gardenStore.pflanzen.first(where: { $0.id == hid }) {
                                        let name = settings.showHabitInsteadOfName ? String(localized: String.LocalizationValue(p.displayedHabitName), locale: locale) : String(localized: String.LocalizationValue(p.name), locale: locale)
                                        drawText("• \(name)", attributes: textAttributes, yPos: &currentY, offset: 15)
                                    } else if let badHabit = GameDatabase.allDecorations.first(where: { $0.id == hid }) {
                                        let itemNameKey = settings.showHabitInsteadOfName ? badHabit.habitNameKey : badHabit.objectNameKey
                                        let name = String(localized: String.LocalizationValue(itemNameKey), locale: locale)
                                        drawText("• \(name)", attributes: textAttributes, yPos: &currentY, offset: 15)
                                    }
                                }
                            }
                            
                            let completions = gardenStore.focusSessions.filter { $0.isRoutine == true && $0.routineNameKey == routine.titleKey }
                            if !completions.isEmpty {
                                let recentCompletions = completions.sorted { $0.date > $1.date }.prefix(5)
                                drawText(String(localized: "export.pdf.routines.history", defaultValue: "Letzte Abschlüsse:", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                                for c in recentCompletions {
                                    let cDate = formatter.string(from: c.date)
                                    drawText(String(format: String(localized: "export.pdf.routines.history_format", defaultValue: "  - %@ (%d Min)", locale: locale), cDate, c.durationMinutes), attributes: textAttributes, yPos: &currentY, offset: 15)
                                }
                            }
                            
                            currentY += 10
                        }
                    } else {
                        drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                    }
                } else {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin.", locale: locale), attributes: textAttributes, yPos: &currentY, offset: 15)
                }
            }
        }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        // Sanitize the filename to prevent path traversal or invalid characters
        let safeFileName = fileName.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "\\", with: "_")
        let fileURL = tempDir.appendingPathComponent("\(safeFileName).pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Fehler beim Speichern der PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    @MainActor
    func generateWeeklyPDFReport(
        fileName: String = "Grovy_Wochenbericht",
        for weekStart: Date,
        gardenStore: GardenStore,
        settings: SettingsStore,
        streakStore: StreakStore,
        assessmentStore: AssessmentStore
    ) -> URL? {
        let report = WeeklyStatsManager.shared.generateReport(for: weekStart, gardenStore: gardenStore)

        
        let pdfMetaData = [
            kCGPDFContextCreator: "Grovy Wochenbericht",
            kCGPDFContextAuthor: "User"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // Explicitly fill background with white to prevent dark mode transparency issues
            UIColor.white.setFill()
            context.cgContext.fill(pageRect)
            
            var currentY: CGFloat = 40.0
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            let sectionHeaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let boldTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            let bodyTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            
            func drawText(_ text: String, attributes: [NSAttributedString.Key: Any], yPos: inout CGFloat, offset: CGFloat = 15, addSpace: CGFloat = 0) {
                let textRect = CGRect(x: 40, y: yPos, width: pageWidth - 80, height: 1000)
                let nsText = text as NSString
                let boundingRect = nsText.boundingRect(with: CGSize(width: pageWidth - 80, height: .greatestFiniteMagnitude),
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: attributes,
                                                     context: nil)
                
                nsText.draw(in: textRect, withAttributes: attributes)
                yPos += boundingRect.height + offset + addSpace
                
                if yPos > pageHeight - 50 {
                    context.beginPage()
                    UIColor.white.setFill()
                    context.cgContext.fill(pageRect)
                    yPos = 40.0
                }
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let rangeString = "\(formatter.string(from: report.weekStartDate)) - \(formatter.string(from: report.weekEndDate))"
            
            drawText(String(localized: "export.pdf.report.title", defaultValue: "Grovy Wochenbericht"), attributes: titleAttributes, yPos: &currentY, offset: 4)
            drawText(String(localized: "export.pdf.report.period", defaultValue: "Zeitraum: %@").replacingOccurrences(of: "%@", with: rangeString), attributes: subtitleAttributes, yPos: &currentY, offset: 25)
            
            drawText(String(localized: "export.pdf.report.summary", defaultValue: "1. Wochen-Zusammenfassung"), attributes: sectionHeaderAttributes, yPos: &currentY, offset: 12, addSpace: 5)
            
            let focusChangeStr = report.focusMinutesChangePercentage >= 0 ? "+\(Int(report.focusMinutesChangePercentage))%" : "\(Int(report.focusMinutesChangePercentage))%"
            let habitsChangeStr = report.habitsChangePercentage >= 0 ? "+\(Int(report.habitsChangePercentage))%" : "\(Int(report.habitsChangePercentage))%"
            
            drawText("• " + String(format: String(localized: "export.pdf.report.total_focus_time", defaultValue: "Gesamt-Fokuszeit: %lld Minuten (%@ im Vergleich zur Vorwoche)"), report.totalFocusMinutes, focusChangeStr), attributes: bodyTextAttributes, yPos: &currentY, offset: 8)
            drawText("• " + String(format: String(localized: "export.pdf.report.completed_habits", defaultValue: "Erledigte Gewohnheiten: %lld (%@ im Vergleich zur Vorwoche)"), report.completedHabitsCount, habitsChangeStr), attributes: bodyTextAttributes, yPos: &currentY, offset: 8)
            drawText("• " + String(format: String(localized: "export.pdf.report.completed_sessions", defaultValue: "Abgeschlossene Fokus-Sessions: %lld"), report.completedSessionsCount), attributes: bodyTextAttributes, yPos: &currentY, offset: 8)
            drawText("• " + String(format: String(localized: "export.pdf.report.earned_xp", defaultValue: "Verdiente Erfahrungspunkte: %lld XP"), report.earnedXP), attributes: bodyTextAttributes, yPos: &currentY, offset: 20)
            
            drawText(String(localized: "export.pdf.report.progress_analysis", defaultValue: "2. Fortschritts-Analyse"), attributes: sectionHeaderAttributes, yPos: &currentY, offset: 12, addSpace: 5)
            drawText(report.feedbackTitle, attributes: boldTextAttributes, yPos: &currentY, offset: 8)
            drawText(report.feedbackDescription, attributes: bodyTextAttributes, yPos: &currentY, offset: 20)
            
            drawText(String(localized: "export.pdf.report.daily_activities", defaultValue: "3. Tägliche Aktivitäten"), attributes: sectionHeaderAttributes, yPos: &currentY, offset: 15, addSpace: 5)
            
            drawText(String(localized: "export.pdf.report.focus_minutes", defaultValue: "Fokus-Minuten:"), attributes: boldTextAttributes, yPos: &currentY, offset: 8)
            for item in report.dailyFocusMinutes {
                drawText("  • " + String(format: String(localized: "export.pdf.report.daily_focus_item", defaultValue: "%@: %lld Min"), item.dayName, item.minutes), attributes: bodyTextAttributes, yPos: &currentY, offset: 6)
            }
            
            currentY += 10
            drawText(String(localized: "export.pdf.report.habits_completed", defaultValue: "Erledigte Gewohnheiten:"), attributes: boldTextAttributes, yPos: &currentY, offset: 8)
            for item in report.dailyHabitsCompleted {
                drawText("  • " + String(format: String(localized: "export.pdf.report.daily_habit_item", defaultValue: "%@: %lld erledigt"), item.dayName, item.count), attributes: bodyTextAttributes, yPos: &currentY, offset: 6)
            }
            
            // 4. Machine Readable Data
            currentY += 40
            let rawDataAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 6, weight: .regular),
                .foregroundColor: UIColor.systemGray5
            ]
            
            let bestFocusDayIndex = report.dailyFocusMinutes.indices.max(by: { report.dailyFocusMinutes[$0].minutes < report.dailyFocusMinutes[$1].minutes }) ?? 0
            let bestDayName = report.dailyFocusMinutes[bestFocusDayIndex].minutes > 0 ? report.dailyFocusMinutes[bestFocusDayIndex].dayName : "none"
            
            let rawDataStr = """
            --- MACHINE READABLE DATA START ---
            total_focus_minutes: \(report.totalFocusMinutes)
            completed_sessions_count: \(report.completedSessionsCount)
            completed_habits_count: \(report.completedHabitsCount)
            earned_xp: \(report.earnedXP)
            best_focus_day: \(bestDayName)
            focus_change_percentage: \(report.focusMinutesChangePercentage)
            habits_change_percentage: \(report.habitsChangePercentage)
            --- MACHINE READABLE DATA END ---
            """
            
            drawText(rawDataStr, attributes: rawDataAttributes, yPos: &currentY, offset: 0)
        }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        // Sanitize the filename to prevent path traversal or invalid characters
        let safeFileName = fileName.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "\\", with: "_")
        let fileURL = tempDir.appendingPathComponent("\(safeFileName).pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Fehler beim Speichern der Wochen-PDF: \(error.localizedDescription)")
            return nil
        }
    }
}

extension PDFExportManager {
    @MainActor
    static func share(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene ?? UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        topVC.present(activityVC, animated: true)
    }
}

