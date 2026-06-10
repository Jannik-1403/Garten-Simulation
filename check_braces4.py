import sys

def check(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    depth = 0
    for i, line in enumerate(lines):
        line_clean = line.split('//')[0]
        import re
        line_clean = re.sub(r'".*?"', '', line_clean)
        
        for char in line_clean:
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
                
        if depth <= 0 and '}' in line_clean:
            print(f"Line {i+1} hits depth {depth}: {line.strip()}")

check("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift")
