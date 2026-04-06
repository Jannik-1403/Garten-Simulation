import SwiftUI

struct HerzenIcon: View {
    let wert: Int

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image("Heart")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
            
            Text("\(wert)")
                .font(.appStats)
                .foregroundStyle(Color.rotPrimary)
        }
    }
}

#Preview {
    HerzenIcon(wert: 5)
}
