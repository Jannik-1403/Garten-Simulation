import re
import sys

def update_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Regex to match: habitNameKey: "...", habitDescriptionKey: "...", 
    # taking into account possible whitespace.
    pattern = r'habitNameKey:\s*"[^"]*",\s*habitDescriptionKey:\s*"[^"]*",\s*'
    new_content = re.sub(pattern, '', content)

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")
    else:
        print(f"No changes in {filepath}")

update_file("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/GameDatabase.swift")
update_file("/Users/jannikschill/Documents/Garten-Simulation/GartenWidget/GameDatabase.swift")
