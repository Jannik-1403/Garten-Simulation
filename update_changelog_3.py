import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - App Group Entitlements & Widget Reload Fix\n"
new_entry += "- Die Main-App ('Garten_Simulation.entitlements') enthielt nicht die 'com.apple.security.application-groups' Entitlement. Dadurch konnten geschriebene UserDefaults-Werte der App-Group nicht vom Widget gelesen werden. Dies wurde behoben!\n"
new_entry += "- Das Widget wird nun automatisch neugeladen (`WidgetCenter.shared.reloadAllTimelines()`), sobald sich der Pro-Status in der Main-App ändert oder beim Start synchronisiert wird.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
