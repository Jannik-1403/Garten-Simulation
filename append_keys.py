import re

file_path = "/Users/jannikschill/Documents/Garten-Simulation/add_translations.py"

with open(file_path, 'r') as f:
    content = f.read()

new_keys = """
    "export.config.section.habits": {"de": "Gute Gewohnheiten", "en": "Good Habits", "es": "Buenos Hábitos", "fr": "Bonnes Habitudes", "it": "Buone Abitudini", "ja": "良い習慣", "ko": "좋은 습관", "nl": "Goede Gewoonten", "pl": "Dobre Nawyki", "pt": "Bons Hábitos", "tr": "İyi Alışkanlıklar"},
    "export.config.stats": {"de": "Statistiken (Gesamtfortschritt)", "en": "Statistics (Overall Progress)", "es": "Estadísticas", "fr": "Statistiques", "it": "Statistiche", "ja": "統計", "ko": "통계", "nl": "Statistieken", "pl": "Statystyki", "pt": "Estatísticas", "tr": "İstatistikler"},
    "export.config.bad_habits": {"de": "Schlechte Gewohnheiten & Rückfälle", "en": "Bad Habits & Relapses", "es": "Malos Hábitos", "fr": "Mauvaises Habitudes", "it": "Cattive Abitudini", "ja": "悪い習慣", "ko": "나쁜 습관", "nl": "Slechte Gewoonten", "pl": "Złe Nawyki", "pt": "Maus Hábitos", "tr": "Kötü Alışkanlıklar"},
    "export.config.routines": {"de": "Routinen", "en": "Routines", "es": "Rutinas", "fr": "Routines", "it": "Routine", "ja": "ルーチン", "ko": "루틴", "nl": "Routines", "pl": "Rutyny", "pt": "Rotinas", "tr": "Rutinler"},
    "export.config.timer": {"de": "Timer Aufzeichnungen", "en": "Timer Logs", "es": "Registros del Temporizador", "fr": "Enregistrements du minuteur", "it": "Registri Timer", "ja": "タイマー記録", "ko": "타이머 기록", "nl": "Timer Logs", "pl": "Dzienniki Timera", "pt": "Registros do Temporizador", "tr": "Zamanlayıcı Kayıtları"},
    "export.config.quiz": {"de": "Quiz Ergebnisse", "en": "Quiz Results", "es": "Resultados del Cuestionario", "fr": "Résultats du Quiz", "it": "Risultati Quiz", "ja": "クイズ結果", "ko": "퀴즈 결과", "nl": "Quiz Resultaten", "pl": "Wyniki Quizu", "pt": "Resultados do Quiz", "tr": "Test Sonuçları"},
    "export.config.section.optional": {"de": "Zusätzliche Daten", "en": "Additional Data", "es": "Datos Adicionales", "fr": "Données supplémentaires", "it": "Dati aggiuntivi", "ja": "追加データ", "ko": "추가 데이터", "nl": "Aanvullende Gegevens", "pl": "Dodatkowe Dane", "pt": "Dados Adicionais", "tr": "Ek Veriler"},
    "export.config.button": {"de": "PDF generieren", "en": "Generate PDF", "es": "Generar PDF", "fr": "Générer PDF", "it": "Genera PDF", "ja": "PDFを生成", "ko": "PDF 생성", "nl": "PDF genereren", "pl": "Generuj PDF", "pt": "Gerar PDF", "tr": "PDF Oluştur"},
    
    "export.pdf.focus.type_routine": {"de": "Routine", "en": "Routine", "es": "Rutina", "fr": "Routine", "it": "Routine", "ja": "ルーチン", "ko": "루틴", "nl": "Routine", "pl": "Rutyna", "pt": "Rotina", "tr": "Rutin"},
    "export.pdf.focus.type_habit": {"de": "Gewohnheit", "en": "Habit", "es": "Hábito", "fr": "Habitude", "it": "Abitudine", "ja": "習慣", "ko": "습관", "nl": "Gewoonte", "pl": "Nawyk", "pt": "Hábito", "tr": "Alışkanlık"},
    "export.pdf.focus.habit_name": {"de": "Gewohnheit: %@", "en": "Habit: %@", "es": "Hábito: %@", "fr": "Habitude : %@", "it": "Abitudine: %@", "ja": "習慣: %@", "ko": "습관: %@", "nl": "Gewoonte: %@", "pl": "Nawyk: %@", "pt": "Hábito: %@", "tr": "Alışkanlık: %@"},
    "export.pdf.focus.tasks": {"de": "Aufgaben:", "en": "Tasks:", "es": "Tareas:", "fr": "Tâches :", "it": "Compiti:", "ja": "タスク:", "ko": "과제:", "nl": "Taken:", "pl": "Zadania:", "pt": "Tarefas:", "tr": "Görevler:"},
    "export.pdf.routines.history": {"de": "Letzte Abschlüsse:", "en": "Recent completions:", "es": "Finalizaciones recientes:", "fr": "Réalisations récentes :", "it": "Completamenti recenti:", "ja": "最近の完了:", "ko": "최근 완료:", "nl": "Recente voltooiingen:", "pl": "Ostatnie zakończenia:", "pt": "Conclusões recentes:", "tr": "Son tamamlamalar:"},
    "stats.categories_watered": {"de": "Gegossen pro Kategorie:", "en": "Watered per category:", "es": "Regado por categoría:", "fr": "Arrosé par catégorie :", "it": "Innaffiato per categoria:", "ja": "カテゴリごとの水やり:", "ko": "카테고리별 물주기:", "nl": "Water gegeven per categorie:", "pl": "Podlane na kategorię:", "pt": "Regado por categoria:", "tr": "Kategoriye göre sulama:"},
    "export.quiz.action.title": {"de": "Was man verbessern kann:", "en": "What to improve:", "es": "Qué mejorar:", "fr": "Ce qu'il faut améliorer :", "it": "Cosa migliorare:", "ja": "改善点:", "ko": "개선할 점:", "nl": "Wat te verbeteren:", "pl": "Co poprawić:", "pt": "O que melhorar:", "tr": "Neler geliştirilebilir:"},
"""

content = content.replace('"export.selection.generate": {"de": "PDF Exportieren",', new_keys + '\n    "export.selection.generate": {"de": "PDF Exportieren",')

with open(file_path, 'w') as f:
    f.write(content)
