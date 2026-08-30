import sys
from datetime import datetime

file_path = "CHANGELOG.md"
with open(file_path, "r") as f:
    content = f.read()

today = datetime.now().strftime("%Y-%m-%d")

new_entry = f"## [{today}] - App Tour Routing & Localization Texts\n"
new_entry += "- **App Tour Routing:** Fixed a bug where restarting the App Tour from the Developer Menu would keep the user on the Profile tab instead of switching to the Habits tab.\n"
new_entry += "- **Localization:** Updated the descriptions for the 'Schlechte Gewohnheiten' and 'Shop & Power-Ups' tour steps. Ensured 100% translation coverage across all 15 languages.\n\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
