import SwiftUI

struct DashboardCard<Content: View, Footer: View>: View {
    let title: String
    let badgeText: String?
    let badgeColor: Color
    let mainStat: String
    let subStat: String?
    let content: Content
    let footer: Footer
    
    var onExpand: (() -> Void)? = nil
    
    init(
        title: String,
        badgeText: String? = nil,
        badgeColor: Color = .gruenPrimary,
        mainStat: String,
        subStat: String? = nil,
        onExpand: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.title = title
        self.badgeText = badgeText
        self.badgeColor = badgeColor
        self.mainStat = mainStat
        self.subStat = subStat
        self.onExpand = onExpand
        self.content = content()
        self.footer = footer()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(badgeColor.opacity(0.15))
                        .foregroundStyle(badgeColor)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    ShareLink(item: "\(title): \(mainStat) \(subStat ?? "")") {
                        Image(systemName: "square.and.arrow.up")
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                    
                    Button {
                        onExpand?()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .padding(8)
                            .contentShape(Rectangle())
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary.opacity(0.6))
            }
            
            // Main Stat
            VStack(alignment: .leading, spacing: 4) {
                Text(mainStat)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                if let sub = subStat {
                    Text(sub)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            
            // Content (Chart)
            content
                .frame(minHeight: 120)
            
            // Footer
            Divider()
            
            footer
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

struct DashboardFooterItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.secondary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
