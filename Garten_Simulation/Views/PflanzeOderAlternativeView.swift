import SwiftUI

struct PflanzeOderAlternativeView: View {
    let pflanzeBelohnung: GartenPassBelohnung  // der originale .pflanze(...) Case
    let onWahl: (GartenPassBelohnung) -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text(settings.localizedString(for: "pflanze_auswahl_titel"))
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text(settings.localizedString(for: "pflanze_auswahl_untertitel"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // Optionskarten
            VStack(spacing: 12) {
                // Option 1: Pflanze annehmen
                AuswahlKarte(
                    icon: AnyView(
                        Image("Plants")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    ),
                    titel: settings.localizedString(for: "pflanze_auswahl_option_pflanze"),
                    untertitel: settings.localizedString(for: "pflanze_auswahl_option_pflanze_sub")
                ) {
                    onWahl(pflanzeBelohnung)
                    dismiss()
                }

                // Option 2: 2 Spins
                AuswahlKarte(
                    icon: AnyView(
                        Image("Spin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    ),
                    titel: settings.localizedString(for: "pflanze_auswahl_option_spins"),
                    untertitel: settings.localizedString(for: "pflanze_auswahl_option_spins_sub")
                ) {
                    onWahl(GartenPassBelohnung(typ: .gluecksradDrehung(2)))
                    dismiss()
                }

                // Option 3: 150 Coins
                AuswahlKarte(
                    icon: AnyView(
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    ),
                    titel: settings.localizedString(for: "pflanze_auswahl_option_coins"),
                    untertitel: settings.localizedString(for: "pflanze_auswahl_option_coins_sub")
                ) {
                    onWahl(GartenPassBelohnung(typ: .coins(150)))
                    dismiss()
                }

                // Option 4: Zufälliges Power-Up
                AuswahlKarte(
                    icon: AnyView(
                        Image("Powerup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                    ),
                    titel: settings.localizedString(for: "pflanze_auswahl_option_powerup"),
                    untertitel: settings.localizedString(for: "pflanze_auswahl_option_powerup_sub")
                ) {
                    onWahl(GartenPassBelohnung(typ: .powerUp(id: "random")))
                    dismiss()
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

// MARK: - Optionskarte
private struct AuswahlKarte: View {
    let icon: AnyView
    let titel: String
    let untertitel: String
    let onTap: () -> Void

    var body: some View {
        Button {
            // Delay to allow the 3D "pop-back" animation to complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                onTap()
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 56, height: 56)
                    icon
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(titel)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text(untertitel)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
        }
        .buttonStyle(GartenPassSelectionCardButtonStyle())
    }
}

private struct GartenPassSelectionCardButtonStyle: ButtonStyle {
    @AppStorage("isHapticEnabled") var isHapticEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        let depth: CGFloat = 5
        let isPressed = configuration.isPressed
        
        ZStack {
            // Shadow Layer (Base)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(hex: "#E0E0E0"))
            
            // Front Face (Top)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.systemBackground))
                .overlay {
                    configuration.label
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1.2)
                )
                .offset(y: isPressed ? 0 : -depth)
        }
        .padding(.top, depth) // Compensate for the upward offset
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isPressed)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: isPressed && isHapticEnabled)
    }
}
