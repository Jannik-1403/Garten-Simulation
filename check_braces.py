import sys

def check(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    depth = 0
    for i, line in enumerate(lines):
        line_clean = line.split('//')[0] # naive comment stripping
        for char in line_clean:
            if char == '{':
                depth += 1
            elif char == '}':
                depth -= 1
        
        if 'private func noteRow' in line:
            print(f"Line {i+1}: noteRow declared at depth {depth}")

check("/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/PflanzeDetailSheet.swift")
