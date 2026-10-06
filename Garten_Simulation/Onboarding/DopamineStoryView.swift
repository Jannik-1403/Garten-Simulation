import SwiftUI

// MARK: - State Management
enum IntroPhase: Equatable {
    case chaos
    case transition
    case logoReveal
    case logoAnimation
    case complete
}

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

// MARK: - Main View
struct DopamineStoryView: View {
    let theme: DopamineStoryTheme
    let onFinish: () -> Void

    @State private var phase: IntroPhase = .chaos

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
            // 6. Übergang von Chaos zu Weiß
            // Der Hintergrund blendet sehr weich ins Reine Weiß über.
            Color(phase == .chaos ? UIColor(white: 0.1, alpha: 1.0) : UIColor.systemBackground)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5), value: phase)

            // 4. Animation – Phase 1: Chaos
            if phase == .chaos || phase == .transition {
                ChaosScene(isActive: phase == .chaos)
                    .transition(.opacity)
                    .zIndex(1)
            }

            // 7. & 8. GROVY erscheint & 3D Extrusion
            if phase != .chaos && phase != .transition {
                GroovyLogoScene(phase: phase)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                    .zIndex(2)
            }

            // 13. Loslegen-Button
            if phase == .complete {
                VStack {
                    Spacer()
                    ExtrudedButton3D(
                        title: String(localized: "grovy_intro_btn", defaultValue: "Loslegen →"),
                        action: {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            onFinish()
                        }
                    )
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).animation(.spring(response: 0.6, dampingFraction: 0.5)),
                        removal: .opacity
                    ))
                }
                .zIndex(3)
            }
        }
        .onAppear {
            runOrchestration()
        }
    }

    private func runOrchestration() {
        // 0.0s Chaos
        // 2.0s Transition
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation { phase = .transition }
            
            // 3.0s GROVY erscheint (starke Y-Rotation für Seitenansicht)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    phase = .logoReveal
                }
                
                // 5.0s GROVY dreht sich zur Front (leichte Rotation bleibt)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 2.0)) {
                        phase = .logoAnimation
                    }
                    
                    // 7.0s Button erscheint
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            phase = .complete
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Chaos Scene (Phase 1)
struct ChaosScene: View {
    let isActive: Bool
    
    // Generiere feste Zufallsdaten für 20 Karten
    private let cards: [(id: Int, x: CGFloat, y: CGFloat, z: CGFloat, rotX: Double, rotY: Double, rotZ: Double, scale: CGFloat, type: Int)] = (0..<20).map { i in
        (
            id: i,
            x: CGFloat.random(in: -200...200),
            y: CGFloat.random(in: -400...400),
            z: CGFloat.random(in: -500...200),
            rotX: Double.random(in: -180...180),
            rotY: Double.random(in: -180...180),
            rotZ: Double.random(in: -180...180),
            scale: CGFloat.random(in: 0.5...1.5),
            type: Int.random(in: 0...3)
        )
    }
    
    @State private var timeOffset: CGFloat = 0

    var body: some View {
        ZStack {
            ForEach(cards, id: \.id) { card in
                // Die Z-Achsen Bewegung simulieren wir durch scale und opacity
                let currentZ = card.z + timeOffset
                // Reset Logik für Endlos-Flug (wenn Karte hinter Kamera, setz sie zurück)
                let wrappedZ = currentZ.truncatingRemainder(dividingBy: 1000) - 500
                
                // Nahe der Kamera (z > 0) -> Groß, Weit weg (z < -500) -> Klein
                let normalizedScale = max(0, (wrappedZ + 500) / 500)
                
                ChaosCard3D(type: card.type)
                    .scaleEffect(card.scale * normalizedScale)
                    .offset(x: card.x * normalizedScale, y: card.y * normalizedScale)
                    .rotation3DEffect(.degrees(card.rotX + Double(timeOffset * 0.1)), axis: (x: 1, y: 0, z: 0))
                    .rotation3DEffect(.degrees(card.rotY + Double(timeOffset * 0.2)), axis: (x: 0, y: 1, z: 0))
                    .rotation3DEffect(.degrees(card.rotZ), axis: (x: 0, y: 0, z: 1))
                    .opacity(isActive ? Double(normalizedScale) : 0.0)
                    .blur(radius: normalizedScale > 0.8 ? 0 : 2) // Tiefenunschärfe
            }
        }
        .onAppear {
            // Endlose schnelle Vorwärtsbewegung
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                timeOffset = 1000
            }
        }
        // Komplexe Szene beschleunigen
        .drawingGroup()
    }
}

