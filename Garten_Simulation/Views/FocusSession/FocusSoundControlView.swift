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
        VStack(spacing: 12) {
            HStack {
                // Zurück-Button
                Button {
                    withAnimation {
                        selectPrevious()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                
                // Swipebare Sound-Auswahl
                TabView(selection: $selectedSound) {
                    ForEach(FocusSound.allCases) { sound in
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: sound.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(sound == selectedSound ? .goldPrimary : .primary)
                                
                                Text(sound.displayName)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                if sound.isPremium {
                                    Image(systemName: iapStore.isProUser ? "checkmark.seal.fill" : "lock.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(.goldPrimary)
                                }
                            }
                            
                            if sound.isPremium && !iapStore.isProUser {
                                Text(String(localized: "focus.sound.pro_required", defaultValue: "PRO Feature"))
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundColor(.goldPrimary)
                            } else {
                                Text(sound == audioManager.currentSound && audioManager.isPlaying
                                     ? String(localized: "focus.sound.playing", defaultValue: "Wird abgespielt...")
                                     : String(localized: "focus.sound.ready", defaultValue: "Bereit zum Abspielen"))
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tag(sound)
                    }
                }
                .frame(height: 54)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Vorwärts-Button
                Button {
                    withAnimation {
                        selectNext()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            // Abspiel- & Stopp-Button
            Button {
                togglePlay()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isCurrentSoundPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                    
                    Text(isCurrentSoundPlaying
                         ? String(localized: "focus.sound.button.stop", defaultValue: "Stoppen")
                         : String(localized: "focus.sound.button.start", defaultValue: "Starten"))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(isCurrentSoundPlaying ? Color.red : Color.goldPrimary)
                .cornerRadius(20)
                .shadow(color: (isCurrentSoundPlaying ? Color.red : Color.goldPrimary).opacity(0.3), radius: 5, y: 3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemBackground).opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        // Bei Wischen des Sounds automatisch den Ton anpassen, falls bereits abgespielt wird
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
