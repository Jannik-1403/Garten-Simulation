import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - Widget Pro Version Fix\n"
new_entry += "- Die Pro-Version Freischaltung wurde korrigiert, sodass Widgets den Kauf-Status (auch bei älteren Käufen) aus der Main-App erfolgreich über die App-Group ('group.com.jannik.grovy') übernehmen.\n"
new_entry += "- `isProUser_active` wird beim Start der App (`IAPStore`) in den Shared UserDefaults gesichert.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
