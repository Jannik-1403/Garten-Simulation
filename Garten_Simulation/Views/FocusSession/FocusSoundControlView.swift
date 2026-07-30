import SwiftUI

/// Eine Kontrollansicht für die Fokus-Sound-Maschine, kompakt und erweiterbar.
struct FocusSoundControlView: View {
    @ObservedObject var audioManager = FocusAudioManager.shared
    @EnvironmentObject var iapStore: IAPStore
    @State private var selectedSound: FocusSound = .none
    @State private var showPaywall: Bool = false
    
    @State private var isExpanded: Bool = false
    @State private var collapseTimer: Timer? = nil

    private var isCurrentSoundPlaying: Bool {
        audioManager.isPlaying && audioManager.currentSound == selectedSound
    }
    
    private var isLocked: Bool {
        !iapStore.isProUser && selectedSound.isPremium
    }

    var body: some View {
        ZStack {
            if isExpanded {
                expandedView
                    .transition(.scale(scale: 0.8, anchor: .trailing).combined(with: .opacity))
            } else {
                collapsedView
                    .transition(.scale(scale: 0.8, anchor: .trailing).combined(with: .opacity))
            }
        }
        .onChange(of: selectedSound) { _, newSound in
            if audioManager.isPlaying {
                if !iapStore.isProUser && newSound.isPremium {
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
        .onDisappear {
            collapseTimer?.invalidate()
        }
    }
    
    // MARK: - Collapsed View
    private var collapsedView: some View {
        Button {
            togglePlay()
        } label: {
            Image(systemName: isCurrentSoundPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue, in: Circle())
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    if isHapticEnabled() {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                    expand()
                }
        )
    }
    
    // MARK: - Expanded View
    private var expandedView: some View {
        HStack(spacing: 12) {
            Button {
                resetCollapseTimer()
                withAnimation(.spring(response: 0.3)) { selectPrevious() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isLocked ? .white.opacity(0.7) : .white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 2) {
                Text(selectedSound.displayName)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(minWidth: 80)
            
            Button {
                resetCollapseTimer()
                withAnimation(.spring(response: 0.3)) { selectNext() }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isLocked ? .white.opacity(0.7) : .white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            
            Divider()
                .background(Color.white.opacity(0.5))
                .frame(height: 24)
            
            Button {
                resetCollapseTimer()
                togglePlay()
            } label: {
                Image(systemName: isCurrentSoundPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isLocked ? .white.opacity(0.5) : .white)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isLocked ? Color.goldPrimary : Color.blue)
                .shadow(color: (isLocked ? Color.goldPrimary : Color.blue).opacity(0.4), radius: 8, x: 0, y: 4)
        )
    }

    // MARK: - Logic
    
    private func expand() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isExpanded = true
        }
        resetCollapseTimer()
    }
    
    private func resetCollapseTimer() {
        collapseTimer?.invalidate()
        collapseTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded = false
            }
        }
    }

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

    private func togglePlay() {
        if !iapStore.isProUser && selectedSound.isPremium {
            showPaywall = true
            return
        }
        if isCurrentSoundPlaying {
            audioManager.stop()
        } else {
            if selectedSound == .none {
                // If it's none, we might want to default to the first real sound
                let all = FocusSound.allCases
                if all.count > 1 {
                    selectedSound = all[1] // assuming 0 is .none
                    audioManager.play(sound: selectedSound)
                }
            } else {
                audioManager.play(sound: selectedSound)
            }
        }
    }
    
    private func isHapticEnabled() -> Bool {
        UserDefaults.standard.bool(forKey: "isHapticEnabled") // default behavior, though the environment might have a wrapper
    }
}

#Preview {
    FocusSoundControlView()
        .environmentObject(IAPStore())
        .padding()
}
