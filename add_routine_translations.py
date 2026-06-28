import json
import os

catalog_path = "Garten_Simulation/Localizable.xcstrings"

with open(catalog_path, 'r', encoding='utf-8') as f:
    catalog = json.load(f)

new_keys = {
    "Zeit für Routine: %@": {
        "de": "Zeit für Routine: %@",
        "en": "Time for routine: %@",
        "es": "Tiempo de rutina: %@",
        "fr": "Temps pour la routine : %@",
        "it": "Tempo per la routine: %@",
        "pt": "Hora da rotina: %@",
        "ja": "ルーチンの時間です: %@",
        "ko": "루틴 시간: %@",
        "pl": "Czas na rutynę: %@",
        "nl": "Tijd voor routine: %@",
        "tr": "Rutin zamanı: %@"
    },
    "Starte jetzt deine Routine und verdiene Fokus-Punkte!": {
        "de": "Starte jetzt deine Routine und verdiene Fokus-Punkte!",
        "en": "Start your routine now and earn focus points!",
        "es": "¡Comienza tu rutina ahora y gana puntos de enfoque!",
        "fr": "Commencez votre routine maintenant et gagnez des points de concentration !",
        "it": "Inizia la tua routine ora e guadagna punti focus!",
        "pt": "Começa a tua rotina agora e ganha pontos de foco!",
        "ja": "今すぐルーチンを始めて、フォーカスポイントを獲得しましょう！",
        "ko": "지금 루틴을 시작하고 포커스 포인트를 획득하세요!",
        "pl": "Rozpocznij rutynę teraz i zdobywaj punkty skupienia!",
        "nl": "Start nu je routine en verdien focuspunten!",
        "tr": "Rutininize şimdi başlayın ve odak puanları kazanın!"
    }
}

if "strings" not in catalog:
    catalog["strings"] = {}

for key, translations in new_keys.items():
    if key not in catalog["strings"]:
        catalog["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, text in translations.items():
        if lang not in catalog["strings"][key]["localizations"]:
            catalog["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": text
                }
            }
        else:
            catalog["strings"][key]["localizations"][lang]["stringUnit"]["value"] = text
            catalog["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"

with open(catalog_path, 'w', encoding='utf-8') as f:
    json.dump(catalog, f, indent=2, ensure_ascii=False)

print("Translation update completed!")
