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
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                
                Spacer()
                
                Text(selectedSound.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
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
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            // Abspiel- & Schloss-Button als großes Item3DButton
            let isLocked = selectedSound.isPremium && !iapStore.isProUser
            
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
        .background(Color(UIColor.secondarySystemBackground).opacity(0.4)) // schlichter, dezenter Hintergrund
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
        // Bei Soundwechsel automatisch den Ton anpassen, falls bereits abgespielt wird
        .onChange(of: selectedSound) { _, newSound in
            if audioManager.isPlaying {
                if newSound.isPremium && !iapStore.isProUser {
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
        if selectedSound.isPremium && !iapStore.isProUser {
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
