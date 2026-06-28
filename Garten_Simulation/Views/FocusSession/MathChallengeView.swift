import SwiftUI

struct MathChallengeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsStore
    
    let problemString: String
    let correctAnswer: Int
    var onCancelSession: () -> Void
    
    @State private var userAnswer: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Text(String(localized: "math_challenge.title"))
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "math_challenge.description"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(problemString + " = ?")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.horizontal)
                
                TextField(String(localized: "math_challenge.placeholder"), text: $userAnswer)
                    .keyboardType(.numberPad)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(showError ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .padding(.horizontal)
                    .onChange(of: userAnswer) { _, _ in
                        showError = false
                    }
                
                if showError {
                    Text(String(localized: "math_challenge.error"))
                        .foregroundStyle(.red)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                Button {
                    if let answer = Int(userAnswer), answer == correctAnswer {
                        dismiss()
                        onCancelSession()
                    } else {
                        showError = true
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                } label: {
                    Text(String(localized: "math_challenge.confirm_cancel"))
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .red, shadowColor: .red.darker()))
                .padding(.horizontal, 24)
                
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "math_challenge.continue_focus"))
                }
                .buttonStyle(DuolingoButtonStyle(size: .large, fillWidth: true, backgroundColor: .blauPrimary, shadowColor: .blauPrimary.darker()))
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .standardNavigationX()
        }
    }
}
