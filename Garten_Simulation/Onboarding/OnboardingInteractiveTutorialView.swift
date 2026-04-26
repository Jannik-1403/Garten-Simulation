import SwiftUI

struct OnboardingInteractiveTutorialView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    @State private var innerPose: IgelPose = .giesst
    @State private var gegossen = false
    @State private var ringProgress: CGFloat = 0.0
    @State private var showNext = false
    @State private var plantPosition: CGPoint = .zero
    
    var tutorialPlant: Plant? {
        guard let firstID = data.gewaehltePflanzenIDs.first else {
            return GameDatabase.allPlants.first
        }
        return GameDatabase.allPlants.first { $0.id == firstID }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                OnboardingIgelView(
                    pose: innerPose,
                    sprechblasenText: gegossen ? settings.localizedString(for: "onboarding_tutorial_giessen_erfolg") : settings.localizedString(for: "onboarding_tutorial_giessen_blase")
                )
                .padding(.top, 20)
                
                Spacer()
                
                // Simulated Plant Card (Unified with Garden View)
                if let plant = tutorialPlant {
                    VStack(spacing: 24) {
                        ZStack {
                            // Progress Ring (Garden Style)
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                                .frame(width: 130, height: 130)
                            
                            Circle()
                                .trim(from: 0, to: ringProgress)
                                .stroke(
                                    Color.gruenPrimary,
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                )
                                .frame(width: 130, height: 130)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.6), value: ringProgress)
                            
                            // Target Glow (Garden Style)
                            Circle()
                                .stroke(Color.gruenPrimary.opacity(gegossen ? 0.6 : 0.0), lineWidth: 10)
                                .frame(width: 145, height: 145)
                                .blur(radius: 5)
                                .animation(.easeOut(duration: 0.3), value: gegossen)
                            
                            PflanzenButton(
                                plant: plant,
                                seltenheit: .bronze,
                                farbe: Color.gruenPrimary,
                                sekundaerFarbe: Color.gruenPrimary.darker(),
                                groesse: 120,
                                alwaysShowFullGrown: true,
                                externerPress: false
                            )
                            .overlay {
                                if gegossen {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.green)
                                        .background(Circle().fill(.white))
                                        .offset(x: 45, y: -45)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                plantPosition = geo.frame(in: .global).center
                            }
                            .onChange(of: geo.frame(in: .global)) { _, newValue in
                                plantPosition = newValue.center
                            }
                        })
                        
                        VStack(spacing: 4) {
                            Text(settings.localizedString(for: plant.localizedName))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                            
                            Text(settings.localizedString(for: "onboarding_tutorial_giessen_test"))
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if showNext {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.35)) {
                            data.currentStep += 1
                        }
                    } label: {
                        Text(settings.localizedString(for: "onboarding_weiter"))
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
                } else {
                    // Spacer for the button area to keep layout stable
                    Spacer().frame(height: 100)
                }
            }
            
            // Interaction Layer
            if !gegossen && plantPosition != .zero {
                VStack {
                    Spacer()
                    DragToWater(
                        onGiessen: {
                            handleWateringSuccess()
                        },
                        pflanzenPosition: plantPosition,
                        istErledigt: gegossen
                    )
                    .frame(height: 100)
                    .padding(.bottom, 60) // Moved significantly lower
                }
            }
        }
        .animation(.spring(), value: gegossen)
        .animation(.spring(), value: showNext)
    }
    
    private func handleWateringSuccess() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            ringProgress = 1.0
            gegossen = true
            innerPose = .daumenHoch
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showNext = true
            }
        }
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
