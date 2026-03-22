import SwiftUI

extension Font {
    // Headlines — fett & markant
    static let appTitel = Font.system(
        size: 28, weight: .black, design: .rounded
    )
    static let appHeadline = Font.system(
        size: 20, weight: .bold, design: .rounded
    )
    static let appSubheadline = Font.system(
        size: 16, weight: .semibold, design: .rounded
    )

    // Body — clean & lesbar
    static let appBody = Font.system(
        size: 15, weight: .regular, design: .rounded
    )
    static let appCaption = Font.system(
        size: 12, weight: .medium, design: .rounded
    )
    static let appBadge = Font.system(
        size: 10, weight: .semibold, design: .rounded
    )

    // Buttons — immer bold rounded
    static let appButton = Font.system(
        size: 15, weight: .bold, design: .rounded
    )
    static let appButtonKlein = Font.system(
        size: 13, weight: .bold, design: .rounded
    )

    // Stats (Streak, Gems, Herzen)
    static let appStats = Font.system(
        size: 18, weight: .bold, design: .rounded
    )
}
