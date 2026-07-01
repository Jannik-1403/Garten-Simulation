import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "custom.tracker.create": {
        "de": "Tracker erstellen", "en": "Create Tracker", "ko": "트래커 만들기", "ja": "トラッカーを作成",
        "es": "Crear rastreador", "fr": "Créer un traqueur", "it": "Crea tracker",
        "pt": "Criar rastreador", "pl": "Utwórz tracker", "nl": "Tracker maken", "tr": "İzleyici Oluştur"
    },
    "custom.tracker.progress": {
        "de": "Fortschritt heute", "en": "Today's Progress", "ko": "오늘의 진행 상황", "ja": "今日の進捗",
        "es": "Progreso de hoy", "fr": "Progression du jour", "it": "Progressi di oggi",
        "pt": "Progresso de hoje", "pl": "Dzisiejszy postęp", "nl": "Voortgang van vandaag", "tr": "Bugünün İlerlemesi"
    },
    "apple.health.progress": {
        "de": "Fortschritt heute", "en": "Today's Progress", "ko": "오늘의 진행률", "ja": "今日の進捗",
        "es": "Progreso de hoy", "fr": "Progression du jour", "it": "Progressi di oggi",
        "pt": "Progresso de hoje", "pl": "Dzisiejszy postęp", "nl": "Voortgang van vandaag", "tr": "Bugünün İlerlemesi"
    },
    "apple.health.target": {
        "de": "Tagesziel", "en": "Daily Target", "ko": "일일 목표", "ja": "1日の目標",
        "es": "Objetivo diario", "fr": "Objectif quotidien", "it": "Obiettivo quotidiano",
        "pt": "Meta diária", "pl": "Cel dzienny", "nl": "Dagelijks doel", "tr": "Günlük Hedef"
    },
    "apple.health.unit.steps": {
        "de": "Schritte", "en": "Steps", "ko": "걸음", "ja": "歩",
        "es": "Pasos", "fr": "Pas", "it": "Passi",
        "pt": "Passos", "pl": "Kroki", "nl": "Stappen", "tr": "Adımlar"
    },
    "apple.health.unit.water": {
        "de": "ml", "en": "ml", "ko": "ml", "ja": "ml",
        "es": "ml", "fr": "ml", "it": "ml",
        "pt": "ml", "pl": "ml", "nl": "ml", "tr": "ml"
    },
    "apple.health.unit.sleep": {
        "de": "h", "en": "h", "ko": "시간", "ja": "時間",
        "es": "h", "fr": "h", "it": "h",
        "pt": "h", "pl": "godz.", "nl": "u", "tr": "sa"
    },
    "apple.health.unit.mindfulness": {
        "de": "min", "en": "min", "ko": "분", "ja": "分",
        "es": "min", "fr": "min", "it": "min",
        "pt": "min", "pl": "min", "nl": "min", "tr": "dk"
    },
    "apple.health.unit.running": {
        "de": "min", "en": "min", "ko": "분", "ja": "分",
        "es": "min", "fr": "min", "it": "min",
        "pt": "min", "pl": "min", "nl": "min", "tr": "dk"
    },
    "apple.health.unit.strengthTraining": {
        "de": "min", "en": "min", "ko": "분", "ja": "分",
        "es": "min", "fr": "min", "it": "min",
        "pt": "min", "pl": "min", "nl": "min", "tr": "dk"
    },
    "apple.health.pro_locked": {
        "de": "Grovy Pro Feature", "en": "Grovy Pro Feature", "ko": "Grovy Pro 기능", "ja": "Grovy Pro機能",
        "es": "Función Grovy Pro", "fr": "Fonctionnalité Grovy Pro", "it": "Funzionalità Grovy Pro",
        "pt": "Recurso Grovy Pro", "pl": "Funkcja Grovy Pro", "nl": "Grovy Pro-functie", "tr": "Grovy Pro Özelliği"
    },
    "plant.detail.notes_header": {
        "de": "Notizen", "en": "Notes", "ko": "메모", "ja": "メモ",
        "es": "Notas", "fr": "Notes", "it": "Appunti",
        "pt": "Notas", "pl": "Notatki", "nl": "Opmerkingen", "tr": "Notlar"
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
