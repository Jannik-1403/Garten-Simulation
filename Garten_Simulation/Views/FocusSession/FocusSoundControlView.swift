import SwiftUI

/// Eine Kontrollansicht für die Fokus-Sound-Maschine, die das Wischen zwischen Sounds
/// und das Starten/Stoppen ermöglicht.
struct FocusSoundControlView: View {
    @ObservedObject var audioManager = FocusAudioManager.shared
    @EnvironmentObject var iapStore: IAPStore
    @State private var selectedSound: FocusSound = .none
    @State private var showPaywall: Bool = false
    
    private var isCurrentSoundPlaying: Bool {
        audioManager.isPlaying && audioManager.currentSound == selectedSound
    }
    
    var body: some View {
        let isLocked = !iapStore.isProUser
        
        VStack(spacing: 16) {
            // Header: Sound-Auswahl (Pfeil Links - Name - Pfeil Rechts) ohne Icons
            HStack {
                Button {
                    withAnimation {
                        selectPrevious()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isLocked ? .white.opacity(0.8) : .secondary)
                        .padding(8)
                }
                
                Spacer()
                
                Text(selectedSound.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isLocked ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 160)
                
                Spacer()
                
                Button {
                    withAnimation {
                        selectNext()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isLocked ? .white.opacity(0.8) : .secondary)
                        .padding(8)
                }
            }
            
            // Abspiel- & Schloss-Button als großes Item3DButton
            if isLocked {
                // Goldener 3D-Button mit Schloss für gesperrte Premium-Sounds
                Item3DButton(
                    farbe: .goldPrimary,
                    sekundaerFarbe: .goldPrimary.darker(),
                    groesse: 80,
                    isRectangular: false,
                    aktion: {
                        showPaywall = true
                    }
                ) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                // Großer weiß/grauer 3D-Button für freigegebene Sounds
                Item3DButton(
                    farbe: Color(white: 0.96),
                    sekundaerFarbe: Color(white: 0.82),
                    groesse: 80,
                    isRectangular: false,
                    aktion: {
                        togglePlay()
                    }
                ) {
                    Image(systemName: isCurrentSoundPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                // 3D-Schatten/Boden-Layer für die Karte (weiter nach unten)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isLocked ? .goldPrimary.darker() : Color(UIColor.secondarySystemBackground).darker(by: 0.12))
                    .offset(y: 8)
                
                // Haupt-Layer der Karte (Gold wenn gesperrt)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isLocked ? .goldPrimary : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }
        )
        .padding(.bottom, 8) // Ausgleich für den 3D-Schatten-Offset
        // Bei Soundwechsel automatisch den Ton anpassen, falls bereits abgespielt wird
        .onChange(of: selectedSound) { _, newSound in
            if audioManager.isPlaying {
                if !iapStore.isProUser {
                    audioManager.stop()
                } else {
                    audioManager.play(sound: newSound)
                }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(iapStore)
        }
    }
    
    private func selectPrevious() {
        let all = FocusSound.allCases
        if let currentIndex = all.firstIndex(of: selectedSound) {
            let prevIndex = (currentIndex - 1 + all.count) % all.count
            selectedSound = all[prevIndex]
        }
    }
    
    private func selectNext() {
        let all = FocusSound.allCases
        if let currentIndex = all.firstIndex(of: selectedSound) {
            let nextIndex = (currentIndex + 1) % all.count
            selectedSound = all[nextIndex]
        }
    }
    
    private func togglePlay() {
        if !iapStore.isProUser {
            showPaywall = true
            return
        }
        
        if isCurrentSoundPlaying {
            audioManager.stop()
        } else {
            audioManager.play(sound: selectedSound)
        }
    }
}

#Preview {
    FocusSoundControlView()
        .environmentObject(IAPStore())
        .padding()
}
