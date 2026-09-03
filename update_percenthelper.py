import re

with open("Garten_Simulation/Localization/PercentHelper.swift", "r") as f:
    content = f.read()

# First, undo the mess: replace all instances of my nested mess with clean `.formatted(.percent)`
content = re.sub(r'\(?\d+\(?0?\.formatted\(\.percent\)( as String\)?)+\)?', lambda m: re.search(r'\d+', m.group(0).replace('(', '')).group(0) + '.formatted(.percent)', content)
# Wait, just download a clean version from git? No, it wasn't committed.
# Better yet, just use a precise regex replacement from original code to new.
