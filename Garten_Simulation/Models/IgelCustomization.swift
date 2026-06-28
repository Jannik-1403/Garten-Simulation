import SwiftUI

enum IgelPose: String, CaseIterable, Codable {
    case stehend     = "stehend"
    case rennen      = "rennen"
    case schlafen    = "schlafen"
    case winken      = "winken"
    case liegen      = "liegen"
    case astronaut   = "astronaut"
    case sportler    = "sportler"
    case ninja       = "ninja"
    case schlafanzug = "schlafanzug"

    var assetName: String {
        switch self {
        case .stehend:     return "Igel_Stehend"
        case .rennen:      return "Igel-rennen"
        case .schlafen:    return "Igel-Schlafen"
        case .winken:      return "Igel_Winken"
        case .liegen:      return "Igel_Liegen"
        case .astronaut:   return "Igel_Outfit_Astronaut"
        case .sportler:    return "Igel_Outfit_Sportler"
        case .ninja:       return "Igel_Outfit_Ninja"
        case .schlafanzug: return "Igel_Outfit_Schlafanzug"
        }
    }

    var displayName: String {
        switch self {
        case .stehend:     return NSLocalizedString("igel_pose_stehend", comment: "")
        case .rennen:      return NSLocalizedString("igel_pose_rennen", comment: "")
        case .schlafen:    return NSLocalizedString("igel_pose_schlafen", comment: "")
        case .winken:      return NSLocalizedString("igel_pose_winken", comment: "")
        case .liegen:      return NSLocalizedString("igel_pose_liegen", comment: "")
        case .astronaut:   return NSLocalizedString("igel_pose_astronaut", comment: "")
        case .sportler:    return NSLocalizedString("igel_pose_sportler", comment: "")
        case .ninja:       return NSLocalizedString("igel_pose_ninja", comment: "")
        case .schlafanzug: return NSLocalizedString("igel_pose_schlafanzug", comment: "")
        }
    }
}

enum IgelAccessoire: String, CaseIterable, Codable {
    case keins = "keins"
    case hut = "hut"
    case brille = "brille"
    case schal = "schal"
    case blume = "blume"

    var displayName: String {
        switch self {
        case .keins: return NSLocalizedString("igel_acc_keins", comment: "")
        case .hut: return NSLocalizedString("igel_acc_hut", comment: "")
        case .brille: return NSLocalizedString("igel_acc_brille", comment: "")
        case .schal: return NSLocalizedString("igel_acc_schal", comment: "")
        case .blume: return NSLocalizedString("igel_acc_blume", comment: "")
        }
    }
}

enum IgelGesicht: String, CaseIterable, Codable {
    case froh = "froh"
    case cool = "cool"
    case schlafrig = "schlafrig"
    case verliebt = "verliebt"
    case stolz = "stolz"

    var displayName: String {
        switch self {
        case .froh: return NSLocalizedString("igel_gesicht_froh", comment: "")
        case .cool: return NSLocalizedString("igel_gesicht_cool", comment: "")
        case .schlafrig: return NSLocalizedString("igel_gesicht_schlafrig", comment: "")
        case .verliebt: return NSLocalizedString("igel_gesicht_verliebt", comment: "")
        case .stolz: return NSLocalizedString("igel_gesicht_stolz", comment: "")
        }
    }
}

enum IgelPortraitBackground: String, CaseIterable, Codable {
    case standard = "standard"
    case blau = "blau"
    case gruen = "gruen"
    case orange = "orange"
    case pink = "pink"
    case lila = "lila"
    case gelb = "gelb"

    var color: Color {
        switch self {
        case .standard: return Color(UIColor.secondarySystemGroupedBackground)
        case .blau: return Color.blue.opacity(0.15)
        case .gruen: return Color.green.opacity(0.15)
        case .orange: return Color.orange.opacity(0.15)
        case .pink: return Color.pink.opacity(0.15)
        case .lila: return Color.purple.opacity(0.15)
        case .gelb: return Color.yellow.opacity(0.15)
        }
    }
}

struct IgelCustomization: Codable {
    var name: String = ""
    var nameChangeCount: Int = 0
    var pose: IgelPose = .stehend
    var accessoire: IgelAccessoire = .keins
    var gesicht: IgelGesicht = .froh
    var background: IgelPortraitBackground = .standard
}
