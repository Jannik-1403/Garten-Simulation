import Foundation
import UIKit
import PDFKit

class PDFExportManager {
    static let shared = PDFExportManager()

    func generateAllNotesPDF(gardenStore: GardenStore, settings: SettingsStore) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Garten Simulation",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: NSLocalizedString("pdf.notes.title", comment: "")
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 595.2 // A4 Width
        let pageHeight = 841.8 // A4 Height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
            
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18)
            ]
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            
            var currentY: CGFloat = 40.0
            let margin: CGFloat = 40.0
            let contentWidth = pageWidth - 2 * margin
            
            func drawText(_ text: String, attributes: [NSAttributedString.Key: Any], yPos: inout CGFloat, addSpace: CGFloat = 10) {
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                let textHeight = attributedString.boundingRect(with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
                
                if yPos + textHeight > pageHeight - margin {
                    context.beginPage()
                    yPos = margin
                }
                
                let rect = CGRect(x: margin, y: yPos, width: contentWidth, height: textHeight)
                attributedString.draw(in: rect)
                yPos += textHeight + addSpace
            }
            
            // Title
            drawText(NSLocalizedString("pdf.notes.title", comment: ""), attributes: titleAttributes, yPos: &currentY, addSpace: 30)
            
            // Gute Gewohnheiten
            let goodHabits = gardenStore.pflanzen.filter { !$0.notizen.isEmpty }
            if !goodHabits.isEmpty {
                drawText(NSLocalizedString("pdf.notes.good_habits", comment: ""), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                for plant in goodHabits {
                    let name = settings.showHabitInsteadOfName ? NSLocalizedString(plant.displayedHabitName, comment: "") : NSLocalizedString(plant.name, comment: "")
                    drawText("🌱 \(name)", attributes: headerAttributes, yPos: &currentY)
                    for (index, note) in plant.notizen.enumerated() {
                        drawText("\(index + 1). \(note)", attributes: textAttributes, yPos: &currentY)
                    }
                    currentY += 10
                }
            }
            
            // Schlechte Gewohnheiten
            let badHabitNotes = gardenStore.badHabitNotes.filter { !$0.value.isEmpty }
            if !badHabitNotes.isEmpty {
                currentY += 20
                drawText(NSLocalizedString("pdf.notes.bad_habits", comment: ""), attributes: headerAttributes, yPos: &currentY, addSpace: 15)
                
                for (id, notes) in badHabitNotes {
                    let itemNameKey: String
                    if let badHabit = GameDatabase.allDecorations.first(where: { $0.id == id }) {
                        itemNameKey = settings.showHabitInsteadOfName ? badHabit.habitNameKey : badHabit.objectNameKey
                    } else {
                        // Fallback logic
                        itemNameKey = id
                    }
                    
                    let name = NSLocalizedString(itemNameKey, comment: "")
                    drawText("⚠️ \(name)", attributes: headerAttributes, yPos: &currentY)
                    for (index, note) in notes.enumerated() {
                        drawText("\(index + 1). \(note)", attributes: textAttributes, yPos: &currentY)
                    }
                    currentY += 10
                }
            }
        }
        
        // Save to temp directory
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(NSLocalizedString("pdf.notes.filename", comment: "Notes.pdf"))
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to write PDF data: \(error)")
            return nil
        }
    }
}
