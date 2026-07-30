# -*- coding: utf-8 -*-
import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "goal.edit.pointsLabel": {"de": "Pkt.", "en": "pts.", "es": "pts.", "fr": "pts", "it": "pti.", "pt": "pts.", "nl": "ptn.", "pl": "pkt.", "ru": "очк.", "tr": "puan", "ja": "pt", "ko": "pt", "zh-Hans": "分", "zh-Hant": "分", "hi": "अंक"},
    "goal.edit.targetLabel": {"de": "Ziel:", "en": "Target:", "es": "Objetivo:", "fr": "Objectif :", "it": "Obiettivo:", "pt": "Alvo:", "nl": "Doel:", "pl": "Cel:", "ru": "Цель:", "tr": "Hedef:", "ja": "目標:", "ko": "목표:", "zh-Hans": "目标:", "zh-Hant": "目標:", "hi": "लक्ष्य:"},
    "goal.link.title": {"de": "Ziel-Beitrag", "en": "Goal Contribution", "es": "Contribución al objetivo", "fr": "Contribution à l'objectif", "it": "Contributo all'obiettivo", "pt": "Contribuição para o objetivo", "nl": "Doelbijdrage", "pl": "Wkład w cel", "ru": "Вклад в цель", "tr": "Hedef Katkısı", "ja": "目標への貢献", "ko": "목표 기여", "zh-Hans": "目标贡献", "zh-Hant": "目標貢獻", "hi": "लक्ष्य योगदान"},
    "todos.tab.select_plant": {"de": "Für welche Gewohnheit?", "en": "For which habit?", "es": "¿Para qué hábito?", "fr": "Pour quelle habitude ?", "it": "Per quale abitudine?", "pt": "Para qual hábito?", "nl": "Voor welke gewoonte?", "pl": "Dla którego nawyku?", "ru": "Для какой привычки?", "tr": "Hangi alışkanlık için?", "ja": "どの習慣のため？", "ko": "어떤 습관을 위해?", "zh-Hans": "为了哪个习惯？", "zh-Hant": "為了哪個習慣？", "hi": "किस आदत के लिए?"},
    "todos.tab.empty": {"de": "Keine offenen To-Dos.", "en": "No open To-Dos.", "es": "No hay tareas pendientes.", "fr": "Aucune tâche ouverte.", "it": "Nessuna attività aperta.", "pt": "Sem tarefas pendentes.", "nl": "Geen openstaande To-Do's.", "pl": "Brak otwartych zadań.", "ru": "Нет открытых задач.", "tr": "Açık Görev Yok.", "ja": "オープンなタスクはありません。", "ko": "열린 할 일이 없습니다.", "zh-Hans": "没有未完成的任务。", "zh-Hant": "沒有未完成的任務。", "hi": "कोई खुला कार्य नहीं।"},
    "goal.edit.title": {"de": "Ziel bearbeiten", "en": "Edit Goal", "es": "Editar objetivo", "fr": "Modifier l'objectif", "it": "Modifica obiettivo", "pt": "Editar objetivo", "nl": "Doel bewerken", "pl": "Edytuj cel", "ru": "Редактировать цель", "tr": "Hedefi Düzenle", "ja": "目標を編集", "ko": "목표 편집", "zh-Hans": "编辑目标", "zh-Hant": "編輯目標", "hi": "लक्ष्य संपादित करें"},
    "goal.frequency.label": {"de": "Häufigkeit pro Woche:", "en": "Frequency per week:", "es": "Frecuencia por semana:", "fr": "Fréquence par semaine :", "it": "Frequenza a settimana:", "pt": "Frequência por semana:", "nl": "Frequentie per week:", "pl": "Częstotliwość w tygodniu:", "ru": "Частота в неделю:", "tr": "Haftalık Sıklık:", "ja": "週の頻度:", "ko": "주당 빈도:", "zh-Hans": "每周频率:", "zh-Hant": "每週頻率:", "hi": "प्रति सप्ताह आवृत्ति:"}
}

existing_langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'de', 'zh-Hant']

for key, lang_dict in translations.items():
    if key not in data['strings']:
        data['strings'][key] = {"extractionState": "manual", "localizations": {}}
        
    for lang in existing_langs:
        val = lang_dict.get(lang) or lang_dict.get('en')
        
        if 'localizations' not in data['strings'][key]:
            data['strings'][key]['localizations'] = {}
            
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected accurate localizations successfully!")
