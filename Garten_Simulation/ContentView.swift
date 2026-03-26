import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GartenView()
                .tabItem {
                    Label("Garten", systemImage: "leaf.fill")
                }
            
            AufgabenView()
                .tabItem {
                    Label("Aufgaben", systemImage: "checkmark.circle.fill")
                }
            
            GewohnheitenView()
                .tabItem {
                    Label("Gewohnheiten", systemImage: "flame.fill")
                }
            
            UnifiedShopView()
                .tabItem {
                    Label("Shop", systemImage: "cart.fill")
                }
            
            ProfilView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .tint(.green)
    }
}

#Preview {
    ContentView()
}
