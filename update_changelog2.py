import os
from datetime import datetime

file_path = "CHANGELOG.md"
entry = f"""
## [{datetime.now().strftime('%Y-%m-%d')}] - Onboarding Animation Refinement
- Update: In der `GrovyIntroView` wurde das Bar-Chart durch eine animierte exponentielle Wachstumskurve mit einem Pfeil ersetzt. Die Kurve fliegt am Ende dynamisch nach oben aus dem Bild.
- Hinzugefügt: Subtile schwebende Partikel (Plus-Zeichen und Kreise) wurden als Hintergrundanimation zur Szene hinzugefügt, um sie lebendiger zu machen.
"""

content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

with open(file_path, "w") as f:
    f.write(entry + "\n" + content)
