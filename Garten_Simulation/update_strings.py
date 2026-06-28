import json
import os

file_path = "Localizable.xcstrings"

with open(file_path, "r") as f:
    data = json.load(f)

new_strings = {
    "routine.session.ready.subtitle": {
        "de": "%lld Gewohnheiten. Bereit?",
        "en": "%lld habits. Ready?",
        "es": "%lld hábitos. ¿Listo?",
        "fr": "%lld habitudes. Prêt ?",
        "it": "%lld abitudini. Pronto?",
        "pt": "%lld hábitos. Pronto?",
        "ja": "%lldの習慣。準備はいいですか？",
        "ko": "%lld개의 습관. 준비되셨나요?",
        "pl": "%lld nawyków. Gotowy?",
        "nl": "%lld gewoontes. Klaar?",
        "tr": "%lld alışkanlık. Hazır mısın?"
    },
    "routine.session.progress": {
        "de": "Schritt %lld von %lld",
        "en": "Step %lld of %lld",
        "es": "Paso %lld de %lld",
        "fr": "Étape %lld sur %lld",
        "it": "Passo %lld di %lld",
        "pt": "Passo %lld de %lld",
        "ja": "ステップ %lld / %lld",
        "ko": "%lld / %lld 단계",
        "pl": "Krok %lld z %lld",
        "nl": "Stap %lld van %lld",
        "tr": "Adım %lld / %lld"
    },
    "routine.success.subtitle": {
        "de": "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!",
        "en": "You were extremely focused for %lld minutes. The XP will be split among all your plants!",
        "es": "Estuviste extremadamente concentrado durante %lld minutos. ¡La XP se dividirá entre todas tus plantas!",
        "fr": "Vous avez été extrêmement concentré pendant %lld minutes. L'XP sera répartie entre toutes vos plantes !",
        "it": "Sei stato estremamente concentrato per %lld minuti. L'XP sarà divisa tra tutte le tue piante!",
        "pt": "Você esteve extremamente focado por %lld minutos. A XP será dividida entre todas as suas plantas!",
        "ja": "%lld分間、非常に集中していました。XPはすべての植物に分配されます！",
        "ko": "%lld분 동안 매우 집중했습니다. XP는 모든 식물에 분배됩니다!",
        "pl": "Byłeś niezwykle skupiony przez %lld minut. PD zostaną podzielone między wszystkie twoje rośliny!",
        "nl": "Je was extreem gefocust gedurende %lld minuten. De XP wordt verdeeld over al je planten!",
        "tr": "%lld dakika boyunca son derece odaklandınız. XP tüm bitkileriniz arasında paylaştırılacak!"
    }
}

for key, translations in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings updated successfully!")
