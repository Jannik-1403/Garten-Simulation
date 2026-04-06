import SwiftUI

struct XPIcon: View {
    let wert: Int

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image("XP")
                .resizable()
                .scaledToFit()
                .frame(width: 34, height: 34)
            
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(Color.blauPrimary)
        }
    }
}

#Preview {
    XPIcon(wert: 1250)
}
