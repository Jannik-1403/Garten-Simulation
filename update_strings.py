import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r") as f:
    data = json.load(f)

new_keys = {
    "export.pdf.report.title": {
        "de": "Grovy Wochenbericht",
        "en": "Grovy Weekly Report",
        "es": "Informe Semanal de Grovy",
        "fr": "Rapport Hebdomadaire Grovy",
        "it": "Rapporto Settimanale Grovy",
        "ja": "Grovy 週間レポート",
        "ko": "Grovy 주간 보고서",
        "nl": "Grovy Weekrapport",
        "pl": "Raport Tygodniowy Grovy",
        "pt": "Relatório Semanal Grovy",
        "tr": "Grovy Haftalık Raporu"
    },
    "export.pdf.report.period": {
        "de": "Zeitraum: %@",
        "en": "Period: %@",
        "es": "Período: %@",
        "fr": "Période: %@",
        "it": "Periodo: %@",
        "ja": "期間: %@",
        "ko": "기간: %@",
        "nl": "Periode: %@",
        "pl": "Okres: %@",
        "pt": "Período: %@",
        "tr": "Dönem: %@"
    },
    "export.pdf.report.summary": {
        "de": "1. Wochen-Zusammenfassung",
        "en": "1. Weekly Summary",
        "es": "1. Resumen Semanal",
        "fr": "1. Résumé Hebdomadaire",
        "it": "1. Riepilogo Settimanale",
        "ja": "1. 週間サマリー",
        "ko": "1. 주간 요약",
        "nl": "1. Weekoverzicht",
        "pl": "1. Podsumowanie Tygodnia",
        "pt": "1. Resumo Semanal",
        "tr": "1. Haftalık Özet"
    },
    "export.pdf.report.total_focus_time": {
        "de": "Gesamt-Fokuszeit: %lld Minuten (%@ im Vergleich zur Vorwoche)",
        "en": "Total Focus Time: %lld Minutes (%@ compared to last week)",
        "es": "Tiempo Total de Enfoque: %lld Minutos (%@ comparado con la semana pasada)",
        "fr": "Temps de Concentration Total: %lld Minutes (%@ par rapport à la semaine dernière)",
        "it": "Tempo di Concentrazione Totale: %lld Minuti (%@ rispetto alla scorsa settimana)",
        "ja": "合計集中時間: %lld 分 (先週比 %@)",
        "ko": "총 집중 시간: %lld 분 (지난주 대비 %@)",
        "nl": "Totale Focustijd: %lld Minuten (%@ in vergelijking met vorige week)",
        "pl": "Całkowity Czas Skupienia: %lld Minut (%@ w porównaniu z zeszłym tygodniem)",
        "pt": "Tempo Total de Foco: %lld Minutos (%@ comparado com a semana passada)",
        "tr": "Toplam Odaklanma Süresi: %lld Dakika (geçen haftaya göre %@)"
    },
    "export.pdf.report.completed_habits": {
        "de": "Erledigte Gewohnheiten: %lld (%@ im Vergleich zur Vorwoche)",
        "en": "Completed Habits: %lld (%@ compared to last week)",
        "es": "Hábitos Completados: %lld (%@ comparado con la semana pasada)",
        "fr": "Habitudes Complétées: %lld (%@ par rapport à la semaine dernière)",
        "it": "Abitudini Completate: %lld (%@ rispetto alla scorsa settimana)",
        "ja": "完了した習慣: %lld (先週比 %@)",
        "ko": "완료된 습관: %lld (지난주 대비 %@)",
        "nl": "Voltooide Gewoontes: %lld (%@ in vergelijking met vorige week)",
        "pl": "Ukończone Nawyki: %lld (%@ w porównaniu z zeszłym tygodniem)",
        "pt": "Hábitos Concluídos: %lld (%@ comparado com a semana passada)",
        "tr": "Tamamlanan Alışkanlıklar: %lld (geçen haftaya göre %@)"
    },
    "export.pdf.report.completed_sessions": {
        "de": "Abgeschlossene Fokus-Sessions: %lld",
        "en": "Completed Focus Sessions: %lld",
        "es": "Sesiones de Enfoque Completadas: %lld",
        "fr": "Sessions de Concentration Complétées: %lld",
        "it": "Sessioni di Concentrazione Completate: %lld",
        "ja": "完了した集中セッション: %lld",
        "ko": "완료된 집중 세션: %lld",
        "nl": "Voltooide Focus Sessies: %lld",
        "pl": "Zakończone Sesje Skupienia: %lld",
        "pt": "Sessões de Foco Concluídas: %lld",
        "tr": "Tamamlanan Odaklanma Seansları: %lld"
    },
    "export.pdf.report.earned_xp": {
        "de": "Verdiente Erfahrungspunkte: %lld XP",
        "en": "Earned Experience Points: %lld XP",
        "es": "Puntos de Experiencia Ganados: %lld XP",
        "fr": "Points d'Expérience Gagnés: %lld XP",
        "it": "Punti Esperienza Guadagnati: %lld XP",
        "ja": "獲得した経験値: %lld XP",
        "ko": "획득한 경험치: %lld XP",
        "nl": "Verdiende Ervaringspunten: %lld XP",
        "pl": "Zdobyte Punkty Doświadczenia: %lld XP",
        "pt": "Pontos de Experiência Ganhos: %lld XP",
        "tr": "Kazanılan Deneyim Puanları: %lld XP"
    },
    "export.pdf.report.progress_analysis": {
        "de": "2. Fortschritts-Analyse",
        "en": "2. Progress Analysis",
        "es": "2. Análisis de Progreso",
        "fr": "2. Analyse de Progression",
        "it": "2. Analisi del Progresso",
        "ja": "2. 進捗分析",
        "ko": "2. 진행 상황 분석",
        "nl": "2. Voortgangsanalyse",
        "pl": "2. Analiza Postępów",
        "pt": "2. Análise de Progresso",
        "tr": "2. İlerleme Analizi"
    },
    "export.pdf.report.daily_activities": {
        "de": "3. Tägliche Aktivitäten",
        "en": "3. Daily Activities",
        "es": "3. Actividades Diarias",
        "fr": "3. Activités Quotidiennes",
        "it": "3. Attività Quotidiane",
        "ja": "3. 日常の活動",
        "ko": "3. 일일 활동",
        "nl": "3. Dagelijkse Activiteiten",
        "pl": "3. Codzienne Aktywności",
        "pt": "3. Atividades Diárias",
        "tr": "3. Günlük Aktiviteler"
    },
    "export.pdf.report.focus_minutes": {
        "de": "Fokus-Minuten:",
        "en": "Focus Minutes:",
        "es": "Minutos de Enfoque:",
        "fr": "Minutes de Concentration:",
        "it": "Minuti di Concentrazione:",
        "ja": "集中時間（分）:",
        "ko": "집중 시간(분):",
        "nl": "Focus Minuten:",
        "pl": "Minuty Skupienia:",
        "pt": "Minutos de Foco:",
        "tr": "Odaklanma Dakikaları:"
    },
    "export.pdf.report.daily_focus_item": {
        "de": "%@: %lld Min",
        "en": "%@: %lld Min",
        "es": "%@: %lld Min",
        "fr": "%@: %lld Min",
        "it": "%@: %lld Min",
        "ja": "%@: %lld 分",
        "ko": "%@: %lld 분",
        "nl": "%@: %lld Min",
        "pl": "%@: %lld Min",
        "pt": "%@: %lld Min",
        "tr": "%@: %lld Dk"
    },
    "export.pdf.report.habits_completed": {
        "de": "Erledigte Gewohnheiten:",
        "en": "Completed Habits:",
        "es": "Hábitos Completados:",
        "fr": "Habitudes Complétées:",
        "it": "Abitudini Completate:",
        "ja": "完了した習慣:",
        "ko": "완료된 습관:",
        "nl": "Voltooide Gewoontes:",
        "pl": "Ukończone Nawyki:",
        "pt": "Hábitos Concluídos:",
        "tr": "Tamamlanan Alışkanlıklar:"
    },
    "export.pdf.report.daily_habit_item": {
        "de": "%@: %lld erledigt",
        "en": "%@: %lld completed",
        "es": "%@: %lld completado",
        "fr": "%@: %lld complété",
        "it": "%@: %lld completato",
        "ja": "%@: %lld 完了",
        "ko": "%@: %lld 완료",
        "nl": "%@: %lld voltooid",
        "pl": "%@: %lld ukończono",
        "pt": "%@: %lld concluído",
        "tr": "%@: %lld tamamlandı"
    }
}

for key, translations in new_keys.items():
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

with open(path, "w") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
