import SwiftUI

struct MultiStrangPfadView: View {
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var settings: SettingsStore

    /// When set, the view runs in embedded mode (no NavigationStack, filtered to one habit)
    var filterHabit: HabitModel? = nil

    @State private var ausgewaehlterTag: PfadStrangTag? = nil
    @State private var selectedPage: Int = 0
    @State private var initialized = false
    @State private var showDayPicker: Bool = false

    var body: some View {
        if filterHabit != nil {
            // ── Embedded mode: no NavigationStack, just raw content ──
            embeddedContent
        } else {
            // ── Standalone mode: full NavigationStack with toolbar ──
            NavigationStack {
                embeddedContent
                    .navigationTitle(NSLocalizedString("tab_pfad", comment: ""))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showDayPicker = true
                            } label: {
                                Image(systemName: "calendar")
                                    .font(.headline)
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Shared Content

    private var embeddedContent: some View {
        ZStack {
            // Background is now provided by the canvas grid logic

            // Empty state when the habit has no strand yet
            if filterHabit != nil && !pfadStore.istPfadAktiv {
                emptyPfadState
            } else if let filter = filterHabit,
                      !pfadStore.straenge.contains(where: { $0.pflanzenID == filter.plantID }) {
                emptyPfadState
            } else {
                TabView(selection: $selectedPage) {
                    ForEach(0..<90, id: \.self) { dayIdx in
                        MultiStrangCanvas(
                            straenge: pfadStore.straenge,
                            verschmelzungen: pfadStore.verschmelzungen,
                            ausgewaehlterTag: $ausgewaehlterTag,
                            selectedDay: dayIdx + 1,
                            dynamicScale: 1.0,
                            filterHabit: filterHabit
                        )
                        .tag(dayIdx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Day indicator + calendar button for embedded mode
                if filterHabit != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Item3DButton(
                                icon: "calendar",
                                farbe: .orangePrimary,
                                sekundaerFarbe: .orangeSecondary,
                                groesse: 44,
                                iconSkalierung: 0.55
                            ) {
                                showDayPicker = true
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 12)
                        }
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            calculateInitialPage()
            initialized = true
        }
        .sheet(isPresented: $showDayPicker) {
            DayPickerView(selectedDay: $selectedPage, heute: pfadStore.tagHeute())
        }
        .sheet(item: $ausgewaehlterTag) { tag in
            PfadTagDetailView(tag: tag)
        }
    }

    // MARK: - Empty State

    private var emptyPfadState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 52))
                .foregroundStyle(Color.gruenPrimary.opacity(0.4))
            Text(NSLocalizedString("verlauf.leer.titel", comment: ""))
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text(NSLocalizedString("verlauf.leer.beschreibung", comment: ""))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Helpers

    private func calculateInitialPage() {
        let heute = pfadStore.tagHeute()
        selectedPage = max(0, heute - 1)
    }
}
