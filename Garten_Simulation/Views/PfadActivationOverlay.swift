import SwiftUI

struct PfadActivationOverlay: View {
    @ObservedObject var habit: HabitModel
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var pfadStore: GartenPfadStore
    
    @State private var ausgewaehlt: PfadSchwierigkeit = .anfaenger

    /// Liest die tatsächlich gespeicherte Schwierigkeit direkt aus dem Habit-Modell.
    private var gespeicherteSchwierigkeit: PfadSchwierigkeit {
        if let raw = habit.individualSchwierigkeit,
           let diff = PfadSchwierigkeit(rawValue: raw) {
            return diff
        }
        return ausgewaehlt
    }

    @State private var isAnimating = false
    @State private var isChangingDifficulty = false
    
    var body: some View {
        ZStack {
            Color.appHintergrund
            
            VStack(spacing: 24) {
                Spacer()
                
                // 90 Tage 3D Button + Belohnungstext
                VStack(spacing: 12) {
                    Button(action: { FeedbackManager.shared.playTap() }) {
                        Text(String(localized: "pfad_activation_90_tage"))
                            .font(.system(size: 42, weight: .black, design: .rounded))
                    }
                    .buttonStyle(Pressed3DTextButtonStyle())
                    .padding(.bottom, 12)
                }
                
                Spacer()
                
                // Reward Area
                VStack(spacing: 12) {
                    Image("coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

                    // Münzenbelohnung – 3D-Text wie Glücksrad/Spieltitel
                    // Liest immer direkt aus dem gespeicherten Modell → kein falscher Wert nach Neustart
                    let aktiveStufe = gespeicherteSchwierigkeit
                    let formatted = NumberFormatter.localizedString(from: NSNumber(value: aktiveStufe.muenzen), number: .decimal)
                    ZStack {
                        // Schattenebene
                        Text(formatted)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(aktiveStufe.farbe.opacity(0.35))
                            .offset(y: 6)
                        // Haupttextebene
                        Text(formatted)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(aktiveStufe.farbe)
                    }
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: aktiveStufe)
                        
                    Text(String(localized: "pfad_activation_belohnung"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
                
                Spacer()
                
                // Activate Button
                Item3DButton(
                    farbe: .orange,
                    sekundaerFarbe: Color(hex: "#E65100"),
                    groesse: 60,
                    isRectangular: true,
                    aktion: {
                        FeedbackManager.shared.playSuccess()
                        withAnimation(.easeInOut) {
                            habit.pfadAktiviertAm = Date()
                            
                            let ziel = settings.ausgewaehltesZiel.isEmpty ? "fitness" : settings.ausgewaehltesZiel
                            let sRaw = habit.individualSchwierigkeit ?? PfadSchwierigkeit.anfaenger.rawValue
                            let schwierigkeit = PfadSchwierigkeit(rawValue: sRaw) ?? .anfaenger
                            
                            pfadStore.pflanzeHinzufuegen(habit, ziel: ziel, schwierigkeit: schwierigkeit)
                            gardenStore.savePlants()
                        }
                    }
                ) {
                    Text(String(localized: "pfad_activation_btn"))
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
            }
        }
        .frame(minHeight: 400)
        .onAppear {
            if let existingDiff = habit.individualSchwierigkeit, let diffEnum = PfadSchwierigkeit(rawValue: existingDiff) {
                ausgewaehlt = diffEnum
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0).delay(0.1)) {
                isAnimating = true
            }
        }
    }
}
