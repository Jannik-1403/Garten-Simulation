import Foundation
import AppIntents

public struct PlantEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Pflanze"
    public static var defaultQuery = PlantQuery()

    public let id: String
    public let name: String
    public let symbolName: String

    public init(id: String, name: String, symbolName: String) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
    }

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "",
            image: DisplayRepresentation.Image(systemName: symbolName)
        )
    }

    // Static member for better discovery
    static var allPlants: [PlantEntity] {
        let shared = SharedUserDefaults.suite
        guard let data = shared.data(forKey: "garden_plants"),
              let pflanzen = try? JSONDecoder().decode([HabitModel].self, from: data) else {
            return []
        }
        
        let lang = shared.string(forKey: "appLanguage") ?? Locale.current.language.languageCode?.identifier ?? "de"
        
        return pflanzen
            .filter { !$0.istBewässert } // Nur Pflanzen zeigen, die noch nicht gegossen wurden
            .map { habit in
                var finalName = habit.habitName
                
                // Falls es ein Key ist (z.B. plant.erdbeere.name), übersetzen wir ihn
                if finalName.contains(".") {
                    finalName = AppStrings.get(finalName, language: lang)
                }
                
                // Falls immer noch leer oder Key (Fallback), nutzen wir den Display-Namen
                if finalName.isEmpty || finalName.contains(".") {
                    if let dbPlant = GameDatabase.allPlants.first(where: { $0.id.lowercased() == habit.plantID.lowercased() }) {
                        finalName = AppStrings.get(dbPlant.name, language: lang)
                    }
                }
                
                return PlantEntity(id: habit.id, name: finalName, symbolName: habit.symbolName)
            }
    }
}

public struct PlantQuery: EntityStringQuery {
    public init() {}
    public func entities(for identifiers: [PlantEntity.ID]) async throws -> [PlantEntity] {
        return PlantEntity.allPlants.filter { identifiers.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [PlantEntity] {
        return PlantEntity.allPlants
    }
    
    public func entities(matching string: String) async throws -> [PlantEntity] {
        return PlantEntity.allPlants.filter { $0.name.localizedCaseInsensitiveContains(string) }
    }
}

extension PlantQuery: EnumerableEntityQuery {
    public func allEntities() async throws -> [PlantEntity] {
        return PlantEntity.allPlants
    }
}
