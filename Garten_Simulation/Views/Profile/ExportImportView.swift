import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct ExportImportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var achievementStore: AchievementStore
    @EnvironmentObject var settingsStore: SettingsStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var assessmentStore: AssessmentStore
    
    // SwiftData context (optional if used)
    @Environment(\.modelContext) private var modelContext
    
    @State private var showShareSheet = false
    @State private var exportURL: URL? = nil
    @State private var showFilePicker = false
    @State private var showImportConfirm = false
    @State private var importURL: URL? = nil
    @State private var errorMessage: String? = nil
    @State private var erfolgreich = false
    @State private var isLoading = false
    
    // External import support
    var preselectedImportURL: URL? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Illustration
                        Image("ExportImport")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .scaleEffect(2.2)
                            .allowsHitTesting(false)
                            .padding(.top, 20)
                        
                        Text(String(localized: "backup_export_hint"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        VStack(spacing: 16) {
                            // MARK: Export Button
                            Button {
                                exportSave()
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text(String(localized: "backup_export_titel"))
                                }
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                backgroundColor: Color(red: 0.33, green: 0.76, blue: 0.01), // Duo Green
                                shadowColor: Color(red: 0.35, green: 0.65, blue: 0.00)
                            ))
                            
                            // MARK: Import Button
                            Button {
                                showFilePicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "folder.badge.plus")
                                    Text(String(localized: "backup_import_titel"))
                                }
                            }
                            .buttonStyle(DuolingoButtonStyle(
                                backgroundColor: Color(red: 0.11, green: 0.70, blue: 0.93), // Duo Blue
                                shadowColor: Color(red: 0.10, green: 0.58, blue: 0.78)
                            ))
                        }
                        .padding(.horizontal, 20)
                        
                        Text(String(localized: "backup_import_hint"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                }
                
                // MARK: Loading Overlay
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(40)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                // MARK: Success Toast
                if erfolgreich {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(String(localized: "backup_erfolg"))
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.green)
                        .clipShape(Capsule())
                        .shadow(radius: 10)
                        .padding(.bottom, 50)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(10)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: erfolgreich)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
            .navigationTitle(String(localized: "backup_title"))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            .background(
                Color.clear
                    .sheet(isPresented: $showShareSheet, onDismiss: { exportURL = nil }) {
                        if let url = exportURL {
                            ShareSheet(activityItems: [url])
                        }
                    }
            )
            .background(
                Color.clear
                    .fileImporter(
                        isPresented: $showFilePicker,
                        allowedContentTypes: [UTType(filenameExtension: "gartensave") ?? .data],
                        allowsMultipleSelection: false
                    ) { result in
                        switch result {
                        case .success(let urls):
                            if let url = urls.first {
                                importURL = url
                                showImportConfirm = true
                            }
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                        }
                    }
            )
            .background(
                Color.clear
                    .alert(String(localized: "backup_import_bestaetigung_titel"), isPresented: $showImportConfirm) {
                        Button(String(localized: "backup_import_bestaetigung_ja"), role: .destructive) {
                            if let url = importURL {
                                performImport(from: url)
                            }
                        }
                        Button(String(localized: "button.cancel"), role: .cancel) {
                            importURL = nil
                        }
                    } message: {
                        Text(String(localized: "backup_import_bestaetigung_text"))
                    }
            )
            .background(
                Color.clear
                    .alert(String(localized: "backup_fehler_titel"), isPresented: Binding(
                        get: { errorMessage != nil },
                        set: { if !$0 { errorMessage = nil } }
                    )) {
                        Button(String(localized: "button.ok"), role: .cancel) {}
                    } message: {
                        if let msg = errorMessage {
                            Text(msg)
                        }
                    }
            )
            .onAppear {
                if let url = preselectedImportURL {
                    self.importURL = url
                    self.showImportConfirm = true
                }
            }
        }
    }
    
    private func exportSave() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                let url = try DataExportImportManager.shared.exportieren(
                    gardenStore: gardenStore,
                    shopStore: shopStore,
                    achievementStore: achievementStore,
                    settingsStore: settingsStore,
                    streakStore: streakStore,
                    assessmentStore: assessmentStore
                )
                self.exportURL = url
                self.showShareSheet = true
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func performImport(from url: URL) {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                try DataExportImportManager.shared.importieren(
                    von: url,
                    gardenStore: gardenStore,
                    shopStore: shopStore,
                    achievementStore: achievementStore,
                    settingsStore: settingsStore,
                    streakStore: streakStore,
                    assessmentStore: assessmentStore,
                    modelContext: modelContext
                )
                
                // Show success
                self.isLoading = false
                withAnimation {
                    isLoading = false
                    erfolgreich = true
                }
                
                FeedbackManager.shared.playSuccess()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation { erfolgreich = false }
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    ExportImportView()
        .environmentObject(GardenStore())
        .environmentObject(ShopStore())
        .environmentObject(AchievementStore(gardenStore: GardenStore(), streakStore: StreakStore()))
        .environmentObject(SettingsStore())
        .environmentObject(StreakStore())
        .environmentObject(AssessmentStore())
}
