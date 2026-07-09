import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    "common.success": {
        "de": "Erfolgreich!",
        "en": "Success!",
        "es": "¡Éxito!",
        "fr": "Succès !",
        "it": "Successo!",
        "ja": "成功しました！",
        "ko": "성공!",
        "nl": "Succes!",
        "pl": "Sukces!",
        "pt": "Sucesso!",
        "tr": "Başarılı!"
    },
    "screenTime.suggestions.added": {
        "de": "Die Webseite %@ wurde hinzugefügt und ist ab sofort blockiert.",
        "en": "The website %@ has been added and is now blocked.",
        "es": "El sitio web %@ se ha añadido y ahora está bloqueado.",
        "fr": "Le site %@ a été ajouté et est désormais bloqué.",
        "it": "Il sito web %@ è stato aggiunto ed è ora bloccato.",
        "ja": "ウェブサイト %@ が追加され、ブロックされました。",
        "ko": "웹사이트 %@ 이(가) 추가되어 이제 차단되었습니다.",
        "nl": "De website %@ is toegevoegd en is nu geblokkeerd.",
        "pl": "Witryna %@ została dodana i jest teraz zablokowana.",
        "pt": "O site %@ foi adicionado e agora está bloqueado.",
        "tr": "%@ web sitesi eklendi ve artık engellendi."
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

print("Strings updated successfully.")
