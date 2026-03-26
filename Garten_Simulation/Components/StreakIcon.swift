import SwiftUI

struct StreakIcon: View {
    let wert: Int

    var body: some View {
        HStack(spacing: 4) {
            Image("Sonnen_Streak")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    StreakIcon(wert: 12)
}
