import SwiftUI

struct DeveloperView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var tourManager: InteractiveTourManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Section 1: Onboarding & App-Tour
                    settingsSection(title: "Onboarding & App-Tour") {
                        VStack(spacing: 0) {
                            Button {
                                settings.onboardingAbgeschlossen = false
                                FeedbackManager.shared.playSuccess()
                                dismiss()
                            } label: {
                                settingRow(
                                    title: String(localized: "settings.onboarding.repeat", defaultValue: "Onboarding wiederholen"),
                                    icon: "arrow.counterclockwise.circle.fill",
                                    color: .orange
                                )
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                gardenStore.selectedTab = 0
                                FeedbackManager.shared.playSuccess()
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    tourManager.startTour()
                                }
                            } label: {
                                settingRow(
                                    title: "App-Tour wiederholen",
                                    icon: "sparkles",
                                    color: .blue
                                )
                            }
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                if let bundleID = Bundle.main.bundleIdentifier {
                                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                                }
                                SharedUserDefaults.suite.removePersistentDomain(forName: SharedUserDefaults.suiteName)
                                
                                FeedbackManager.shared.playError()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    exit(0)
                                }
                            } label: {
                                settingRow(
                                    title: "App-Daten komplett löschen",
                                    icon: "trash.fill",
                                    color: .red
                                )
                            }
                        }
                    }
                    
                    // Section 2: Cheats
                    settingsSection(title: String(localized: "developer.cheats.title", defaultValue: "Cheats")) {
                        VStack(spacing: 0) {
                            Button {
                                gardenStore.coins += 100_000
                                gardenStore.saveStats()
                                FeedbackManager.shared.playSuccess()
                                dismiss()
                            } label: {
                                settingRow(
                                    title: String(localized: "developer.cheats.addCoins", defaultValue: "+ 100.000 Münzen"),
                                    icon: "dollarsign.circle.fill",
                                    color: .yellow
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(String(localized: "developer.options.title", defaultValue: "Developer Options"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                LiquidGlassDismissButton { dismiss() }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
            
            content()
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                )
        }
    }
    
    private func settingRow(title: String, icon: String, color: Color, isAsset: Bool = false) -> some View {
        HStack(spacing: 12) {
            Group {
                if isAsset {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                } else {
                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                }
            }
            .frame(width: 28, height: 28)
            .background(Circle().fill(color))
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
