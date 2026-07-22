import re

pbx_path = "Garten_Simulation.xcodeproj/project.pbxproj"
with open(pbx_path, "r", encoding="utf-8") as f:
    content = f.read()

# We can remove any line containing Localizable.strings
lines = content.split('\n')
new_lines = []
for line in lines:
    if "Localizable.strings" not in line:
        new_lines.append(line)

with open(pbx_path, "w", encoding="utf-8") as f:
    f.write('\n'.join(new_lines))