// Einzelne 3D Karte im Chaos
struct ChaosCard3D: View {
    let type: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(cardBackground)
                .frame(width: 80, height: 120)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Abstrakter Inhalt der Karte (Keine Emojis!)
            VStack(spacing: 8) {
                if type == 0 {
                    // Abstrakter Graph
                    Path { p in
                        p.move(to: CGPoint(x: 10, y: 40))
                        p.addLine(to: CGPoint(x: 30, y: 20))
                        p.addLine(to: CGPoint(x: 50, y: 50))
                        p.addLine(to: CGPoint(x: 70, y: 10))
                    }
                    .stroke(Color.white, lineWidth: 3)
                    .frame(height: 50)
                } else if type == 1 {
                    // Social Media Feed Mock
                    Circle().fill(Color.white.opacity(0.8)).frame(width: 30, height: 30)
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.5)).frame(width: 60, height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.3)).frame(width: 40, height: 8)
                } else if type == 2 {
                    // Progress Bar
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.2)).frame(width: 60, height: 10)
                        Capsule().fill(Color.white).frame(width: 40, height: 10)
                    }
                } else {
                    // Abstrakte Formen (Notification)
                    RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.8)).frame(width: 50, height: 30)
                    RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.4)).frame(width: 50, height: 15)
                }
            }
        }
    }
    
    var cardBackground: LinearGradient {
        switch type {
        case 0: return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 1: return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2: return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.pink, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}


// MARK: - Groovy Logo Scene
struct GroovyLogoScene: View {
    let phase: IntroPhase
    
    // Kamera/Rotations-Werte
    // logoReveal: Seitenansicht (Extrusion sehr stark sichtbar)
    // logoAnimation/complete: Fast Frontal (leichte Perspektive bleibt)
    
    var rotationY: Double {
        if phase == .logoReveal { return 45.0 }
        return 10.0 // Leichte Rest-Rotation, damit es 3D bleibt
    }
    
    var rotationX: Double {
        if phase == .logoReveal { return -15.0 }
        return -5.0
    }

    var body: some View {
        ZStack {
            ExtrudedText(
                text: "GROVY",
                depthSteps: 25,
                depthX: 1.5, // Verschiebung pro Step nach X (für die Tiefe)
                depthY: 1.5, // Verschiebung pro Step nach Y
                frontContent: FocusContent() // Bewegte Bilder in der Maske!
            )
            .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.3)
            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.3)
            // Gesamt-Schatten des Objekts auf dem weißen Boden
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 30)
        }
    }
}

// MARK: - Die bewegte Fokus-Welt (Innere Maske)
struct FocusContent: View {
    @State private var offset: CGFloat = 0
    
    var body: some View {
        // Reine, saubere abstrakte Vektorformen (Natur, Wasser, Energie) - KEINE EMOJIS!
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Zwei identische Ansichten für nahtlosen Loop
                FocusLandscape(width: geo.size.width * 2)
                FocusLandscape(width: geo.size.width * 2)
            }
            .offset(x: offset)
            .onAppear {
                withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                    offset = -(geo.size.width * 2)
                }
            }
        }
    }
}

// Eine abstrakte, fließende "Fokus"-Landschaft (reines SwiftUI)
struct FocusLandscape: View {
    let width: CGFloat
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(colors: [Color(red: 0.1, green: 0.8, blue: 0.5), Color.blauPrimary], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            // Abstraktes fließendes "Wasser" oder "Energie"
            Path { path in
                path.move(to: CGPoint(x: 0, y: 150))
                path.addCurve(to: CGPoint(x: width/2, y: 100), control1: CGPoint(x: width/4, y: 50), control2: CGPoint(x: width/4, y: 150))
                path.addCurve(to: CGPoint(x: width, y: 150), control1: CGPoint(x: width*0.75, y: 50), control2: CGPoint(x: width*0.75, y: 150))
                path.addLine(to: CGPoint(x: width, y: 300))
                path.addLine(to: CGPoint(x: 0, y: 300))
                path.closeSubpath()
            }
            .fill(Color.white.opacity(0.3))
            
            // Fliegende Partikel/Kreise (Abstrakt für Gewohnheiten/Erfolge)
            ForEach(0..<10, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: CGFloat.random(in: 10...30))
                    .position(x: CGFloat.random(in: 0...width), y: CGFloat.random(in: 20...180))
            }
        }
        .frame(width: width)
    }
}

