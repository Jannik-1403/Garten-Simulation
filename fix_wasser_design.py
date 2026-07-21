import re

content = open("Garten_Simulation/Views/Profile/WasserDetailView.swift").read()

# 1. Update the VStack spacing and remove Divider/Background
old_vstack = """                                VStack(spacing: 0) {
                                    let sorted = gardenStore.pflanzenNachMlSortiert
                                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, habit in
                                        WasserRankingRow(rank: index + 1, habit: habit)
                                        
                                        if index < sorted.count - 1 {
                                            Divider()
                                                .padding(.leading, 70)
                                        }
                                    }
                                }
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .padding(.horizontal, 20)"""

new_vstack = """                                VStack(spacing: 16) {
                                    let sorted = gardenStore.pflanzenNachMlSortiert
                                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, habit in
                                        WasserRankingRow(rank: index + 1, habit: habit)
                                    }
                                }
                                .padding(.horizontal, 20)"""

content = content.replace(old_vstack, new_vstack)

# 2. Update WasserRankingRow view
old_row = """    var body: some View {
        HStack(spacing: 16) {
            // Rang-Nummer in einem kleinen Kreis
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor : Color.secondary.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Text(verbatim: "\\(rank)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(rank <= 3 ? .white : .secondary)
            }"""

new_row = """    var body: some View {
        HStack(spacing: 16) {
            // Rang-Nummer in einem kleinen Kreis (3D Button Style)
            ZStack {
                // 3D Schatten / untere Kante
                Circle()
                    .fill(rank <= 3 ? rankColor.darker() : Color.secondary.opacity(0.5))
                    .frame(width: 32, height: 32)
                    .offset(y: 3)
                    
                // Hauptfläche
                Circle()
                    .fill(rank <= 3 ? rankColor : Color(UIColor.systemGray5))
                    .frame(width: 32, height: 32)
                
                Text(verbatim: "\\(rank)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(rank <= 3 ? .white : .primary)
            }"""

content = content.replace(old_row, new_row)

# 3. Add 3D card styling to the end of the HStack in WasserRankingRow
old_row_end = """        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatVolume(_ ml: Double) -> String {"""

new_row_end = """        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        // Neo-Brutalismus / 3D harter Schatten
        .shadow(color: Color.black.opacity(0.12), radius: 0, x: 0, y: 6)
    }
    
    private func formatVolume(_ ml: Double) -> String {"""

content = content.replace(old_row_end, new_row_end)

open("Garten_Simulation/Views/Profile/WasserDetailView.swift", "w").write(content)
print("Changes applied!")
