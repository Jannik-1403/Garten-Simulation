import SwiftUI

// MARK: - Shop Detail Payload

struct ShopDetailPayload: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String?
    let price: Int
    let icon: String
    let color: Color
    let shadowColor: Color
    let tag: String?
}

// MARK: - Shop Item Detail View

struct ShopItemDetailView: View {
    let payload: ShopDetailPayload
    let onBuy: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var iconWobble = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background tint
            LinearGradient(
                colors: [payload.color.opacity(0.15), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    heroSection
                    infoCard
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                .padding(.bottom, 140) // Space for bottom bar
            }
            
            // Bottom Bar Fixed
            VStack {
                Spacer()
                bottomBar
            }
        }
        .background(Color.appHintergrund.ignoresSafeArea())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                iconWobble = true
            }
        }
    }
    
    private var heroSection: some View {
        ZStack {
            // Icon directly displayed
            Image(payload.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .shadow(color: payload.shadowColor.opacity(0.3), radius: 10, y: 5)
                .offset(y: iconWobble ? -6 : 0)
        }
        .frame(height: 180)
    }
    
    private var infoCard: some View {
        VStack(spacing: 16) {
            if let tag = payload.tag {
                Text(tag)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(payload.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(payload.color.opacity(0.15)))
            }
            
            Text(payload.title)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
            
            Text(payload.subtitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let desc = payload.description {
                Divider().padding(.vertical, 8)
                
                Text(desc)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var bottomBar: some View {
        VStack(spacing: 16) {
            Button(action: {
                onBuy()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text("KAUFEN FÜR \(payload.price)")
                    Image("Coin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .buttonStyle(DuolingoButtonStyle(size: .large))
            
            Button("Abbrechen") {
                dismiss()
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
        )
    }
}
