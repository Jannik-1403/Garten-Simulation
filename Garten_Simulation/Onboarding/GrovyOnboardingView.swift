import SwiftUI

struct GrovyOnboardingView: View {
    @EnvironmentObject var data: OnboardingData
    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 40) {
                // Header (Oben)
                GrovyOnboardingHeaderView(progress: progress)
                
                Spacer()
                
                // Visual Area (Mitte)
                GrovyOnboardingVisualAreaView(progress: progress)
                
                Spacer()
                
                // Interaktions-Bereich (Unten)
                if !isCompleted {
                    GrovyOnboardingSliderView(progress: $progress, isCompleted: $isCompleted)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        withAnimation(.easeInOut(duration: 0.35)) {
                            data.currentStep += 1
                        }
                    } label: {
                        Text(String(localized: "grovy_onboarding_button_start", defaultValue: "Loslegen"))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(
                        size: .large,
                        backgroundColor: Color.gruenPrimary,
                        shadowColor: Color.gruenPrimary.darker(),
                        foregroundColor: .white
                    ))
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 40)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isCompleted)
    }
}

// MARK: - Subviews

struct GrovyOnboardingHeaderView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            // Titel ändert sich basierend auf dem Fortschritt
            let isProblem = progress < 0.5
            Text(isProblem ? String(localized: "grovy_onboarding_title_problem", defaultValue: "Dopamin-Chaos") : String(localized: "grovy_onboarding_title_solution", defaultValue: "Fokus & Energie"))
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(isProblem ? .red : .green)
                .contentTransition(.numericText()) // Smooth transition
                .animation(.easeInOut, value: isProblem)
            
            Text(String(localized: "grovy_onboarding_subtitle", defaultValue: "Finde deine Balance"))
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
    }
}

struct GrovyOnboardingVisualAreaView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            // State A (Progress 0.0) - "Das Problem"
            ZStack {
                // Erschöpftes 3D-Gehirn
                // Asset-Katalog: "brain_exhausted"
                Image(systemName: "brain.head.profile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.red.opacity(0.8))
                
                // Rote Social-Media-Icons, Flammen, Notification-Badges (Platzhalter)
                // Asset-Katalog: z.B. "icon_flame", "icon_notification"
                ForEach(0..<5) { i in
                    Image(systemName: "flame.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                        .offset(x: cos(Double(i) * .pi * 2 / 5) * 100, y: sin(Double(i) * .pi * 2 / 5) * 100)
                }
            }
            // Bewegung nach außen, Schrumpfen und Verblassen bei steigendem Progress
            // progress = 0 -> scale 1.0, opacity 1.0
            // progress = 1 -> scale 0.0, opacity 0.0
            .scaleEffect(1.0 - progress)
            .opacity(1.0 - (progress * 2)) // Verblasst schneller
            
            // State B (Progress 1.0) - "Die Lösung"
            ZStack {
                // Starkes, lächelndes 3D-Gehirn
                // Asset-Katalog: "brain_strong"
                Image(systemName: "brain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .foregroundColor(.green)
                
                // Grüne Hanteln, Bücher, Häkchen (Platzhalter)
                // Asset-Katalog: z.B. "icon_dumbell", "icon_book"
                ForEach(0..<4) { i in
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 35))
                        .offset(x: cos(Double(i) * .pi * 2 / 4) * 110, y: sin(Double(i) * .pi * 2 / 4) * 110)
                }
            }
            // Ploppt auf und wird sichtbar bei steigendem Progress
            // progress = 0 -> scale 0.5, opacity 0.0
            // progress = 1 -> scale 1.0, opacity 1.0
            .scaleEffect(0.5 + (progress * 0.5))
            .opacity(progress)
        }
        .frame(height: 300)
    }
}

struct GrovyOnboardingSliderView: View {
    @Binding var progress: Double
    @Binding var isCompleted: Bool
    
    // Wir speichern den Start-Offset, um relativ wischen zu können
    @State private var dragOffset: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width
            let thumbWidth: CGFloat = 60
            let maxDrag = sliderWidth - thumbWidth
            
            ZStack(alignment: .leading) {
                // Hintergrund-Track (Grau, eingedrückt)
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: thumbWidth)
                    .overlay(
                        Text(String(localized: "grovy_onboarding_slider_hint", defaultValue: "Wischen zum Ändern"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.gray.opacity(0.8))
                    )
                
                // Progress-Füllung (Grün)
                Capsule()
                    .fill(Color.gruenPrimary.opacity(0.5))
                    .frame(width: thumbWidth + CGFloat(progress) * maxDrag, height: thumbWidth)
                
                // Der Thumb (Ziehelement) - 3D Look
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 3)
                    .frame(width: thumbWidth - 10, height: thumbWidth - 10)
                    .overlay(
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.gray)
                    )
                    .padding(5)
                    .offset(x: CGFloat(progress) * maxDrag)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Wir berechnen den neuen Progress-Wert basierend auf der Translation
                                let newProgress = min(max(value.translation.width / maxDrag, 0), 1)
                                progress = Double(newProgress)
                            }
                            .onEnded { _ in
                                if progress >= 0.95 {
                                    // Einrasten und beenden
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                        progress = 1.0
                                        isCompleted = true
                                        let impact = UIImpactFeedbackGenerator(style: .heavy)
                                        impact.impactOccurred()
                                    }
                                } else {
                                    // Zurückschnappen, falls nicht weit genug gezogen
                                    withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6)) {
                                        progress = 0.0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(height: 60)
        .padding(.horizontal, 40)
    }
}

#Preview {
    GrovyOnboardingView()
}
