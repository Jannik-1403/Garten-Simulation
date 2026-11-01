import SwiftUI
import StoreKit

// Modern Overview: 5-Year Goal at the top, full-width 3D cards for Statistics and Focus below.
// Character and weekly goal removed (weekly goal lives on To-Dos tab).
struct ProfilView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var streakStore: StreakStore
    @EnvironmentObject var characterStore: CharacterStore
    @EnvironmentObject var iap: IAPStore
    @State private var showSettings = false
    @State private var showStreak = false
    @State private var showFocus = false
    @State private var showStatistics = false
    @State private var focusHabit: HabitModel?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.appHintergrund.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 1. 5-Jahres-Ziel ganz oben
                        YearGoalBannerView()
                            .padding(.top, 16)

                        // 2. Statistik (kompakte Kartengröße, Icon füllt den 3D-Button schön aus)
                        DuolingoCard(action: { showStatistics = true }) {
                            HStack(spacing: 16) {
                                Item3DButton(
                                    farbe: .blauPrimary,
                                    sekundaerFarbe: Color.blauPrimary.darker(),
                                    groesse: 64,
                                    iconSkalierung: 1.15,
                                    aktion: nil
                                ) {
                                    Image("ProIconAnalytics")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(1.35)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(String(localized: "Statistik", defaultValue: "Statistik"))
                                        .font(.system(size: 19, weight: .black, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "statistics.subtitle", defaultValue: "Fortschritt & Verläufe ansehen"))
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 4)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        .accessibilityIdentifier("button_statistics")

                        // 3. Fokus-Timer (normale Standard-Icongröße)
                        DuolingoCard(action: { showFocus = true }) {
                            HStack(spacing: 16) {
                                Item3DButton(
                                    farbe: Color.lilaPrimary,
                                    sekundaerFarbe: Color.lilaPrimary.darker(),
                                    groesse: 64,
                                    aktion: nil
                                ) {
                                    Image("Timer full")
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(String(localized: "profile.focus.title", defaultValue: "Fokus-Timer"))
                                        .font(.system(size: 19, weight: .black, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Text(String(localized: "profile.focus.start", defaultValue: "Fokussitzung jetzt starten"))
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 4)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 24)
                        .accessibilityIdentifier("button_focus")

                        Color.clear.frame(height: 100)
                    }
                    .frame(maxWidth: 750)
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.appHintergrund, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(.primary)
                    }
                    .accessibilityIdentifier("button_settings")
                }
            }
            .navigationDestination(isPresented: $showSettings) { SettingsView() }
            .navigationDestination(isPresented: $showStreak) { StreakView() }
            .fullScreenCover(isPresented: $showStatistics) { NavigationStack { StatisticsDashboard() } }
            .fullScreenCover(isPresented: $showFocus) { GenericFocusTimerSetupSheet { focusHabit = $0 } }
            .fullScreenCover(item: $focusHabit) { habit in GenericFocusSessionContainer(habit: habit) }
            .onChange(of: gardenStore.triggerStreakDetail) { _, value in
                if value { showStreak = true; gardenStore.triggerStreakDetail = false }
            }
        }
    }
}
