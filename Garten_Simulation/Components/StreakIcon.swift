import SwiftUI

struct StreakIcon: View {
    let wert: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.appStats)
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    StreakIcon(wert: 12)
}
