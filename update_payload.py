import re

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/ShopDetailPayload.swift', 'r') as f:
    content = f.read()

content = re.sub(r'\s*let habitTitleKey: String\?', '', content)
content = re.sub(r'\s*let habitDescriptionKey: String\?', '', content)
content = re.sub(r',\s*habitTitleKey: String\? = nil', '', content)
content = re.sub(r',\s*habitDescriptionKey: String\? = nil', '', content)
content = re.sub(r'\s*self\.habitTitleKey = habitTitleKey', '', content)
content = re.sub(r'\s*self\.habitDescriptionKey = habitDescriptionKey', '', content)
content = re.sub(r',\s*habitTitleKey: decoration\.habitNameKey', '', content)
content = re.sub(r',\s*habitDescriptionKey: decoration\.habitDescriptionKey', '', content)

with open('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/ShopDetailPayload.swift', 'w') as f:
    f.write(content)

