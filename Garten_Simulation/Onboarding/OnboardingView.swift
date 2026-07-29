import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var garden: GardenStore

    
    @StateObject var data = OnboardingData()
    @State private var showConfetti = false
    private let totalSteps = 6
    
    var body: some View {
        ZStack {
            FloatingBackgroundView()
            
            VStack(spacing: 0) {
                // Header: Back & Progress
                HStack(spacing: 16) {
                    if data.currentStep > 1 && data.currentStep <= totalSteps {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                data.currentStep -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Spacer().frame(width: 24)
                    }
                    
                    // Progressive Bar
                    OnboardingProgressBar(currentStep: data.currentStep, totalSteps: totalSteps)
                    
                    Spacer().frame(width: 24)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 10)
                
                // Content
                ZStack {
                    switch data.currentStep {
                    case 1:
                        OnboardingWillkommenView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 2:
                        GoalOnboardingView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 3:
                        OnboardingPflanzenView()
                            .transition(AnyTransition.asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .leading)
                            ))
                            
                    case 4:
                        OnboardingNotificationView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 5:
                        OnboardingScreenTimeView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 6:
                        OnboardingLegalView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    default:
                        EmptyView()
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: data.currentStep)
            }
            .environmentObject(data)
        }
        .overlay {
            if showConfetti {
                ConfettiParticleView()
            }
        }
        .onChange(of: data.currentStep) { _, newStep in
            if newStep > totalSteps {
                finishOnboarding()
            }
        }
    }
    
    private func finishOnboarding() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        FeedbackManager.shared.playSuccess()
        showConfetti = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let ziel = data.gewaehltesZiele.first ?? .gesund
        
        let defaultTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
        
        if data.gewaehltePflanzenIDs.isEmpty {
            if let defaultPlant = ziel.pflanzenIDs.first {
                garden.pflanzeHinzufuegenAusOnboarding(plantID: defaultPlant, reminderTime: defaultTime)
            }
        } else {
            for plantID in data.gewaehltePflanzenIDs {
                garden.pflanzeHinzufuegenAusOnboarding(plantID: plantID, reminderTime: defaultTime)
            }
        }
        
        garden.onboardingSetup()
        

        
        withAnimation {
            settings.ausgewaehltesZiel = ziel.rawValue
            settings.onboardingAbgeschlossen = true
        }
        }
    }
}

