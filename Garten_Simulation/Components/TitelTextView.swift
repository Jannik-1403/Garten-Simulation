import SwiftUI

struct TitelTextView: View {
    @EnvironmentObject var settings: SettingsStore
    let titel: PlayerTitle
    var fontSize: CGFloat = 17
    var colorOverride: Color? = nil
    
    @State private var leuchtet = false

    var body: some View {
        let baseColor = colorOverride ?? titel.titleColor
        
        Text(NSLocalizedString(titel.displayName, comment: ""))
            .font(.system(size: fontSize, weight: .black, design: .rounded))
            .foregroundStyle(baseColor)
    }
}
