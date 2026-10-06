import XCTest
@testable import Garten_Simulation

final class DecodeTests: XCTestCase {

    func testDecodingGardenPlants() throws {
        let sharedDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
        guard let data = sharedDefaults?.data(forKey: "garden_plants") else {
            XCTFail("Keine Daten in garden_plants gefunden")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let plants = try decoder.decode([HabitModel].self, from: data)
            XCTAssertFalse(plants.isEmpty, "Dekodierte Pflanzenliste ist leer")
            
            for plant in plants {
                print("Lade Pflanze: \(plant.name)")
                let target = plant.target(for: Date())
                print("Target für heute: \(target)")
                XCTAssertNotNil(target, "Target darf nicht nil sein")
            }
        } catch {
            XCTFail("Dekodierung fehlgeschlagen: \(error)")
        }
    }
}
