import json
import sys

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"

try:
    with open(file_path, 'r') as f:
        data = json.load(f)
except Exception as e:
    print(f"Error reading {file_path}: {e}")
    sys.exit(1)

keys_to_add = {
    "note.auto.routine": {"de": "(mit Routine)", "en": "(with routine)", "es": "(con rutina)", "fr": "(avec routine)", "it": "(con routine)", "ja": "(ルーチンあり)", "ko": "(루틴 포함)", "nl": "(met routine)", "pl": "(z rutyną)", "pt": "(com rotina)", "tr": "(rutin ile)"},
    "note.auto.no_routine": {"de": "(ohne Routine)", "en": "(without routine)", "es": "(sin rutina)", "fr": "(sans routine)", "it": "(senza routine)", "ja": "(ルーチンなし)", "ko": "(루틴 없음)", "nl": "(zonder routine)", "pl": "(bez rutyny)", "pt": "(sem rotina)", "tr": "(rutinsiz)"},
    "note.auto.completed": {"de": "Gewohnheit abgeschlossen", "en": "Habit completed", "es": "Hábito completado", "fr": "Habitude terminée", "it": "Abitudine completata", "ja": "習慣完了", "ko": "습관 완료", "nl": "Gewoonte voltooid", "pl": "Nawyk zakończony", "pt": "Hábito concluído", "tr": "Alışkanlık tamamlandı"},
    "export.config.title": {"de": "PDF Export Konfigurator", "en": "PDF Export Configurator", "es": "Configurador de Exportación PDF", "fr": "Configurateur d'exportation PDF", "it": "Configuratore Esportazione PDF", "ja": "PDFエクスポート設定", "ko": "PDF 내보내기 구성기", "nl": "PDF Export Configurator", "pl": "Konfigurator Eksportu PDF", "pt": "Configurador de Exportação PDF", "tr": "PDF Dışa Aktarma Yapılandırıcısı"},
    "export.config.subtitle": {"de": "Wähle aus, welche Daten in die PDF aufgenommen werden sollen.", "en": "Choose which data should be included in the PDF.", "es": "Elige qué datos deben incluirse en el PDF.", "fr": "Choisissez quelles données doivent être incluses dans le PDF.", "it": "Scegli quali dati includere nel PDF.", "ja": "PDFに含めるデータを選択してください。", "ko": "PDF에 포함될 데이터를 선택하세요.", "nl": "Kies welke gegevens in de PDF moeten worden opgenomen.", "pl": "Wybierz, które dane mają zostać uwzględnione w PDF.", "pt": "Escolha quais dados devem ser incluídos no PDF.", "tr": "PDF'e dahil edilecek verileri seçin."},
    "export.option.notes": {"de": "Notizen der Gewohnheiten", "en": "Habit Notes", "es": "Notas de Hábitos", "fr": "Notes d'habitudes", "it": "Note delle abitudini", "ja": "習慣のメモ", "ko": "습관 메모", "nl": "Gewoonte notities", "pl": "Notatki nawyków", "pt": "Notas de Hábitos", "tr": "Alışkanlık Notları"},
    "export.option.timer": {"de": "Fokus Zeit Statistiken", "en": "Focus Time Statistics", "es": "Estadísticas de Tiempo de Enfoque", "fr": "Statistiques de Temps de Concentration", "it": "Statistiche Tempo di Focus", "ja": "集中時間の統計", "ko": "집중 시간 통계", "nl": "Focus Tijd Statistieken", "pl": "Statystyki Czasu Skupienia", "pt": "Estatísticas de Tempo de Foco", "tr": "Odaklanma Zamanı İstatistikleri"},
    "export.option.stats": {"de": "Allgemeine Statistiken (Streaks)", "en": "General Statistics (Streaks)", "es": "Estadísticas Generales (Rachas)", "fr": "Statistiques Générales (Séries)", "it": "Statistiche Generali (Serie)", "ja": "一般的な統計 (ストリーク)", "ko": "일반 통계 (스트릭)", "nl": "Algemene Statistieken (Streaks)", "pl": "Ogólne Statystyki (Serie)", "pt": "Estatísticas Gerais (Sequências)", "tr": "Genel İstatistikler (Seriler)"},
    "export.option.quiz": {"de": "Quiz Ergebnisse", "en": "Quiz Results", "es": "Resultados del Cuestionario", "fr": "Résultats du Quiz", "it": "Risultati Quiz", "ja": "クイズ結果", "ko": "퀴즈 결과", "nl": "Quiz Resultaten", "pl": "Wyniki Quizu", "pt": "Resultados do Quiz", "tr": "Test Sonuçları"},
    "export.option.bad_habits": {"de": "Schlechte Gewohnheiten", "en": "Bad Habits", "es": "Malos Hábitos", "fr": "Mauvaises Habitudes", "it": "Cattive Abitudini", "ja": "悪い習慣", "ko": "나쁜 습관", "nl": "Slechte Gewoonten", "pl": "Złe Nawyki", "pt": "Maus Hábitos", "tr": "Kötü Alışkanlıklar"},
    "export.option.routines": {"de": "Routinen", "en": "Routines", "es": "Rutinas", "fr": "Routines", "it": "Routine", "ja": "ルーチン", "ko": "루틴", "nl": "Routines", "pl": "Rutyny", "pt": "Rotinas", "tr": "Rutinler"},
    "export.config.nav_title": {"de": "PDF Export", "en": "PDF Export", "es": "Exportación PDF", "fr": "Exportation PDF", "it": "Esportazione PDF", "ja": "PDFエクスポート", "ko": "PDF 내보내기", "nl": "PDF Export", "pl": "Eksport PDF", "pt": "Exportação PDF", "tr": "PDF Dışa Aktarma"},
    "pdf.notes.title": {"de": "App Daten Export", "en": "App Data Export", "es": "Exportación de Datos de la App", "fr": "Exportation de Données de l'Application", "it": "Esportazione Dati App", "ja": "アプリデータエクスポート", "ko": "앱 데이터 내보내기", "nl": "App Data Export", "pl": "Eksport Danych Aplikacji", "pt": "Exportação de Dados da App", "tr": "Uygulama Veri Dışa Aktarımı"},
    "pdf.notes.good_habits": {"de": "Gute Gewohnheiten", "en": "Good Habits", "es": "Buenos Hábitos", "fr": "Bonnes Habitudes", "it": "Buone Abitudini", "ja": "良い習慣", "ko": "좋은 습관", "nl": "Goede Gewoonten", "pl": "Dobre Nawyki", "pt": "Bons Hábitos", "tr": "İyi Alışkanlıklar"},
    "stats.streak.current": {"de": "Aktueller Streak", "en": "Current Streak", "es": "Racha Actual", "fr": "Série Actuelle", "it": "Serie Attuale", "ja": "現在のストリーク", "ko": "현재 스트릭", "nl": "Huidige Streak", "pl": "Obecna Seria", "pt": "Sequência Atual", "tr": "Mevcut Seri"},
    "stats.streak.highest": {"de": "Höchster Streak", "en": "Highest Streak", "es": "Mayor Racha", "fr": "Meilleure Série", "it": "Serie Migliore", "ja": "最高ストリーク", "ko": "최고 스트릭", "nl": "Hoogste Streak", "pl": "Najwyższa Seria", "pt": "Melhor Sequência", "tr": "En Yüksek Seri"},
    "export.notes.label": {"de": "Notizen & Erledigungen:", "en": "Notes & Completions:", "es": "Notas y Finalizaciones:", "fr": "Notes & Réalisations :", "it": "Note & Completamenti:", "ja": "メモと完了:", "ko": "메모 및 완료:", "nl": "Notities & Voltooiingen:", "pl": "Notatki i Zakończenia:", "pt": "Notas e Conclusões:", "tr": "Notlar ve Tamamlamalar:"},
    "pdf.notes.bad_habits": {"de": "Schlechte Gewohnheiten", "en": "Bad Habits", "es": "Malos Hábitos", "fr": "Mauvaises Habitudes", "it": "Cattive Abitudini", "ja": "悪い習慣", "ko": "나쁜 습관", "nl": "Slechte Gewoonten", "pl": "Złe Nawyki", "pt": "Maus Hábitos", "tr": "Kötü Alışkanlıklar"},
    "stats.total_usages": {"de": "Gesamt genutzt", "en": "Total used", "es": "Uso total", "fr": "Total utilisé", "it": "Utilizzo totale", "ja": "合計使用回数", "ko": "총 사용량", "nl": "Totaal gebruikt", "pl": "Łącznie użyte", "pt": "Uso total", "tr": "Toplam kullanım"},
    "export.notes.triggers": {"de": "Auslöser / Notizen:", "en": "Triggers / Notes:", "es": "Desencadenantes / Notas:", "fr": "Déclencheurs / Notes :", "it": "Trigger / Note:", "ja": "トリガー/メモ:", "ko": "트리거 / 메모:", "nl": "Triggers / Notities:", "pl": "Wyzwalacze / Notatki:", "pt": "Gatilhos / Notas:", "tr": "Tetikleyiciler / Notlar:"},
    "export.stats.title": {"de": "Statistiken", "en": "Statistics", "es": "Estadísticas", "fr": "Statistiques", "it": "Statistiche", "ja": "統計", "ko": "통계", "nl": "Statistieken", "pl": "Statystyki", "pt": "Estatísticas", "tr": "İstatistikler"},
    "stats.overall_streak": {"de": "Gesamte App Streak", "en": "Overall App Streak", "es": "Racha General de la App", "fr": "Série Globale de l'Application", "it": "Serie Globale dell'App", "ja": "アプリ全体のストリーク", "ko": "전체 앱 스트릭", "nl": "Algemene App Streak", "pl": "Ogólna Seria Aplikacji", "pt": "Sequência Geral do App", "tr": "Genel Uygulama Serisi"},
    "stats.overall_streak.max": {"de": "Max", "en": "Max", "es": "Max", "fr": "Max", "it": "Max", "ja": "最大", "ko": "최대", "nl": "Max", "pl": "Maks", "pt": "Max", "tr": "Maks"},
    "stats.plants_watered": {"de": "Gesamt gegossen", "en": "Total watered", "es": "Total regado", "fr": "Total arrosé", "it": "Totale innaffiato", "ja": "合計水やり回数", "ko": "총 물주기", "nl": "Totaal water gegeven", "pl": "Łącznie podlane", "pt": "Total regado", "tr": "Toplam sulama"},
    "stats.focus_time": {"de": "Gesamte Fokus Zeit", "en": "Total Focus Time", "es": "Tiempo Total de Enfoque", "fr": "Temps de Concentration Total", "it": "Tempo di Focus Totale", "ja": "合計集中時間", "ko": "총 집중 시간", "nl": "Totale Focus Tijd", "pl": "Całkowity Czas Skupienia", "pt": "Tempo Total de Foco", "tr": "Toplam Odaklanma Süresi"},
    "time.minutes": {"de": "Minuten", "en": "Minutes", "es": "Minutos", "fr": "Minutes", "it": "Minuti", "ja": "分", "ko": "분", "nl": "Minuten", "pl": "Minuty", "pt": "Minutos", "tr": "Dakika"},
    "export.quiz.title": {"de": "Quiz Ergebnisse", "en": "Quiz Results", "es": "Resultados del Cuestionario", "fr": "Résultats du Quiz", "it": "Risultati Quiz", "ja": "クイズ結果", "ko": "퀴즈 결과", "nl": "Quiz Resultaten", "pl": "Wyniki Quizu", "pt": "Resultados do Quiz", "tr": "Test Sonuçları"},
    "export.routines.title": {"de": "Routinen", "en": "Routines", "es": "Rutinas", "fr": "Routines", "it": "Routine", "ja": "ルーチン", "ko": "루틴", "nl": "Routines", "pl": "Rutyny", "pt": "Rotinas", "tr": "Rutinler"},
    "export.routines.last_done": {"de": "Zuletzt ausgeführt", "en": "Last performed", "es": "Última vez realizado", "fr": "Dernière exécution", "it": "Ultima esecuzione", "ja": "最終実行", "ko": "마지막 실행", "nl": "Laatst uitgevoerd", "pl": "Ostatnio wykonane", "pt": "Última execução", "tr": "Son gerçekleştirilen"},
    "export.routines.habits": {"de": "Gewohnheiten", "en": "Habits", "es": "Hábitos", "fr": "Habitudes", "it": "Abitudini", "ja": "習慣", "ko": "습관", "nl": "Gewoonten", "pl": "Nawyki", "pt": "Hábitos", "tr": "Alışkanlıklar"},
    "export.selection.generate": {"de": "PDF Exportieren", "en": "Export PDF", "es": "Exportar PDF", "fr": "Exporter en PDF", "it": "Esporta PDF", "ja": "PDFエクスポート", "ko": "PDF 내보내기", "nl": "PDF Exporteren", "pl": "Eksportuj PDF", "pt": "Exportar PDF", "tr": "PDF Dışa Aktar"}
}

for key, langs in keys_to_add.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, trans in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": trans
            }
        }

with open(file_path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Added keys successfully.")
