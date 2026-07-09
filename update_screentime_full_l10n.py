import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

all_strings = {
    # --- Blocked Apps title ---
    "screenTime.blocked.apps.title": {
        "de": "Blockierte Apps",
        "en": "Blocked Apps",
        "es": "Apps bloqueadas",
        "fr": "Apps bloquées",
        "it": "App bloccate",
        "ja": "ブロック済みアプリ",
        "ko": "차단된 앱",
        "nl": "Geblokkeerde apps",
        "pl": "Zablokowane aplikacje",
        "pt": "Apps bloqueados",
        "tr": "Engellenen Uygulamalar"
    },
    # --- Screen Time main ---
    "screenTime.title": {
        "de": "Bildschirmzeit",
        "en": "Screen Time",
        "es": "Tiempo en pantalla",
        "fr": "Temps d'écran",
        "it": "Tempo di utilizzo",
        "ja": "スクリーンタイム",
        "ko": "화면 시간",
        "nl": "Schermtijd",
        "pl": "Czas ekranu",
        "pt": "Tempo de ecrã",
        "tr": "Ekran Süresi"
    },
    "screenTime.blocked.title": {
        "de": "Bildschirmzeit aktiv",
        "en": "Screen Time Active",
        "es": "Tiempo de pantalla activo",
        "fr": "Temps d'écran actif",
        "it": "Tempo di utilizzo attivo",
        "ja": "スクリーンタイム有効中",
        "ko": "화면 시간 활성 중",
        "nl": "Schermtijd actief",
        "pl": "Czas ekranu aktywny",
        "pt": "Tempo de ecrã ativo",
        "tr": "Ekran Süresi Etkin"
    },
    "screenTime.blocked.desc": {
        "de": "Du befindest dich gerade in deiner aktiven Block-Zeit.",
        "en": "You are currently in your active block window.",
        "es": "Estás actualmente en tu ventana de bloqueo activa.",
        "fr": "Vous êtes actuellement dans votre plage de blocage active.",
        "it": "Sei attualmente nel tuo intervallo di blocco attivo.",
        "ja": "現在アクティブなブロック時間帯です。",
        "ko": "현재 활성 차단 시간대에 있습니다.",
        "nl": "Je bevindt je momenteel in je actieve blokkeerperiode.",
        "pl": "Jesteś obecnie w aktywnym oknie blokady.",
        "pt": "Está atualmente na sua janela de bloqueio ativa.",
        "tr": "Şu anda aktif engelleme pencerenizdesiniz."
    },
    "screenTime.emergency.unlock": {
        "de": "Notfall-Entsperrung",
        "en": "Emergency Unlock",
        "es": "Desbloqueo de emergencia",
        "fr": "Déverrouillage d'urgence",
        "it": "Sblocco di emergenza",
        "ja": "緊急ロック解除",
        "ko": "긴급 잠금 해제",
        "nl": "Noodontgrendeling",
        "pl": "Awaryjne odblokowanie",
        "pt": "Desbloqueio de emergência",
        "tr": "Acil Kilit Açma"
    },
    "screenTime.auth.request": {
        "de": "Bildschirmzeit-Zugriff erlauben",
        "en": "Allow Screen Time Access",
        "es": "Permitir acceso al tiempo de pantalla",
        "fr": "Autoriser l'accès au temps d'écran",
        "it": "Consenti accesso al tempo di utilizzo",
        "ja": "スクリーンタイムのアクセスを許可",
        "ko": "화면 시간 접근 허용",
        "nl": "Schermtijdtoegang toestaan",
        "pl": "Zezwól na dostęp do czasu ekranu",
        "pt": "Permitir acesso ao tempo de ecrã",
        "tr": "Ekran Süresi Erişimine İzin Ver"
    },
    # --- Adult Filter ---
    "screenTime.suggestions.adult.title": {
        "de": "Adult Filter",
        "en": "Adult Filter",
        "es": "Filtro adulto",
        "fr": "Filtre adulte",
        "it": "Filtro adulti",
        "ja": "アダルトフィルター",
        "ko": "성인 필터",
        "nl": "Volwassenenfilter",
        "pl": "Filtr dla dorosłych",
        "pt": "Filtro adulto",
        "tr": "Yetişkin Filtresi"
    },
    # --- Schedule ---
    "screenTime.schedule.title": {
        "de": "Block-Zeitplan",
        "en": "Block Schedule",
        "es": "Horario de bloqueo",
        "fr": "Plage de blocage",
        "it": "Piano di blocco",
        "ja": "ブロックスケジュール",
        "ko": "차단 일정",
        "nl": "Blokkeerplan",
        "pl": "Harmonogram blokowania",
        "pt": "Agenda de bloqueio",
        "tr": "Engelleme Takvimi"
    },
    "screenTime.schedule.active": {
        "de": "Zeitplan aktivieren",
        "en": "Enable Schedule",
        "es": "Activar horario",
        "fr": "Activer la plage",
        "it": "Attiva piano",
        "ja": "スケジュールを有効にする",
        "ko": "일정 활성화",
        "nl": "Plan activeren",
        "pl": "Włącz harmonogram",
        "pt": "Ativar agenda",
        "tr": "Takvimi Etkinleştir"
    },
    "screenTime.schedule.applyWeekdays": {
        "de": "Mo–Fr gleich",
        "en": "Apply Mon–Fri",
        "es": "Aplicar Lu–Vi",
        "fr": "Appliquer Lun–Ven",
        "it": "Applica Lun–Ven",
        "ja": "月〜金に適用",
        "ko": "월~금에 적용",
        "nl": "Ma–Vr toepassen",
        "pl": "Zastosuj Pon–Pt",
        "pt": "Aplicar Seg–Sex",
        "tr": "Pzt–Cum Uygula"
    },
    "screenTime.schedule.applyWeekend": {
        "de": "Sa–So gleich",
        "en": "Apply Sat–Sun",
        "es": "Aplicar Sáb–Dom",
        "fr": "Appliquer Sam–Dim",
        "it": "Applica Sab–Dom",
        "ja": "土・日に適用",
        "ko": "토・일에 적용",
        "nl": "Za–Zo toepassen",
        "pl": "Zastosuj Sob–Nd",
        "pt": "Aplicar Sáb–Dom",
        "tr": "Cmt–Paz Uygula"
    },
    "screenTime.schedule.start": {
        "de": "Startzeit",
        "en": "Start Time",
        "es": "Hora de inicio",
        "fr": "Heure de début",
        "it": "Ora di inizio",
        "ja": "開始時刻",
        "ko": "시작 시간",
        "nl": "Begintijd",
        "pl": "Czas rozpoczęcia",
        "pt": "Hora de início",
        "tr": "Başlangıç Saati"
    },
    "screenTime.schedule.end": {
        "de": "Endzeit",
        "en": "End Time",
        "es": "Hora de fin",
        "fr": "Heure de fin",
        "it": "Ora di fine",
        "ja": "終了時刻",
        "ko": "종료 시간",
        "nl": "Eindtijd",
        "pl": "Czas zakończenia",
        "pt": "Hora de fim",
        "tr": "Bitiş Saati"
    },
    "screenTime.schedule.day.inactive": {
        "de": "Inaktiv",
        "en": "Inactive",
        "es": "Inactivo",
        "fr": "Inactif",
        "it": "Inattivo",
        "ja": "無効",
        "ko": "비활성",
        "nl": "Inactief",
        "pl": "Nieaktywny",
        "pt": "Inativo",
        "tr": "Etkin Değil"
    },
    "screenTime.schedule.select_apps": {
        "de": "Apps & Kategorien für Zeitplan",
        "en": "Apps & Categories for Schedule",
        "es": "Apps y categorías para el horario",
        "fr": "Apps et catégories pour la plage",
        "it": "App e categorie per il piano",
        "ja": "スケジュール用アプリとカテゴリ",
        "ko": "일정용 앱 및 카테고리",
        "nl": "Apps en categorieën voor plan",
        "pl": "Aplikacje i kategorie dla planu",
        "pt": "Apps e categorias para a agenda",
        "tr": "Takvim için Uygulamalar ve Kategoriler"
    },
    # --- Weekdays ---
    "weekday.monday":    {"de":"Montag","en":"Monday","es":"Lunes","fr":"Lundi","it":"Lunedì","ja":"月曜日","ko":"월요일","nl":"Maandag","pl":"Poniedziałek","pt":"Segunda-feira","tr":"Pazartesi"},
    "weekday.tuesday":   {"de":"Dienstag","en":"Tuesday","es":"Martes","fr":"Mardi","it":"Martedì","ja":"火曜日","ko":"화요일","nl":"Dinsdag","pl":"Wtorek","pt":"Terça-feira","tr":"Salı"},
    "weekday.wednesday": {"de":"Mittwoch","en":"Wednesday","es":"Miércoles","fr":"Mercredi","it":"Mercoledì","ja":"水曜日","ko":"수요일","nl":"Woensdag","pl":"Środa","pt":"Quarta-feira","tr":"Çarşamba"},
    "weekday.thursday":  {"de":"Donnerstag","en":"Thursday","es":"Jueves","fr":"Jeudi","it":"Giovedì","ja":"木曜日","ko":"목요일","nl":"Donderdag","pl":"Czwartek","pt":"Quinta-feira","tr":"Perşembe"},
    "weekday.friday":    {"de":"Freitag","en":"Friday","es":"Viernes","fr":"Vendredi","it":"Venerdì","ja":"金曜日","ko":"금요일","nl":"Vrijdag","pl":"Piątek","pt":"Sexta-feira","tr":"Cuma"},
    "weekday.saturday":  {"de":"Samstag","en":"Saturday","es":"Sábado","fr":"Samedi","it":"Sabato","ja":"土曜日","ko":"토요일","nl":"Zaterdag","pl":"Sobota","pt":"Sábado","tr":"Cumartesi"},
    "weekday.sunday":    {"de":"Sonntag","en":"Sunday","es":"Domingo","fr":"Dimanche","it":"Domenica","ja":"日曜日","ko":"일요일","nl":"Zondag","pl":"Niedziela","pt":"Domingo","tr":"Pazar"},
    # --- Info ---
    "screenTime.info.title": {
        "de": "Wie funktioniert das?",
        "en": "How does this work?",
        "es": "¿Cómo funciona?",
        "fr": "Comment ça fonctionne ?",
        "it": "Come funziona?",
        "ja": "どのように機能しますか？",
        "ko": "어떻게 작동하나요?",
        "nl": "Hoe werkt dit?",
        "pl": "Jak to działa?",
        "pt": "Como funciona?",
        "tr": "Bu nasıl çalışır?"
    },
    "screenTime.info.desc": {
        "de": "Der Shield-Block zeigt einen Warn-Overlay über Apps. Die betroffenen Apps werden nicht gelöscht und können vom Nutzer weiterhin geöffnet werden (mit Bestätigung). Der Erwachsenen-Filter gilt nur in Safari.",
        "en": "The shield block shows a warning overlay over apps. Affected apps are not deleted and can still be opened (with confirmation). The adult filter only applies in Safari.",
        "es": "El bloqueo escudo muestra una superposición de advertencia sobre las apps. Las apps no se eliminan y aún pueden abrirse (con confirmación). El filtro adulto solo aplica en Safari.",
        "fr": "Le blocage shield affiche une superposition d'avertissement sur les apps. Les apps ne sont pas supprimées et peuvent toujours être ouvertes (avec confirmation). Le filtre adulte ne s'applique qu'à Safari.",
        "it": "Il blocco shield mostra una sovrapposizione di avviso sulle app. Le app non vengono eliminate e possono ancora essere aperte (con conferma). Il filtro adulti si applica solo in Safari.",
        "ja": "シールドブロックはアプリ上に警告を表示します。対象アプリは削除されず、確認後に開くことができます。アダルトフィルターはSafariのみ有効です。",
        "ko": "쉴드 차단은 앱 위에 경고를 표시합니다. 앱은 삭제되지 않으며 확인 후 열 수 있습니다. 성인 필터는 Safari에만 적용됩니다.",
        "nl": "Het shield-blok toont een waarschuwing over apps. Apps worden niet verwijderd en kunnen nog worden geopend (met bevestiging). Het volwassenenfilter geldt alleen in Safari.",
        "pl": "Blokada shield wyświetla ostrzeżenie nad aplikacjami. Aplikacje nie są usuwane i nadal można je otworzyć (z potwierdzeniem). Filtr dla dorosłych działa tylko w Safari.",
        "pt": "O bloqueio shield mostra um aviso sobre os apps. Os apps não são eliminados e ainda podem ser abertos (com confirmação). O filtro adulto aplica-se apenas no Safari.",
        "tr": "Kalkan bloğu uygulamalar üzerinde uyarı gösterir. Uygulamalar silinmez ve onay ile açılabilir. Yetişkin filtresi yalnızca Safari'de geçerlidir."
    },
}

added = 0
updated = 0

for key, lang_dict in all_strings.items():
    is_new = key not in data["strings"]
    if is_new:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
        added += 1
    else:
        updated += 1
    
    if "localizations" not in data["strings"][key]:
        data["strings"][key]["localizations"] = {}
    
    for lang in langs:
        val = lang_dict.get(lang, lang_dict["en"])
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {"state": "translated", "value": val}
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"Done. {added} new keys, {updated} updated. Total Screen Time keys: {len(all_strings)}")
