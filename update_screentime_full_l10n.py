import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

all_strings = {
    "screenTime.blocked.apps.title": {
        "en": "Blocked Apps", "de": "Blockierte Apps", "es": "Apps bloqueadas", "fr": "Apps bloquées",
        "it": "App bloccate", "ja": "ブロック済みアプリ", "ko": "차단된 앱", "nl": "Geblokkeerde apps",
        "pl": "Zablokowane aplikacje", "pt": "Apps bloqueados", "tr": "Engellenen Uygulamalar",
        "hi": "ब्लॉक किए गए ऐप्स", "ru": "Заблокированные приложения", "zh-Hans": "阻止的应用程序", "zh-Hant": "封鎖的應用程式"
    },
    "screenTime.title": {
        "en": "Screen Time", "de": "Bildschirmzeit", "es": "Tiempo en pantalla", "fr": "Temps d'écran",
        "it": "Tempo di utilizzo", "ja": "スクリーンタイム", "ko": "화면 시간", "nl": "Schermtijd",
        "pl": "Czas ekranu", "pt": "Tempo de ecrã", "tr": "Ekran Süresi",
        "hi": "स्क्रीन टाइम", "ru": "Экранное время", "zh-Hans": "屏幕使用时间", "zh-Hant": "螢幕使用時間"
    },
    "screenTime.blocked.title": {
        "en": "Screen Time Active", "de": "Bildschirmzeit aktiv", "es": "Tiempo de pantalla activo", "fr": "Temps d'écran actif",
        "it": "Tempo di utilizzo attivo", "ja": "スクリーンタイム有効中", "ko": "화면 시간 활성 중", "nl": "Schermtijd actief",
        "pl": "Czas ekranu aktywny", "pt": "Tempo de ecrã ativo", "tr": "Ekran Süresi Etkin",
        "hi": "स्क्रीन टाइम सक्रिय", "ru": "Экранное время активно", "zh-Hans": "屏幕使用时间已激活", "zh-Hant": "螢幕使用時間已啟動"
    },
    "screenTime.blocked.desc": {
        "en": "You are currently in your active block window.", "de": "Du befindest dich gerade in deiner aktiven Block-Zeit.", 
        "es": "Estás actualmente en tu ventana de bloqueo activa.", "fr": "Vous êtes actuellement dans votre plage de blocage active.",
        "it": "Sei attualmente nel tuo intervallo di blocco attivo.", "ja": "現在アクティブなブロック時間帯です。", "ko": "현재 활성 차단 시간대에 있습니다.", 
        "nl": "Je bevindt je momenteel in je actieve blokkeerperiode.", "pl": "Jesteś obecnie w aktywnym oknie blokady.", 
        "pt": "Está atualmente na sua janela de bloqueio ativa.", "tr": "Şu anda aktif engelleme pencerenizdesiniz.",
        "hi": "आप वर्तमान में अपने सक्रिय ब्लॉक विंडो में हैं।", "ru": "Вы сейчас находитесь в активном окне блокировки.", 
        "zh-Hans": "您目前正处于活动阻止时间段内。", "zh-Hant": "您目前正處於活動封鎖時間段內。"
    },
    "screenTime.emergency.unlock": {
        "en": "Emergency Unlock", "de": "Notfall-Entsperrung", "es": "Desbloqueo de emergencia", "fr": "Déverrouillage d'urgence",
        "it": "Sblocco di emergenza", "ja": "緊急ロック解除", "ko": "긴급 잠금 해제", "nl": "Noodontgrendeling",
        "pl": "Awaryjne odblokowanie", "pt": "Desbloqueio de emergência", "tr": "Acil Kilit Açma",
        "hi": "आपातकालीन अनलॉक", "ru": "Экстренная разблокировка", "zh-Hans": "紧急解锁", "zh-Hant": "緊急解鎖"
    },
    "screenTime.auth.request": {
        "en": "Allow Screen Time Access", "de": "Bildschirmzeit-Zugriff erlauben", "es": "Permitir acceso al tiempo de pantalla", "fr": "Autoriser l'accès au temps d'écran",
        "it": "Consenti accesso al tempo di utilizzo", "ja": "スクリーンタイムのアクセスを許可", "ko": "화면 시간 접근 허용", "nl": "Schermtijdtoegang toestaan",
        "pl": "Zezwól na dostęp do czasu ekranu", "pt": "Permitir acesso ao tempo de ecrã", "tr": "Ekran Süresi Erişimine İzin Ver",
        "hi": "स्क्रीन टाइम एक्सेस की अनुमति दें", "ru": "Разрешить доступ к экранному времени", "zh-Hans": "允许访问屏幕使用时间", "zh-Hant": "允許存取螢幕使用時間"
    },
    "screenTime.suggestions.adult.title": {
        "en": "Adult Filter", "de": "Adult Filter", "es": "Filtro adulto", "fr": "Filtre adulte",
        "it": "Filtro adulti", "ja": "アダルトフィルター", "ko": "성인 필터", "nl": "Volwassenenfilter",
        "pl": "Filtr dla dorosłych", "pt": "Filtro adulto", "tr": "Yetişkin Filtresi",
        "hi": "वयस्क फ़िल्टर", "ru": "Фильтр для взрослых", "zh-Hans": "成人内容过滤器", "zh-Hant": "成人內容過濾器"
    },
    "screenTime.schedule.title": {
        "en": "Block Schedule", "de": "Block-Zeitplan", "es": "Horario de bloqueo", "fr": "Plage de blocage",
        "it": "Piano di blocco", "ja": "ブロックスケジュール", "ko": "차단 일정", "nl": "Blokkeerplan",
        "pl": "Harmonogram blokowania", "pt": "Agenda de bloqueio", "tr": "Engelleme Takvimi",
        "hi": "ब्लॉक अनुसूची", "ru": "График блокировки", "zh-Hans": "阻止计划", "zh-Hant": "封鎖排程"
    },
    "screenTime.schedule.active": {
        "en": "Enable Schedule", "de": "Zeitplan aktivieren", "es": "Activar horario", "fr": "Activer la plage",
        "it": "Attiva piano", "ja": "スケジュールを有効にする", "ko": "일정 활성화", "nl": "Plan activeren",
        "pl": "Włącz harmonogram", "pt": "Ativar agenda", "tr": "Takvimi Etkinleştir",
        "hi": "अनुसूची सक्षम करें", "ru": "Включить график", "zh-Hans": "启用计划", "zh-Hant": "啟用排程"
    },
    "screenTime.schedule.applyWeekdays": {
        "en": "Apply Mon–Fri", "de": "Mo–Fr gleich", "es": "Aplicar Lu–Vi", "fr": "Appliquer Lun–Ven",
        "it": "Applica Lun–Ven", "ja": "月〜金に適用", "ko": "월~금에 적용", "nl": "Ma–Vr toepassen",
        "pl": "Zastosuj Pon–Pt", "pt": "Aplicar Seg–Sex", "tr": "Pzt–Cum Uygula",
        "hi": "सोम-शुक्र लागू करें", "ru": "Применить Пн-Пт", "zh-Hans": "应用周一至周五", "zh-Hant": "應用週一至週五"
    },
    "screenTime.schedule.applyWeekend": {
        "en": "Apply Sat–Sun", "de": "Sa–So gleich", "es": "Aplicar Sáb–Dom", "fr": "Appliquer Sam–Dim",
        "it": "Applica Sab–Dom", "ja": "土・日に適用", "ko": "토・일에 적용", "nl": "Za–Zo toepassen",
        "pl": "Zastosuj Sob–Nd", "pt": "Aplicar Sáb–Dom", "tr": "Cmt–Paz Uygula",
        "hi": "शनि-रवि लागू करें", "ru": "Применить Сб-Вс", "zh-Hans": "应用周六至周日", "zh-Hant": "應用週六至週日"
    },
    "screenTime.schedule.start": {
        "en": "Start Time", "de": "Startzeit", "es": "Hora de inicio", "fr": "Heure de début",
        "it": "Ora di inizio", "ja": "開始時刻", "ko": "시작 시간", "nl": "Begintijd",
        "pl": "Czas rozpoczęcia", "pt": "Hora de início", "tr": "Başlangıç Saati",
        "hi": "आरंभ समय", "ru": "Время начала", "zh-Hans": "开始时间", "zh-Hant": "開始時間"
    },
    "screenTime.schedule.end": {
        "en": "End Time", "de": "Endzeit", "es": "Hora de fin", "fr": "Heure de fin",
        "it": "Ora di fine", "ja": "終了時刻", "ko": "종료 시간", "nl": "Eindtijd",
        "pl": "Czas zakończenia", "pt": "Hora de fim", "tr": "Bitiş Saati",
        "hi": "अंत समय", "ru": "Время окончания", "zh-Hans": "结束时间", "zh-Hant": "結束時間"
    },
    "screenTime.schedule.day.inactive": {
        "en": "Inactive", "de": "Inaktiv", "es": "Inactivo", "fr": "Inactif",
        "it": "Inattivo", "ja": "無効", "ko": "비활성", "nl": "Inactief",
        "pl": "Nieaktywny", "pt": "Inativo", "tr": "Etkin Değil",
        "hi": "निष्क्रिय", "ru": "Неактивно", "zh-Hans": "未激活", "zh-Hant": "未啟用"
    },
    "screenTime.schedule.select_apps": {
        "en": "Apps & Categories for Schedule", "de": "Apps & Kategorien für Zeitplan", "es": "Apps y categorías para el horario", "fr": "Apps et catégories pour la plage",
        "it": "App e categorie per il piano", "ja": "スケジュール用アプリとカテゴリ", "ko": "일정용 앱 및 카테고리", "nl": "Apps en categorieën voor plan",
        "pl": "Aplikacje i kategorie dla planu", "pt": "Apps e categorias para a agenda", "tr": "Takvim için Uygulamalar ve Kategoriler",
        "hi": "अनुसूची के लिए ऐप्स और श्रेणियां", "ru": "Приложения и категории для графика", "zh-Hans": "计划的应用程序和类别", "zh-Hant": "排程的應用程式與類別"
    },
    "weekday.monday":    {"de":"Montag","en":"Monday","es":"Lunes","fr":"Lundi","it":"Lunedì","ja":"月曜日","ko":"월요일","nl":"Maandag","pl":"Poniedziałek","pt":"Segunda-feira","tr":"Pazartesi","hi":"सोमवार","ru":"Понедельник","zh-Hans":"星期一","zh-Hant":"星期一"},
    "weekday.tuesday":   {"de":"Dienstag","en":"Tuesday","es":"Martes","fr":"Mardi","it":"Martedì","ja":"火曜日","ko":"화요일","nl":"Dinsdag","pl":"Wtorek","pt":"Terça-feira","tr":"Salı","hi":"मंगलवार","ru":"Вторник","zh-Hans":"星期二","zh-Hant":"星期二"},
    "weekday.wednesday": {"de":"Mittwoch","en":"Wednesday","es":"Miércoles","fr":"Mercredi","it":"Mercoledì","ja":"水曜日","ko":"수요일","nl":"Woensdag","pl":"Środa","pt":"Quarta-feira","tr":"Çarşamba","hi":"बुधवार","ru":"Среда","zh-Hans":"星期三","zh-Hant":"星期三"},
    "weekday.thursday":  {"de":"Donnerstag","en":"Thursday","es":"Jueves","fr":"Jeudi","it":"Giovedì","ja":"木曜日","ko":"목요일","nl":"Donderdag","pl":"Czwartek","pt":"Quinta-feira","tr":"Perşembe","hi":"गुरुवार","ru":"Четверг","zh-Hans":"星期四","zh-Hant":"星期四"},
    "weekday.friday":    {"de":"Freitag","en":"Friday","es":"Viernes","fr":"Vendredi","it":"Venerdì","ja":"金曜日","ko":"금요일","nl":"Vrijdag","pl":"Piątek","pt":"Sexta-feira","tr":"Cuma","hi":"शुक्रवार","ru":"Пятница","zh-Hans":"星期五","zh-Hant":"星期五"},
    "weekday.saturday":  {"de":"Samstag","en":"Saturday","es":"Sábado","fr":"Samedi","it":"Sabato","ja":"土曜日","ko":"토요일","nl":"Zaterdag","pl":"Sobota","pt":"Sábado","tr":"Cumartesi","hi":"शनिवार","ru":"Суббота","zh-Hans":"星期六","zh-Hant":"星期六"},
    "weekday.sunday":    {"de":"Sonntag","en":"Sunday","es":"Domingo","fr":"Dimanche","it":"Domenica","ja":"日曜日","ko":"일요일","nl":"Zondag","pl":"Niedziela","pt":"Domingo","tr":"Pazar","hi":"रविवार","ru":"Воскресенье","zh-Hans":"星期日","zh-Hant":"星期日"},
    "screenTime.info.title": {
        "en": "How does this work?", "de": "Wie funktioniert das?", "es": "¿Cómo funciona?", "fr": "Comment ça fonctionne ?",
        "it": "Come funziona?", "ja": "どのように機能しますか？", "ko": "어떻게 작동하나요?", "nl": "Hoe werkt dit?",
        "pl": "Jak to działa?", "pt": "Como funciona?", "tr": "Bu nasıl çalışır?",
        "hi": "यह कैसे काम करता है?", "ru": "Как это работает?", "zh-Hans": "这是如何工作的？", "zh-Hant": "這是如何運作的？"
    },
    "screenTime.info.desc": {
        "en": "The shield block shows a warning overlay over apps. Affected apps are not deleted and can still be opened (with confirmation). The adult filter only applies in Safari.",
        "de": "Der Shield-Block zeigt einen Warn-Overlay über Apps. Die betroffenen Apps werden nicht gelöscht und können vom Nutzer weiterhin geöffnet werden (mit Bestätigung). Der Erwachsenen-Filter gilt nur in Safari.",
        "es": "El bloqueo escudo muestra una superposición de advertencia sobre las apps. Las apps no se eliminan y aún pueden abrirse (con confirmación). El filtro adulto solo aplica en Safari.",
        "fr": "Le blocage shield affiche une superposition d'avertissement sur les apps. Les apps ne sont pas supprimées et peuvent toujours être ouvertes (avec confirmation). Le filtre adulte ne s'applique qu'à Safari.",
        "it": "Il blocco shield mostra una sovrapposizione di avviso sulle app. Le app non vengono eliminate e possono ancora essere aperte (con conferma). Il filtro adulti si applica solo in Safari.",
        "ja": "シールドブロックはアプリ上に警告を表示します。対象アプリは削除されず、確認後に開くことができます。アダルトフィルターはSafariのみ有効です。",
        "ko": "쉴드 차단은 앱 위에 경고를 표시합니다. 앱은 삭제되지 않으며 확인 후 열 수 있습니다. 성인 필터는 Safari에만 적용됩니다.",
        "nl": "Het shield-blok toont een waarschuwing over apps. Apps worden niet verwijderd en kunnen nog worden geopend (met bevestiging). Het volwassenenfilter geldt alleen in Safari.",
        "pl": "Blokada shield wyświetla ostrzeżenie nad aplikacjami. Aplikacje nie są usuwane i nadal można je otworzyć (z potwierdzeniem). Filtr dla dorosłych działa tylko w Safari.",
        "pt": "O bloqueio shield mostra um aviso sobre os apps. Os apps não são eliminados e ainda podem ser abertos (com confirmação). O filtro adulto aplica-se apenas no Safari.",
        "tr": "Kalkan bloğu uygulamalar üzerinde uyarı gösterir. Uygulamalar silinmez ve onay ile açılabilir. Yetişkin filtresi yalnızca Safari'de geçerlidir.",
        "hi": "शील्ड ब्लॉक ऐप्स पर चेतावनी ओवरले दिखाता है। प्रभावित ऐप्स हटाए नहीं जाते हैं और अभी भी (पुष्टि के साथ) खोले जा सकते हैं। वयस्क फ़िल्टर केवल सफारी में लागू होता है।",
        "ru": "Блок щита показывает предупреждение поверх приложений. Пострадавшие приложения не удаляются и все еще могут быть открыты (с подтверждением). Фильтр для взрослых применяется только в Safari.",
        "zh-Hans": "屏蔽阻止在应用程序上显示警告覆盖。受影响的应用程序不会被删除，并且仍然可以（确认后）打开。成人内容过滤器仅适用于Safari。",
        "zh-Hant": "封鎖會在應用程式上顯示警告覆蓋。受影響的應用程式不會被刪除，並且仍然可以（確認後）打開。成人內容過濾器僅適用於Safari。"
    }
}

for key, lang_dict in all_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    if "localizations" not in data["strings"][key]:
        data["strings"][key]["localizations"] = {}
    for lang in langs:
        val = lang_dict.get(lang, lang_dict["en"])
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {"state": "translated", "value": val}
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated all 15 languages!")
