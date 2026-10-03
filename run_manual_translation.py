# -*- coding: utf-8 -*-
import json

translations = {
    "fitness.cleaning.summary.progress": {
        "de": "%1$@ / %2$@ erledigt", "en": "%1$@ / %2$@ done", "es": "%1$@ / %2$@ hecho", "fr": "%1$@ / %2$@ fait", "hi": "%1$@ / %2$@ हो गया", "it": "%1$@ / %2$@ fatto", "ja": "%1$@ / %2$@ 完了", "ko": "%1$@ / %2$@ 완료", "nl": "%1$@ / %2$@ klaar", "pl": "%1$@ / %2$@ zrobione", "pt": "%1$@ / %2$@ feito", "pt-BR": "%1$@ / %2$@ feito", "ru": "%1$@ / %2$@ готово", "tr": "%1$@ / %2$@ tamamlandı", "zh-Hans": "%1$@ / %2$@ 已完成", "zh-Hant": "%1$@ / %2$@ 已完成"
    },
    "fitness.cleaning.detail.good": {
        "de": "Toll, du hast heute schon alle fälligen Aufgaben erledigt!", "en": "Great, you have completed all due tasks today!", "es": "¡Genial, has completado todas las tareas pendientes de hoy!", "fr": "Super, vous avez terminé toutes les tâches prévues aujourd'hui !", "hi": "बढ़िया, आपने आज के सभी नियत कार्य पूरे कर लिए हैं!", "it": "Ottimo, hai completato tutti i compiti previsti per oggi!", "ja": "素晴らしい、今日のすべてのタスクを完了しました！", "ko": "멋져요, 오늘 마감인 모든 작업을 완료했습니다!", "nl": "Geweldig, je hebt alle geplande taken voor vandaag voltooid!", "pl": "Świetnie, wykonałeś wszystkie dzisiejsze zadania!", "pt": "Ótimo, você concluiu todas as tarefas previstas para hoje!", "pt-BR": "Ótimo, você concluiu todas as tarefas de hoje!", "ru": "Отлично, вы выполнили все запланированные на сегодня задачи!", "tr": "Harika, bugün yapılması gereken tüm görevleri tamamladınız!", "zh-Hans": "太棒了，你已经完成了今天所有的任务！", "zh-Hant": "太棒了，您已經完成了今天所有的任務！"
    },
    "fitness.cleaning.summary.good": {
        "de": "Sauber ✓", "en": "Clean ✓", "es": "Limpio ✓", "fr": "Propre ✓", "hi": "साफ़ ✓", "it": "Pulito ✓", "ja": "きれい ✓", "ko": "깨끗함 ✓", "nl": "Schoon ✓", "pl": "Czysto ✓", "pt": "Limpo ✓", "pt-BR": "Limpo ✓", "ru": "Чисто ✓", "tr": "Temiz ✓", "zh-Hans": "干净 ✓", "zh-Hant": "乾淨 ✓"
    },
    "cleaning.today.title": {
        "de": "Heute aufräumen", "en": "Clean today", "es": "Limpiar hoy", "fr": "Nettoyer aujourd'hui", "hi": "आज साफ करें", "it": "Pulisci oggi", "ja": "今日掃除する", "ko": "오늘 청소하기", "nl": "Vandaag schoonmaken", "pl": "Sprzątaj dzisiaj", "pt": "Limpar hoje", "pt-BR": "Limpar hoje", "ru": "Убраться сегодня", "tr": "Bugün temizle", "zh-Hans": "今天打扫", "zh-Hant": "今天打掃"
    },
    "cleaning.today.none": {
        "de": "Heute steht nichts an – genieß den freien Tag!", "en": "Nothing due today - enjoy your day off!", "es": "No hay nada para hoy - ¡disfruta de tu día libre!", "fr": "Rien de prévu aujourd'hui - profitez de votre jour de congé !", "hi": "आज कुछ भी नहीं है - अपनी छुट्टी का आनंद लें!", "it": "Niente in programma oggi - goditi il tuo giorno libero!", "ja": "今日は予定がありません - 休日をお楽しみください！", "ko": "오늘은 일정이 없습니다 - 휴일을 즐기세요!", "nl": "Er staat niets op de planning voor vandaag - geniet van je vrije dag!", "pl": "Dziś nic nie masz w planach - ciesz się dniem wolnym!", "pt": "Nada programado para hoje - aproveite seu dia de folga!", "pt-BR": "Nada programado para hoje - aproveite seu dia de folga!", "ru": "На сегодня ничего не запланировано - наслаждайтесь выходным!", "tr": "Bugün hiçbir şey planlanmadı - boş gününüzün tadını çıkarın!", "zh-Hans": "今天没有任务 - 享受您的休息日！", "zh-Hant": "今天沒有任務 - 享受您的休息日！"
    },
    "cleaning.upcoming.title": {
        "de": "Demnächst", "en": "Upcoming", "es": "Próximamente", "fr": "À venir", "hi": "आगामी", "it": "Prossimamente", "ja": "近日公開", "ko": "예정", "nl": "Binnenkort", "pl": "Wkrótce", "pt": "Em breve", "pt-BR": "Em breve", "ru": "Скоро", "tr": "Yaklaşan", "zh-Hans": "即将到来", "zh-Hant": "即將到來"
    },
    "cleaning.stats.title": {
        "de": "Statistik", "en": "Statistics", "es": "Estadísticas", "fr": "Statistiques", "hi": "आंकड़े", "it": "Statistiche", "ja": "統計", "ko": "통계", "nl": "Statistieken", "pl": "Statystyki", "pt": "Estatísticas", "pt-BR": "Estatísticas", "ru": "Статистика", "tr": "İstatistikler", "zh-Hans": "统计", "zh-Hant": "統計"
    },
    "cleaning.stats.today": {
        "de": "Heute", "en": "Today", "es": "Hoy", "fr": "Aujourd'hui", "hi": "आज", "it": "Oggi", "ja": "今日", "ko": "오늘", "nl": "Vandaag", "pl": "Dzisiaj", "pt": "Hoje", "pt-BR": "Hoje", "ru": "Сегодня", "tr": "Bugün", "zh-Hans": "今天", "zh-Hant": "今天"
    },
    "cleaning.stats.week": {
        "de": "Letzte 7 Tage", "en": "Last 7 days", "es": "Últimos 7 días", "fr": "Les 7 derniers jours", "hi": "पिछले 7 दिन", "it": "Ultimi 7 giorni", "ja": "過去7日間", "ko": "최근 7일", "nl": "Afgelopen 7 dagen", "pl": "Ostatnie 7 dni", "pt": "Últimos 7 dias", "pt-BR": "Últimos 7 dias", "ru": "Последние 7 дней", "tr": "Son 7 gün", "zh-Hans": "最近 7 天", "zh-Hant": "最近 7 天"
    },
    "cleaning.stats.streak": {
        "de": "Aufräum-Tage in Folge", "en": "Cleaning days in a row", "es": "Días de limpieza seguidos", "fr": "Jours de nettoyage d'affilée", "hi": "लगातार सफाई के दिन", "it": "Giorni di pulizia di fila", "ja": "連続掃除日数", "ko": "연속 청소 일수", "nl": "Schoonmaakdagen op rij", "pl": "Kolejne dni sprzątania", "pt": "Dias de limpeza seguidos", "pt-BR": "Dias de limpeza seguidos", "ru": "Дни уборки подряд", "tr": "Art arda temizlik günleri", "zh-Hans": "连续打扫天数", "zh-Hant": "連續打掃天數"
    },
    "cleaning.stats.total": {
        "de": "Erledigt insgesamt", "en": "Total completed", "es": "Total completado", "fr": "Total terminé", "hi": "कुल पूर्ण", "it": "Totale completato", "ja": "合計完了", "ko": "총 완료", "nl": "Totaal voltooid", "pl": "Razem ukończone", "pt": "Total concluído", "pt-BR": "Total concluído", "ru": "Всего выполнено", "tr": "Toplam tamamlanan", "zh-Hans": "总计完成", "zh-Hant": "總計完成"
    },
    "cleaning.empty.title": {
        "de": "Keine Aufgaben", "en": "No tasks", "es": "Sin tareas", "fr": "Aucune tâche", "hi": "कोई कार्य नहीं", "it": "Nessun compito", "ja": "タスクなし", "ko": "작업 없음", "nl": "Geen taken", "pl": "Brak zadań", "pt": "Sem tarefas", "pt-BR": "Sem tarefas", "ru": "Нет задач", "tr": "Görev yok", "zh-Hans": "没有任务", "zh-Hant": "沒有任務"
    },
    "cleaning.empty.explanation": {
        "de": "Lege Aufgaben wie „Bett abziehen“ mit eigenem Rhythmus an. Die Gewohnheit ist dann nur an Tagen fällig, an denen etwas ansteht.", "en": "Create tasks like 'Make bed' with your own rhythm. The habit is then only due on days when something is scheduled.", "es": "Crea tareas como 'Hacer la cama' con tu propio ritmo. El hábito solo se deberá realizar los días en que haya algo programado.", "fr": "Créez des tâches comme 'Faire le lit' avec votre propre rythme. L'habitude n'est due que les jours où quelque chose est prévu.", "hi": "अपने लय के साथ 'बिस्तर बनाएं' जैसे कार्य बनाएं। यह आदत केवल उन दिनों में देय होती है जब कुछ निर्धारित होता है।", "it": "Crea compiti come 'Rifare il letto' con il tuo ritmo. L'abitudine è prevista solo nei giorni in cui c'è qualcosa in programma.", "ja": "「ベッドメイキング」のようなタスクを自分自身のリズムで作成します。習慣は、予定がある日にのみ期限になります。", "ko": "'침대 정리'와 같은 작업을 자신만의 리듬으로 만드세요. 그런 다음 일정이 있는 날에만 습관 마감일이 됩니다.", "nl": "Maak taken zoals 'Bed opmaken' met je eigen ritme. De gewoonte is dan alleen verschuldigd op dagen waarop iets gepland is.", "pl": "Twórz zadania typu 'Pościel łóżko' we własnym rytmie. Nawyk ten jest obowiązkowy tylko w dniach, w których coś jest zaplanowane.", "pt": "Crie tarefas como 'Fazer a cama' com o seu próprio ritmo. O hábito só é devido em dias em que algo está programado.", "pt-BR": "Crie tarefas como 'Fazer a cama' com o seu próprio ritmo. O hábito só é devido em dias em que algo está programado.", "ru": "Создавайте задачи вроде 'Заправить кровать' в своем собственном ритме. Привычка будет актуальна только в дни, когда что-то запланировано.", "tr": "'Yatağı topla' gibi görevleri kendi ritminizle oluşturun. Alışkanlık yalnızca bir şeyin planlandığı günlerde geçerlidir.", "zh-Hans": "以您自己的节奏创建诸如“铺床”之类的任务。只有在安排了某些事情的日子才需要完成该习惯。", "zh-Hant": "以您自己的節奏建立諸如「鋪床」之類的任務。只有在安排了某些事情的日子才需要完成該習慣。"
    },
    "cleaning.add.title": {
        "de": "Neue Aufgabe", "en": "New task", "es": "Nueva tarea", "fr": "Nouvelle tâche", "hi": "नया कार्य", "it": "Nuovo compito", "ja": "新しいタスク", "ko": "새 작업", "nl": "Nieuwe taak", "pl": "Nowe zadanie", "pt": "Nova tarefa", "pt-BR": "Nova tarefa", "ru": "Новая задача", "tr": "Yeni görev", "zh-Hans": "新任务", "zh-Hant": "新任務"
    },
    "cleaning.status.done": {
        "de": "Erledigt", "en": "Done", "es": "Hecho", "fr": "Terminé", "hi": "पूर्ण", "it": "Fatto", "ja": "完了", "ko": "완료", "nl": "Klaar", "pl": "Gotowe", "pt": "Feito", "pt-BR": "Feito", "ru": "Готово", "tr": "Tamamlandı", "zh-Hans": "已完成", "zh-Hant": "已完成"
    },
    "cleaning.status.due": {
        "de": "Heute fällig", "en": "Due today", "es": "Vence hoy", "fr": "À faire aujourd'hui", "hi": "आज देय", "it": "Da fare oggi", "ja": "今日が期限", "ko": "오늘 마감", "nl": "Vandaag fällig", "pl": "Do wykonania dzisiaj", "pt": "Vence hoje", "pt-BR": "Vence hoje", "ru": "Выполнить сегодня", "tr": "Bugün tamamlanmalı", "zh-Hans": "今天到期", "zh-Hant": "今天到期"
    },
    "button.edit": {
        "de": "Bearbeiten", "en": "Edit", "es": "Editar", "fr": "Modifier", "hi": "संपादित करें", "it": "Modifica", "ja": "編集", "ko": "편집", "nl": "Bewerken", "pl": "Edytuj", "pt": "Editar", "pt-BR": "Editar", "ru": "Редактировать", "tr": "Düzenle", "zh-Hans": "编辑", "zh-Hant": "編輯"
    },
    "button.delete": {
        "de": "Löschen", "en": "Delete", "es": "Eliminar", "fr": "Supprimer", "hi": "हटाएं", "it": "Elimina", "ja": "削除", "ko": "삭제", "nl": "Verwijderen", "pl": "Usuń", "pt": "Excluir", "pt-BR": "Excluir", "ru": "Удалить", "tr": "Sil", "zh-Hans": "删除", "zh-Hant": "刪除"
    },
    "cleaning.delete.confirm": {
        "de": "Aufgabe löschen?", "en": "Delete task?", "es": "¿Eliminar tarea?", "fr": "Supprimer la tâche ?", "hi": "कार्य हटाएं?", "it": "Eliminare compito?", "ja": "タスクを削除しますか？", "ko": "작업을 삭제하시겠습니까?", "nl": "Taak verwijderen?", "pl": "Usunąć zadanie?", "pt": "Excluir tarefa?", "pt-BR": "Excluir tarefa?", "ru": "Удалить задачу?", "tr": "Görevi sil?", "zh-Hans": "删除任务？", "zh-Hant": "刪除任務？"
    },
    "cleaning.delete.action": {
        "de": "Löschen", "en": "Delete", "es": "Eliminar", "fr": "Supprimer", "hi": "हटाएं", "it": "Elimina", "ja": "削除", "ko": "삭제", "nl": "Verwijderen", "pl": "Usuń", "pt": "Excluir", "pt-BR": "Excluir", "ru": "Удалить", "tr": "Sil", "zh-Hans": "删除", "zh-Hant": "刪除"
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

print("Done translating!")
