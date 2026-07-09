import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    "screenTime.emergency.unlock": {
        "de": "Notfall-Entsperrung",
        "en": "Emergency Unlock",
        "es": "Desbloqueo de emergencia",
        "fr": "Déverrouillage d'urgence",
        "it": "Sblocco di emergenza",
        "ja": "緊急ロック解除",
        "ko": "긴급 잠금 해제",
        "nl": "Noodontgrendeling",
        "pl": "Odblokowanie awaryjne",
        "pt": "Desbloqueio de emergência",
        "tr": "Acil Kilit Açma"
    }
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        val = lang_dict.get(lang, lang_dict["en"])
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
            
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Emergency string updated successfully.")
