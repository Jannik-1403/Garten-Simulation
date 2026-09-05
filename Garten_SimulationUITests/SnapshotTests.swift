import XCTest

final class SnapshotTests: XCTestCase {
    
    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments.append("-isScreenshotMode")
        app.launch()
    }
    
    @MainActor
    func testTakeScreenshots() {
        let app = XCUIApplication()
        
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
        
        app.tap()
        
        // Warte, bis die App geladen ist
        XCTAssertTrue(app.buttons["tab_habits"].waitForExistence(timeout: 10))
        sleep(2)
        
        // Habits Tab (Standard) -> Gesund kochen
        app.buttons["habit_Gesund kochen"].tap()
        sleep(1)
        snapshot("01_Plant_GesundKochen")
        app.buttons["button_back"].tap()
        sleep(1)
        
        // Krafttraining
        app.buttons["habit_Krafttraining"].tap()
        sleep(1)
        snapshot("02_Plant_Krafttraining")
        app.buttons["button_back"].tap()
        sleep(1)
        
        // Obst und Gemüse
        app.buttons["habit_Obst und Gemüse"].tap()
        sleep(1)
        snapshot("03_Plant_ObstGemuese")
        app.buttons["button_back"].tap()
        sleep(1)
        
        // Routinen
        app.buttons["tab_routines"].tap()
        sleep(1)
        snapshot("04_Routinen")
        
        // ToDos
        app.buttons["tab_todos"].tap()
        sleep(1)
        snapshot("05_ToDos")
        
        // Profil
        app.buttons["tab_profile"].tap()
        sleep(1)
        snapshot("06_Profil")
        
        // Streak
        app.buttons["tab_habits"].tap()
        sleep(1)
        app.buttons["button_streak"].tap()
        sleep(1)
        snapshot("07_Streak")
        // Dismiss the streak sheet
        app.swipeDown()
        sleep(1)
        
        // Settings & Screentime
        app.buttons["tab_profile"].tap()
        sleep(1)
        app.buttons["button_settings"].tap()
        sleep(1)
        app.buttons["button_screentime"].tap()
        sleep(1)
        snapshot("08_Bildschirmzeit")
    }
}
