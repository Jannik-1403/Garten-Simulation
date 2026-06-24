import re

file_path = "Garten_Simulation/Views/Profile/ProfilComponents.swift"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Extract triggersContent
triggers_content_pattern = r'    private var triggersContent: some View \{\n        let calendar = Calendar\.current(?:.|\n)*?                \}\n            \}\n        \}\n    \}\n'
match = re.search(triggers_content_pattern, content)
if match:
    extracted = match.group(0)
    # Remove from current location
    content = content.replace(extracted, "")
    
    # Insert at the end of StatDetailFullscreenView
    # Let's find the closing brace of StatDetailFullscreenView.
    # The end of StatDetailFullscreenView has `private func getBarHeight` and some other methods.
    # It might be easier to inject before `    private func initiateShare() {` inside StatDetailFullscreenView.
    initiate_share_str = "    private func initiateShare() {\n        switch detail {"
    if initiate_share_str in content:
        content = content.replace(initiate_share_str, extracted + "\n" + initiate_share_str)
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Fixed scope!")
else:
    print("Could not find triggersContent to move!")
