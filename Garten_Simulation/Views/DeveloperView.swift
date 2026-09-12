import SwiftUI
import StoreKit
import TelemetryDeck

struct DeveloperView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var tourManager: InteractiveTourManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    
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
                            
                            Divider().padding(.leading, 44)
                            
                            Button {
                                requestReview()
                            } label: {
                                settingRow(
                                    title: "Review-Popup Test (Direkter Aufruf)",
                                    icon: "star.fill",
                                    color: .orange
                                )
                            }
                            
#if DEBUG
                            Divider().padding(.leading, 44)
                            
                            Button {
                                triggerAllTelemetryTestSignals()
                                simulateVariedHabitCompletions()
                                FeedbackManager.shared.playSuccess()
                            } label: {
                                settingRow(
                                    title: "🧪 TelemetryDeck Test-Daten senden",
                                    icon: "antenna.radiowaves.left.and.right",
                                    color: .purple
                                )
                            }
#endif
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
    
#if DEBUG
    private func triggerAllTelemetryTestSignals() {
        Task {
            print("[Test-Telemetry] Sende app_opened...")
            TelemetryDeck.signal("app_opened")
            
            print("[Test-Telemetry] Sende shop_item_purchased (Test_Pflanze_Kaktus)...")
            let paramsKaktus: [String: String] = ["item_name": "Test_Pflanze_Kaktus"]
            TelemetryDeck.signal("shop_item_purchased", parameters: paramsKaktus)
            
            print("[Test-Telemetry] Sende shop_item_purchased (Test_Pflanze_Monstera)...")
            let paramsMonstera: [String: String] = ["item_name": "Test_Pflanze_Monstera"]
            TelemetryDeck.signal("shop_item_purchased", parameters: paramsMonstera)
            
            print("[Test-Telemetry] Sende shop_item_purchased (Test_Gewohnheit_Sport)...")
            let paramsSport: [String: String] = ["item_name": "Test_Gewohnheit_Sport"]
            TelemetryDeck.signal("shop_item_purchased", parameters: paramsSport)
            
            print("[Test-Telemetry] Sende health_integration_toggled (true)...")
            let paramsHealthTrue: [String: String] = ["enabled": "true"]
            TelemetryDeck.signal("health_integration_toggled", parameters: paramsHealthTrue)
            
            print("[Test-Telemetry] Sende health_integration_toggled (false)...")
            let paramsHealthFalse: [String: String] = ["enabled": "false"]
            TelemetryDeck.signal("health_integration_toggled", parameters: paramsHealthFalse)
            
            print("[Test-Telemetry] Sende routine_used...")
            TelemetryDeck.signal("routine_used")
            
            print("[Test-Telemetry] Sende todo_used...")
            TelemetryDeck.signal("todo_used")
            
            print("[Test-Telemetry] Sende focus_timer_started...")
            TelemetryDeck.signal("focus_timer_started")
            
            print("[Test-Telemetry] Sende quiz_answered...")
            TelemetryDeck.signal("quiz_answered")
            
            // NEUE SIGNALE HINZUGEFÜGT:
            print("[Test-Telemetry] Sende habit_completed (Krafttraining)...")
            let paramsHabit1: [String: String] = ["habit_name": "Krafttraining", "category": "good", "is_custom": "false"]
            TelemetryDeck.signal("habit_completed", parameters: paramsHabit1)
            
            print("[Test-Telemetry] Sende habit_completed (Fastfood)...")
            let paramsHabit2: [String: String] = ["habit_name": "Fastfood", "category": "bad", "is_custom": "false"]
            TelemetryDeck.signal("habit_completed", parameters: paramsHabit2)
            
            print("[Test-Telemetry] Sende custom_habit_created (Meine eigene Gewohnheit)...")
            let paramsCustomHabit: [String: String] = ["habit_name": "Meine eigene Gewohnheit"]
            TelemetryDeck.signal("custom_habit_created", parameters: paramsCustomHabit)
            
            print("[Test-Telemetry] Sende streak_milestone_reached (10 Tage)...")
            let paramsStreak: [String: String] = ["streak_days": "10", "habit_name": "Krafttraining"]
            TelemetryDeck.signal("streak_milestone_reached", parameters: paramsStreak)
            
            print("[Test-Telemetry] Sende daily_spin_completed...")
            TelemetryDeck.signal("daily_spin_completed")
            
            print("[Test-Telemetry] Alle Signale erfolgreich gesendet!")
        }
    }
    
    private func simulateVariedHabitCompletions() {
        Task {
            let habitCounts = [
                ("Wasser trinken", 5, "good"),
                ("Spanisch lernen", 4, "good"),
                ("Krafttraining", 3, "good"),
                ("Lesen", 2, "good"),
                ("Fastfood vermeiden", 2, "good"),
                ("Meditation", 1, "good")
            ]
            
            for (habitName, count, category) in habitCounts {
                for _ in 0..<count {
                    print("[Telemetry Test] Gewohnheit gesendet: \(habitName)")
                    let params: [String: String] = [
                        "habit_name": habitName,
                        "category": category,
                        "is_custom": "false"
                    ]
                    TelemetryDeck.signal("habit_completed", parameters: params)
                }
            }
        }
    }
#endif
}
