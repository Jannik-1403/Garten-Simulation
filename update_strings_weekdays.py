import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

translations = {
    "screenTime.schedule.summary": {
        "de": "Der Zeitplan ist an den ausgewählten Tagen aktiv.",
        "en": "The schedule is active on the selected days.",
        "es": "El horario está activo en los días seleccionados.",
        "fr": "Le programme est actif les jours sélectionnés.",
        "it": "Il programma è attivo nei giorni selezionati.",
        "ja": "スケジュールは選択された日に有効です。",
        "ko": "선택한 날짜에 일정이 활성화됩니다.",
        "nl": "Het schema is actief op de geselecteerde dagen.",
        "pl": "Harmonogram jest aktywny w wybrane dni.",
        "pt": "O horário está ativo nos dias selecionados.",
        "tr": "Program seçilen günlerde etkindir."
    },
    "screenTime.suggestions.copied.title": {
        "de": "Link kopiert!",
        "en": "Link copied!",
        "es": "¡Enlace copiado!",
        "fr": "Lien copié !",
        "it": "Link copiato!",
        "ja": "リンクをコピーしました！",
        "ko": "링크 복사됨!",
        "nl": "Link gekopieerd!",
        "pl": "Skopiowano link!",
        "pt": "Link copiado!",
        "tr": "Bağlantı kopyalandı!"
    },
    "screenTime.suggestions.copied.desc": {
        "de": "Wir haben %@ für dich in die Zwischenablage kopiert. Tippe auf 'Öffnen', klicke oben ins Suchfeld und wähle 'Einsetzen', um es zu blockieren.",
        "en": "We copied %@ to your clipboard. Tap 'Open', tap the search bar, and select 'Paste' to block it.",
        "es": "Copiamos %@ en el portapapeles. Toca 'Abrir', selecciona la barra de búsqueda y pega para bloquearlo.",
        "fr": "Nous avons copié %@ dans votre presse-papiers. Appuyez sur 'Ouvrir', appuyez sur la barre de recherche et collez pour bloquer.",
        "it": "Abbiamo copiato %@ negli appunti. Tocca 'Apri', tocca la barra di ricerca e incolla per bloccarlo.",
        "ja": "クリップボードに%@をコピーしました。「開く」をタップし、検索バーをタップして「ペースト」を選択し、ブロックしてください。",
        "ko": "클립보드에 %@을(를) 복사했습니다. '열기'를 탭하고 검색 표시줄을 탭한 다음 '붙여넣기'를 선택하여 차단하세요.",
        "nl": "We hebben %@ naar je klembord gekopieerd. Tik op 'Openen', tik op de zoekbalk en plak om het te blokkeren.",
        "pl": "Skopiowaliśmy %@ do schowka. Stuknij 'Otwórz', stuknij pasek wyszukiwania i wybierz 'Wklej', aby zablokować.",
        "pt": "Copiamos %@ para a sua área de transferência. Toque em 'Abrir', toque na barra de pesquisa e cole para bloquear.",
        "tr": "%@ panoya kopyalandı. 'Aç'a dokunun, arama çubuğuna dokunun ve engellemek için yapıştırın."
    },
    "common.open": {
        "de": "Öffnen",
        "en": "Open",
        "es": "Abrir",
        "fr": "Ouvrir",
        "it": "Apri",
        "ja": "開く",
        "ko": "열기",
        "nl": "Open",
        "pl": "Otwórz",
        "pt": "Abrir",
        "tr": "Aç"
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
