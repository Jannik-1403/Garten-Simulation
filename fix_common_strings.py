import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "common.delete": {
        "de": "Löschen", "en": "Delete", "ko": "삭제", "ja": "削除", "es": "Eliminar",
        "fr": "Supprimer", "it": "Elimina", "pt": "Excluir", "pl": "Usuń", "nl": "Verwijderen", "tr": "Sil"
    },
    "common.save": {
        "de": "Speichern", "en": "Save", "ko": "저장", "ja": "保存", "es": "Guardar",
        "fr": "Enregistrer", "it": "Salva", "pt": "Salvar", "pl": "Zapisz", "nl": "Opslaan", "tr": "Kaydet"
    }
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, val in lang_dict.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
