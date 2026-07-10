import SwiftUI

struct PDFExportConfigView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var assessmentStore: AssessmentStore
    
    @State private var includeGoodHabits = true
    @State private var includeNotes = true
    @State private var includeTimer = true // Focus Timer
    @State private var includeStatistics = true
    @State private var includeQuizResults = true
    @State private var includeBadHabits = true
    @State private var includeRoutines = true
    
    @State private var generatedPDFUrl: URL? = nil
    @State private var pdfFileName: String = String(localized: "export.pdf.default_filename", defaultValue: "Garten_Bericht")

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        

                        
                        // Optionale Bereiche
                        Text(String(localized: "export.config.section.optional", defaultValue: "Zusätzliche Daten", locale: Locale(identifier: settings.appLanguage)))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        toggleRow(title: String(localized: "export.config.section.habits", defaultValue: "Gute Gewohnheiten", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeGoodHabits)
                        toggleRow(title: String(localized: "export.config.stats", defaultValue: "Statistiken (Gesamtfortschritt)", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeStatistics)
                        toggleRow(title: String(localized: "export.config.bad_habits", defaultValue: "Schlechte Gewohnheiten & Rückfälle", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeBadHabits)
                        toggleRow(title: String(localized: "export.config.routines", defaultValue: "Routinen", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeRoutines)
                        toggleRow(title: String(localized: "export.config.timer", defaultValue: "Timer Aufzeichnungen", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeTimer)
                        toggleRow(title: String(localized: "export.config.quiz", defaultValue: "Quiz Ergebnisse", locale: Locale(identifier: settings.appLanguage)), isSelected: $includeQuizResults)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "export.pdf.filename_title", defaultValue: "PDF Dateiname"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        TextField(String(localized: "export.pdf.filename_placeholder", defaultValue: "Name eingeben"), text: $pdfFileName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
                // Export Button
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.opacity(0.7),
                    groesse: 56,
                    isRectangular: true,
                    aktion: {
                        let fileNameToUse = pdfFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Garten_Bericht" : pdfFileName
                        let pdfUrl = PDFExportManager.shared.generatePDF(
                            fileName: fileNameToUse,
                            gardenStore: gardenStore,
                            settings: settings,
                            streakStore: streakStore,
                            assessmentStore: assessmentStore,
                            includeGoodHabits: includeGoodHabits,
                            includeNotes: includeNotes,
                            includeTimer: includeTimer,
                            includeStatistics: includeStatistics,
                            includeQuizResults: includeQuizResults,
                            includeBadHabits: includeBadHabits,
                            includeRoutines: includeRoutines
                        )
                        if let pdfUrl = pdfUrl {
                            self.generatedPDFUrl = pdfUrl
                            PDFExportManager.share(items: [pdfUrl])
                        }
                    }
                ) {
                    Text(String(localized: "export.config.button", defaultValue: "PDF generieren", locale: Locale(identifier: settings.appLanguage)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color(hex: "#F2F2F7").ignoresSafeArea())
            .navigationTitle(String(localized: "export.config.title", defaultValue: "PDF Export Konfigurator", locale: Locale(identifier: settings.appLanguage)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func toggleRow(title: String, isSelected: Binding<Bool>) -> some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.5)) {
                isSelected.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Text(title)
                Spacer()
                Image(systemName: isSelected.wrappedValue ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected.wrappedValue ? .blauPrimary : Color(hex: "#C7C7CC"))
                    .font(.system(size: 20))
            }
        }
        .buttonStyle(DuolingoButtonStyle(
            size: .medium,
            fillWidth: true,
            backgroundColor: .white,
            shadowColor: Color(hex: "#C7C7CC"),
            foregroundColor: .primary
        ))
    }
    
    private func generateAndShare() {
        let fileNameToUse = pdfFileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Garten_Bericht" : pdfFileName
        if let url = PDFExportManager.shared.generatePDF(
            fileName: fileNameToUse,
            gardenStore: gardenStore,
            settings: settings,
            streakStore: streakStore,
            assessmentStore: assessmentStore,
            includeGoodHabits: includeGoodHabits,
            includeNotes: includeNotes,
            includeTimer: includeTimer,
            includeStatistics: includeStatistics,
            includeQuizResults: includeQuizResults,
            includeBadHabits: includeBadHabits,
            includeRoutines: includeRoutines
        ) {
            generatedPDFUrl = url
            PDFExportManager.share(items: [url])
        }
    }
}
