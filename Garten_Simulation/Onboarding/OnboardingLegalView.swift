import SwiftUI

struct OnboardingLegalView: View {
    @EnvironmentObject var data: OnboardingData
    @EnvironmentObject var settings: SettingsStore
    
    @State private var hasAcceptedTerms = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingIgelView(
                pose: hasAcceptedTerms ? .daumenHoch : .erklaert,
                sprechblasenText: String(localized: "onboarding_legal_bubble_title") // e.g. "Fast geschafft! Nur noch eine kleine Formsache."
            )
            .padding(.top, 20)
            
            Spacer()
            
            // Apple-like Card for Legal stuff
            VStack(alignment: .leading, spacing: 20) {
                Text(String(localized: "onboarding_legal_title")) // e.g. "Nutzungsbedingungen & Datenschutz"
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 4)
                
                Text(String(localized: "onboarding_legal_desc")) // e.g. "Bevor du loslegst, bitten wir dich, unsere Bedingungen zu akzeptieren."
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Benefits List
                VStack(alignment: .leading, spacing: 12) {
                    benefitRow(icon: "person.crop.circle.badge.xmark", text: String(localized: "onboarding_legal_benefit_1"))
                    benefitRow(icon: "shield.lefthalf.filled", text: String(localized: "onboarding_legal_benefit_2"), color: .blauPrimary)
                    benefitRow(icon: "lock.shield", text: String(localized: "onboarding_legal_benefit_3"), color: .green)
                }
                .padding(.vertical, 8)
                
                // Toggle with custom design
                Button {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        hasAcceptedTerms.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 16) {
                        // Checkbox
                        ZStack {
                            Circle()
                                .strokeBorder(hasAcceptedTerms ? Color.blauPrimary : Color.gray.opacity(0.3), lineWidth: 2)
                                .background(Circle().fill(hasAcceptedTerms ? Color.blauPrimary : Color.clear))
                                .frame(width: 28, height: 28)
                            
                            if hasAcceptedTerms {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.top, 2)
                        
                        // Text with Links
                        VStack(alignment: .leading, spacing: 6) {
                            Text(String(localized: "onboarding_legal_checkbox_text")) // e.g. "Ich habe die Bedingungen gelesen und stimme zu."
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Link(destination: URL(string: "https://shrouded-parka-be8.notion.site/Terms-of-Use-37dd74b814d2805393b6e17145019e9c")!) {
                                    Text(String(localized: "onboarding_legal_terms"))
                                        .underline()
                                        .foregroundStyle(Color.blauPrimary)
                                }
                                
                                Link(destination: URL(string: "https://shrouded-parka-be8.notion.site/Privacy-Policy-37dd74b814d28080acc3c9303df218c8")!) {
                                    Text(String(localized: "onboarding_legal_privacy"))
                                        .underline()
                                        .foregroundStyle(Color.blauPrimary)
                                }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .padding(.top, 2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(16)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.12), radius: 0, x: 0, y: 8)
            }
            .padding(.horizontal, 24)
            
            Spacer(minLength: 32)
            
            Button {
                finish()
            } label: {
                Text(String(localized: "onboarding_legal_finish_button")) // e.g. "Loslegen"
            }
            .buttonStyle(DuolingoButtonStyle(
                size: .large,
                backgroundColor: Color.blauPrimary,
                shadowColor: Color.blauPrimary.darker(),
                foregroundColor: .white
            ))
            .disabled(!hasAcceptedTerms)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    private func finish() {
        FeedbackManager.shared.playTap()
        withAnimation(.easeInOut(duration: 0.35)) {
            data.currentStep += 1
        }
    }
    
    private func benefitRow(icon: String, text: String, color: Color = .gray) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 24, alignment: .center)
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
