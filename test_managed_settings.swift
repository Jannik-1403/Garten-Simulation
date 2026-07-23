import Foundation
import ManagedSettings

let store = ManagedSettingsStore()
print("App Store: \(type(of: store.appStore))")
print("Account: \(type(of: store.account))")
