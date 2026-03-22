import SwiftUI

struct HerzenIcon: View {
    let wert: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .font(.appStats)
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    HerzenIcon(wert: 5)
}
