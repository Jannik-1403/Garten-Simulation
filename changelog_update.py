import os
from datetime import datetime
file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

new_entry = "## " + datetime.now().strftime("%Y-%m-%d %H:%M:%S") + " - Brustumfang & Info-Texte\n- Neuer Körperumfang 'Brustumfang' hinzugefügt.\n- Info-Texte (i-Icon) mit genauen Messanleitungen für alle Körperumfänge eingebaut.\n- Alle neuen Strings zu 100% lokalisiert (inklusive Fallback).\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
