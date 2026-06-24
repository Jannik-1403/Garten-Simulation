import SwiftUI

// MARK: - App Tour Prompt Overlay
struct AppTourPromptOverlay: View {
    @EnvironmentObject var settingsStore: SettingsStore
    let onStartTour: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(settingsStore.localizedString(for: "tour_prompt_title"))
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text(settingsStore.localizedString(for: "tour_prompt_desc"))
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: {
                        settingsStore.appTourPromptShown = true
                        onStartTour()
                    }) {
                        Text(settingsStore.localizedString(for: "tour_prompt_yes"))
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: Color.gruenPrimary, shadowColor: Color.gruenPrimary.darker(), foregroundColor: .white))
                    
                    Button(action: {
                        withAnimation {
                            settingsStore.appTourPromptShown = true
                            settingsStore.appTourAbgeschlossen = true
                        }
                    }) {
                        Text(settingsStore.localizedString(for: "tour_prompt_no"))
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: Color.rotPrimary, shadowColor: Color.rotPrimary.darker(), foregroundColor: .white))
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color(white: 0.85), radius: 0, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 2)
            )
            .padding(24)
        }
        .zIndex(99999)
    }
}

struct InteractiveTourOverlay: View {
    @EnvironmentObject var tourManager: InteractiveTourManager
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var gardenStore: GardenStore
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Dim background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Optional: do not allow dismiss by tapping outside, force clicking Next or the Tab
                    }
                
                // Draw coach mark based on current step
                bubbleView(for: tourManager.currentStep, geo: geo)
                    .animation(.spring(), value: tourManager.currentStep)
            }
        }
    }
    
    @ViewBuilder
    private func bubbleView(for step: TourStep, geo: GeometryProxy) -> some View {
        let w = geo.size.width
        let h = geo.size.height
        
        let frame = tourManager.anchors[step] ?? CGRect(x: w/2, y: h/2, width: 0, height: 0)
        
        let targetPoint: CGPoint = {
            if step == .shopPrompt {
                return CGPoint(x: w * 0.375, y: h - geo.safeAreaInsets.bottom - 25)
            }
            if step == .profilePrompt {
                return CGPoint(x: w * 0.875, y: h - geo.safeAreaInsets.bottom - 25)
            }
            if frame.width > 0 {
                let localMinY = frame.minY - geo.safeAreaInsets.top
                let localMaxY = frame.maxY - geo.safeAreaInsets.top
                let localMidY = frame.midY - geo.safeAreaInsets.top
                
                let isOnTopHalf = localMidY <= h / 2
                if isOnTopHalf {
                    return CGPoint(x: frame.midX, y: localMaxY) // Point UP to bottom of frame
                } else {
                    return CGPoint(x: frame.midX, y: localMinY) // Point DOWN to top of frame
                }
            }
            return CGPoint(x: w/2, y: h/2) // Fallback center
        }()
        
        let arrowEdge: Edge? = {
            if frame.width > 0 && step != .shopPrompt && step != .profilePrompt {
                let localMidY = frame.midY - geo.safeAreaInsets.top
                return localMidY <= h / 2 ? .top : .bottom
            }
            return targetPoint.y <= h / 2 ? .top : .bottom
        }()
        
        // Configuration for each step
        let config = stepConfig(for: step)
        
        VStack(spacing: 0) {
            if arrowEdge == .bottom {
                Spacer()
                SmartBubble(
                    title: config.title,
                    desc: config.desc,
                    arrowEdge: .bottom,
                    targetX: targetPoint.x,
                    screenWidth: w,
                    onNext: config.onNext
                )
                Color.clear.frame(height: h - targetPoint.y)
            } else if arrowEdge == .top {
                Color.clear.frame(height: targetPoint.y)
                SmartBubble(
                    title: config.title,
                    desc: config.desc,
                    arrowEdge: .top,
                    targetX: targetPoint.x,
                    screenWidth: w,
                    onNext: config.onNext
                )
                Spacer()
            } else {
                Spacer()
                SmartBubble(
                    title: config.title,
                    desc: config.desc,
                    arrowEdge: nil,
                    targetX: targetPoint.x,
                    screenWidth: w,
                    onNext: config.onNext
                )
                Spacer()
            }
        }
        .frame(width: w, height: h)
    }
    
    // Helper to get text and actions
    private func stepConfig(for step: TourStep) -> (title: String, desc: String, onNext: () -> Void) {
        switch step {
        case .coinsIntro:
            return (settings.localizedString(for: "tour_coins_title"), settings.localizedString(for: "tour_coins_desc"), { tourManager.nextStep() })
        case .livesIntro:
            return (settings.localizedString(for: "tour_lives_title"), settings.localizedString(for: "tour_lives_desc"), { tourManager.nextStep() })
        case .streakHeaderIntro:
            return (settings.localizedString(for: "tour_streak_header_title"), settings.localizedString(for: "tour_streak_header_desc"), { tourManager.nextStep() })
        case .dailyRingIntro:
            return (settings.localizedString(for: "tour_daily_ring_title"), settings.localizedString(for: "tour_daily_ring_desc"), { tourManager.nextStep() })
        case .intro:
            return (settings.localizedString(for: "tour_1_title"), settings.localizedString(for: "tour_1_desc"), { 
                if let firstPlant = gardenStore.pflanzen.first {
                    tourManager.showPlantDetail = firstPlant
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { tourManager.nextStep() }
            })
        case .focusTimer:
            return (settings.localizedString(for: "tour_5_title"), settings.localizedString(for: "tour_5_desc"), { tourManager.nextStep() })
        case .plantStreak:
            return (settings.localizedString(for: "tour_plant_streak_title"), settings.localizedString(for: "tour_plant_streak_desc"), { tourManager.nextStep() })
        case .plantPath:
            return (settings.localizedString(for: "tour_plant_path_title"), settings.localizedString(for: "tour_plant_path_desc"), {
                tourManager.showPlantDetail = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { tourManager.nextStep() }
            })
        case .badHabits:
            return (settings.localizedString(for: "tour_2_title"), settings.localizedString(for: "tour_2_desc"), { tourManager.nextStep() })
        case .shopPrompt:
            return (settings.localizedString(for: "tab.shop"), settings.localizedString(for: "tour_shop_prompt_desc"), {
                gardenStore.selectedTab = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { tourManager.nextStep() }
            })
        case .shopIntro:
            return (settings.localizedString(for: "tour_3_title"), settings.localizedString(for: "tour_3_desc"), { tourManager.nextStep() })
        case .profilePrompt:
            return (settings.localizedString(for: "tab.profil"), settings.localizedString(for: "tour_profile_prompt_desc"), {
                gardenStore.selectedTab = 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { tourManager.nextStep() }
            })
        case .titles:
            return (settings.localizedString(for: "tour_4_title"), settings.localizedString(for: "tour_4_desc"), { tourManager.nextStep() })
        case .achievements:
            return (settings.localizedString(for: "tour_6_title"), settings.localizedString(for: "tour_6_desc"), { tourManager.nextStep() })
        case .streak:
            return (settings.localizedString(for: "tour_7_title"), settings.localizedString(for: "tour_7_desc"), { tourManager.nextStep() })
        case .inventory:
            return (settings.localizedString(for: "tour_inventory_title"), settings.localizedString(for: "tour_inventory_desc"), { tourManager.nextStep() })
        case .done:
            return ("", "", {})
        }
    }
}

