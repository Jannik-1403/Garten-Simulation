import os
import re

def find_hardcoded_strings():
    swift_files = []
    for root, dirs, files in os.walk("Garten_Simulation"):
        for file in files:
            if file.endswith(".swift"):
                swift_files.append(os.path.join(root, file))
                
    hardcoded_patterns = [
        re.compile(r'Text\("([^"]+)"\)'),
        re.compile(r'Button\("([^"]+)"'),
        re.compile(r'Label\("([^"]+)"'),
        re.compile(r'\.navigationTitle\("([^"]+)"\)')
    ]
    
    ignore_exact = ["", "•", "0", "-1", "100", ".", "%@", "%d", " ", "-", "+", "  "]
    
    results = []
    for file in swift_files:
        with open(file, "r", encoding="utf-8") as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                if "String(localized" in line:
                    continue
                if "PreviewProvider" in line or "#Preview" in line:
                    continue # Skip previews roughly, actually it's hard to skip full preview blocks line by line
                
                for p in hardcoded_patterns:
                    matches = p.findall(line)
                    for m in matches:
                        if m.strip() not in ignore_exact and not m.startswith("\\("):
                            results.append(f"{file}:{i+1}: {line.strip()}")
                            
    for r in results:
        print(r)

find_hardcoded_strings()
