import json

with open('./Localizable.xcstrings', 'r') as f:
    data = json.load(f)

strings = data.get('strings', {})

raw_keys_to_remove = [
    "Du hast die App zu lange verlassen. Dein Fokus-Timer wurde abgebrochen.",
    "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!",
    "Fokus-Session starten",
    "Maximale Leben erreicht",
    "Starte jetzt deine Routine und verdiene Fokus-Punkte!",
    "Ultimatives Luxus-Item!",
    "Unterziel hinzufügen..."
]

removed = 0
for k in raw_keys_to_remove:
    if k in strings:
        del strings[k]
        removed += 1
        print(f"Removed: {k}")

with open('./Localizable.xcstrings', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Removed {removed} raw keys.")
