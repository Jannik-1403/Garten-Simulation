import json
import os

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r") as f:
    data = json.load(f)

# 1. Delete pt-BR from localizations
# 2. Delete empty strings and %lld%% keys
keys_to_delete = ["", " ", "  ", "%lld%%"]

for key in keys_to_delete:
    if key in data["strings"]:
        del data["strings"][key]

for key, value in data.get("strings", {}).items():
    if "localizations" in value and "pt-BR" in value["localizations"]:
        del value["localizations"]["pt-BR"]

# 3. Add missing translations for 11 languages
langs = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "tr"]

missing_data = {
    "export.good_habits.title": {
        "de": "Gute Gewohnheiten", "en": "Good Habits", "es": "Buenos Hábitos", "fr": "Bonnes Habitudes",
        "it": "Buone Abitudini", "ja": "良い習慣", "ko": "좋은 습관", "nl": "Goede Gewoontes", "pl": "Dobre Nawyki",
        "pt": "Bons Hábitos", "tr": "İyi Alışkanlıklar"
    },
    "export.no_data": {
        "de": "Keine Daten", "en": "No Data", "es": "Sin Datos", "fr": "Aucune Donnée",
        "it": "Nessun Dato", "ja": "データなし", "ko": "데이터 없음", "nl": "Geen Gegevens", "pl": "Brak Danych",
        "pt": "Sem Dados", "tr": "Veri Yok"
    },
    "export.notes.empty": {
        "de": "Keine Notizen", "en": "No Notes", "es": "Sin Notas", "fr": "Aucune Note",
        "it": "Nessuna Nota", "ja": "メモなし", "ko": "메모 없음", "nl": "Geen Notities", "pl": "Brak Notatek",
        "pt": "Sem Notas", "tr": "Not Yok"
    },
    "export.pdf.date": {
        "de": "Datum: %@", "en": "Date: %@", "es": "Fecha: %@", "fr": "Date : %@",
        "it": "Data: %@", "ja": "日付: %@", "ko": "날짜: %@", "nl": "Datum: %@", "pl": "Data: %@",
        "pt": "Data: %@", "tr": "Tarih: %@"
    },
    "export.pdf.focus.routine_format": {
        "de": "Routine: %@", "en": "Routine: %@", "es": "Rutina: %@", "fr": "Routine : %@",
        "it": "Routine: %@", "ja": "ルーチン: %@", "ko": "루틴: %@", "nl": "Routine: %@", "pl": "Rutyna: %@",
        "pt": "Rotina: %@", "tr": "Rutin: %@"
    },
    "export.pdf.focus.session_format": {
        "de": "%@ Min", "en": "%@ Min", "es": "%@ Min", "fr": "%@ Min",
        "it": "%@ Min", "ja": "%@ 分", "ko": "%@ 분", "nl": "%@ Min", "pl": "%@ Min",
        "pt": "%@ Min", "tr": "%@ Dk"
    },
    "export.pdf.routines.history_format": {
        "de": "Verlauf der letzten %@ Tage", "en": "History of last %@ days", "es": "Historial de los últimos %@ días", "fr": "Historique des %@ derniers jours",
        "it": "Cronologia degli ultimi %@ giorni", "ja": "過去%@日間の履歴", "ko": "최근 %@일 기록", "nl": "Geschiedenis van laatste %@ dagen", "pl": "Historia z ostatnich %@ dni",
        "pt": "Histórico dos últimos %@ dias", "tr": "Son %@ günün geçmişi"
    },
    "export.pdf.title": {
        "de": "Fortschrittsbericht", "en": "Progress Report", "es": "Informe de Progreso", "fr": "Rapport de Progrès",
        "it": "Rapporto sui Progressi", "ja": "進捗レポート", "ko": "진행 보고서", "nl": "Voortgangsrapport", "pl": "Raport z Postępów",
        "pt": "Relatório de Progresso", "tr": "İlerleme Raporu"
    },
    "export.selection.all": {
        "de": "Alle Daten exportieren", "en": "Export All Data", "es": "Exportar Todos los Datos", "fr": "Exporter Toutes les Données",
        "it": "Esporta Tutti i Dati", "ja": "すべてのデータをエクスポート", "ko": "모든 데이터 내보내기", "nl": "Exporteer Alle Gegevens", "pl": "Eksportuj Wszystkie Dane",
        "pt": "Exportar Todos os Dados", "tr": "Tüm Verileri Dışa Aktar"
    },
    "export.selection.custom": {
        "de": "Benutzerdefinierte Auswahl", "en": "Custom Selection", "es": "Selección Personalizada", "fr": "Sélection Personnalisée",
        "it": "Selezione Personalizzata", "ja": "カスタム選択", "ko": "사용자 지정 선택", "nl": "Aangepaste Selectie", "pl": "Niestandardowy Wybór",
        "pt": "Seleção Personalizada", "tr": "Özel Seçim"
    },
    "export.selection.only_this": {
        "de": "Nur diese Pflanze", "en": "Only This Plant", "es": "Solo Esta Planta", "fr": "Uniquement Cette Plante",
        "it": "Solo Questa Pianta", "ja": "この植物のみ", "ko": "이 식물만", "nl": "Alleen Deze Plant", "pl": "Tylko Ta Roślina",
        "pt": "Apenas Esta Planta", "tr": "Sadece Bu Bitki"
    },
    "export.selection.subtitle": {
        "de": "Was möchtest du exportieren?", "en": "What do you want to export?", "es": "¿Qué deseas exportar?", "fr": "Que voulez-vous exporter ?",
        "it": "Cosa vuoi esportare?", "ja": "何をエクスポートしますか？", "ko": "무엇을 내보내시겠습니까?", "nl": "Wat wil je exporteren?", "pl": "Co chcesz wyeksportować?",
        "pt": "O que você deseja exportar?", "tr": "Neyi dışa aktarmak istersiniz?"
    },
    "export.selection.title": {
        "de": "Daten exportieren", "en": "Export Data", "es": "Exportar Datos", "fr": "Exporter les Données",
        "it": "Esporta Dati", "ja": "データエクスポート", "ko": "데이터 내보내기", "nl": "Gegevens Exporteren", "pl": "Eksportuj Dane",
        "pt": "Exportar Dados", "tr": "Verileri Dışa Aktar"
    },
    "export.timer.title": {
        "de": "Fokus-Timer", "en": "Focus Timer", "es": "Temporizador de Enfoque", "fr": "Minuteur de Concentration",
        "it": "Timer di Focus", "ja": "フォーカスタイマー", "ko": "집중 타이머", "nl": "Focustimer", "pl": "Minutnik Skupienia",
        "pt": "Temporizador de Foco", "tr": "Odaklanma Zamanlayıcısı"
    },
    "quiz.finance": {
        "de": "Finanzen", "en": "Finance", "es": "Finanzas", "fr": "Finances",
        "it": "Finanze", "ja": "ファイナンス", "ko": "재정", "nl": "Financiën", "pl": "Finanse",
        "pt": "Finanças", "tr": "Finans"
    },
    "quiz.fitness": {
        "de": "Fitness", "en": "Fitness", "es": "Fitness", "fr": "Fitness",
        "it": "Fitness", "ja": "フィットネス", "ko": "피트니스", "nl": "Fitness", "pl": "Fitness",
        "pt": "Fitness", "tr": "Fitness"
    },
    "quiz.growth": {
        "de": "Wachstum", "en": "Growth", "es": "Crecimiento", "fr": "Croissance",
        "it": "Crescita", "ja": "成長", "ko": "성장", "nl": "Groei", "pl": "Rozwój",
        "pt": "Crescimento", "tr": "Büyüme"
    },
    "quiz.health": {
        "de": "Gesundheit", "en": "Health", "es": "Salud", "fr": "Santé",
        "it": "Salute", "ja": "健康", "ko": "건강", "nl": "Gezondheid", "pl": "Zdrowie",
        "pt": "Saúde", "tr": "Sağlık"
    },
    "quiz.lifestyle": {
        "de": "Lifestyle", "en": "Lifestyle", "es": "Estilo de Vida", "fr": "Mode de Vie",
        "it": "Stile di Vita", "ja": "ライフスタイル", "ko": "라이프스타일", "nl": "Levensstijl", "pl": "Styl Życia",
        "pt": "Estilo de Vida", "tr": "Yaşam Tarzı"
    },
    "quiz.mental": {
        "de": "Mental", "en": "Mental", "es": "Mental", "fr": "Mental",
        "it": "Mentale", "ja": "メンタル", "ko": "멘탈", "nl": "Mentaal", "pl": "Mentalne",
        "pt": "Mental", "tr": "Zihinsel"
    },
    "routine.timer.edit_individual": {
        "de": "Zeit anpassen", "en": "Adjust Time", "es": "Ajustar Tiempo", "fr": "Ajuster le Temps",
        "it": "Regola Tempo", "ja": "時間を調整", "ko": "시간 조정", "nl": "Tijd Aanpassen", "pl": "Dostosuj Czas",
        "pt": "Ajustar Tempo", "tr": "Zamanı Ayarla"
    },
    "settings.pdf_export": {
        "de": "Daten exportieren (PDF)", "en": "Export Data (PDF)", "es": "Exportar Datos (PDF)", "fr": "Exporter les Données (PDF)",
        "it": "Esporta Dati (PDF)", "ja": "データエクスポート (PDF)", "ko": "데이터 내보내기 (PDF)", "nl": "Gegevens Exporteren (PDF)", "pl": "Eksportuj Dane (PDF)",
        "pt": "Exportar Dados (PDF)", "tr": "Verileri Dışa Aktar (PDF)"
    },
    "stats.categories_watered_format": {
        "de": "%@ gegossen", "en": "Watered %@", "es": "%@ regadas", "fr": "%@ arrosées",
        "it": "%@ annaffiate", "ja": "%@ 栽培", "ko": "%@ 물주기 완료", "nl": "%@ water gegeven", "pl": "%@ podlanych",
        "pt": "%@ regadas", "tr": "%@ sulandı"
    },
    "stats.total_focus": {
        "de": "Fokus gesamt", "en": "Total Focus", "es": "Enfoque Total", "fr": "Concentration Totale",
        "it": "Focus Totale", "ja": "合計フォーカス", "ko": "총 집중 시간", "nl": "Totale Focus", "pl": "Całkowite Skupienie",
        "pt": "Foco Total", "tr": "Toplam Odaklanma"
    },
    "pdf.notes.filename": {
        "de": "Notizen_GartenSimulation.pdf", "en": "Notes_GardenSimulation.pdf", "es": "Notas_SimulacionJardin.pdf", "fr": "Notes_SimulationJardin.pdf",
        "it": "Note_SimulazioneGiardino.pdf", "ja": "Notes_GardenSimulation.pdf", "ko": "Notes_GardenSimulation.pdf", "nl": "Notities_TuinSimulatie.pdf", "pl": "Notatki_SymulacjaOgrodu.pdf",
        "pt": "Notas_SimulacaoJardim.pdf", "tr": "Notlar_BahceSimulasyonu.pdf"
    },
    "plant.detail.notes_header": {
        "de": "Notizen", "en": "Notes", "es": "Notas", "fr": "Notes",
        "it": "Note", "ja": "メモ", "ko": "메모", "nl": "Notities", "pl": "Notatki",
        "pt": "Notas", "tr": "Notlar"
    }
}

for key, translations in missing_data.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    if "localizations" not in data["strings"][key]:
        data["strings"][key]["localizations"] = {}
        
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
