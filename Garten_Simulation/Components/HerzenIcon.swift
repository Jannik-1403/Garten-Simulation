import SwiftUI

struct HerzenIcon: View {
    let wert: Int

    var body: some View {
        HStack(spacing: 4) {
            Image("Hert")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    HerzenIcon(wert: 5)
}
