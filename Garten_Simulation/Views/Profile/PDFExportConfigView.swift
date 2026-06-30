import SwiftUI

struct PDFExportConfigView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var assessmentStore: AssessmentStore
    
    @State private var includeGoodHabits = false
    @State private var includeNotes = true
    @State private var includeTimer = true // Focus Timer
    @State private var includeStatistics = true
    @State private var includeQuizResults = true
    @State private var includeBadHabits = true
    @State private var includeRoutines = true
    
    @State private var generatedPDFUrl: URL? = nil
    @State private var isSharing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Gewohnheiten (optional)
                        toggleRow(title: String(localized: "export.config.section.habits", defaultValue: "Gute Gewohnheiten"), isSelected: $includeGoodHabits)
                        
                        Divider().padding(.vertical, 8)
                        
                        // Optionale Bereiche
                        Text(String(localized: "export.config.section.optional", defaultValue: "Zusätzliche Daten"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        toggleRow(title: String(localized: "export.config.stats", defaultValue: "Statistiken (Gesamtfortschritt)"), isSelected: $includeStatistics)
                        toggleRow(title: String(localized: "export.config.bad_habits", defaultValue: "Schlechte Gewohnheiten & Rückfälle"), isSelected: $includeBadHabits)
                        toggleRow(title: String(localized: "export.config.routines", defaultValue: "Routinen"), isSelected: $includeRoutines)
                        toggleRow(title: String(localized: "export.config.timer", defaultValue: "Timer Aufzeichnungen"), isSelected: $includeTimer)
                        toggleRow(title: String(localized: "export.config.quiz", defaultValue: "Quiz Ergebnisse"), isSelected: $includeQuizResults)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                
                // Export Button
                Item3DButton(
                    farbe: .blauPrimary,
                    sekundaerFarbe: Color.blauPrimary.opacity(0.7),
                    groesse: 56,
                    isRectangular: true,
                    aktion: {
                        let pdfUrl = PDFExportManager.shared.generatePDF(
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
                            self.isSharing = true
                        }
                    }
                ) {
                    Text(String(localized: "export.config.button", defaultValue: "PDF generieren"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle(String(localized: "export.config.title", defaultValue: "PDF Export Konfigurator"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $isSharing) {
            if let url = generatedPDFUrl {
                PDFExportShareSheet(activityItems: [url])
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
        if let url = PDFExportManager.shared.generatePDF(
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
            isSharing = true
        }
    }
}
