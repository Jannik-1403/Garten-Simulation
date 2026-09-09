import re

with open('Garten_Simulation/Models/NutrientIndexManager.swift', 'r') as f:
    content = f.read()

# Add sources to NutrientItem
content = content.replace('var isEnabled: Bool = true', 'var isEnabled: Bool = true\n    var sources: String?')

# Update loadSettings
loadSettings_replacement = """            for i in loadedVits.indices {
                if let match = defVitamins.first(where: { $0.hkTypeIdentifier == loadedVits[i].hkTypeIdentifier }) {
                    loadedVits[i].name = match.name
                    loadedVits[i].unitString = match.unitString
                    loadedVits[i].sources = match.sources
                }
            }
            self.vitamins = loadedVits
            
            var loadedMins = savedState["minerals"] ?? defMinerals
            for i in loadedMins.indices {
                if let match = defMinerals.first(where: { $0.hkTypeIdentifier == loadedMins[i].hkTypeIdentifier }) {
                    loadedMins[i].name = match.name
                    loadedMins[i].unitString = match.unitString
                    loadedMins[i].sources = match.sources
                }
            }
            self.minerals = loadedMins
            
            var loadedFiber = savedState["fiber"]?.first ?? defFiber
            loadedFiber.name = defFiber.name
            loadedFiber.unitString = defFiber.unitString
            loadedFiber.sources = defFiber.sources
            self.fiber = loadedFiber"""

content = re.sub(r'            for i in loadedVits.indices \{\n.*?self\.fiber = loadedFiber', loadSettings_replacement, content, flags=re.DOTALL)

# Update the default lists to include sources
def replacer(match):
    line = match.group(0)
    # Extract the string localized key (e.g., nutrient.vitamin_c)
    m = re.search(r'String\(localized: "(nutrient\.[^"]+)"', line)
    if m:
        key = m.group(1)
        source_key = key.replace('nutrient.', 'nutrient.sources.')
        # add sources parameter
        line = line.replace('))]', f'), sources: String(localized: "{source_key}", defaultValue: ""))]')
        line = line.replace(')),', f'), sources: String(localized: "{source_key}", defaultValue: "")),')
        line = line.replace('))', f'), sources: String(localized: "{source_key}", defaultValue: ""))')
    return line

content = re.sub(r'NutrientItem\(id: UUID\(\), name: String\(localized: "nutrient\..*?\)\)', replacer, content)

with open('Garten_Simulation/Models/NutrientIndexManager.swift', 'w') as f:
    f.write(content)
