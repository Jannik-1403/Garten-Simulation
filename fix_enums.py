import re

file_path = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix StatDetail enum
content = re.sub(r'(case activity, balance, xp, coins, milestones[^\n]*)', r'\1, focus, triggers', content)

# Fix ShareCardType enum
# The original might be:
#         case coins
#         case focus
# or without focus. Let's find it.
