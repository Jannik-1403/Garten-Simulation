import SwiftUI
import Combine

// MARK: - DopamineStoryView (The Marvel Logo 6-Step Intro)
// Entwickelt exakt nach dem 6-Schritte-Plan.

struct DopamineStoryTheme {
    var primaryText: Color
    var secondaryText: Color
    var fontDesign: Font.Design

    static let grovy = DopamineStoryTheme(
        primaryText: .primary,
        secondaryText: .secondary,
        fontDesign: .rounded
    )
}

struct DopamineStoryView: View {
    let theme: DopamineStoryTheme
    let onFinish: () -> Void

    // Schritt 1: Architektur und Zustandsverwaltung
    @State private var animationsPhase = 0
    // 0 = Start / Flackern (Phase 1)
    // 1 = Masken-Bewegung / Logo Reveal (Phase 2)
    // 2 = Call-to-Action sichtbar (Phase 3)

    @State private var currentImageIndex = 0
    @State private var continuousOffset: CGFloat = 0.0

    // Chaos/Dopamin-Bilder (Da wir keine Assets haben, nutzen wir Emojis/Symbole, die wie Bilder wirken)
    private let chaosImages = ["📱", "🔥", "💀", "🍔", "🎮", "📉", "💥", "⏳"]
    
    // Fokus-Bilder (Gewohnheiten, Hanteln)
    private let focusImages = ["📚", "🏋️‍♀️", "✅", "🧠", "🌱", "💧", "📈", "🧘‍♂️"]

    // Der Timer für Phase 1
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(
        theme: DopamineStoryTheme = .grovy,
        showsProgress: Bool = false,
        showsFinishButton: Bool = false,
        finishTitle: String = "",
        onFinish: @escaping () -> Void = {}
    ) {
        self.theme = theme
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            // Schritt 3: Der Übergang zum hellblauen/weißen Hintergrund
            // Weicher Übergang von Chaos (Dunkelgrau/Rot) zu Fokus (Reinweiß / SystemBackground)
            Color(animationsPhase == 0 ? UIColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 1.0) : UIColor.systemBackground)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5), value: animationsPhase)

            // Schritt 2: Phase 1 – Das schnelle Flackern (Dopamin-Chaos)
            if animationsPhase == 0 {
                ZStack {
                    // Bildschirmfüllendes Bildelement
                    Color.black.ignoresSafeArea()
                    
                    Text(chaosImages[currentImageIndex % chaosImages.count])
                        .font(.system(size: 250))
                        .shadow(color: .red, radius: 40, x: 0, y: 0)
                        .scaleEffect(1.0 + CGFloat(currentImageIndex % 2) * 0.2) // Leichtes Pochen
                }
                .transition(.opacity)
                .onReceive(timer) { _ in
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.5)
                    currentImageIndex += 1
                }
            }

            // Schritt 4 & 5: Der 3D-Text ("GROVY") und die Masken-Logik
            if animationsPhase >= 1 {
                ZStack {
                    // Der Container: Lange horizontale Reihe mit Fokus-Bildern
                    HStack(spacing: 0) {
                        ForEach(0..<100, id: \.self) { i in
                            Text(focusImages[i % focusImages.count])
                                .font(.system(size: 150))
                                .frame(width: 150, height: 150)
                                .background(Color(white: 0.95)) // Leichter Kontrast im Buchstabe
                        }
                    }
                    // Schritt 5: Fließende Bewegung innerhalb der Buchstaben
                    .offset(x: continuousOffset)
                    .onAppear {
                        withAnimation(.linear(duration: 40.0).repeatForever(autoreverses: false)) {
                            continuousOffset = -3000 // Endlos gleitend von rechts nach links
                        }
                    }
                }
                // Die Maske: Der Text "GROVY"
                .mask {
                    Text("GROVY")
                        .font(.system(size: 120, weight: .heavy, design: theme.fontDesign))
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .padding(.horizontal, 10)
                }
                // Der 3D-Effekt: Schräg im Raum stehend wie das Marvel-Logo
                .rotation3DEffect(
                    .degrees(15),
                    axis: (x: 1, y: -0.5, z: 0),
                    perspective: 0.8
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 15) // Mächtiger 3D Schatten
                .transition(.scale(scale: 0.5).combined(with: .opacity))
                .offset(y: animationsPhase >= 2 ? -60 : 0) // Macht Platz für den Button
            }
            
            // Schritt 6: Der Abschluss (Call-to-Action)
            if animationsPhase >= 2 {
                VStack {
                    Spacer()
                    
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        onFinish()
                    } label: {
                        Text(String(localized: "grovy_intro_btn", defaultValue: "Loslegen"))
                            .font(.system(size: 20, weight: .heavy, design: theme.fontDesign))
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: Color.blauPrimary,
                        shadowColor: Color.blauPrimary.darker(),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            runOrchestration()
        }
    }

    private func runOrchestration() {
        // Nach einer festgelegten Zeit (z.B. 2 Sekunden) wechselst du die Animationsphase.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            timer.upstream.connect().cancel() // Das Flackern stoppt abrupt
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animationsPhase = 1
            }
            
            // Mit einer leichten Verzögerung (z.B. nach weiteren 2 Sekunden) den Button einblenden
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animationsPhase = 2
                }
            }
        }
    }
}