// MARK: - ExtrudedText (Die ECHTE 3D-Körper-Komponente)
struct ExtrudedText<FrontContent: View>: View {
    let text: String
    let depthSteps: Int
    let depthX: CGFloat
    let depthY: CGFloat
    let frontContent: FrontContent
    
    private var baseFont: Font {
        .system(size: 100, weight: .black, design: .rounded)
    }
    
    var body: some View {
        ZStack {
            // 1. Die Extrusion (Seitenwände und Tiefe)
            // Wir rendern den Text mehrfach nach hinten versetzt
            // Start bei i = 1, da i = 0 die Vorderseite (Maske) ist.
            ForEach((1...depthSteps).reversed(), id: \.self) { step in
                let progress = Double(step) / Double(depthSteps)
                
                Text(text)
                    .font(baseFont)
                    // Das Material der Seitenflächen: Ein kühles, leicht glänzendes Grau/Blau
                    .foregroundColor(Color(white: 0.8 - (progress * 0.4))) // Nach hinten dunkler (Schatten)
                    .offset(x: CGFloat(step) * depthX, y: CGFloat(step) * depthY)
                    // Leichtes Highlight an den Kanten
                    .shadow(color: Color.white.opacity(0.2), radius: 1, x: -1, y: -1)
            }
            
            // 2. Die echte Rückwand (für sauberen Abschluss und Ambient Occlusion)
            Text(text)
                .font(baseFont)
                .foregroundColor(Color(white: 0.3))
                .offset(x: CGFloat(depthSteps) * depthX, y: CGFloat(depthSteps) * depthY)
                .shadow(color: .black.opacity(0.4), radius: 5, x: 5, y: 5)
            
            // 3. Die Vorderseite (Frontfläche) als Maske für den fließenden Fokus-Inhalt
            frontContent
                .mask(
                    Text(text)
                        .font(baseFont)
                )
                // Kanten-Highlight der Frontfläche (Lichtreflexion)
                .overlay(
                    Text(text)
                        .font(baseFont)
                        .foregroundColor(Color.white.opacity(0.15))
                        .offset(x: -1, y: -1)
                        .mask(Text(text).font(baseFont))
                )
        }
        // Optimiere das dicke Geometrie-Rendering!
        .drawingGroup()
    }
}

// MARK: - ExtrudedButton3D (Plastischer Custom-Button)
struct ExtrudedButton3D: View {
    let title: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    // Button Geometrie
    let buttonHeight: CGFloat = 60
    let depth: CGFloat = 8
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Der Boden / Die Seitenfläche (Schatten & Extrusion)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.blauPrimary.opacity(0.8)) // Dunklere Kante
                    .frame(height: buttonHeight)
                    .offset(y: depth) // Nach unten versetzt
                    .shadow(color: Color.blauPrimary.opacity(0.4), radius: 10, x: 0, y: 10) // Weicher Bodenschatten
                
                // 2. Die Frontfläche
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Color.blauPrimary.opacity(0.9), Color.blauPrimary], startPoint: .top, endPoint: .bottom))
                    .frame(height: buttonHeight)
                    // Wenn gedrückt, drückt sich die Frontfläche nach unten (Offset)
                    .offset(y: isPressed ? depth : 0)
                    // Subtiles Oberlicht (Highlight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .offset(y: isPressed ? depth : 0)
                    )
                
                // 3. Der Text
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: isPressed ? depth : 0)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.6)) {
                                isPressed = true
                            }
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = false
                        }
                        action()
                    }
            )
        }
        .frame(height: buttonHeight + depth)
    }
}
