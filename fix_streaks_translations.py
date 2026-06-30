import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    data = json.load(f)

keys_to_add = {
    "stats.max_streak": {"de": "Höchster Streak (Tage): %lld", "en": "Highest Streak (Days): %lld", "es": "Racha Más Alta (Días): %lld", "fr": "Plus longue série (Jours) : %lld", "it": "Serie più lunga (Giorni): %lld", "ja": "最高ストリーク (日数): %lld", "ko": "최고 스트릭 (일): %lld", "nl": "Hoogste Streak (Dagen): %lld", "pl": "Najwyższa seria (dni): %lld", "pt": "Maior Sequência (Dias): %lld", "tr": "En Yüksek Seri (Gün): %lld"},
    "stats.current_streak": {"de": "Aktueller Streak: %lld", "en": "Current Streak: %lld", "es": "Racha Actual: %lld", "fr": "Série actuelle : %lld", "it": "Serie attuale: %lld", "ja": "現在のストリーク: %lld", "ko": "현재 스트릭: %lld", "nl": "Huidige Streak: %lld", "pl": "Obecna seria: %lld", "pt": "Sequência Atual: %lld", "tr": "Mevcut Seri: %lld"},
    "stats.completed_challenges": {"de": "Abgeschlossene 90-Tage Challenges: %lld", "en": "Completed 90-Day Challenges: %lld", "es": "Retos de 90 días completados: %lld", "fr": "Défis de 90 jours terminés : %lld", "it": "Sfide di 90 giorni completate: %lld", "ja": "完了した90日間チャレンジ: %lld", "ko": "완료된 90일 챌린지: %lld", "nl": "Voltooide 90-dagen challenges: %lld", "pl": "Ukończone 90-dniowe wyzwania: %lld", "pt": "Desafios de 90 Dias Concluídos: %lld", "tr": "Tamamlanan 90 Günlük Zorluklar: %lld"},
    "export.bad_habits.title": {"de": "Schlechte Gewohnheiten & Rückfälle", "en": "Bad Habits & Relapses", "es": "Malos Hábitos y Recaídas", "fr": "Mauvaises Habitudes & Rechutes", "it": "Cattive Abitudini e Ricadute", "ja": "悪い習慣と再発", "ko": "나쁜 습관 & 재발", "nl": "Slechte Gewoonten & Terugvallen", "pl": "Złe Nawyki i Nawroty", "pt": "Maus Hábitos e Recaídas", "tr": "Kötü Alışkanlıklar & Nüksetmeler"},
    "export.bad_habits.max_streak": {"de": "Längster Streak ohne Rückfall: %lld Tage", "en": "Longest Streak Without Relapse: %lld Days", "es": "Racha más larga sin recaer: %lld días", "fr": "Plus longue série sans rechute : %lld jours", "it": "Serie più lunga senza ricadute: %lld giorni", "ja": "再発なしの最長ストリーク: %lld日", "ko": "재발 없는 최장 스트릭: %lld일", "nl": "Langste streak zonder terugval: %lld dagen", "pl": "Najdłuższa seria bez nawrotu: %lld dni", "pt": "Maior Sequência Sem Recaída: %lld Dias", "tr": "Nüksetmeden En Uzun Seri: %lld Gün"},
    "export.bad_habits.triggers": {"de": "  Auslöser: %@", "en": "  Triggers: %@", "es": "  Desencadenantes: %@", "fr": "  Déclencheurs : %@", "it": "  Trigger: %@", "ja": "  トリガー: %@", "ko": "  트리거: %@", "nl": "  Triggers: %@", "pl": "  Wyzwalacze: %@", "pt": "  Gatilhos: %@", "tr": "  Tetikleyiciler: %@"}
}

for key, langs in keys_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, trans in langs.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {}
        data["strings"][key]["localizations"][lang]["stringUnit"] = {
            "state": "translated",
            "value": trans
        }

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
