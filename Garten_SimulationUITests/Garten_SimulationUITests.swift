import XCTest

final class Garten_SimulationUITests: XCTestCase {
    
    @MainActor
    func testTakeScreenshots() throws {
        continueAfterFailure = true
        
        let app = XCUIApplication()
        // Pass arguments to disable tour and other interfering elements
        app.launchArguments.append("-disableTour")
        app.launchArguments.append("-hasSeenOnboarding")
        app.launchArguments.append("YES")
        app.launchArguments.append("-isUITest")
        app.launch()
        
        // Add an interruption monitor to handle system alerts like Notifications
        addUIInterruptionMonitor(withDescription: "System Dialog") { alert in
            let allowButton = alert.buttons.element(boundBy: 1) // Usually "Allow" is the second button
            if allowButton.exists {
                allowButton.tap()
                return true
            }
            let okButton = alert.buttons["OK"]
            if okButton.exists {
                okButton.tap()
                return true
            }
            let allow = alert.buttons["Erlauben"]
            if allow.exists {
                allow.tap()
                return true
            }
            return false
        }
        
        // Tap the app to trigger the interruption monitor if a dialog is present
        app.tap()
        
        // Wait for app to settle
        sleep(5)
        
        takeScreenshot(name: "app_store_garden_new")
        
        // Find Shop tab
        let shopTab = app.tabBars.buttons.element(boundBy: 1)
        if shopTab.exists {
            shopTab.tap()
            sleep(2)
            takeScreenshot(name: "app_store_shop_new")
        }
        
        // Find Pass tab
        let passTab = app.tabBars.buttons.element(boundBy: 2)
        if passTab.exists {
            passTab.tap()
            sleep(2)
            takeScreenshot(name: "app_store_pass_new")
        }
        
        // Find Profile tab
        let profileTab = app.tabBars.buttons.element(boundBy: 3)
        if profileTab.exists {
            profileTab.tap()
            sleep(2)
            takeScreenshot(name: "app_store_profile_new")
        }
    }
    
    func takeScreenshot(name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let path = "/Users/jannikschill/.gemini/antigravity/brain/f146e453-628a-4c62-ba2c-2852228f9758/\(name).png"
        try? screenshot.pngRepresentation.write(to: URL(fileURLWithPath: path))
    }
}
