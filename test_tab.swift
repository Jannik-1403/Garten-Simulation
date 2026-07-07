import SwiftUI

@available(iOS 18.0, *)
struct TestView: View {
    var body: some View {
        TabView {
            Text("1").tabItem { Text("1") }
        }
        .tabViewStyle(.tabBarOnly)
    }
}
