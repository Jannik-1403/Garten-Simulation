import SwiftUI

struct PDFExportConfigView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var assessmentStore: AssessmentStore
    
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
                        
                        // Gewohnheiten (immer dabei)
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(localized: "export.config.section.habits", defaultValue: "Gute Gewohnheiten"))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text(String(localized: "export.config.habits_always_included", defaultValue: "Werden standardmäßig immer exportiert."))
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
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
                Button {
                    let pdfUrl = PDFExportManager.shared.generatePDF(
                        gardenStore: gardenStore,
                        settings: settings,
                        streakStore: streakStore,
                        assessmentStore: assessmentStore,
                        includeNotes: true,
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
                } label: {
                    Text(String(localized: "export.config.button", defaultValue: "PDF generieren"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.blauPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.blauPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle(String(localized: "export.config.title", defaultValue: "PDF Export Konfigurator"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.gray.opacity(0.5), Color(hex: "#F2F2F7"))
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
