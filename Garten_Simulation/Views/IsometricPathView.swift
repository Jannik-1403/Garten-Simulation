struct IsoDecoration: Identifiable {
    let id = UUID()
    let col: Int
    let row: Int
    let imageName: String
    let widthPt: CGFloat
    let heightPt: CGFloat
    var yOffset: CGFloat = 0
}

import SwiftUI

struct IsometricPathView: View {
    @ObservedObject var habit: HabitModel
    @EnvironmentObject var settings: SettingsStore
    
    // Konstanten für den Schlangenpfad
    private let totalDays = 90
    
    private let pathGridCoordinates: [(col: Int, row: Int)] = {
        var path = [(Int, Int)]()
        var col = 1      // ← zurück auf 1
        var row = 3      // ← zurück auf 3
        var directionIsCol = true
        var stepsInDirection = 0
        let maxSteps = 4 // ← zurück auf 4
        
        for _ in 0..<90 {
            path.append((col, row))
            if stepsInDirection >= maxSteps {
                directionIsCol.toggle()
                stepsInDirection = 0
            }
            if directionIsCol { col += 1 }
            else { row += 1 }
            stepsInDirection += 1
        }
        return path
    }()


    private let decorations: [IsoDecoration] = [
        IsoDecoration(
            col: 8, row: 10,
            imageName: "deko_busch",
            widthPt: 250, heightPt: 250,
            yOffset: -20
        ),


        // Baum: nach dem Busch (gr\u00f6\u00dfere row-Zahl = weiter unten)
        IsoDecoration(
            col: 12, row: 10,
            imageName: "deko_baum",
            widthPt: 220, heightPt: 220,
            yOffset: -20
        )












    ]
















    @State private var selectedDay: SelectedDay? = nil

    struct SelectedDay: Identifiable {
        let id = UUID()
        let index: Int
    }

    private let canvasWidth: CGFloat = UIScreen.main.bounds.width
    private var canvasHeight: CGFloat {
        // Tag 90 (index 89) ist der unterste Punkt.
        tilePosition(index: totalDays - 1).y + 500
    }

