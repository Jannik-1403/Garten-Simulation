import json
import os

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

strings_to_add = {
    "widget_routine_empty": {
        "de": "Keine Aufgaben.",
        "en": "No tasks.",
        "es": "Sin tareas.",
        "fr": "Aucune tâche.",
        "it": "Nessun compito.",
        "pt": "Sem tarefas.",
        "ja": "タスクなし。",
        "ko": "할 일 없음.",
        "pl": "Brak zadań.",
        "nl": "Geen taken.",
        "tr": "Görev yok."
    },
    "widget_routine_not_selected": {
        "de": "Routine auswählen (Widget bearbeiten)",
        "en": "Select Routine (Edit Widget)",
        "es": "Seleccionar rutina (Editar widget)",
        "fr": "Sélectionner la routine (Modifier le widget)",
        "it": "Seleziona routine (Modifica widget)",
        "pt": "Selecionar rotina (Editar widget)",
        "ja": "ルーチンを選択（ウィジェットを編集）",
        "ko": "루틴 선택 (위젯 편집)",
        "pl": "Wybierz rutynę (Edytuj widżet)",
        "nl": "Selecteer routine (Widget bewerken)",
        "tr": "Rutin seç (Widget'ı düzenle)"
    },
    "widget_interactive_routine_title": {
        "de": "Routine (Pro)",
        "en": "Routine (Pro)",
        "es": "Rutina (Pro)",
        "fr": "Routine (Pro)",
        "it": "Routine (Pro)",
        "pt": "Rotina (Pro)",
        "ja": "ルーチン (Pro)",
        "ko": "루틴 (Pro)",
        "pl": "Rutyna (Pro)",
        "nl": "Routine (Pro)",
        "tr": "Rutin (Pro)"
    },
    "widget_interactive_routine_desc": {
        "de": "Erledige deine Routinen direkt vom Homescreen.",
        "en": "Complete your routines directly from the homescreen.",
        "es": "Completa tus rutinas directamente desde la pantalla de inicio.",
        "fr": "Terminez vos routines directement depuis l'écran d'accueil.",
        "it": "Completa le tue routine direttamente dalla schermata iniziale.",
        "pt": "Conclua suas rotinas diretamente na tela inicial.",
        "ja": "ホーム画面から直接ルーチンを完了します。",
        "ko": "홈 화면에서 직접 루틴을 완료하세요.",
        "pl": "Ukończ swoje rutyny bezpośrednio z ekranu głównego.",
        "nl": "Voltooi je routines direct vanaf het startscherm.",
        "tr": "Rutinlerinizi doğrudan ana ekrandan tamamlayın."
    }
}

for key, translations in strings_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": translations.get(lang, translations["de"])
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
