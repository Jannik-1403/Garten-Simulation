import SwiftUI

struct ProfileDetailView: View {
    let title: String
    let icon: String
    let value: String
    let color: Color
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header 3D Card
                    VStack(spacing: 16) {
                        Image(systemName: icon)
                            .font(.system(size: 48))
                            .foregroundStyle(color)
                        
                        VStack(spacing: 4) {
                            Text(value)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                            Text(title)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 10)
                    )
                    .padding(.horizontal, 24)
                    
                    // Detailed Stats / History
                    VStack(alignment: .leading, spacing: 20) {
                        Text(settings.localizedString(for: "common.details"))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 12) {
                            detailRow(label: settings.localizedString(for: "common.total"), value: value)
                            detailRow(label: settings.localizedString(for: "common.this_month"), value: "+\(Int.random(in: 1...5))")
                            detailRow(label: settings.localizedString(for: "common.record"), value: value)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ProfileDetailView(title: "Pflanzen", icon: "leaf.fill", value: "24", color: .green)
    }
}
