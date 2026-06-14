import re

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/InventoryItemDetailSheet.swift', 'r') as f:
    content = f.read()

# 1. Remove isTrash
content = re.sub(r'\s*private var isTrash: Bool \{ item\.id\.hasPrefix\("trash\."\) \}\n', '', content)

# 2. Replace body to just be the content of normalDetailBody
# Wait, let's just make body return normalDetailBody for now to be safe, or just inline it.
body_replacement = """    var body: some View {
        normalDetailBody
    }"""
content = re.sub(r'\s*var body: some View \{[\s\S]*?normalDetailBody\n\s*\}\n\s*\}', '\n' + body_replacement, content)

# 3. Remove trashDetailBody and all its helpers down to normalDetailBody
pattern = r'// MARK: - Trash / Bad Habit Detail.*?// MARK: - Normal \(nicht-Trash\) Detail Body'
content = re.sub(pattern, '// MARK: - Detail Body', content, flags=re.DOTALL)

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Views/InventoryItemDetailSheet.swift', 'w') as f:
    f.write(content)

print("InventoryItemDetailSheet updated.")
