import os
from datetime import datetime

file_path = "CHANGELOG.md"
content = ""
if os.path.exists(file_path):
    with open(file_path, "r") as f:
        content = f.read()

date_str = datetime.now().strftime("%Y-%m-%d")
new_entry = f"## [{date_str}] - Coin Page Badges Translation Fix\n"
new_entry += "- Die noch auf Englisch hartcodierten Shop-Badges ('Popular' und 'Best Value') auf der Coin-Seite wurden in den Localizable.xcstrings auf Chinesisch ('熱門', '超值') übersetzt.\n"

with open(file_path, "w") as f:
    f.write(new_entry + content)
