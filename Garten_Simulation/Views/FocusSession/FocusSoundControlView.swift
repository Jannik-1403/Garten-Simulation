import SwiftUI

/// Eine Kontrollansicht für die Fokus-Sound-Maschine.
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

        ZStack {
            // ── Hintergrund 3D-Karte ──────────────────────────────────────
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isLocked
                          ? Color.goldPrimary.darker()
                          : Color(UIColor.secondarySystemBackground).darker(by: 0.12))
                    .offset(y: 8)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isLocked
                          ? Color.goldPrimary
                          : Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.black.opacity(0.10), lineWidth: 1)
                    )
            }

            // ── Inhalt ────────────────────────────────────────────────────
            VStack(spacing: 16) {

                // Sound-Auswahl Header
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectPrevious() }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isLocked ? .white.opacity(0.85) : .secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(selectedSound.displayName)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(isLocked ? .white : .primary)
                        .multilineTextAlignment(.center)
                        .frame(minWidth: 130)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        withAnimation(.spring(response: 0.3)) { selectNext() }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(isLocked ? .white.opacity(0.85) : .secondary)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }

                // Play / Lock Button
                if isLocked {
                    Item3DButton(
                        farbe: .goldPrimary,
                        sekundaerFarbe: .goldPrimary.darker(),
                        groesse: 76,
                        shadowDepthFactor: 0.10,
                        isRectangular: false,
                        aktion: { showPaywall = true }
                    ) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Item3DButton(
                        farbe: Color(white: 0.96),
                        sekundaerFarbe: Color(white: 0.80),
                        groesse: 76,
                        shadowDepthFactor: 0.10,
                        isRectangular: false,
                        aktion: { togglePlay() }
                    ) {
                        Image(systemName: isCurrentSoundPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
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

    // MARK: - Navigation

    private func selectPrevious() {
        let all = FocusSound.allCases
        guard let idx = all.firstIndex(of: selectedSound) else { return }
        selectedSound = all[(idx - 1 + all.count) % all.count]
    }

    private func selectNext() {
        let all = FocusSound.allCases
        guard let idx = all.firstIndex(of: selectedSound) else { return }
        selectedSound = all[(idx + 1) % all.count]
    }

    // MARK: - Playback

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
