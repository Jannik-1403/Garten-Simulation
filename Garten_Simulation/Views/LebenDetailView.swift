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
                            Circle()
                                .fill(Color.red.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image("Heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(gardenStore.leben) / 5")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            Text(settings.localizedString(for: "leben.verbleibend"))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 24)

                    Divider()

                    // Erklärung der Regeln
                    VStack(alignment: .leading, spacing: 16) {
                        RuleRow(icon: "drop.fill", color: .blue, text: settings.localizedString(for: "leben.regel1"), isSystemIcon: true)
                        RuleRow(icon: "heart.slash.fill", color: .red, text: settings.localizedString(for: "leben.regel2"), isSystemIcon: true)
                        RuleRow(icon: "arrow.counterclockwise", color: .green, text: settings.localizedString(for: "leben.regel3"), isSystemIcon: true)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.primary.opacity(0.05), lineWidth: 1)
                    )

                    // Welche Pflanzen haben Leben gekostet (Log)
                    if !gardenStore.gestorbenePflanzenLog.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(settings.localizedString(for: "leben.verloren.durch"))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.horizontal, 4)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(gardenStore.gestorbenePflanzenLog.reversed().enumerated()), id: \.offset) { _, name in
                                    HStack(spacing: 12) {
                                        Image("Heart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text(name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("-1")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.red)
                                    }
                                    .padding()
                                    .background(Color.red.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
                .padding()
            }
            .navigationTitle(settings.localizedString(for: "leben.titel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton {
                        dismiss()
                    }
                }
            }
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
