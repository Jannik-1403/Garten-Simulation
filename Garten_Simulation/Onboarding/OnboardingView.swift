import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var garden: GardenStore
    
    @StateObject var data = OnboardingData()
    
    private let totalSteps = 8
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header: Back & Progress
                HStack(spacing: 16) {
                    if data.currentStep > 1 && data.currentStep < totalSteps {
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
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 12)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.blauPrimary, .blauPrimary.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(data.currentStep) / CGFloat(totalSteps), height: 12)
                        }
                    }
                    .frame(height: 12)
                    
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
                        OnboardingZielView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 3:
                        if let ziel = data.gewaehltesZiel {
                            OnboardingPflanzenView()
                            .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        } else {
                            OnboardingCustomPlantView()
                            .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        }
                        
                    case 4:
                        OnboardingInteractiveTutorialView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 5:
                        OnboardingZeitView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 6:
                        OnboardingPowerUpTutorialView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 7:
                        OnboardingTutorialWeedView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    case 8:
                        OnboardingFertigView()
                        .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                        
                    default:
                        EmptyView()
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: data.currentStep)
            }
            .environmentObject(data)
        }
    }
}
