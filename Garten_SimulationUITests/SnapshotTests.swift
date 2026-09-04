import XCTest

final class SnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("-isScreenshotMode")
        app.launch()
    }
    
    @MainActor
    func testTakeScreenshots() {
        let app = XCUIApplication()
        
        // Füge einen Interruption Monitor hinzu, falls System-Dialoge aufpoppen (z.B. Benachrichtigungen)
        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            if alert.buttons["Allow"].exists {
                alert.buttons["Allow"].tap()
                return true
            }
            if alert.buttons["Erlauben"].exists {
                alert.buttons["Erlauben"].tap()
                return true
            }
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
        
        // Tippen um den Interruption Monitor auszulösen
        app.tap()
        
        // 1. Warte, bis die App geladen ist (z.B. indem wir prüfen, ob die Tab-Bar da ist)
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Die App hat nicht rechtzeitig geladen.")
        
        sleep(3) // Kurz warten, bis alle Animationen durch sind
        
        // Mache den ersten Screenshot mit snapshot("01_Dashboard")
        snapshot("01_Dashboard")
        
        // 2. Tippe auf den Tab "Routinen" (anstelle von "statsTabButton")
        let routinenTab = tabBar.buttons["Routinen"]
        if routinenTab.exists {
            routinenTab.tap()
            sleep(2)
            // Mache den zweiten Screenshot mit snapshot("02_Statistics") (hier für Routinen adaptiert)
            snapshot("02_Routines")
        }
        
        // 3. Tippe auf den Tab "To-Dos" (anstelle von "addHabitButton")
        let todosTab = tabBar.buttons["To-Dos"]
        if todosTab.exists {
            todosTab.tap()
            sleep(2)
            // Mache den dritten Screenshot mit snapshot("03_AddHabit") (hier für To-Dos adaptiert)
            snapshot("03_Todos")
        }
        
        // Optional: Einen weiteren Screenshot für den Shop
        let shopTab = tabBar.buttons["Shop"]
        if shopTab.exists {
            shopTab.tap()
            sleep(2)
            snapshot("04_Shop")
        }
        
        // Optional: Einen weiteren Screenshot für das Profil
        let profileTab = tabBar.buttons["Profil"]
        if profileTab.exists {
            profileTab.tap()
            sleep(2)
            snapshot("05_Profile")
        }
    }
}
