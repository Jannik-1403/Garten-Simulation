import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                let isCompleted = step <= currentStep
                
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isCompleted ? Color.blauPrimary : Color.gray.opacity(0.15))
                    .frame(height: 12)
                    .shadow(color: isCompleted ? Color.blauPrimary.darker() : Color.clear, radius: 0, x: 0, y: isCompleted ? 4 : 0)
                    .offset(y: isCompleted ? -2 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentStep)
            }
        }
        .frame(height: 16)
    }
}
