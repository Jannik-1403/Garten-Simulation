import SwiftUI

struct TitelAuswahlSheet: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var titelStore: TitelStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appHintergrund.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(titelStore.freigeschalteteTitel()) { titel in
                            TitelZeile(titel: titel, istAktiv: titelStore.aktiverTitelID == titel.id) {
                                titelStore.setzeAktivenTitel(titel)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(settings.localizedString(for: "titel.auswahl.titel"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    LiquidGlassDismissButton { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct TitelZeile: View {
    let titel: PlayerTitle
    let istAktiv: Bool
    let onTap: () -> Void
    @State private var isVisualPressed = false

    var body: some View {
        let shadowDepth: CGFloat = 4
        
        let bgColor = istAktiv ? titel.titleColor : Color(.secondarySystemGroupedBackground)
        let shadowColor = istAktiv ? titel.titleColor.darker(by: 0.3) : Color(.systemGray4)
        let textColor = istAktiv ? Color.white : Color.primary
        
        Button {
            // Kurze Verzögerung für die Animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                onTap()
            }
        } label: {
            ZStack {
                // Untere Schicht (Schatten / Base)
                RoundedRectangle(cornerRadius: 14)
                    .fill(shadowColor)

                // Obere Schicht
                HStack(spacing: 14) {
                    if !istAktiv {
                        Circle()
                            .fill(titel.titleColor)
                            .frame(width: 10, height: 10)
                    }

                    TitelTextView(
                        titel: titel, 
                        colorOverride: istAktiv ? .white : nil
                    )

                    Spacer()

                    if istAktiv {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white)
                            .font(.title3)
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 14).fill(bgColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(istAktiv ? .white.opacity(0.3) : .clear, lineWidth: 1.5)
                )
                .offset(y: isVisualPressed ? 0 : -shadowDepth)
            }
        }
        .buttonStyle(RowPressedButtonStyle(isPressed: $isVisualPressed))
        .padding(.top, shadowDepth)
    }
}

// Hilfs-ButtonStyle um den Pressed-State nach außen zu geben (wie in Item3DButton)
struct RowPressedButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                if newValue {
                    isPressed = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
    }
}
