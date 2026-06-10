import os
import re

files = [
    "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift",
    "/Users/jannikschill/Documents/Garten-Simulation/GartenWidget/AppStrings.swift",
    "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Stores/SettingsStore.swift"
]

for filepath in files:
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replacements
        content = content.replace('Garten Simulation', 'Grovy')
        content = content.replace('Garten-Simulation', 'Grovy')
        content = content.replace('Gartensimulation', 'Grovy')
        content = content.replace('garten-simulation', 'grovy') # For urlString if applicable
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
    else:
        print(f"Not found: {filepath}")
