import re
import sys

def extract_properties(content):
    # Regex to find property declarations like `@Published var name: Type = Default`
    # We only care about property name and type
    props = {}
    lines = content.split('\n')
    for line in lines:
        match = re.search(r'(?:@Published\s+)?(?:private\(set\)\s+)?(?:var|let)\s+([a-zA-Z0-9_]+)\s*:\s*([a-zA-Z0-9_?\[\]:<>\s]+)(?:\s*=\s*(.*))?', line.strip())
        if match:
            name = match.group(1)
            type_str = match.group(2).strip()
            # If it's a computed property, skip
            if '{' in line or '}' in line or type_str.endswith('{'): continue
            props[name] = type_str
    return props

with open('Garten_Simulation/Models/HabitModel.swift', 'r') as f:
    main_content = f.read()
    
with open('GartenWidget/HabitModel.swift', 'r') as f:
    widget_content = f.read()

main_props = extract_properties(main_content)
widget_props = extract_properties(widget_content)

missing = {k: v for k, v in main_props.items() if k not in widget_props}
print("Missing properties:", missing.keys())

# Let's see what is actually missing.
