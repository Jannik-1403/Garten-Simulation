import json

translations = {
  "tracking.mode.counter.example": {
    "de": "Beispiel: %d von %d %@ → %@ erledigt.",
    "en": "Example: %d of %d %@ → %@ completed.",
    "es": "Ejemplo: %d de %d %@ → %@ completado.",
    "fr": "Exemple : %d sur %d %@ → %@ terminé.",
    "hi": "उदाहरण: %d में से %d %@ → %@ पूर्ण।",
    "it": "Esempio: %d di %d %@ → %@ completato.",
    "ja": "例: %2$d 中 %1$d 回の %3$@ → %4$@ 完了。",
    "ko": "예시: %2$d 중 %1$d회 %3$@ → %4$@ 완료.",
    "nl": "Voorbeeld: %d van de %d %@ → %@ voltooid.",
    "pl": "Przykład: %d z %d %@ → %@ ukończono.",
    "pt": "Exemplo: %d de %d %@ → %@ concluído.",
    "pt-BR": "Exemplo: %d de %d %@ → %@ concluído.",
    "ru": "Пример: %d из %d %@ → %@ выполнено.",
    "tr": "Örnek: %2$d %@'den %1$d'si → %4$@ tamamlandı.",
    "zh-Hans": "示例：%2$d 个 %3$@ 中的 %1$d 个 → 已完成 %4$@。",
    "zh-Hant": "範例：%2$d 個 %3$@ 中的 %1$d 個 → 已完成 %4$@。"
  }
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

for key, trans_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "extracted_with_value", "localizations": {}}
    
    for lang, text in trans_dict.items():
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
