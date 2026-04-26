import SwiftUI

struct PflanzeOderAlternativeView: View {
    let pflanzeBelohnung: GartenPassBelohnung  // der originale .pflanze(...) Case
    let onWahl: (GartenPassBelohnung) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text(NSLocalizedString("pflanze_auswahl_titel", comment: ""))
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text(NSLocalizedString("pflanze_auswahl_untertitel", comment: ""))
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
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gruenPrimary)
                    ),
                    titel: NSLocalizedString("pflanze_auswahl_option_pflanze", comment: ""),
                    untertitel: NSLocalizedString("pflanze_auswahl_option_pflanze_sub", comment: "")
                ) {
                    onWahl(pflanzeBelohnung)
                    dismiss()
                }

                // Option 2: 2 Spins
                AuswahlKarte(
                    icon: AnyView(
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                            .font(.system(size: 28))
                            .foregroundColor(.blauPrimary)
                    ),
                    titel: NSLocalizedString("pflanze_auswahl_option_spins", comment: ""),
                    untertitel: NSLocalizedString("pflanze_auswahl_option_spins_sub", comment: "")
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
                    titel: NSLocalizedString("pflanze_auswahl_option_coins", comment: ""),
                    untertitel: NSLocalizedString("pflanze_auswahl_option_coins_sub", comment: "")
                ) {
                    onWahl(GartenPassBelohnung(typ: .coins(150)))
                    dismiss()
                }

                // Option 4: Zufälliges Power-Up
                AuswahlKarte(
                    icon: AnyView(
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.goldPrimary)
                    ),
                    titel: NSLocalizedString("pflanze_auswahl_option_powerup", comment: ""),
                    untertitel: NSLocalizedString("pflanze_auswahl_option_powerup_sub", comment: "")
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
        GartenPassSelectionCardVisualView(configuration: configuration, isHapticEnabled: isHapticEnabled)
    }
}

private struct GartenPassSelectionCardVisualView: View {
    let configuration: ButtonStyle.Configuration
    let isHapticEnabled: Bool
    
    @State private var isVisualPressed = false
    private let depth: CGFloat = 5
    
    var body: some View {
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
                .offset(y: isVisualPressed ? 0 : -depth)
        }
        .padding(.top, depth) // Compensate for the upward offset
        .animation(.spring(response: 0.22, dampingFraction: 0.5), value: isVisualPressed)
        .onChange(of: configuration.isPressed) { oldValue, newValue in
            if newValue {
                isVisualPressed = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isVisualPressed = false
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: configuration.isPressed)
    }
}
