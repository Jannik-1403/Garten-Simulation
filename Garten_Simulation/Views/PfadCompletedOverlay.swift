import SwiftUI

struct PfadCompletedOverlay: View {
    let habit: HabitModel
    let coinsEarned: Int
    let onCollect: () -> Void
    let onDismiss: () -> Void
    
    @EnvironmentObject var settings: SettingsStore
    
    @State private var visible = false
    @State private var cardOffset: CGFloat = 300
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .opacity(visible ? 1 : 0)
                .onTapGesture { safeDismiss() }
            
            if visible {
                VStack(spacing: 24) {
                    
                    // Icon and Title
                    VStack(spacing: 12) {
                        Image(habit.symbolName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(hex: habit.symbolColor))
                            .shadow(color: Color(hex: habit.symbolColor).opacity(0.3), radius: 10, y: 5)
                        
                        Text(settings.localizedString(for: "pfad_abschluss_titel"))
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description
                    VStack(spacing: 16) {
                        let descTemplate = settings.localizedString(for: "pfad_abschluss_desc")
                        Text(descTemplate.replacingOccurrences(of: "[HABIT]", with: habit.habitName.isEmpty ? habit.name : habit.habitName))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        // Reward Box
                        HStack(spacing: 8) {
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("+\(coinsEarned)")
                                .font(.system(.title3, design: .rounded, weight: .black))
                                .foregroundColor(Color(hex: "#FFD60A"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FFD60A").opacity(0.15))
                        .clipShape(Capsule())
                    }
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            FeedbackManager.shared.playSuccess()
                            safeDismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onCollect()
                            }
                        }) {
                            Text(settings.localizedString(for: "pfad_abschluss_btn_einsammeln").uppercased())
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .buttonStyle(DuolingoButtonStyle(
                            size: .large,
                            fillWidth: true,
                            backgroundColor: Color(hex: "#FF9F0A"),
                            shadowColor: Color(hex: "#FF9F0A").darker(),
                            foregroundColor: .black
                        ))
                    }
                }
                .padding(32)
                .background(
                    ZStack(alignment: .bottom) {
                        // 3D Shadow Layer (Base)
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(hex: "#E0E0E0"))
                            .offset(y: 8)
                        
                        // Main White Surface
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.black.opacity(0.1), lineWidth: 1.5)
                            )
                    }
                )
                .padding(.horizontal, 24)
                .frame(maxWidth: 400)
                .offset(y: cardOffset)
            }
        }
        .onAppear {
            FeedbackManager.shared.playSuccess()
            withAnimation(.easeIn(duration: 0.2)) {
                visible = true
            }
            withAnimation(.spring(duration: 0.4)) {
                cardOffset = 0
            }
        }
    }
    

    
    private func safeDismiss() {
        withAnimation(.spring(duration: 0.3)) {
            cardOffset = 400
            visible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}
