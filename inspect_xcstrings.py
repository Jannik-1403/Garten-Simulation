import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

keys_to_inspect = [
    "garden.habits.active",
    "routine.session.ready.subtitle",
    "weed_popup_body",
    "weed.detail.beschreibung",
    "assessment.lifestyle.profile.mitlaeufer.desc",
    "assessment.finance.profile.impulsiver.desc",
    "assessment.lifestyle.profile.chaot.desc",
    "assessment.finance.profile.kontrolleur.break"
]

for key in keys_to_inspect:
    if key in data["strings"]:
        print(f"\n--- {key} ---")
        print(json.dumps(data["strings"][key], indent=2, ensure_ascii=False))
    else:
        print(f"\nKey not found: {key}")
