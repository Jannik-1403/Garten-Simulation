import SwiftUI

struct XPInfoSheet: View {
    @EnvironmentObject var gardenStore: GardenStore
    @EnvironmentObject var settings: SettingsStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appHintergrund.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Image("XP")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color(hex: "#FFD000").opacity(0.3), radius: 10, x: 0, y: 5)
                            }

                            
                            Text(settings.localizedString(for: "xp_info.title"))
                                .font(.system(size: 26, weight: .black, design: .rounded))
                        }
                        .padding(.top, 40)
                        
                        // Info Card
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(settings.localizedString(for: "xp_info.current_label"))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .textCase(.uppercase)
                                
                                HStack(alignment: .lastTextBaseline, spacing: 8) {
                                    Text("\(gardenStore.gesamtXP)")
                                        .font(.system(size: 48, weight: .black, design: .rounded))
                                        .foregroundStyle(Color(hex: "#D9A300")) // Dunkelgelb
                                    
                                    Text("XP")
                                        .font(.system(size: 24, weight: .black, design: .rounded))
                                        .foregroundStyle(Color(hex: "#D9A300").opacity(0.7))
                                }
                            }
                            
                            Divider()
                            
                            Text(settings.localizedString(for: "xp_info.description"))
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .lineSpacing(6)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(28)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 20)
                }
                
                // Close Button - Fixed at bottom
                Button {
                    dismiss()
                } label: {
                    Text(settings.localizedString(for: "common.close"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.primary)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
                .padding(.top, 10)
                .background(Color.appHintergrund)
            }
        }
    }
}

#Preview {
    XPInfoSheet()
        .environmentObject(GardenStore())
        .environmentObject(SettingsStore())
}
