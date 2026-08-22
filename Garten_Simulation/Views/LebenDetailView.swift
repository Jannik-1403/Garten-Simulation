import SwiftUI

struct LebenDetailView: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Aktuelle Leben anzeigen
                    VStack(spacing: 12) {
                        ZStack {
                            Image("Heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        VStack(spacing: 4) {
                            Text(verbatim: "\(gardenStore.leben) / 5")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            Text(String(localized: "leben.verbleibend"))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))

                    Divider()

                    // Erklärung der Regeln
                    VStack(alignment: .leading, spacing: 16) {
                        RuleRow(icon: "drop.fill", color: .blue, text: String(localized: "leben.regel1"), isSystemIcon: true)
                        RuleRow(icon: "heart.slash.fill", color: .red, text: String(localized: "leben.regel2"), isSystemIcon: true)
                        RuleRow(icon: "arrow.counterclockwise", color: .green, text: String(localized: "leben.regel3"), isSystemIcon: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .item3DContainer(farbe: Color(UIColor.systemBackground), sekundaerFarbe: Color(UIColor.systemGray5))
                    
                    if gardenStore.leben < 5 {
                        Button(action: {
                            if gardenStore.coins >= 500 {
                                gardenStore.coinsAbziehen(amount: 500, beschreibung: String(localized: "buy.heart.desc", defaultValue: "Herz gekauft"))
                                withAnimation {
                                    gardenStore.leben += 1
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                Text(String(localized: "buy.heart.button", defaultValue: "Herz kaufen"))
                                Spacer()
                                HStack(spacing: 4) {
                                    Text("500")
                                    Image("Coin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(Item3DButtonStyle(
                            farbe: gardenStore.coins >= 500 ? .blauPrimary : .gray,
                            sekundaerFarbe: gardenStore.coins >= 500 ? .blauSecondary : Color(white: 0.6),
                            groesse: 56,
                            isRectangular: true
                        ))
                        .disabled(gardenStore.coins < 500)
                        .padding(.top, 16)
                    }
                }
                .padding()
            }
            .navigationTitle(String(localized: "leben.titel"))
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
            .background(Color.appHintergrund.ignoresSafeArea())
        }
    }
}

private struct RuleRow: View {
    let icon: String
    let color: Color
    let text: String
    var isSystemIcon: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if isSystemIcon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
            }
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(color.opacity(0.1))
            .clipShape(Circle())

            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    LebenDetailView()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
}
