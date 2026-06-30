import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r") as f:
    data = json.load(f)

new_strings = {
    "character.category.body": {
        "de": "Körper", "en": "Body", "es": "Cuerpo", "fr": "Corps",
        "it": "Corpo", "pt": "Corpo", "ja": "体", "ko": "신체",
        "pl": "Ciało", "nl": "Lichaam", "tr": "Vücut"
    },
    "character.category.hair": {
        "de": "Haare", "en": "Hair", "es": "Pelo", "fr": "Cheveux",
        "it": "Capelli", "pt": "Cabelo", "ja": "髪", "ko": "머리카락",
        "pl": "Włosy", "nl": "Haar", "tr": "Saç"
    },
    "character.category.eyes": {
        "de": "Augen", "en": "Eyes", "es": "Ojos", "fr": "Yeux",
        "it": "Occhi", "pt": "Olhos", "ja": "目", "ko": "눈",
        "pl": "Oczy", "nl": "Ogen", "tr": "Gözler"
    },
    "character.category.mouth": {
        "de": "Mund", "en": "Mouth", "es": "Boca", "fr": "Bouche",
        "it": "Bocca", "pt": "Boca", "ja": "口", "ko": "입",
        "pl": "Usta", "nl": "Mond", "tr": "Ağız"
    },
    "character.category.background": {
        "de": "Hintergrund", "en": "Background", "es": "Fondo", "fr": "Fond",
        "it": "Sfondo", "pt": "Fundo", "ja": "背景", "ko": "배경",
        "pl": "Tło", "nl": "Achtergrond", "tr": "Arka Plan"
    },
    "character.category.extras": {
        "de": "Extras", "en": "Extras", "es": "Extras", "fr": "Extras",
        "it": "Extra", "pt": "Extras", "ja": "エクストラ", "ko": "기타",
        "pl": "Dodatki", "nl": "Extra's", "tr": "Ekstralar"
    }
}

for key, langs in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, text in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings added successfully!")
