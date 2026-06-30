import Foundation
import UIKit
import PDFKit
import SwiftUI

class PDFExportManager {
    static let shared = PDFExportManager()

    @MainActor
    func generatePDF(
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
            
            // Reusable Attributes
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold)
            ]
            let subheaderAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
            let boldTextAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold)
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
                    yPos = 40.0
                }
            }
            
            // Title
            let title = String(localized: "export.pdf.title", defaultValue: "Dein Garten Bericht")
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
            drawText(String(localized: "export.pdf.date", defaultValue: "Erstellt am \(formatter.string(from: Date()))"), attributes: textAttributes, yPos: &currentY, addSpace: 20)
            
            // 1. Gute Gewohnheiten & Notizen (Optional)
            if includeGoodHabits {
                drawText(String(localized: "export.good_habits.title", defaultValue: "Gute Gewohnheiten & Notizen"), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                let plantsToExport = gardenStore.pflanzen.filter { plantIds == nil || plantIds!.contains($0.id) }
                
                for plant in plantsToExport {
                    let titleStr = settings.showHabitInsteadOfName ? NSLocalizedString(plant.displayedHabitName, comment: "") : NSLocalizedString(plant.name, comment: "")
                    drawText(titleStr, attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                    
                    if includeNotes {
                        let notes = plant.notizen
                        if notes.isEmpty {
                            drawText(String(localized: "export.notes.empty", defaultValue: "Keine Notizen vorhanden."), attributes: textAttributes, yPos: &currentY, offset: 15)
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
                drawText(String(localized: "export.stats.title", defaultValue: "Allgemeine Statistiken"), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                drawText(String(localized: "stats.max_streak", defaultValue: "Höchster Streak (Tage): \(streakStore.bestStreak)"), attributes: textAttributes, yPos: &currentY, offset: 15)
                drawText(String(localized: "stats.current_streak", defaultValue: "Aktueller Streak: \(streakStore.currentStreak)"), attributes: textAttributes, yPos: &currentY, offset: 15)
                
                let challengeText = String(localized: "stats.completed_challenges", defaultValue: "Abgeschlossene 90-Tage Challenges: \(gardenStore.completed90DayChallenges)")
                drawText(challengeText, attributes: textAttributes, yPos: &currentY, offset: 15)
            }
            
            // 3. Timer / Fokus Zeit
            if includeTimer {
                currentY += 20
                drawText(String(localized: "export.timer.title", defaultValue: "Fokus Zeit Statistiken"), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                let totalMinutes = gardenStore.focusSessions.reduce(0) { $0 + $1.durationMinutes }
                drawText(String(localized: "stats.total_focus", defaultValue: "Gesamte Fokus Zeit: \(totalMinutes / 60)h \(totalMinutes % 60)m"), attributes: textAttributes, yPos: &currentY, offset: 15)
                
                let sessions = gardenStore.focusSessions.sorted { $0.date > $1.date }.prefix(20) // Letzte 20 Sessions
                if sessions.isEmpty {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                } else {
                    for session in sessions {
                        let dateStr = formatter.string(from: session.date)
                        let isRoutineStr = (session.isRoutine == true) ? String(localized: "export.pdf.focus.type_routine", defaultValue: "Routine") : String(localized: "export.pdf.focus.type_habit", defaultValue: "Gewohnheit")
                        drawText("• \(dateStr) - \(session.durationMinutes) Min (\(isRoutineStr))", attributes: boldTextAttributes, yPos: &currentY, offset: 15)
                        
                        if session.isRoutine == true, let rNameKey = session.routineNameKey {
                            drawText("  Routine: \(NSLocalizedString(rNameKey, comment: ""))", attributes: textAttributes, yPos: &currentY, offset: 15)
                        } else if let hName = session.habitName {
                            let habitTitle = settings.showHabitInsteadOfName ? (gardenStore.pflanzen.first(where: { $0.id == session.habitId })?.displayedHabitName ?? hName) : hName
                            drawText("  " + String(format: String(localized: "export.pdf.focus.habit_name", defaultValue: "Gewohnheit: %@"), NSLocalizedString(habitTitle, comment: "")), attributes: textAttributes, yPos: &currentY, offset: 15)
                        }
                        
                        if let tasks = session.tasks, !tasks.isEmpty {
                            drawText("  " + String(localized: "export.pdf.focus.tasks", defaultValue: "Aufgaben:"), attributes: textAttributes, yPos: &currentY, offset: 15)
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
                drawText(String(localized: "export.bad_habits.title", defaultValue: "Schlechte Gewohnheiten & Rückfälle"), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
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
                    
                    let title = NSLocalizedString(itemNameKey, comment: "")
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
                    
                    let streakText = String(localized: "export.bad_habits.max_streak", defaultValue: "Längster Streak ohne Rückfall: \(maxStreakDays) Tage")
                    drawText(streakText, attributes: textAttributes, yPos: &currentY, offset: 15)
                    
                    if sortedExecutions.isEmpty {
                        drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                    } else {
                        for execution in sortedExecutions {
                            let dateStr = formatter.string(from: execution.date)
                            drawText("• \(dateStr)", attributes: textAttributes, yPos: &currentY, offset: 15)
                            // If BadHabitExecution had notes we'd show them, but it only has 'triggers' (and coinsLost)
                            if let triggers = execution.triggers, !triggers.isEmpty {
                                let triggersStr = triggers.joined(separator: ", ")
                                drawText(String(localized: "export.bad_habits.triggers", defaultValue: "  Auslöser: \(triggersStr)"), attributes: textAttributes, yPos: &currentY, offset: 15)
                            }
                        }
                    }
                    currentY += 10
                }
                
                if !exportedAny {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                }
            }
            
            // 5. Quiz Ergebnisse als Screenshot
            if includeQuizResults {
                currentY += 20
                
                // Draw ImageRenderer snapshot
                let quizView = QuizScreenshotView(assessmentStore: assessmentStore)
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
                drawText(String(localized: "export.routines.title", defaultValue: "Routinen"), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                if let data = UserDefaults.standard.data(forKey: "customRoutinesData") {
                    struct MinimalRoutine: Codable {
                        var titleKey: String
                        var assignedHabitIDs: [String]
                    }
                    if let saved = try? JSONDecoder().decode([MinimalRoutine].self, from: data), !saved.isEmpty {
                        for routine in saved {
                            drawText(NSLocalizedString(routine.titleKey, comment: ""), attributes: subheaderAttributes, yPos: &currentY, offset: 15)
                            
                            if routine.assignedHabitIDs.isEmpty {
                                drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                            } else {
                                for hid in routine.assignedHabitIDs {
                                    if let p = gardenStore.pflanzen.first(where: { $0.id == hid }) {
                                        let name = settings.showHabitInsteadOfName ? NSLocalizedString(p.displayedHabitName, comment: "") : NSLocalizedString(p.name, comment: "")
                                        drawText("• \(name)", attributes: textAttributes, yPos: &currentY, offset: 15)
                                    } else if let badHabit = GameDatabase.allDecorations.first(where: { $0.id == hid }) {
                                        let itemNameKey = settings.showHabitInsteadOfName ? badHabit.habitNameKey : badHabit.objectNameKey
                                        let name = NSLocalizedString(itemNameKey, comment: "")
                                        drawText("• \(name)", attributes: textAttributes, yPos: &currentY, offset: 15)
                                    }
                                }
                            }
                            
                            let completions = gardenStore.focusSessions.filter { $0.isRoutine == true && $0.routineNameKey == routine.titleKey }
                            if !completions.isEmpty {
                                let recentCompletions = completions.sorted { $0.date > $1.date }.prefix(5)
                                drawText(String(localized: "export.pdf.routines.history", defaultValue: "Letzte Abschlüsse:"), attributes: textAttributes, yPos: &currentY, offset: 15)
                                for c in recentCompletions {
                                    let cDate = formatter.string(from: c.date)
                                    drawText("  - \(cDate) (\(c.durationMinutes) Min)", attributes: textAttributes, yPos: &currentY, offset: 15)
                                }
                            }
                            
                            currentY += 10
                        }
                    } else {
                        drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                    }
                } else {
                    drawText(String(localized: "export.no_data", defaultValue: "Keine Daten momentan drin."), attributes: textAttributes, yPos: &currentY, offset: 15)
                }
            }
        }
        
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("Garten_Bericht.pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Fehler beim Speichern der PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
