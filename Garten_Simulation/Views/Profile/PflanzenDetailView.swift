import SwiftUI

struct PflanzenDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore

    var pflanzen: [HabitModel] { gardenStore.pflanzen }

    var gesamtXP: Int { gardenStore.gesamtXP }

    var seltenste: HabitModel? {
        pflanzen.max(by: { $0.currentXP < $1.currentXP })
    }

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Hero-Karte — Zusammenfassung
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.green)
                        }

                        Text("\(pflanzen.count)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))

                        Text("profile.plants.subtitle", bundle: .main)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    // MARK: Stats-Reihe
                    sectionHeader(NSLocalizedString("common.details", comment: ""))

                    VStack(spacing: 0) {
                        detailRow(
                            labelKey: "common.total",
                            value: "\(pflanzen.count)",
                            icon: "leaf.fill",
                            color: .green
                        )
                        Divider().padding(.leading, 52)

                        detailRow(
                            labelKey: "profile.xp.earned",
                            value: "\(gesamtXP) XP",
                            icon: "star.fill",
                            color: .orange
                        )
                        Divider().padding(.leading, 52)

                        detailRow(
                            labelKey: "common.active",
                            value: "\(pflanzen.filter { $0.istBewässert }.count)",
                            icon: "drop.fill",
                            color: .blauPrimary
                        )
                        Divider().padding(.leading, 52)

                        if let beste = seltenste {
                            detailRow(
                                labelKey: "profile.xp.max",
                                value: beste.name,
                                icon: "crown.fill",
                                color: .goldPrimary
                            )
                        }
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 1)
                    .padding(.horizontal, 20)

                    // MARK: Pflanzen-Grid
                    sectionHeader(NSLocalizedString("profile.plants.list", comment: ""))

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        ForEach(pflanzen) { pflanze in
                            PflanzenGridCell(pflanze: pflanze)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(Text("profile.plants", bundle: .main))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .kerning(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }

    private func detailRow(labelKey: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(color)
            }

            Text(LocalizedStringKey(labelKey))
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

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 72, height: 72)

                Circle()
                    .fill(Color.green)
                    .frame(width: 68, height: 68)

                Image(pflanze.bildName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            Text(pflanze.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)

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
