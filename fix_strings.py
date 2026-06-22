path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace \\n with \n in assessment.category.headline
content = content.replace('\\\\n', '\\n')

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
