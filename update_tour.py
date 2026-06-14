import re

# Update InteractiveTourManager.swift
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Stores/InteractiveTourManager.swift', 'r') as f:
    content = f.read()
# Remove "case badHabits = 8"
content = re.sub(r'\s*case badHabits\s*=\s*\d+', '', content)
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Stores/InteractiveTourManager.swift', 'w') as f:
    f.write(content)

# Update GartenView.swift
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/GartenView.swift', 'r') as f:
    content = f.read()
# Remove .tourAnchor(.badHabits, ...)
content = re.sub(r'\.tourAnchor\(\.badHabits,.*?\)', '', content, flags=re.DOTALL)
# Remove if newStep == .badHabits { proxy.scrollTo(TourStep.badHabits, anchor: .bottom) }
content = re.sub(r'if newStep == \.badHabits \{[^}]+\}', '', content, flags=re.DOTALL)
# Remove .id(TourStep.badHabits)
content = re.sub(r'\.id\(TourStep\.badHabits\)', '', content)
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/GartenView.swift', 'w') as f:
    f.write(content)

# Update InteractiveTourOverlay.swift
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/InteractiveTourOverlay.swift', 'r') as f:
    content = f.read()
# Remove case .badHabits: return ...
pattern = r'case \.badHabits:\s*return \[.*?\]'
content = re.sub(pattern, '', content, flags=re.DOTALL)
with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/InteractiveTourOverlay.swift', 'w') as f:
    f.write(content)

print("Tour updated.")
