import SwiftUI

struct GartenPassPowerUpWheelView: View {
    @EnvironmentObject var gartenPfadStore: GartenPfadStore
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var powerUpStore: PowerUpStore
    @Environment(\.dismiss) var dismiss
    
    var onRewardClaimed: (GartenPassBelohnung) -> Void
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var winningPowerUp: PowerUpItem? = nil
    @State private var showResultOverlay = false
    @State private var contentOpacity: Double = 0
    
    private let wheelSize: CGFloat = 300
    private let powerUps = GameDatabase.allPowerUps.prefix(10) // We use the 10 available powerups
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground).ignoresSafeArea()
                .onTapGesture {
                    if !isSpinning && !showResultOverlay {
                        dismiss()
                    }
                }
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Button {
                        FeedbackManager.shared.playTap()
                    } label: {
                        Text(NSLocalizedString("powerup_wheel_title", comment: "Power-Up Glücksrad"))
                    }
                    .buttonStyle(PowerUpWheelTitleStyle())
                    
                    Text(NSLocalizedString("powerup_wheel_subtitle", comment: "Drehe für dein Power-Up!"))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // The Wheel
                ZStack {
                    // 3D Shadow/Base
                    Circle()
                        .fill(Color(hex: "#0F1A30"))
                        .frame(width: wheelSize + 30, height: wheelSize + 30)
                    
                    // Interactive Layer
                    Button {
                        spinWheel()
                    } label: {
                        ZStack {
                            // Wheel Face
                            Circle()
                                .fill(Color(hex: "#1A2744"))
                                .frame(width: wheelSize + 30, height: wheelSize + 30)
                                .overlay(Circle().stroke(Color.black, lineWidth: 3))
                            
                            PowerUpWheelSlices(powerUps: Array(powerUps))
                                .frame(width: wheelSize, height: wheelSize)
                                .rotationEffect(.degrees(rotation))
                            
                            // Rim dots
                            ForEach(0..<12, id: \.self) { i in
                                WheelRimDot(index: i, totalDots: 12, rimRadius: (wheelSize + 30) / 2 - 8)
                            }
                            
                            // Center hub
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#0F1A30"))
                                    .frame(width: 40, height: 40)
                                Circle()
                                    .fill(Color(hex: "#1A2744"))
                                    .frame(width: 40, height: 40)
                                    .overlay(Circle().stroke(Color.white.opacity(0.8), lineWidth: 3))
                                    .offset(y: -3)
                            }
                        }
                        .offset(y: -6)
                    }
                    .buttonStyle(Press3DWrapperButtonStyle(depth: 6))
                    .disabled(isSpinning || showResultOverlay)
                    
                    // Pointer
                    WheelTrianglePointer()
                        .fill(Color.orange)
                        .frame(width: 24, height: 30)
                        .overlay(WheelTrianglePointer().stroke(Color.black, lineWidth: 2))
                        .offset(y: -(wheelSize / 2) - 15)
                        .shadow(radius: 2)
                }
                
                Spacer()
                
                // Spin/Dismiss Button
                if !isSpinning && !showResultOverlay {
                    Button(action: spinWheel) {
                        Text(NSLocalizedString("wheel_drehen", comment: "DREHEN"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, backgroundColor: .orange, shadowColor: .orange.darker()))
                    .padding(.horizontal, 40)
                }
                
                Spacer().frame(height: 40)
            }
            .opacity(contentOpacity)
            
            // Result Reveal (Success Overlay)
            if showResultOverlay, let pu = winningPowerUp {
                PowerUpResultView(powerUp: pu) {
                    claimAndDismiss(pu: pu)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }
    }
    
    private func spinWheel() {
        guard !isSpinning else { return }
        isSpinning = true
        
        let winner = powerUps.randomElement()!
        winningPowerUp = winner
        
        let winnerIndex = powerUps.firstIndex(where: { $0.id == winner.id }) ?? 0
        let segDeg = 360.0 / Double(powerUps.count)
        let targetSliceAngle = Double(winnerIndex) * segDeg + (segDeg / 2)
        
        let fullSpins = 6.0 * 360.0
        let targetRotation = rotation + fullSpins + (360.0 - targetSliceAngle)
        
        // Haptics
        let tickCount = Int(fullSpins / segDeg) + powerUps.count
        let duration: Double = 4.0
        for tick in 0..<tickCount {
            let progress = Double(tick) / Double(tickCount)
            let easedTime = progress * duration * (2.0 - progress)
            DispatchQueue.main.asyncAfter(deadline: .now() + easedTime) {
                if isSpinning {
                    FeedbackManager.shared.playTick()
                }
            }
        }
        
        withAnimation(.timingCurve(0.15, 0.85, 0.35, 1.0, duration: duration)) {
            rotation = targetRotation
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.5) {
            FeedbackManager.shared.playSuccess()
            withAnimation(.spring()) {
                showResultOverlay = true
                isSpinning = false
            }
        }
    }
    
    private func claimAndDismiss(pu: PowerUpItem) {
        // Build the reward object
        let reward = GartenPassBelohnung(typ: .powerUp(id: pu.id))
        
        // Use standard fulfillment logic
        gartenPfadStore.belohnungGutschreiben(reward, gardenStore: gardenStore, powerUpStore: powerUpStore)
        
        dismiss()
        onRewardClaimed(reward)
    }
}

// MARK: - Wheel Components

struct PowerUpWheelSlices: View {
    let powerUps: [PowerUpItem]
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)
            let radius = min(geo.size.width, geo.size.height) / 2
            let count = powerUps.count
            let segDeg = 360.0 / Double(count)
            
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let pu = powerUps[i]
                    let startDeg = -90.0 + Double(i) * segDeg
                    let endDeg = startDeg + segDeg
                    let midDeg = startDeg + segDeg / 2
                    let midRad = midDeg * .pi / 180
                    
                    // Slice
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(pu.color.gradient)
                    
                    // Divider
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius, startAngle: .degrees(startDeg), endAngle: .degrees(endDeg), clockwise: false)
                    }
                    .stroke(Color.black.opacity(0.3), lineWidth: 1.5)
                    
                    // Icon
                    Image(pu.symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .shadow(radius: 1)
                        .rotationEffect(.degrees(midDeg + 90))
                        .position(
                            x: center.x + CGFloat(cos(midRad)) * radius * 0.68,
                            y: center.y + CGFloat(sin(midRad)) * radius * 0.68
                        )
                }
            }
        }
    }
}

struct PowerUpResultView: View {
    let powerUp: PowerUpItem
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(powerUp.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(powerUp.symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            }
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("powerup_wheel_win", comment: "GEWONNEN!"))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(NSLocalizedString(powerUp.name, comment: ""))
                    .font(.title3.bold())
                    .foregroundColor(powerUp.color)
                
                Text(NSLocalizedString(powerUp.description, comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Button(action: onContinue) {
                Text(NSLocalizedString("wheel_weiter", comment: "Weiter"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DuolingoButtonStyle(size: .large))
            .padding(.top, 10)
        }
        .padding(32)
        .background(
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(hex: "#E0E0E0"))
                    .offset(y: 8)
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                    )
            }
        )
        .padding(.horizontal, 30)
    }
}

struct PowerUpWheelTitleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        ZStack {
            // Lower layer (shadow)
            configuration.label
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(Color.goldPrimary.opacity(0.35))
                .offset(y: 6)

            // Upper layer (visible text)
            configuration.label
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(LinearGradient(colors: [.goldPrimary, .orangePrimary], startPoint: .top, endPoint: .bottom))
                .offset(y: isPressed ? 6 : 0)
        }
        .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressed)
    }
}
