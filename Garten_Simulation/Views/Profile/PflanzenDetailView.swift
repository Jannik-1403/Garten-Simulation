import SwiftUI

struct PflanzenDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    var pflanzen: [HabitModel] { gardenStore.pflanzen }

    var gesamtXP: Int { gardenStore.gesamtXP }

    @State private var ausgewaehltePflanze: HabitModel? = nil
    @EnvironmentObject var powerUpStore: PowerUpStore
    @EnvironmentObject var shopStore: ShopStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    @EnvironmentObject var interactiveTourManager: InteractiveTourManager

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if pflanzen.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary.opacity(0.3))
                            
                            VStack(spacing: 8) {
                                Text(settings.localizedString(for: "garden.empty.title"))
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text(settings.localizedString(for: "garden.empty.subtitle"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 20)
                    } else {
                        // MARK: Pflanzen-Grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 12
                        ) {
                            ForEach(pflanzen) { pflanze in
                                PflanzenGridCell(pflanze: pflanze) {
                                    ausgewaehltePflanze = pflanze
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                    }

                    Spacer(minLength: 40)
                }
            }
            .navigationTitle(settings.localizedString(for: "profile.plants"))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            .fullScreenCover(item: $ausgewaehltePflanze) { pflanze in
                ZStack {
                    NavigationStack {
                        PflanzeDetailSheet(
                            pflanze: pflanze,
                            wetterEvent: .normal, // Default for inventory view
                            onLoeschen: {
                                gardenStore.pflanzEntfernen(pflanze: pflanze)
                                ausgewaehltePflanze = nil
                            }
                        )
                    }
                    
                    if interactiveTourManager.isActive {
                        InteractiveTourOverlay()
                            .zIndex(99998)
                    }
                }
                .environmentObject(gardenStore)
                .environmentObject(shopStore)
                .environmentObject(settings)
                .environmentObject(powerUpStore)
                .environmentObject(pfadStore)
                .environmentObject(interactiveTourManager)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .kerning(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }

    private func detailRow(labelKey: String, value: String, icon: String, color: Color, isAsset: Bool = false) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                if isAsset {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(color)
                }
            }

            Text(settings.localizedString(for: labelKey))
                .font(.system(size: 16))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct PflanzenGridCell: View {
    let pflanze: HabitModel
    var action: (() -> Void)? = nil
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 8) {
            Item3DButton(
                icon: pflanze.plantImageName,
                farbe: pflanze.color,
                sekundaerFarbe: pflanze.color.darker(),
                groesse: 80,
                iconSkalierung: 1.5,
                aktion: action
            )

            Text(settings.showHabitInsteadOfName 
                ? settings.localizedString(for: pflanze.habitName)
                : settings.localizedString(for: pflanze.name))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(pflanze.seltenheit.lokalisiertTitel)
                .font(.system(size: 10, weight: .bold))
            .foregroundStyle(pflanze.seltenheit.farbe)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(pflanze.seltenheit.farbe.opacity(0.1))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
