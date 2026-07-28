import os
import re

directory = "/Users/jannikschill/Documents/Garten-Simulation"

files_to_delete = [
    "Garten_Simulation/Models/ActivePowerUp.swift",
    "Garten_Simulation/Models/PowerUpWeedSupport.swift",
    "Garten_Simulation/Stores/PowerUpStore.swift",
    "Garten_Simulation/Views/ActivePowerUpDetailSheet.swift",
    "Garten_Simulation/Views/PowerUpPlantPickerSheet.swift",
    "Garten_Simulation/Onboarding/OnboardingPowerUpTutorialView.swift",
    "Garten_Simulation/Onboarding/OnboardingPowerUpDetailSheet.swift",
    "Garten_Simulation/Components/WeedPowerUpSection.swift",
    "GartenWidget/WetterEvent.swift",
    "Garten_Simulation/Stores/GartenPfadStore.swift",
    "Garten_Simulation/Views/PfadTagDetailView.swift",
    "GartenWidget/PfadDatenbank.swift",
    "GartenWidget/PfadStrangTag.swift",
    "Garten_Simulation/Models/PfadStrang.swift",
    "Garten_Simulation/Models/PfadVerschmelzung.swift"
]

for file in files_to_delete:
    path = os.path.join(directory, file)
    if os.path.exists(path):
        os.remove(path)
        print(f"Deleted {path}")

# Regex patterns to remove
patterns_to_remove = [
    re.compile(r'^\s*@EnvironmentObject\s+var\s+powerUpStore\s*:\s*PowerUpStore\s*\n', re.MULTILINE),
    re.compile(r'^\s*\.environmentObject\(.*powerUpStore.*\)\s*\n', re.MULTILINE),
    re.compile(r'^\s*\.environmentObject\(.*PowerUpStore\(\).*\)\s*\n', re.MULTILINE),
    re.compile(r'^\s*let\s+powerUpStore\s*=\s*PowerUpStore\(\)\s*\n', re.MULTILINE),
    re.compile(r'^\s*let\s+powerUpStore\s*:\s*PowerUpStore\s*\n', re.MULTILINE),
    re.compile(r'^\s*self\.powerUpStore\s*=\s*PowerUpStore\(\)\s*\n', re.MULTILINE),
    
    re.compile(r'^\s*@EnvironmentObject\s+var\s+pfadStore\s*:\s*GartenPfadStore\s*\n', re.MULTILINE),
    re.compile(r'^\s*\.environmentObject\(.*pfadStore.*\)\s*\n', re.MULTILINE),
    re.compile(r'^\s*\.environmentObject\(.*GartenPfadStore\(\).*\)\s*\n', re.MULTILINE),
    re.compile(r'^\s*let\s+gartenPfadStore\s*:\s*GartenPfadStore\s*\n', re.MULTILINE),
    re.compile(r'^\s*self\.gartenPfadStore\s*=.*\n', re.MULTILINE),
]

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith(".swift"):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            for pattern in patterns_to_remove:
                content = pattern.sub('', content)
            
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f"Cleaned up {filepath}")
