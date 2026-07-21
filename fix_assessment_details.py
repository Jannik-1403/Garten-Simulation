import re

with open("Garten_Simulation/Models/AssessmentResult+Detailed.swift", "r") as f:
    code = f.read()

# Replace section titles safely
section_titles = {
    "Fragen im Assessment": "assessment.source.questions",
    "Deine Rohscores": "assessment.source.raw_scores",
    "Dein schwächster Bereich": "assessment.source.weakest_area",
    "Berechnung": "assessment.source.calculation",
    "Kategorien": "assessment.source.categories"
}

for ger, key in section_titles.items():
    code = code.replace(f'sectionTitle: "{ger}"', f'sectionTitle: String(localized: "{key}", defaultValue: "{ger}")')

# Now to replace items safely, we will only replace strings that do not contain interpolation \(
# We can find all literal strings `"[^"\\]*"`
import hashlib

def repl(match):
    val = match.group(1)
    # Don't replace empty strings or very short ones like "+"
    if len(val) < 3 or val in ["+", "-", " : "]: return match.group(0)
    
    # Check if it looks like an item (long text)
    if " " in val and ":" not in val[:15]: # simple heuristic
        h = hashlib.md5(val.encode('utf-8')).hexdigest()[:8]
        return f'String(localized: "assessment.source.item.{h}", defaultValue: "{val}")'
    return match.group(0)

lines = code.split('\n')
in_items = False
for i, line in enumerate(lines):
    if 'items: [' in line:
        in_items = True
    if in_items and '])' in line:
        in_items = False
        
    if in_items:
        # replace strings that don't have \( in them
        # simple regex for purely alphanumeric+space strings inside quotes
        # actually, let's just do it manually for the items since there's string interpolation.
        pass

with open("Garten_Simulation/Models/AssessmentResult+Detailed.swift", "w") as f:
    f.write(code)
