
import re

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/de.lproj/Localizable.strings"

with open(path, "r", encoding="utf-8") as f:
    lines = f.readlines()

in_comment = False
for i, line in enumerate(lines):
    line = line.strip()
    if not line:
        continue
    if line.startswith("/*"):
        if not "*/" in line:
            in_comment = True
        continue
    if in_comment:
        if "*/" in line:
            in_comment = False
        continue
    if line.startswith("//"):
        continue
    
    # Check if it matches "key" = "value";
    if not re.match(r'^".*" = ".*";$', line):
        print(f"Error at line {i+1}: {line}")