struct SmartBubble: View {
    let title: String
    let desc: String
    let arrowEdge: Edge?
    let targetX: CGFloat
    let screenWidth: CGFloat
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if arrowEdge == .top {
                ArrowView(edge: .top)
                    .offset(x: clampArrowX(targetX) - screenWidth/2)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(desc)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Spacer()
                    Button(action: onNext) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .buttonStyle(DuolingoButtonStyle(size: .small, fillWidth: false, backgroundColor: Color.black, shadowColor: Color(hex: "#333333"), foregroundColor: .white))
                    .padding(.top, 4)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color(white: 0.85), radius: 0, x: 0, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 2)
            )
            .padding(.horizontal, 24)
            
            if arrowEdge == .bottom {
                ArrowView(edge: .bottom)
                    .offset(x: clampArrowX(targetX) - screenWidth/2)
            }
        }
    }
    
    // Ensure the arrow doesn't detach from the box by going too far to the edges
    private func clampArrowX(_ x: CGFloat) -> CGFloat {
        // The box has 24 padding on each side. The arrow should stay within the box width.
        // Screen width - 48 is max box width.
        // Box spans from 24 to screenWidth - 24.
        // Arrow is 20 wide, center is at targetX.
        let minX: CGFloat = 24 + 20
        let maxX: CGFloat = screenWidth - 24 - 20
        return min(max(x, minX), maxX)
    }
}

struct ArrowView: View {
    let edge: Edge
    var body: some View {
        Path { path in
            if edge == .bottom {
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 15))
            } else if edge == .top {
                path.move(to: CGPoint(x: 10, y: 0))
                path.addLine(to: CGPoint(x: 20, y: 15))
                path.addLine(to: CGPoint(x: 0, y: 15))
            }
        }
        .fill(Color(UIColor.systemBackground))
        .frame(width: 20, height: 15)
        // Move the shadow slightly
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: edge == .bottom ? 2 : -2)
        // Z-Index trick to hide the seam
        .zIndex(1)
        .padding(.bottom, edge == .bottom ? 0 : -1)
        .padding(.top, edge == .top ? 0 : -1)
    }
}

struct TourAnchorModifier: ViewModifier {
    let step: TourStep
    @EnvironmentObject var tourManager: InteractiveTourManager
    
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .global)) { old, new in
                        DispatchQueue.main.async {
                            tourManager.anchors[step] = new
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            tourManager.anchors[step] = geo.frame(in: .global)
                        }
                    }
            }
        )
    }
}

extension View {
    func tourAnchor(_ step: TourStep) -> some View {
        self.modifier(TourAnchorModifier(step: step))
    }
    
    @ViewBuilder
    func tourAnchor(_ step: TourStep, condition: Bool) -> some View {
        if condition {
            self.modifier(TourAnchorModifier(step: step))
        } else {
            self
        }
    }
}

#Preview {
    InteractiveTourOverlay()
        .environmentObject(InteractiveTourManager())
        .environmentObject(SettingsStore())
        .environmentObject(GardenStore())
}
