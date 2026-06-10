import sys

def check(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    depth = 0
    for i, line in enumerate(lines):
        line_clean = line.split('//')[0]
        # remove strings to avoid matching braces in strings
        import re
        line_clean = re.sub(r'".*?"', '', line_clean)
        
        for char in line_clean:
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
                
        if i+1 in [82, 83, 84, 85, 313, 314, 329, 330, 331, 332, 440, 441, 485, 486, 487]:
            print(f"Line {i+1} is at depth {depth}: {line.strip()}")

check("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift")
