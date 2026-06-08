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
        case .stehend:     return AppStrings.get("igel_pose_stehend", language: SettingsStore.shared.appLanguage)
        case .rennen:      return AppStrings.get("igel_pose_rennen", language: SettingsStore.shared.appLanguage)
        case .schlafen:    return AppStrings.get("igel_pose_schlafen", language: SettingsStore.shared.appLanguage)
        case .winken:      return AppStrings.get("igel_pose_winken", language: SettingsStore.shared.appLanguage)
        case .liegen:      return AppStrings.get("igel_pose_liegen", language: SettingsStore.shared.appLanguage)
        case .astronaut:   return AppStrings.get("igel_pose_astronaut", language: SettingsStore.shared.appLanguage)
        case .sportler:    return AppStrings.get("igel_pose_sportler", language: SettingsStore.shared.appLanguage)
        case .ninja:       return AppStrings.get("igel_pose_ninja", language: SettingsStore.shared.appLanguage)
        case .schlafanzug: return AppStrings.get("igel_pose_schlafanzug", language: SettingsStore.shared.appLanguage)
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
        case .keins: return AppStrings.get("igel_acc_keins", language: SettingsStore.shared.appLanguage)
        case .hut: return AppStrings.get("igel_acc_hut", language: SettingsStore.shared.appLanguage)
        case .brille: return AppStrings.get("igel_acc_brille", language: SettingsStore.shared.appLanguage)
        case .schal: return AppStrings.get("igel_acc_schal", language: SettingsStore.shared.appLanguage)
        case .blume: return AppStrings.get("igel_acc_blume", language: SettingsStore.shared.appLanguage)
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
        case .froh: return AppStrings.get("igel_gesicht_froh", language: SettingsStore.shared.appLanguage)
        case .cool: return AppStrings.get("igel_gesicht_cool", language: SettingsStore.shared.appLanguage)
        case .schlafrig: return AppStrings.get("igel_gesicht_schlafrig", language: SettingsStore.shared.appLanguage)
        case .verliebt: return AppStrings.get("igel_gesicht_verliebt", language: SettingsStore.shared.appLanguage)
        case .stolz: return AppStrings.get("igel_gesicht_stolz", language: SettingsStore.shared.appLanguage)
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
