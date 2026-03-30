import SwiftUI

// Model is now in Models/CoinTransaction.swift

// MARK: - CoinsDetailView
struct CoinsDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore

    // Berechnungen aus echtem Store
    var verdient: Int { gardenStore.gesamtVerdient }
    var ausgegeben: Int { gardenStore.gesamtAusgegeben }

    // Wie-verdienen Tipps
    let verdienstTipps: [(icon: String, farbe: Color, titel: String, betrag: String)] = [
        ("checkmark.circle.fill", .green,      "profile.coins.tip.habit",  "+10 Coins"),
        ("flame.fill",            .orange,     "profile.coins.tip.streak", "+50 Coins"),
        ("star.fill",             .goldPrimary,"profile.coins.tip.levelup", "+100 Coins"),
        ("drop.fill",             .blauPrimary,"profile.coins.tip.watering", "+5 Coins"),
    ]

    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: Hero-Karte
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.goldPrimary.opacity(0.15))
                                .frame(width: 90, height: 90)
                            Image("Coin")
                                .resizable().scaledToFit()
                                .frame(width: 52, height: 52)
                        }

                        Text("\(gardenStore.coins)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.4), value: gardenStore.coins)

                        Text(settings.localizedString(for: "profile.coins.available"))
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.06), radius: 0, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)

                    // MARK: Details
                    sectionHeader(settings.localizedString(for: "common.details"))

                    VStack(spacing: 0) {
                        detailRow(
                            labelKey: "profile.coins.total",
                            value: "\(gardenStore.coins)",
                            icon: "Coin",
                            color: .goldPrimary,
                            isAsset: true
                        )
                        Divider().padding(.leading, 52)

                        detailRow(
                            labelKey: "profile.coins.earned",
                            value: "+\(verdient)",
                            icon: "arrow.up.circle.fill",
                            color: .green,
                            isAsset: false
                        )
                        Divider().padding(.leading, 52)

                        detailRow(
                            labelKey: "profile.coins.spent",
                            value: "-\(ausgegeben)",
                            icon: "cart.fill",
                            color: .red,
                            isAsset: false
                        )
                        Divider().padding(.leading, 52)

                        detailRow(
                            labelKey: "shop.purchases.count",
                            value: "\(gardenStore.gesamtAusgegeben > 0 ? gardenStore.transactions.filter { $0.betrag < 0 }.count : 0)",
                            icon: "bag.fill",
                            color: .blauPrimary,
                            isAsset: false
                        )
                    }
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 1)
                    .padding(.horizontal, 20)

                    // MARK: Wie verdiene ich Coins?
                    sectionHeader(settings.localizedString(for: "profile.coins.how_to_earn"))

                    VStack(spacing: 0) {
                        ForEach(Array(verdienstTipps.enumerated()), id: \.offset) { index, tipp in
                            detailRow(
                                labelKey: tipp.titel,
                                value: tipp.betrag,
                                icon: tipp.icon,
                                color: tipp.farbe,
                                isAsset: false
                            )
                            if index < verdienstTipps.count - 1 {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 1)
                    .padding(.horizontal, 20)

                    // MARK: Transaktions-Verlauf
                    sectionHeader(settings.localizedString(for: "common.history"))

                    VStack(spacing: 0) {
                        if gardenStore.transactions.isEmpty {
                            Text(settings.localizedString(for: "profile.transactions.empty"))
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                                .padding(.vertical, 30)
                                .frame(maxWidth: .infinity)
                        } else {
                            ForEach(Array(gardenStore.transactions.enumerated()), id: \.element.id) { index, transaktion in
                                TransaktionRow(transaktion: transaktion)
                                if index < gardenStore.transactions.count - 1 {
                                    Divider().padding(.leading, 52)
                                }
                            }
                        }
                    }
                    .background(Color(UIColor.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .black.opacity(0.05), radius: 0, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 1)
                    .padding(.horizontal, 20)

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(settings.localizedString(for: "profile.coins"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .kerning(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }

    private func detailRow(labelKey: String, value: String, icon: String, color: Color, isAsset: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                if isAsset {
                    Image(icon)
                        .resizable().scaledToFit()
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

// MARK: - Transaktions-Row
struct TransaktionRow: View {
    let transaktion: CoinTransaction

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(transaktion.farbe.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: transaktion.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(transaktion.farbe)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaktion.beschreibung)
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                Text(transaktion.datum, style: .relative)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(transaktion.betrag > 0 ? "+\(transaktion.betrag)" : "\(transaktion.betrag)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(transaktion.betrag > 0 ? .green : .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
