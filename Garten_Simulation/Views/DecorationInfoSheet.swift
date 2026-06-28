import SwiftUI

struct DecorationInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image("Warndreieck")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .padding(.top, 20)
                    
                    Text(String(localized: "decoration.info.title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(String(localized: "decoration.info.description"))
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .standardNavigationX()
        }
    }
}
