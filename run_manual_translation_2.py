# -*- coding: utf-8 -*-
import json

translations = {
    "cleaning.add.name": {
        "de": "Aufgabe", "en": "Task", "es": "Tarea", "fr": "Tâche", "hi": "कार्य", "it": "Compito", "ja": "タスク", "ko": "작업", "nl": "Taak", "pl": "Zadanie", "pt": "Tarefa", "pt-BR": "Tarefa", "ru": "Задача", "tr": "Görev", "zh-Hans": "任务", "zh-Hant": "任務"
    },
    "cleaning.add.placeholder": {
        "de": "z.B. Küche putzen", "en": "e.g. Clean kitchen", "es": "ej. Limpiar cocina", "fr": "ex. Nettoyer la cuisine", "hi": "उदा. रसोई साफ करें", "it": "es. Pulire la cucina", "ja": "例：キッチンを掃除する", "ko": "예: 주방 청소", "nl": "bijv. Keuken schoonmaken", "pl": "np. Posprzątaj kuchnię", "pt": "ex. Limpar cozinha", "pt-BR": "ex. Limpar cozinha", "ru": "напр. Убрать кухню", "tr": "örn. Mutfağı temizle", "zh-Hans": "例如：打扫厨房", "zh-Hant": "例如：打掃廚房"
    },
    "cleaning.add.icon": {
        "de": "Icon", "en": "Icon", "es": "Icono", "fr": "Icône", "hi": "आइकन", "it": "Icona", "ja": "アイコン", "ko": "아이콘", "nl": "Icoon", "pl": "Ikona", "pt": "Ícone", "pt-BR": "Ícone", "ru": "Иконка", "tr": "Simge", "zh-Hans": "图标", "zh-Hant": "圖示"
    },
    "cleaning.add.color": {
        "de": "Farbe", "en": "Color", "es": "Color", "fr": "Couleur", "hi": "रंग", "it": "Colore", "ja": "色", "ko": "색상", "nl": "Kleur", "pl": "Kolor", "pt": "Cor", "pt-BR": "Cor", "ru": "Цвет", "tr": "Renk", "zh-Hans": "颜色", "zh-Hant": "顏色"
    },
    "cleaning.add.interval": {
        "de": "Intervall", "en": "Interval", "es": "Intervalo", "fr": "Intervalle", "hi": "अंतराल", "it": "Intervallo", "ja": "間隔", "ko": "간격", "nl": "Interval", "pl": "Interwał", "pt": "Intervalo", "pt-BR": "Intervalo", "ru": "Интервал", "tr": "Aralık", "zh-Hans": "间隔", "zh-Hant": "間隔"
    },
    "cleaning.add.day.singular": {
        "de": "Tag", "en": "Day", "es": "Día", "fr": "Jour", "hi": "दिन", "it": "Giorno", "ja": "日", "ko": "일", "nl": "Dag", "pl": "Dzień", "pt": "Dia", "pt-BR": "Dia", "ru": "День", "tr": "Gün", "zh-Hans": "天", "zh-Hant": "天"
    },
    "cleaning.add.days": {
        "de": "Tage", "en": "Days", "es": "Días", "fr": "Jours", "hi": "दिन", "it": "Giorni", "ja": "日", "ko": "일", "nl": "Dagen", "pl": "Dni", "pt": "Dias", "pt-BR": "Dias", "ru": "Дни", "tr": "Gün", "zh-Hans": "天", "zh-Hant": "天"
    },
    "cleaning.add.firstDue": {
        "de": "Startdatum", "en": "Start date", "es": "Fecha de inicio", "fr": "Date de début", "hi": "आरंभ तिथि", "it": "Data di inizio", "ja": "開始日", "ko": "시작일", "nl": "Startdatum", "pl": "Data rozpoczęcia", "pt": "Data de início", "pt-BR": "Data de início", "ru": "Дата начала", "tr": "Başlangıç tarihi", "zh-Hans": "开始日期", "zh-Hant": "開始日期"
    },
    "cleaning.add.title.short": {
        "de": "Neue Aufgabe", "en": "New task", "es": "Nueva tarea", "fr": "Nouvelle tâche", "hi": "नया कार्य", "it": "Nuovo compito", "ja": "新しいタスク", "ko": "새 작업", "nl": "Nieuwe taak", "pl": "Nowe zadanie", "pt": "Nova tarefa", "pt-BR": "Nova tarefa", "ru": "Новая задача", "tr": "Yeni görev", "zh-Hans": "新任务", "zh-Hant": "新任務"
    },
    "cleaning.edit.title": {
        "de": "Aufgabe bearbeiten", "en": "Edit task", "es": "Editar tarea", "fr": "Modifier la tâche", "hi": "कार्य संपादित करें", "it": "Modifica compito", "ja": "タスクを編集", "ko": "작업 편집", "nl": "Taak bewerken", "pl": "Edytuj zadanie", "pt": "Editar tarefa", "pt-BR": "Editar tarefa", "ru": "Редактировать задачу", "tr": "Görevi düzenle", "zh-Hans": "编辑任务", "zh-Hant": "編輯任務"
    },
    "common.cancel": {
        "de": "Abbrechen", "en": "Cancel", "es": "Cancelar", "fr": "Annuler", "hi": "रद्द करें", "it": "Annulla", "ja": "キャンセル", "ko": "취소", "nl": "Annuleren", "pl": "Anuluj", "pt": "Cancelar", "pt-BR": "Cancelar", "ru": "Отмена", "tr": "İptal", "zh-Hans": "取消", "zh-Hant": "取消"
    },
    "common.save": {
        "de": "Speichern", "en": "Save", "es": "Guardar", "fr": "Enregistrer", "hi": "सहेजें", "it": "Salva", "ja": "保存", "ko": "저장", "nl": "Opslaan", "pl": "Zapisz", "pt": "Salvar", "pt-BR": "Salvar", "ru": "Сохранить", "tr": "Kaydet", "zh-Hans": "保存", "zh-Hant": "保存"
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

print("Done translating editor strings!")
