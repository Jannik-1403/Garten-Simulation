import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

targets = [
    "Always Blocked",
    "These apps and websites are always blocked and can only be unlocked via Emergency Unlock.",
    "Pro Gardener Benefits",
    "Discover which days you are most productive.",
    "Track your progress with interactive graphs.",
    "Optimize your workflow based on your data.",
    "Access to all scientifically backed sounds.",
    "Get your brain into the flow state faster.",
    "Effectively block out distracting background noise.",
    "Unlock rare decorations much faster.",
    "Du hast diese Woche keine Fokus-Sessions genutzt. Baue feste Fokus-Zeiten in deinen Alltag ein. Reserviere dir jeden Tag zur selben Uhrzeit (z.B. direkt nach dem Frühstück) 25 Minuten, um eine Routine zu entwickeln.",
    "Min",
    "GESAMT",
    "mal",
    "Kaffee und Spanisch?"
]

found = {}
for k, v in data.get('strings', {}).items():
    if k in targets:
        found[k] = k
    
    # Also check if it's the default value in english or german
    for lang, loc in v.get('localizations', {}).items():
        val = loc.get('stringUnit', {}).get('value')
        if val in targets:
            found[val] = k

print("Found keys:")
for t in targets:
    print(f"Target: {t[:30]}... -> Key: {found.get(t)}")
