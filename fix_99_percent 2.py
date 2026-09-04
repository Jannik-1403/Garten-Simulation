import json

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

languages = ["en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]
strings = data.get("strings", {})

def update_key(key, default_val):
    if key not in strings:
        strings[key] = {}
    if "localizations" not in strings[key]:
        strings[key]["localizations"] = {}
    
    for lang in languages:
        strings[key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": default_val
            }
        }

update_key("", "")
update_key(" ", " ")
update_key("%lld / %lld %@", "%lld / %lld %@")
update_key("calories_unknown_placeholder", "??? kcal")

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated 4 keys to 100% translated.")
