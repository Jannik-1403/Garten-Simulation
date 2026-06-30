import json

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error: {e}")
    exit(1)

new_strings = {
    "routine.session.alreadyCompleted": {
        "de": "Bereits erledigt - keine Belohnung",
        "en": "Already completed - no reward",
        "es": "Ya completado - sin recompensa",
        "fr": "Déjà terminé - pas de récompense",
        "it": "Già completato - nessuna ricompensa",
        "pt": "Já concluído - sem recompensa",
        "ja": "すでに完了しています - 報酬はありません",
        "ko": "이미 완료됨 - 보상 없음",
        "pl": "Już zakończone - brak nagrody",
        "nl": "Al voltooid - geen beloning",
        "tr": "Zaten tamamlandı - ödül yok"
    },
    "routine.session.ready.subtitle.singular": {
        "de": "1 Gewohnheit. Bereit?",
        "en": "1 habit. Ready?",
        "es": "1 hábito. ¿Listo?",
        "fr": "1 habitude. Prêt ?",
        "it": "1 abitudine. Pronto?",
        "pt": "1 hábito. Pronto?",
        "ja": "1の習慣。準備はいいですか？",
        "ko": "1개의 습관. 준비되셨나요?",
        "pl": "1 nawyk. Gotowy?",
        "nl": "1 gewoonte. Klaar?",
        "tr": "1 alışkanlık. Hazır mısın?"
    },
    "routine.session.start": {
        "de": "Starten", "en": "Start", "es": "Comenzar", "fr": "Démarrer", "it": "Inizia",
        "pt": "Iniciar", "ja": "開始", "ko": "시작", "pl": "Start", "nl": "Start", "tr": "Başla"
    },
    "routine.session.finish": {
        "de": "Abschließen", "en": "Finish", "es": "Finalizar", "fr": "Terminer", "it": "Fine",
        "pt": "Concluir", "ja": "完了", "ko": "완료", "pl": "Zakończ", "nl": "Voltooien", "tr": "Bitir"
    },
    "routine.session.next": {
        "de": "Nächste", "en": "Next", "es": "Siguiente", "fr": "Suivant", "it": "Prossimo",
        "pt": "Próximo", "ja": "次へ", "ko": "다음", "pl": "Następny", "nl": "Volgende", "tr": "Sonraki"
    },
    "routine.success.title": {
        "de": "Geschafft!", "en": "Done!", "es": "¡Hecho!", "fr": "Terminé !", "it": "Fatto!",
        "pt": "Feito!", "ja": "完了！", "ko": "완료!", "pl": "Zrobione!", "nl": "Klaar!", "tr": "Tamamlandı!"
    },
    "routine.onboarding.title": {
        "de": "Deine Routinen", "en": "Your routines", "es": "Tus rutinas", "fr": "Vos routines",
        "it": "Le tue routine", "pt": "Suas rotinas", "ja": "あなたのルーチン", "ko": "당신의 루틴",
        "pl": "Twoje rutyny", "nl": "Jouw routines", "tr": "Rutinleriniz"
    },
    "routine.onboarding.subtitle": {
        "de": "Wähle deine bevorzugten Routinen aus und füge direkt Gewohnheiten hinzu.",
        "en": "Choose your preferred routines and add habits directly.",
        "es": "Elige tus rutinas preferidas y añade hábitos directamente.",
        "fr": "Choisissez vos routines préférées et ajoutez des habitudes directement.",
        "it": "Scegli le tue routine preferite e aggiungi le abitudini direttamente.",
        "pt": "Escolha suas rotinas preferidas e adicione hábitos diretamente.",
        "ja": "お好みのルーチンを選択し、習慣を直接追加します。",
        "ko": "선호하는 루틴을 선택하고 습관을 직접 추가하세요.",
        "pl": "Wybierz swoje preferowane rutyny i od razu dodaj nawyki.",
        "nl": "Kies je favoriete routines en voeg direct gewoonten toe.",
        "tr": "Tercih ettiğiniz rutinleri seçin ve doğrudan alışkanlıklar ekleyin."
    },
    "routine.habits": {
        "de": "Gewohnheiten", "en": "Habits", "es": "Hábitos", "fr": "Habitudes", "it": "Abitudini",
        "pt": "Hábitos", "ja": "習慣", "ko": "습관", "pl": "Nawyki", "nl": "Gewoonten", "tr": "Alışkanlıklar"
    },
    "routine.custom.default_name": {
        "de": "Neue Routine", "en": "New Routine", "es": "Nueva Rutina", "fr": "Nouvelle Routine",
        "it": "Nuova Routine", "pt": "Nova Rotina", "ja": "新しいルーチン", "ko": "새로운 루틴",
        "pl": "Nowa Rutyna", "nl": "Nieuwe Routine", "tr": "Yeni Rutin"
    },
    "routine.timer": {
        "de": "Timer", "en": "Timer", "es": "Temporizador", "fr": "Minuteur", "it": "Timer",
        "pt": "Temporizador", "ja": "タイマー", "ko": "타이머", "pl": "Timer", "nl": "Timer", "tr": "Zamanlayıcı"
    },
    "routine.reminder.activate": {
        "de": "Erinnerung aktivieren", "en": "Activate reminder", "es": "Activar recordatorio",
        "fr": "Activer le rappel", "it": "Attiva promemoria", "pt": "Ativar lembrete",
        "ja": "リマインダーを有効にする", "ko": "미리 알림 활성화", "pl": "Aktywuj przypomnienie",
        "nl": "Herinnering activeren", "tr": "Hatırlatıcıyı etkinleştir"
    },
    "routine.reminder.only_routine": {
        "de": "Nur Routine", "en": "Only Routine", "es": "Solo Rutina", "fr": "Seulement Routine",
        "it": "Solo Routine", "pt": "Apenas Rotina", "ja": "ルーチンのみ", "ko": "루틴만",
        "pl": "Tylko Rutyna", "nl": "Alleen Routine", "tr": "Sadece Rutin"
    },
    "routine.reminder.pause_individual": {
        "de": "Pausiere individuelle Erinnerungen", "en": "Pause individual reminders",
        "es": "Pausar recordatorios individuales", "fr": "Mettre en pause les rappels individuels",
        "it": "Pausa promemoria individuali", "pt": "Pausar lembretes individuais",
        "ja": "個別リマインダーを一時停止", "ko": "개별 알림 일시 중지",
        "pl": "Wstrzymaj indywidualne przypomnienia", "nl": "Pauzeer individuele herinneringen",
        "tr": "Bireysel hatırlatıcıları duraklat"
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
