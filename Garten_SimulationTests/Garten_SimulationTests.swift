//
//  Garten_SimulationTests.swift
//  Garten_SimulationTests
//
//  Created by Jannik Schill on 21.03.26.
//

import Testing
import Foundation
@testable import Grovy

struct Garten_SimulationTests {

    @Test func testDecodingGardenPlants() throws {
        let sharedDefaults = UserDefaults(suiteName: "group.com.jannik.grovy")
        guard let data = sharedDefaults?.data(forKey: "garden_plants") else {
            print("Keine Daten in garden_plants gefunden (Simulator Leer?)")
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let plants = try decoder.decode([HabitModel].self, from: data)
            #expect(!plants.isEmpty)
            
            for plant in plants {
                print("Lade Pflanze: \(plant.name)")
                let target = plant.target(for: Date())
                print("Target für heute: \(target)")
            }
            
            // Check if JSONSerialization works like in Widget
            let encodedData = try JSONEncoder().encode(plants)
            let jsonObj = try JSONSerialization.jsonObject(with: encodedData, options: .mutableContainers)
            #expect(jsonObj is [[String: Any]])
            if let arr = jsonObj as? [[String: Any]] {
                print("JSONSerialization hat funktioniert! \(arr.count) Pflanzen.")
            } else {
                XCTFail("JSONSerialization ergab kein [[String: Any]]")
            }
            
        } catch {
            print("DECODE ERROR: \(error)")
            throw error
        }
    }
}
