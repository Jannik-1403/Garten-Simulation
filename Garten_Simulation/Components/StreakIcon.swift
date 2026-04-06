import SwiftUI

struct StreakIcon: View {
    let wert: Int

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image("streak")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
            
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(Color.orangePrimary)
        }
    }
}

#Preview {
    StreakIcon(wert: 12)
}
