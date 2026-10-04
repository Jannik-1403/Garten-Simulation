# -*- coding: utf-8 -*-
import json, os, sys

translations = {
    # Cleaning
    "cleaning.delete.action": {
        "de": "Löschen", "en": "Delete", "es": "Eliminar", "fr": "Supprimer", "hi": "हटाएं", "it": "Elimina", "ja": "削除", "ko": "삭제", "nl": "Verwijderen", "pl": "Usuń", "pt": "Excluir", "pt-BR": "Excluir", "ru": "Удалить", "tr": "Sil", "zh-Hans": "删除", "zh-Hant": "刪除"
    },
    "cleaning.delete.confirm": {
        "de": "Aufgabe löschen?", "en": "Delete task?", "es": "¿Eliminar tarea?", "fr": "Supprimer la tâche ?", "hi": "कार्य हटाएं?", "it": "Eliminare l'attività?", "ja": "タスクを削除しますか？", "ko": "작업을 삭제하시겠습니까?", "nl": "Taak verwijderen?", "pl": "Usunąć zadanie?", "pt": "Excluir tarefa?", "pt-BR": "Excluir tarefa?", "ru": "Удалить задачу?", "tr": "Görev silinsin mi?", "zh-Hans": "删除任务？", "zh-Hant": "刪除任務？"
    },
    "cleaning.empty.explanation": {
        "de": "Lege Aufgaben wie „Bett abziehen“ mit eigenem Rhythmus an. Die Gewohnheit ist dann nur an Tagen fällig, an denen etwas ansteht.",
        "en": "Create tasks like \"Change bed sheets\" with their own rhythm. The habit is then only due on days when something is scheduled.",
        "es": "Crea tareas como \"Cambiar sábanas\" con su propio ritmo. El hábito solo vence en los días programados.",
        "fr": "Créez des tâches comme « Changer les draps » avec leur propre rythme. L'habitude n'est due que les jours programmés.",
        "hi": "\"बिस्तर की चादर बदलें\" जैसे कार्य अपनी लय के साथ बनाएं। आदत केवल उन दिनों पर देय होती है जब कुछ निर्धारित होता है।",
        "it": "Crea attività come \"Cambia le lenzuola\" con il proprio ritmo. L'abitudine è dovuta solo nei giorni programmati.",
        "ja": "「ベッドのシーツを替える」などのタスクを独自のリズムで作成します。この習慣は、予定がある日にのみ期限を迎えます。",
        "ko": "\"침대 시트 교체\"와 같은 작업을 자신만의 리듬으로 만드세요. 습관은 예정된 날에만 마감됩니다.",
        "nl": "Maak taken zoals \"Bed verschonen\" met hun eigen ritme. De gewoonte is dan alleen verschuldigd op dagen dat er iets gepland is.",
        "pl": "Twórz zadania takie jak \"Zmiana pościeli\" z własnym rytmem. Nawyk jest wymagalny tylko w zaplanowane dni.",
        "pt": "Crie tarefas como \"Trocar lençóis\" com seu próprio ritmo. O hábito só é devido em dias programados.",
        "pt-BR": "Crie tarefas como \"Trocar lençóis\" com seu próprio ritmo. O hábito só é devido em dias programados.",
        "ru": "Создавайте задачи, например, «Поменять постельное белье», в своем ритме. Привычка должна быть выполнена только в запланированные дни.",
        "tr": "\"Çarşafları değiştir\" gibi görevleri kendi ritimleriyle oluşturun. Alışkanlık yalnızca planlanan günlerde yapılmalıdır.",
        "zh-Hans": "以自己的节奏创建诸如“换床单”之类的任务。该习惯仅在有安排的日子到期。",
        "zh-Hant": "以自己的節奏創建諸如“換床單”之類的任務。該習慣僅在有安排的日子到期。"
    },
    "cleaning.recurrence.daily": {
        "de": "Täglich", "en": "Daily", "es": "Diario", "fr": "Quotidien", "hi": "दैनिक", "it": "Quotidiano", "ja": "毎日", "ko": "매일", "nl": "Dagelijks", "pl": "Codziennie", "pt": "Diário", "pt-BR": "Diário", "ru": "Ежедневно", "tr": "Günlük", "zh-Hans": "每天", "zh-Hant": "每天"
    },
    "cleaning.recurrence.everyNDays": {
        "de": "Alle %@ Tage", "en": "Every %@ days", "es": "Cada %@ días", "fr": "Tous les %@ jours", "hi": "हर %@ दिन", "it": "Ogni %@ giorni", "ja": "%@日ごと", "ko": "%@일마다", "nl": "Elke %@ dagen", "pl": "Co %@ dni", "pt": "A cada %@ dias", "pt-BR": "A cada %@ dias", "ru": "Каждые %@ дн.", "tr": "Her %@ günde bir", "zh-Hans": "每 %@ 天", "zh-Hant": "每 %@ 天"
    },
    "cleaning.recurrence.everyNWeeks": {
        "de": "Alle %1$@ Wochen: %2$@", "en": "Every %1$@ weeks: %2$@", "es": "Cada %1$@ semanas: %2$@", "fr": "Toutes les %1$@ semaines : %2$@", "hi": "हर %1$@ सप्ताह: %2$@", "it": "Ogni %1$@ settimane: %2$@", "ja": "%1$@週間ごと: %2$@", "ko": "%1$@주마다: %2$@", "nl": "Elke %1$@ weken: %2$@", "pl": "Co %1$@ tyg.: %2$@", "pt": "A cada %1$@ semanas: %2$@", "pt-BR": "A cada %1$@ semanas: %2$@", "ru": "Каждые %1$@ нед.: %2$@", "tr": "Her %1$@ haftada bir: %2$@", "zh-Hans": "每 %1$@ 周：%2$@", "zh-Hant": "每 %1$@ 週：%2$@"
    },
    "cleaning.recurrence.weekly": {
        "de": "Jede Woche: %@", "en": "Every week: %@", "es": "Cada semana: %@", "fr": "Chaque semaine : %@", "hi": "हर सप्ताह: %@", "it": "Ogni settimana: %@", "ja": "毎週: %@", "ko": "매주: %@", "nl": "Elke week: %@", "pl": "Co tydzień: %@", "pt": "Toda semana: %@", "pt-BR": "Toda semana: %@", "ru": "Каждую неделю: %@", "tr": "Her hafta: %@", "zh-Hans": "每周：%@", "zh-Hant": "每週：%@"
    },
    "cleaning.stats.streak": {
        "de": "Aufräum-Tage in Folge", "en": "Cleaning streak", "es": "Racha de limpieza", "fr": "Série de nettoyage", "hi": "सफाई की स्ट्रीक", "it": "Serie di pulizia", "ja": "掃除の連続記録", "ko": "청소 연속 기록", "nl": "Schoonmaakreeks", "pl": "Seria sprzątania", "pt": "Sequência de limpeza", "pt-BR": "Sequência de limpeza", "ru": "Дней уборки подряд", "tr": "Temizlik serisi", "zh-Hans": "连续打扫天数", "zh-Hant": "連續打掃天數"
    },
    "cleaning.stats.title": {
        "de": "Statistik", "en": "Statistics", "es": "Estadísticas", "fr": "Statistiques", "hi": "आँकड़े", "it": "Statistiche", "ja": "統計", "ko": "통계", "nl": "Statistieken", "pl": "Statystyki", "pt": "Estatísticas", "pt-BR": "Estatísticas", "ru": "Статистика", "tr": "İstatistikler", "zh-Hans": "统计数据", "zh-Hant": "統計數據"
    },
    "cleaning.stats.today": {
        "de": "Heute", "en": "Today", "es": "Hoy", "fr": "Aujourd'hui", "hi": "आज", "it": "Oggi", "ja": "今日", "ko": "오늘", "nl": "Vandaag", "pl": "Dzisiaj", "pt": "Hoje", "pt-BR": "Hoje", "ru": "Сегодня", "tr": "Bugün", "zh-Hans": "今天", "zh-Hant": "今天"
    },
    "cleaning.stats.week": {
        "de": "Letzte 7 Tage", "en": "Last 7 days", "es": "Últimos 7 días", "fr": "Les 7 derniers jours", "hi": "पिछले 7 दिन", "it": "Ultimi 7 giorni", "ja": "過去7日間", "ko": "지난 7일", "nl": "Laatste 7 dagen", "pl": "Ostatnie 7 dni", "pt": "Últimos 7 dias", "pt-BR": "Últimos 7 dias", "ru": "Последние 7 дней", "tr": "Son 7 gün", "zh-Hans": "最近7天", "zh-Hant": "最近7天"
    },
    "cleaning.status.done": {
        "de": "Erledigt", "en": "Done", "es": "Hecho", "fr": "Terminé", "hi": "हो गया", "it": "Fatto", "ja": "完了", "ko": "완료", "nl": "Klaar", "pl": "Gotowe", "pt": "Concluído", "pt-BR": "Concluído", "ru": "Выполнено", "tr": "Tamamlandı", "zh-Hans": "已完成", "zh-Hant": "已完成"
    },
    "cleaning.status.due": {
        "de": "Heute fällig", "en": "Due today", "es": "Vence hoy", "fr": "À faire aujourd'hui", "hi": "आज देय", "it": "Scade oggi", "ja": "今日が期限", "ko": "오늘 마감", "nl": "Vandaag verwacht", "pl": "Na dzisiaj", "pt": "Para hoje", "pt-BR": "Para hoje", "ru": "На сегодня", "tr": "Bugün bitmeli", "zh-Hans": "今日到期", "zh-Hant": "今日到期"
    },
    "cleaning.today.none": {
        "de": "Heute steht nichts an – genieß den freien Tag!", "en": "Nothing due today - enjoy your free day!", "es": "¡Nada para hoy, disfruta tu día libre!", "fr": "Rien de prévu aujourd'hui – profitez de votre jour de congé !", "hi": "आज कुछ भी नहीं है - अपने खाली दिन का आनंद लें!", "it": "Niente in programma oggi: goditi il giorno libero!", "ja": "今日は予定がありません。休みを楽しんでください！", "ko": "오늘은 일정이 없습니다. 휴일을 즐기세요!", "nl": "Niets te doen vandaag – geniet van je vrije dag!", "pl": "Brak zadań na dzisiaj - ciesz się wolnym dniem!", "pt": "Nada para hoje - aproveite seu dia de folga!", "pt-BR": "Nada para hoje - aproveite seu dia de folga!", "ru": "На сегодня ничего не запланировано — наслаждайтесь выходным!", "tr": "Bugün hiçbir şey yok - boş gününüzün tadını çıkarın!", "zh-Hans": "今天没有安排——享受您的休息日！", "zh-Hant": "今天沒有安排——享受您的休息日！"
    },
    "cleaning.today.title": {
        "de": "Heute aufräumen", "en": "Clean today", "es": "Limpiar hoy", "fr": "Nettoyer aujourd'hui", "hi": "आज सफाई करें", "it": "Pulisci oggi", "ja": "今日の掃除", "ko": "오늘 청소", "nl": "Vandaag schoonmaken", "pl": "Posprzątaj dzisiaj", "pt": "Limpar hoje", "pt-BR": "Limpar hoje", "ru": "Убраться сегодня", "tr": "Bugün temizle", "zh-Hans": "今日打扫", "zh-Hant": "今日打掃"
    },
    "cleaning.upcoming.title": {
        "de": "Demnächst", "en": "Upcoming", "es": "Próximos", "fr": "À venir", "hi": "आगामी", "it": "In arrivo", "ja": "予定", "ko": "예정", "nl": "Binnenkort", "pl": "Wkrótce", "pt": "Próximos", "pt-BR": "Próximos", "ru": "Предстоящие", "tr": "Yaklaşanlar", "zh-Hans": "即将到来", "zh-Hant": "即將到來"
    },
    "fitness.cleaning.detail.todo": {
        "de": "Heute musst du noch aufräumen: %@", "en": "Today you still need to clean: %@", "es": "Hoy todavía debes limpiar: %@", "fr": "Aujourd'hui, tu dois encore nettoyer : %@", "hi": "आज आपको अभी भी सफाई करनी है: %@", "it": "Oggi devi ancora pulire: %@", "ja": "今日はまだ掃除する必要があります: %@", "ko": "오늘 아직 청소해야 할 일: %@", "nl": "Vandaag moet je nog schoonmaken: %@", "pl": "Dzisiaj musisz jeszcze posprzątać: %@", "pt": "Hoje você ainda precisa limpar: %@", "pt-BR": "Hoje você ainda precisa limpar: %@", "ru": "Сегодня вам еще нужно убрать: %@", "tr": "Bugün hala temizlemen gerekiyor: %@", "zh-Hans": "今天你还需要打扫：%@", "zh-Hant": "今天你還需要打掃：%@"
    },
    "fitness.cleaning.summary.progress": {
        "de": "%1$@ / %2$@ erledigt", "en": "%1$@ / %2$@ done", "es": "%1$@ / %2$@ listos", "fr": "%1$@ / %2$@ fait", "hi": "%1$@ / %2$@ हो गया", "it": "%1$@ / %2$@ fatti", "ja": "%1$@ / %2$@ 完了", "ko": "%1$@ / %2$@ 완료", "nl": "%1$@ / %2$@ klaar", "pl": "%1$@ / %2$@ gotowe", "pt": "%1$@ / %2$@ concluído", "pt-BR": "%1$@ / %2$@ concluído", "ru": "%1$@ / %2$@ выполнено", "tr": "%1$@ / %2$@ tamamlandı", "zh-Hans": "已完成 %1$@ / %2$@", "zh-Hant": "已完成 %1$@ / %2$@"
    },
    
    # New Tags
    "shop.item.exclusive_plant": {
        "de": "Exklusive Pflanze", "en": "Exclusive Plant", "es": "Planta Exclusiva", "fr": "Plante Exclusive", "hi": "विशिष्ट पौधा", "it": "Pianta Esclusiva", "ja": "限定植物", "ko": "독점 식물", "nl": "Exclusieve Plant", "pl": "Ekskluzywna Roślina", "pt": "Planta Exclusiva", "pt-BR": "Planta Exclusiva", "ru": "Эксклюзивное Растение", "tr": "Özel Bitki", "zh-Hans": "专属植物", "zh-Hant": "專屬植物"
    },
    "habit.custom.bad_habit.desc": {
        "de": "Eigene schlechte Angewohnheit", "en": "Custom bad habit", "es": "Mal hábito personalizado", "fr": "Mauvaise habitude personnalisée", "hi": "कस्टम बुरी आदत", "it": "Cattiva abitudine personalizzata", "ja": "カスタム悪い習慣", "ko": "사용자 지정 나쁜 습관", "nl": "Aangepaste slechte gewoonte", "pl": "Własny zły nawyk", "pt": "Mau hábito personalizado", "pt-BR": "Mau hábito personalizado", "ru": "Пользовательская вредная привычка", "tr": "Özel kötü alışkanlık", "zh-Hans": "自定义坏习惯", "zh-Hant": "自定義壞習慣"
    },
    "screentime.exceeded.reason": {
        "de": "Bildschirmzeit-Limit überschritten", "en": "Screen time limit exceeded", "es": "Límite de tiempo de pantalla excedido", "fr": "Limite de temps d'écran dépassée", "hi": "स्क्रीन टाइम सीमा पार हो गई", "it": "Limite di tempo di utilizzo superato", "ja": "スクリーンタイムの制限を超えました", "ko": "화면 시간 제한 초과", "nl": "Schermtijdlimiet overschreden", "pl": "Przekroczono limit czasu przed ekranem", "pt": "Limite de tempo de tela excedido", "pt-BR": "Limite de tempo de tela excedido", "ru": "Превышен лимит экранного времени", "tr": "Ekran süresi sınırı aşıldı", "zh-Hans": "超出屏幕使用时间限制", "zh-Hant": "超出屏幕使用時間限制"
    },
    "notification.fallback.plant": {
        "de": "Pflanze", "en": "Plant", "es": "Planta", "fr": "Plante", "hi": "पौधा", "it": "Pianta", "ja": "植物", "ko": "식물", "nl": "Plant", "pl": "Roślina", "pt": "Planta", "pt-BR": "Planta", "ru": "Растение", "tr": "Bitki", "zh-Hans": "植物", "zh-Hant": "植物"
    },
    "notification.plant.singular": {
        "de": "Pflanze", "en": "plant", "es": "planta", "fr": "plante", "hi": "पौधा", "it": "pianta", "ja": "植物", "ko": "식물", "nl": "plant", "pl": "roślina", "pt": "planta", "pt-BR": "planta", "ru": "растение", "tr": "bitki", "zh-Hans": "植物", "zh-Hant": "植物"
    },
    "notification.plant.plural": {
        "de": "Pflanzen", "en": "plants", "es": "plantas", "fr": "plantes", "hi": "पौधे", "it": "piante", "ja": "植物", "ko": "식물들", "nl": "planten", "pl": "rośliny", "pt": "plantas", "pt-BR": "plantas", "ru": "растения", "tr": "bitkiler", "zh-Hans": "植物", "zh-Hant": "植物"
    },
    "intent.plant_entity.type": {
        "de": "Pflanze", "en": "Plant", "es": "Planta", "fr": "Plante", "hi": "पौधा", "it": "Pianta", "ja": "植物", "ko": "식물", "nl": "Plant", "pl": "Roślina", "pt": "Planta", "pt-BR": "Planta", "ru": "Растение", "tr": "Bitki", "zh-Hans": "植物", "zh-Hant": "植物"
    },
    "intent.water_plant.parameter": {
        "de": "Pflanze", "en": "Plant", "es": "Planta", "fr": "Plante", "hi": "पौधा", "it": "Pianta", "ja": "植物", "ko": "식물", "nl": "Plant", "pl": "Roślina", "pt": "Planta", "pt-BR": "Planta", "ru": "Растение", "tr": "Bitki", "zh-Hans": "植物", "zh-Hant": "植物"
    },
    "habit.history.pro_insights": {
        "de": "PRO INSIGHTS", "en": "PRO INSIGHTS", "es": "PRO INSIGHTS", "fr": "PRO INSIGHTS", "hi": "PRO INSIGHTS", "it": "PRO INSIGHTS", "ja": "PRO INSIGHTS", "ko": "PRO INSIGHTS", "nl": "PRO INSIGHTS", "pl": "PRO INSIGHTS", "pt": "PRO INSIGHTS", "pt-BR": "PRO INSIGHTS", "ru": "PRO INSIGHTS", "tr": "PRO INSIGHTS", "zh-Hans": "PRO INSIGHTS", "zh-Hant": "PRO INSIGHTS"
    },
    "habit.history.legend.not_watered": {
        "de": "Nicht gegossen", "en": "Not watered", "es": "Sin regar", "fr": "Non arrosée", "hi": "नहीं सींचा गया", "it": "Non innaffiato", "ja": "水やりなし", "ko": "물 안 줌", "nl": "Niet bewaterd", "pl": "Niepodlane", "pt": "Não regada", "pt-BR": "Não regada", "ru": "Не полито", "tr": "Sulanmadı", "zh-Hans": "未浇水", "zh-Hant": "未澆水"
    },
    "focus.session.pro_bonus": {
        "de": "Pro-Bonus", "en": "Pro Bonus", "es": "Bono Pro", "fr": "Bonus Pro", "hi": "प्रो बोनस", "it": "Bonus Pro", "ja": "プロボーナス", "ko": "프로 보너스", "nl": "Pro Bonus", "pl": "Bonus Pro", "pt": "Bônus Pro", "pt-BR": "Bônus Pro", "ru": "Pro-бонус", "tr": "Pro Bonusu", "zh-Hans": "Pro奖励", "zh-Hant": "Pro獎勵"
    },
    "stats.chart.week_number": {
        "de": "Woche %@", "en": "Week %@", "es": "Semana %@", "fr": "Semaine %@", "hi": "सप्ताह %@", "it": "Settimana %@", "ja": "%@週目", "ko": "%@주차", "nl": "Week %@", "pl": "Tydzień %@", "pt": "Semana %@", "pt-BR": "Semana %@", "ru": "Неделя %@", "tr": "Hafta %@", "zh-Hans": "第 %@ 周", "zh-Hant": "第 %@ 週"
    },
    "widget_routine_unavailable": {
        "de": "Keine Routine verfügbar", "en": "No routine available", "es": "Sin rutina disponible", "fr": "Aucune routine disponible", "hi": "कोई दिनचर्या उपलब्ध नहीं", "it": "Nessuna routine disponibile", "ja": "利用可能なルーティンなし", "ko": "사용 가능한 루틴 없음", "nl": "Geen routine beschikbaar", "pl": "Brak dostępnej rutyny", "pt": "Nenhuma rotina disponível", "pt-BR": "Nenhuma rotina disponível", "ru": "Нет доступной рутины", "tr": "Kullanılabilir rutin yok", "zh-Hans": "无可用日程", "zh-Hant": "無可用日程"
    },

    # Fixes for EN duplicates
    "body.tracking.delete_target": {
        "de": "Ziel löschen", "en": "Delete target", "es": "Eliminar objetivo", "fr": "Supprimer l'objectif", "hi": "लक्ष्य हटाएं", "it": "Elimina obiettivo", "ja": "目標を削除", "ko": "목표 삭제", "nl": "Doel verwijderen", "pl": "Usuń cel", "pt": "Excluir meta", "pt-BR": "Excluir meta", "ru": "Удалить цель", "tr": "Hedefi sil", "zh-Hans": "删除目标", "zh-Hant": "刪除目標"
    },
    "body.tracking.manual_entries": {
        "de": "Manuelle Einträge", "en": "Manual entries", "es": "Entradas manuales", "fr": "Entrées manuelles", "hi": "मैन्युअल प्रविष्टियां", "it": "Inserimenti manuali", "ja": "手動入力", "ko": "수동 입력", "nl": "Handmatige invoer", "pl": "Wpisy ręczne", "pt": "Entradas manuais", "pt-BR": "Entradas manuais", "ru": "Ручные записи", "tr": "Manuel girişler", "zh-Hans": "手动输入", "zh-Hant": "手動輸入"
    },
    "body.tracking.no_manual_entries": {
        "de": "Keine manuellen Einträge", "en": "No manual entries", "es": "Sin entradas manuales", "fr": "Aucune entrée manuelle", "hi": "कोई मैन्युअल प्रविष्टियां नहीं", "it": "Nessun inserimento manuale", "ja": "手動入力なし", "ko": "수동 입력 없음", "nl": "Geen handmatige invoer", "pl": "Brak wpisów ręcznych", "pt": "Sem entradas manuais", "pt-BR": "Sem entradas manuais", "ru": "Нет ручных записей", "tr": "Manuel giriş yok", "zh-Hans": "无手动输入", "zh-Hant": "無手動輸入"
    },
    "body.tracking.no_target_measurement": {
        "de": "Kein Zielwert festgelegt", "en": "No target set", "es": "Ningún objetivo establecido", "fr": "Aucun objectif fixé", "hi": "कोई लक्ष्य निर्धारित नहीं", "it": "Nessun obiettivo impostato", "ja": "目標が設定されていません", "ko": "목표가 설정되지 않음", "nl": "Geen doel ingesteld", "pl": "Nie ustalono celu", "pt": "Nenhum alvo definido", "pt-BR": "Nenhum alvo definido", "ru": "Цель не установлена", "tr": "Hedef belirlenmedi", "zh-Hans": "未设置目标", "zh-Hant": "未設置目標"
    },
    "body.tracking.no_target_weight": {
        "de": "Kein Zielgewicht festgelegt", "en": "No target weight set", "es": "Sin peso objetivo establecido", "fr": "Aucun poids cible fixé", "hi": "कोई लक्ष्य वजन निर्धारित नहीं", "it": "Nessun peso obiettivo impostato", "ja": "目標体重が設定されていません", "ko": "목표 체중이 설정되지 않음", "nl": "Geen streefgewicht ingesteld", "pl": "Brak docelowej wagi", "pt": "Sem peso alvo", "pt-BR": "Sem peso alvo", "ru": "Целевой вес не установлен", "tr": "Hedef ağırlık belirlenmedi", "zh-Hans": "未设置目标体重", "zh-Hant": "未設置目標體重"
    },
    "body.tracking.tip.measurements": {
        "de": "Tipp: Körperumfänge verändern sich langsam. Wir empfehlen, sie nur einmal im Monat zu messen, um echte Fortschritte zu sehen.",
        "en": "Tip: Body measurements change slowly. We recommend measuring them only once a month to see real progress.",
        "es": "Consejo: Las medidas cambian lentamente. Recomendamos medirlas una vez al mes.",
        "fr": "Astuce : Les mensurations changent lentement. Nous recommandons de les mesurer une fois par mois.",
        "hi": "युक्ति: शरीर का माप धीरे-धीरे बदलता है। हम महीने में केवल एक बार मापने की सलाह देते हैं।",
        "it": "Suggerimento: Le misure cambiano lentamente. Si consiglia di misurare una volta al mese.",
        "ja": "ヒント：体のサイズはゆっくりと変化します。月1回の測定をお勧めします。",
        "ko": "팁: 신체 치수는 천천히 변합니다. 한 달에 한 번만 측정하는 것을 권장합니다.",
        "nl": "Tip: Lichaamsmaten veranderen langzaam. We raden aan om één keer per maand te meten.",
        "pl": "Wskazówka: Wymiary ciała zmieniają się powoli. Zalecamy mierzenie raz w miesiącu.",
        "pt": "Dica: As medidas mudam lentamente. Recomendamos medi-las apenas uma vez por mês.",
        "pt-BR": "Dica: As medidas mudam lentamente. Recomendamos medi-las apenas uma vez por mês.",
        "ru": "Совет: Размеры тела меняются медленно. Рекомендуем измерять их раз в месяц.",
        "tr": "İpucu: Vücut ölçüleri yavaş değişir. Ayda sadece bir kez ölçmenizi öneririz.",
        "zh-Hans": "提示：身体围度变化缓慢。我们建议每月仅测量一次以查看真正的进步。",
        "zh-Hant": "提示：身體圍度變化緩慢。我們建議每月僅測量一次以查看真正的進步。"
    },
    "body.tracking.tip.weight": {
        "de": "Tipp: Für beste Ergebnisse empfehlen wir, das Gewicht jeden Morgen zur selben Zeit, nüchtern und ohne vorher etwas zu essen, zu tracken.",
        "en": "Tip: For best results, we recommend tracking weight every morning at the same time, before eating or drinking.",
        "es": "Consejo: Para mejores resultados, recomendamos registrar el peso todas las mañanas.",
        "fr": "Astuce : Pour de meilleurs résultats, recommandez de suivre le poids chaque matin.",
        "hi": "युक्ति: सर्वोत्तम परिणामों के लिए, हम हर सुबह वजन को ट्रैक करने की सलाह देते हैं।",
        "it": "Suggerimento: Per i migliori risultati, si consiglia di tracciare il peso ogni mattina.",
        "ja": "ヒント：最良の結果を得るには、毎朝同じ時間に体重を記録することをお勧めします。",
        "ko": "팁: 최상의 결과를 위해 매일 아침 같은 시간에 체중을 기록하는 것을 권장합니다.",
        "nl": "Tip: Voor de beste resultaten raden we aan het gewicht elke ochtend bij te houden.",
        "pl": "Wskazówka: Najlepsze wyniki daje ważenie się codziennie rano na czczo.",
        "pt": "Dica: Para melhores resultados, recomendamos registrar o peso todas as manhãs.",
        "pt-BR": "Dica: Para melhores resultados, recomendamos registrar o peso todas as manhãs.",
        "ru": "Совет: Для достижения наилучших результатов рекомендуем отслеживать вес каждое утро натощак.",
        "tr": "İpucu: En iyi sonuçlar için her sabah aynı saatte kilonuzu izlemenizi öneririz.",
        "zh-Hans": "提示：为了获得最佳结果，我们建议每天早上在同一时间、空腹时记录体重。",
        "zh-Hant": "提示：為了獲得最佳結果，我們建議每天早上在同一時間、空腹時記錄體重。"
    },
    "sex.none": {
        "de": "Auswählen", "en": "Select", "es": "Seleccionar", "fr": "Sélectionner", "hi": "चुनें", "it": "Seleziona", "ja": "選択", "ko": "선택", "nl": "Selecteren", "pl": "Wybierz", "pt": "Selecionar", "pt-BR": "Selecionar", "ru": "Выбрать", "tr": "Seç", "zh-Hans": "选择", "zh-Hant": "選擇"
    },
    "shop.tab.items.new": {
        "de": "Schlechte Gewohnheiten", "en": "Bad Habits", "es": "Malos hábitos", "fr": "Mauvaises habitudes", "hi": "बुरी आदतें", "it": "Cattive abitudini", "ja": "悪い習慣", "ko": "나쁜 습관", "nl": "Slechte gewoontes", "pl": "Złe nawyki", "pt": "Maus hábitos", "pt-BR": "Maus hábitos", "ru": "Вредные привычки", "tr": "Kötü Alışkanlıklar", "zh-Hans": "坏习惯", "zh-Hant": "壞習慣"
    },
    "shop.tab.plants.new": {
        "de": "Gute Gewohnheiten", "en": "Good Habits", "es": "Buenos hábitos", "fr": "Bonnes habitudes", "hi": "अच्छी आदतें", "it": "Buone abitudini", "ja": "良い習慣", "ko": "좋은 습관", "nl": "Goede gewoontes", "pl": "Dobre nawyki", "pt": "Bons hábitos", "pt-BR": "Bons hábitos", "ru": "Полезные привычки", "tr": "İyi Alışkanlıklar", "zh-Hans": "好习惯", "zh-Hant": "好習慣"
    },
    "widget_interactive_todos_desc": {
        "de": "Erledige deine To-Dos direkt vom Homescreen.",
        "en": "Complete your To-Dos straight from your homescreen.",
        "es": "Completa tus tareas directamente desde tu pantalla de inicio.",
        "fr": "Terminez vos tâches directement depuis votre écran d'accueil.",
        "hi": "अपने होमस्क्रीन से ही अपने टू-डू पूरे करें।",
        "it": "Completa le tue attività direttamente dalla schermata iniziale.",
        "ja": "ホーム画面から直接To-Doを完了させましょう。",
        "ko": "홈 화면에서 바로 할 일을 완료하세요.",
        "nl": "Voltooi je To-Do's rechtstreeks vanaf je startscherm.",
        "pl": "Kończ swoje zadania prosto z ekranu głównego.",
        "pt": "Conclua suas tarefas diretamente da tela inicial.",
        "pt-BR": "Conclua suas tarefas diretamente da tela inicial.",
        "ru": "Выполняйте свои задачи прямо с главного экрана.",
        "tr": "Görevlerinizi doğrudan ana ekranınızdan tamamlayın.",
        "zh-Hans": "直接从主屏幕完成您的待办事项。",
        "zh-Hant": "直接從主屏幕完成您的待辦事項。"
    },
    "fitness.nutrition.summary": {
        "de": "%lld kcal / %lld kcal",
        "en": "%lld kcal / %lld kcal",
        "es": "%lld kcal / %lld kcal",
        "fr": "%lld kcal / %lld kcal",
        "hi": "%lld किलो कैलोरी / %lld किलो कैलोरी",
        "it": "%lld kcal / %lld kcal",
        "ja": "%lld kcal / %lld kcal",
        "ko": "%lld kcal / %lld kcal",
        "nl": "%lld kcal / %lld kcal",
        "pl": "%lld kcal / %lld kcal",
        "pt": "%lld kcal / %lld kcal",
        "pt-BR": "%lld kcal / %lld kcal",
        "ru": "%lld ккал / %lld ккал",
        "tr": "%lld kcal / %lld kcal",
        "zh-Hans": "%lld kcal / %lld kcal",
        "zh-Hant": "%lld kcal / %lld kcal"
    },
    "fitness.strength.summary.min": {
        "de": "%lld / %lld min", "en": "%lld / %lld min", "es": "%lld / %lld min", "fr": "%lld / %lld min", "hi": "%lld / %lld मिनट", "it": "%lld / %lld min", "ja": "%lld / %lld 分", "ko": "%lld / %lld 분", "nl": "%lld / %lld min", "pl": "%lld / %lld min", "pt": "%lld / %lld min", "pt-BR": "%lld / %lld min", "ru": "%lld / %lld мин", "tr": "%lld / %lld dk", "zh-Hans": "%lld / %lld 分钟", "zh-Hant": "%lld / %lld 分鐘"
    },
    "sex.male": {
        "de": "Männlich", "en": "Male", "es": "Masculino", "fr": "Masculin", "hi": "पुरुष", "it": "Maschio", "ja": "男性", "ko": "남성", "nl": "Mannelijk", "pl": "Mężczyzna", "pt": "Masculino", "pt-BR": "Masculino", "ru": "Мужской", "tr": "Erkek", "zh-Hans": "男性", "zh-Hant": "男性"
    },
    
    # Chart keys that were literal English before
    "Tag": {
        "de": "Tag", "en": "Day", "es": "Día", "fr": "Jour", "hi": "दिन", "it": "Giorno", "ja": "日", "ko": "일", "nl": "Dag", "pl": "Dzień", "pt": "Dia", "pt-BR": "Dia", "ru": "День", "tr": "Gün", "zh-Hans": "天", "zh-Hant": "天"
    },
    "Selected Tag": {
        "de": "Ausgewählter Tag", "en": "Selected Day", "es": "Día seleccionado", "fr": "Jour sélectionné", "hi": "चयनित दिन", "it": "Giorno selezionato", "ja": "選択された日", "ko": "선택된 날", "nl": "Geselecteerde dag", "pl": "Wybrany dzień", "pt": "Dia selecionado", "pt-BR": "Dia selecionado", "ru": "Выбранный день", "tr": "Seçilen Gün", "zh-Hans": "选中日期", "zh-Hant": "選中日期"
    },
    "Selected Gegossen": {
        "de": "Ausgewähltes Gießen", "en": "Selected Watering", "es": "Riego seleccionado", "fr": "Arrosage sélectionné", "hi": "चयनित पानी डालना", "it": "Innaffiatura selezionata", "ja": "選択された水やり", "ko": "선택된 물주기", "nl": "Geselecteerde bewatering", "pl": "Wybrane podlewanie", "pt": "Rega selecionada", "pt-BR": "Rega selecionada", "ru": "Выбранный полив", "tr": "Seçilen Sulama", "zh-Hans": "选中浇水", "zh-Hant": "選中澆水"
    }
}

path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, dict_langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    if "localizations" not in data["strings"][key]:
        data["strings"][key]["localizations"] = {}
        
    for lang, val in dict_langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }
        
# also clear stale states so they don't appear as incomplete
for k in data["strings"]:
    if data["strings"][k].get("extractionState") == "stale":
        del data["strings"][k]["extractionState"]
        # keep it manual just in case
        data["strings"][k]["extractionState"] = "manual"

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Catalog updated successfully.")