    @State private var contentHeight: CGFloat = UIScreen.main.bounds.height * 2

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .top) {
                        IsometricGrassBackground(
                            contentHeight: canvasHeight,
                            pathPositions: (0..<totalDays).map { tilePosition(index: $0) }
                        )
                        .frame(width: canvasWidth, height: canvasHeight)
                        
                        ZStack(alignment: .topLeading) {
                            Color.clear
                                .frame(width: canvasWidth, height: canvasHeight)

                            // Berechne den Fortschritt
                            let firstUnwateredIndex = (0..<totalDays).first { i in
                                let date = dayAt(index: i)
                                return !habit.wateringDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                            } ?? totalDays

                            // Alle Elemente (Tiles + Dekorationen) zusammen nach Z-Order sortieren
                            ForEach(sortedRenderItems(firstUnwateredIndex: firstUnwateredIndex), id: \.sortKey) { item in
                                switch item.kind {
                                case .tile(let i):
                                    tileView(index: i, firstUnwateredIndex: firstUnwateredIndex)
                                        .position(tilePosition(index: i))
                                        .zIndex(item.zValue)
                                        .id(i)
                                    
                                case .deko(let d):
                                    dekoView(deko: d)
                                        .zIndex(item.zValue)
                                }
                            }
                        }
                        .frame(width: canvasWidth, height: canvasHeight)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(key: ContentHeightKey.self, value: geo.size.height)
                            }
                        )
                    }
                }
                .scrollDisabled(selectedDay != nil)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#3e7a2d"))
                .onPreferenceChange(ContentHeightKey.self) { height in
                    contentHeight = max(height, UIScreen.main.bounds.height)
                }
                .onAppear {
                    let firstUnwateredIndex = (0..<totalDays).first { i in
                        let date = dayAt(index: i)
                        return !habit.wateringDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    } ?? (totalDays - 1)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            proxy.scrollTo(firstUnwateredIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .fullScreenCover(item: $selectedDay) { item in
            detailOverlay(for: item.index)
        }
    }
    
    // MARK: - Components
     private func detailOverlay(for index: Int) -> some View {
        let date = dayAt(index: index)
        let dayNum = index + 1
        
        // Berechne erneut den aktuellen freigeschalteten Index
        let firstUnwateredIndex = (0..<totalDays).first { i in
            let d = dayAt(index: i)
            return !habit.wateringDates.contains { Calendar.current.isDate($0, inSameDayAs: d) }
        } ?? totalDays
        
        let isUnlockedStump = (index == firstUnwateredIndex)
        let dateOfTile = dayAt(index: index)
        let isFuture = Calendar.current.compare(dateOfTile, to: Date(), toGranularity: .day) == .orderedDescending
        let canBeCompleted = isUnlockedStump && !isFuture && !habit.istBewässert
        
        let lang = settings.appLanguage
        let diff = habit.individualSchwierigkeit ?? "anfaenger"
        
        // Hole die Pflanze aus der Datenbank für das richtige Asset
        let plant = GameDatabase.allPlants.first { $0.id.lowercased() == habit.plantID.lowercased() }
        let assetName = plant?.assetName ?? "plant_lotus"
        
        // Phase bestimmen
        let phaseKey: String = {
            if dayNum <= 14 { return "einstieg" }
            if dayNum <= 45 { return "aufbau" }
            if dayNum <= 75 { return "vertiefung" }
            return "meisterschaft"
        }()
        
        let phaseName = AppStrings.get("pfad_phase_\(phaseKey)", language: lang)
        let plantID = habit.plantID.lowercased().replacingOccurrences(of: "plant.", with: "")
        
        // Lokalisierte Texte
        let title = AppStrings.get("pfad_\(plantID)_day_\(dayNum)_title", language: lang)
        let displayTitle = title.contains("pfad_") ? String(format: AppStrings.get("pfad_tag_header", language: lang), dayNum) : title
        
        let dayDesc = AppStrings.get("pfad_\(plantID)_day_\(dayNum)_desc_\(diff)", language: lang)
        let displayDesc = dayDesc.contains("pfad_") ? AppStrings.get("pfad_\(plantID)_phase_\(phaseKey)_desc_\(diff)", language: lang) : dayDesc
        
        return VStack(spacing: 0) {
            // Header / Close
            HStack {
                Spacer()
                Button(action: { selectedDay = nil }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(.primary)
                        .padding(12)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            VStack(spacing: 25) {
                // 1. Pflanzen Icon (Oben)
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .padding(.top, 10)
                
                // 2. Phase & Tag
                VStack(spacing: 4) {
                    Text(phaseName.uppercased())
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundColor(.orange)
                    
                    Text(String(format: AppStrings.get("pfad_tag_von", language: lang), dayNum, totalDays))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // 3. Titel & Beschreibung
                VStack(spacing: 12) {
                    Text(displayTitle)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(hex: "#2F2F2F"))
                    
                    Text(displayDesc)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                        .padding(.horizontal, 20)
                        .minimumScaleFactor(0.8)
                }
                
                // 4. Datum & Status
                HStack(spacing: 10) {
                    let isWatered = habit.wateringDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
                    Image(systemName: isWatered ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundColor(isWatered ? .green : .orange)
                        .font(.body)
                    
                    Text(date.formatted(date: .long, time: .omitted))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // 5. ERLEDIGEN Button (NUR wenn dieser Baumstamm der AKTIVE/FREIGESCHALTETE ist)
                if canBeCompleted {
                    Item3DButton(
                        farbe: .green,
                        sekundaerFarbe: Color(hex: "#2E7D32"), // Dunkleres Grün für den 3D-Schatten
                        groesse: 65,
                        isRectangular: true,
                        aktion: {
                            withAnimation {
                                habit.wateringDates.append(date)
                                habit.istBewässert = true
                                habit.streak += 1
                                selectedDay = nil
                            }
                        }
                    ) {
                        Text(AppStrings.get("pfad_erledigen_btn", language: lang).uppercased())
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 15)
                    .padding(.horizontal, 24)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(Color.white)
    }
    
    // MARK: - Layout Helpers
    
    private func tilePosition(index i: Int) -> CGPoint {
        guard i < pathGridCoordinates.count else { return .zero }
        let coord = pathGridCoordinates[i]
        var pt = IsometricMath.point(col: coord.col, row: coord.row, screenWidth: canvasWidth)
        pt.y += IsometricMath.tileHeight / 2   // = 36pt (automatisch korrekt bei jeder Tile-Gr\u00f6\u00dfe)
        return pt
    }











    
    private func dayAt(index i: Int) -> Date {
        // Tag 1 (index 0) ist das Kaufdatum
        return Calendar.current.date(byAdding: .day, value: i, to: habit.gekauftAm) ?? habit.gekauftAm
    }

    // --- RENDER HELPERS ---

    enum RenderKind {
        case tile(Int)
        case deko(IsoDecoration)
    }

    struct RenderItem {
        let sortKey: String
        let zValue: Double
        let kind: RenderKind
    }

    private func sortedRenderItems(firstUnwateredIndex: Int) -> [RenderItem] {
        var items: [RenderItem] = []
        
        // Tiles hinzuf\u00fcgen
        for i in 0..<totalDays {
            let coord = pathGridCoordinates[i]
            let sum = coord.col + coord.row
            items.append(RenderItem(
                sortKey: "tile_\(i)",
                zValue: Double(sum) * 10 + Double(i) * 0.1,
                kind: .tile(i)
            ))
        }
        
        // Dekorationen hinzuf\u00fcgen
        for deko in decorations {
            let sum = deko.col + deko.row
            items.append(RenderItem(
                sortKey: "deko_\(deko.id)",
                // +5 damit Deko leicht vor gleichwertigen Tiles liegt
                zValue: Double(sum) * 10 + 5,
                kind: .deko(deko)
            ))
        }
        
        return items.sorted { $0.zValue < $1.zValue }
    }

    @ViewBuilder
    private func tileView(index i: Int, firstUnwateredIndex: Int) -> some View {
        let dateOfTile = dayAt(index: i)
        let isFuture = Calendar.current.compare(dateOfTile, to: Date(), toGranularity: .day) == .orderedDescending
        
        let status: PathTileView.TileStatus = {
            if i < firstUnwateredIndex { return .erledigt }
            else if i == firstUnwateredIndex {
                if !isFuture && !habit.istBewässert { return .freigeschalten }
                else { return .nichtFreigeschalten }
            } else { return .nichtFreigeschalten }
        }()
        
        return PathTileView(
            dayNumber: i + 1,
            status: status,
            action: {
                withAnimation(.spring()) {
                    selectedDay = SelectedDay(index: i)
                }
            }
        )
    }

    @ViewBuilder
    private func dekoContent(imageName: String, size: CGFloat) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }






    private func dekoView(deko: IsoDecoration) -> some View {
        var pt = IsometricMath.point(col: deko.col, row: deko.row, screenWidth: canvasWidth)
        
        // Unterkante des Bildes auf Tile-Unterrand setzen
        // (so sitzt das Objekt ON the tile, wie ein Baum)
        let posX = pt.x
        let posY = pt.y 
            + IsometricMath.tileHeight          // \u2192 Unterkante der Tile-Oberfl\u00e4che
            - (deko.heightPt / 2)               // \u2192 Bildmitte so dass Unterkante auf Tile sitzt
            + deko.yOffset

        return dekoContent(imageName: deko.imageName, size: deko.widthPt)
            .position(x: posX, y: posY)
            .allowsHitTesting(false)
    }




}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

