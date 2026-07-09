import json

translations = {
    "screentime.tracker.confirm_msg": {
        "en": "Do you really want to change the limit to the new target?",
        "es": "¿De verdad quieres cambiar el límite al nuevo objetivo?",
        "fr": "Voulez-vous vraiment modifier la limite vers le nouvel objectif ?",
        "hi": "क्या आप वास्तव में नए लक्ष्य पर सीमा बदलना चाहते हैं?",
        "it": "Vuoi davvero cambiare il limite al nuovo obiettivo?",
        "ja": "本当に制限を新しい目標に変更しますか？",
        "ko": "정말로 한도를 새로운 목표로 변경하시겠습니까?",
        "nl": "Wil je echt de limiet veranderen naar het nieuwe doel?",
        "pl": "Czy na pewno chcesz zmienić limit na nowy cel?",
        "pt": "Você realmente deseja alterar o limite para a nova meta?",
        "ru": "Вы действительно хотите изменить лимит на новую цель?",
        "tr": "Sınırı gerçekten yeni hedefe değiştirmek istiyor musunuz?",
        "zh-Hans": "您真的要把限制更改为新目标吗？",
        "zh-Hant": "您真的要把限制更改為新目標嗎？"
    },
    "screentime.tracker.confirm_title": {
        "en": "Save Limit?",
        "es": "¿Guardar límite?",
        "fr": "Enregistrer la limite ?",
        "hi": "सीमा सहेजें?",
        "it": "Salva limite?",
        "ja": "制限を保存しますか？",
        "ko": "한도 저장?",
        "nl": "Limiet opslaan?",
        "pl": "Zapisać limit?",
        "pt": "Salvar limite?",
        "ru": "Сохранить лимит?",
        "tr": "Sınırı Kaydet?",
        "zh-Hans": "保存限制？",
        "zh-Hant": "保存限制？"
    },
    "screentime.tracker.settings": {
        "en": "Blocker Settings",
        "es": "Ajustes del bloqueador",
        "fr": "Paramètres du bloqueur",
        "hi": "ब्लॉकर सेटिंग्स",
        "it": "Impostazioni Blocco",
        "ja": "ブロッカー設定",
        "ko": "차단기 설정",
        "nl": "Blocker-instellingen",
        "pl": "Ustawienia blokady",
        "pt": "Configurações do Bloqueador",
        "ru": "Настройки блокировщика",
        "tr": "Engelleyici Ayarları",
        "zh-Hans": "拦截器设置",
        "zh-Hant": "攔截器設置"
    },
    "screenTime.blocked.title": {
        "en": "Screen Time Blocked",
        "es": "Tiempo de pantalla bloqueado",
        "fr": "Temps d'écran bloqué",
        "hi": "स्क्रीन टाइम ब्लॉक किया गया",
        "it": "Tempo di Schermo Bloccato",
        "ja": "スクリーンタイムブロック中",
        "ko": "스크린타임 차단됨",
        "nl": "Schermtijd geblokkeerd",
        "pl": "Czas przed ekranem zablokowany",
        "pt": "Tempo de Tela Bloqueado",
        "ru": "Экранное время заблокировано",
        "tr": "Ekran Süresi Engellendi",
        "zh-Hans": "屏幕使用时间被阻止",
        "zh-Hant": "螢幕使用時間被阻止"
    },
    "screenTime.blocked.desc": {
        "en": "You are currently in your active block time. You can only change these settings once the block time has expired.",
        "es": "Estás en tu tiempo de bloqueo activo. Solo puedes cambiar estos ajustes una vez que expire el tiempo.",
        "fr": "Vous êtes actuellement dans votre temps de blocage actif. Vous ne pouvez modifier ces paramètres qu'une fois le temps expiré.",
        "hi": "आप वर्तमान में अपने सक्रिय ब्लॉक समय में हैं। आप ब्लॉक समय समाप्त होने के बाद ही इन सेटिंग्स को बदल सकते हैं।",
        "it": "Sei attualmente nel tuo periodo di blocco attivo. Puoi modificare queste impostazioni solo al termine del blocco.",
        "ja": "現在、有効なブロック時間中です。ブロック時間が終了するまで設定を変更できません。",
        "ko": "현재 활성 차단 시간입니다. 차단 시간이 만료되어야만 이 설정을 변경할 수 있습니다.",
        "nl": "Je bevindt je momenteel in je actieve bloktijd. Je kunt deze instellingen pas wijzigen nadat de bloktijd is verstreken.",
        "pl": "Jesteś obecnie w aktywnym czasie blokady. Możesz zmienić te ustawienia dopiero po upływie czasu blokady.",
        "pt": "Você está atualmente em seu tempo de bloqueio ativo. Você só pode alterar essas configurações após o término do tempo.",
        "ru": "В настоящее время действует время блокировки. Вы сможете изменить эти настройки только после истечения времени.",
        "tr": "Şu anda aktif engelleme sürenizdesiniz. Bu ayarları yalnızca engelleme süresi dolduğunda değiştirebilirsiniz.",
        "zh-Hans": "您目前处于活动阻止时间内。阻止时间结束后，您才能更改这些设置。",
        "zh-Hant": "您目前處於活動阻止時間內。阻止時間結束後，您才能更改這些設置。"
    },
    "screenTime.auth.request": {
        "en": "Allow Screen Time Access",
        "es": "Permitir acceso al tiempo de pantalla",
        "fr": "Autoriser l'accès au temps d'écran",
        "hi": "स्क्रीन टाइम एक्सेस की अनुमति दें",
        "it": "Consenti l'accesso al tempo di utilizzo",
        "ja": "スクリーンタイムアクセスを許可",
        "ko": "스크린타임 접근 허용",
        "nl": "Schermtijd toegang toestaan",
        "pl": "Zezwól na dostęp do Czasu przed ekranem",
        "pt": "Permitir acesso ao Tempo de Tela",
        "ru": "Разрешить доступ к экранному времени",
        "tr": "Ekran Süresi Erişimine İzin Ver",
        "zh-Hans": "允许访问屏幕使用时间",
        "zh-Hant": "允許訪問螢幕使用時間"
    },
    "screenTime.schedule.active": {
        "en": "Enable Block Schedule",
        "es": "Activar horario de bloqueo",
        "fr": "Activer le calendrier de blocage",
        "hi": "ब्लॉक अनुसूची सक्षम करें",
        "it": "Abilita programma di blocco",
        "ja": "ブロックスケジュールを有効にする",
        "ko": "차단 일정 활성화",
        "nl": "Blokschema inschakelen",
        "pl": "Włącz harmonogram blokady",
        "pt": "Ativar Cronograma de Bloqueio",
        "ru": "Включить расписание блокировки",
        "tr": "Engelleme Planını Etkinleştir",
        "zh-Hans": "启用阻止时间表",
        "zh-Hant": "啟用阻止時間表"
    },
    "screenTime.schedule.start": {
        "en": "Start Time",
        "es": "Hora de inicio",
        "fr": "Heure de début",
        "hi": "प्रारंभ समय",
        "it": "Ora di inizio",
        "ja": "開始時間",
        "ko": "시작 시간",
        "nl": "Starttijd",
        "pl": "Czas rozpoczęcia",
        "pt": "Hora de Início",
        "ru": "Время начала",
        "tr": "Başlangıç Saati",
        "zh-Hans": "开始时间",
        "zh-Hant": "開始時間"
    },
    "screenTime.schedule.end": {
        "en": "End Time",
        "es": "Hora de finalización",
        "fr": "Heure de fin",
        "hi": "समाप्ति समय",
        "it": "Ora di fine",
        "ja": "終了時間",
        "ko": "종료 시간",
        "nl": "Eindtijd",
        "pl": "Czas zakończenia",
        "pt": "Hora de Término",
        "ru": "Время окончания",
        "tr": "Bitiş Saati",
        "zh-Hans": "结束时间",
        "zh-Hant": "結束時間"
    },
    "screenTime.schedule.select_apps": {
        "en": "Select Apps & Categories",
        "es": "Seleccionar aplicaciones y categorías",
        "fr": "Sélectionner des applications et catégories",
        "hi": "ऐप्स और श्रेणियां चुनें",
        "it": "Seleziona App e Categorie",
        "ja": "アプリとカテゴリを選択",
        "ko": "앱 및 카테고리 선택",
        "nl": "Selecteer apps en categorieën",
        "pl": "Wybierz aplikacje i kategorie",
        "pt": "Selecionar Apps e Categorias",
        "ru": "Выбрать приложения и категории",
        "tr": "Uygulamaları ve Kategorileri Seçin",
        "zh-Hans": "选择应用和类别",
        "zh-Hant": "選擇應用和類別"
    },
    "screenTime.info.title": {
        "en": "How does it work?",
        "es": "¿Cómo funciona?",
        "fr": "Comment ça marche ?",
        "hi": "यह कैसे काम करता है?",
        "it": "Come funziona?",
        "ja": "仕組みは？",
        "ko": "어떻게 작동하나요?",
        "nl": "Hoe werkt het?",
        "pl": "Jak to działa?",
        "pt": "Como funciona?",
        "ru": "Как это работает?",
        "tr": "Nasıl çalışır?",
        "zh-Hans": "它是如何工作的？",
        "zh-Hant": "它是如何工作的？"
    },
    "screenTime.info.desc": {
        "en": "During the active block time, you cannot disable the blocker here. If you exceed a daily limit, the 'Too much screen time' habit is automatically bought/checked. If you stick to the limit, your plant is automatically watered at the end of the day.",
        "es": "Durante el tiempo de bloqueo activo, no puedes desactivar el bloqueador aquí. Si excedes el límite, el mal hábito de pantalla se aplicará automáticamente. Si lo cumples, tu planta será regada al final del día.",
        "fr": "Pendant le temps de blocage actif, vous ne pouvez pas désactiver le bloqueur. Si vous dépassez la limite, la mauvaise habitude d'écran s'applique automatiquement. Si vous la respectez, votre plante sera arrosée en fin de journée.",
        "hi": "सक्रिय ब्लॉक समय के दौरान, आप यहाँ ब्लॉकर को अक्षम नहीं कर सकते हैं। यदि आप सीमा से अधिक हैं, तो स्क्रीन टाइम आदत स्वचालित रूप से खरीदी जाती है। यदि आप सीमा पर टिके रहते हैं, तो आपके पौधे को दिन के अंत में स्वचालित रूप से पानी दिया जाता है।",
        "it": "Durante il blocco attivo, non puoi disabilitare il blocco. Se superi il limite, l'abitudine dello schermo viene applicata in automatico. Se lo rispetti, la tua pianta verrà annaffiata a fine giornata.",
        "ja": "有効なブロック時間中は、ここでブロッカーを無効にすることはできません。制限を超えると、スクリーンタイムの悪習慣が自動的に適用されます。制限を守れば、一日の終わりに植物に自動的に水がやられます。",
        "ko": "활성 차단 시간 동안에는 차단기를 비활성화할 수 없습니다. 한도를 초과하면 스크린타임 습관이 자동으로 적용됩니다. 한도를 지키면 하루가 끝날 때 식물에 자동으로 물을 줍니다.",
        "nl": "Tijdens de actieve bloktijd kun je de blokkering niet uitschakelen. Als je de limiet overschrijdt, wordt de schermtijdgewoonte automatisch toegepast. Als je je aan de limiet houdt, krijgt je plant aan het eind van de dag automatisch water.",
        "pl": "W trakcie aktywnego czasu blokady nie możesz jej wyłączyć. Jeśli przekroczysz limit, zły nawyk zostanie automatycznie dodany. Jeśli dotrzymasz limitu, twoja roślina zostanie automatycznie podlana na koniec dnia.",
        "pt": "Durante o tempo de bloqueio ativo, você não pode desativar o bloqueador. Se exceder o limite, o mau hábito da tela é aplicado automaticamente. Se mantiver o limite, a planta será regada ao final do dia.",
        "ru": "Во время активной блокировки вы не можете отключить блокировщик. При превышении лимита привычка экранного времени срабатывает автоматически. Если лимит соблюден, растение будет полито в конце дня.",
        "tr": "Aktif engelleme süresince engelleyiciyi devre dışı bırakamazsınız. Sınırı aşarsanız ekran süresi alışkanlığı otomatik olarak uygulanır. Sınıra uyarsanız, bitkiniz gün sonunda otomatik olarak sulanır.",
        "zh-Hans": "在活动阻止时间内，您无法禁用拦截器。如果超限，屏幕使用时间习惯会自动应用。如果遵守限制，您的植物将在一天结束时自动浇水。",
        "zh-Hant": "在活動阻止時間內，您無法禁用攔截器。如果超限，螢幕使用時間習慣會自動應用。如果遵守限制，您的植物將在一天結束時自動澆水。"
    },
    "screenTime.title": {
        "en": "Screen Time",
        "es": "Tiempo en pantalla",
        "fr": "Temps d'écran",
        "hi": "स्क्रीन टाइम",
        "it": "Tempo di Utilizzo",
        "ja": "スクリーンタイム",
        "ko": "스크린타임",
        "nl": "Schermtijd",
        "pl": "Czas przed ekranem",
        "pt": "Tempo de Tela",
        "ru": "Экранное время",
        "tr": "Ekran Süresi",
        "zh-Hans": "屏幕使用时间",
        "zh-Hant": "螢幕使用時間"
    },
    "screentime.tracker.no_live": {
        "en": "Screen time is automatically checked in the background. Due to Apple privacy restrictions, live progress cannot be displayed here.",
        "es": "El tiempo de pantalla se comprueba automáticamente en segundo plano. Por restricciones de privacidad de Apple, no se puede mostrar el progreso en vivo.",
        "fr": "Le temps d'écran est automatiquement vérifié en arrière-plan. En raison des restrictions de confidentialité d'Apple, la progression en direct ne peut pas être affichée.",
        "hi": "स्क्रीन टाइम स्वचालित रूप से पृष्ठभूमि में चेक किया जाता है। Apple की गोपनीयता प्रतिबंधों के कारण, लाइव प्रगति यहाँ प्रदर्शित नहीं की जा सकती।",
        "it": "Il tempo di utilizzo viene controllato automaticamente in background. A causa delle restrizioni di Apple sulla privacy, non è possibile visualizzare i progressi dal vivo.",
        "ja": "スクリーンタイムはバックグラウンドで自動的にチェックされます。Appleのプライバシー制限により、ライブ進行状況はここに表示できません。",
        "ko": "스크린타임은 백그라운드에서 자동으로 확인됩니다. Apple의 개인정보 보호 제한으로 인해 실시간 진행 상황을 표시할 수 없습니다.",
        "nl": "Schermtijd wordt automatisch op de achtergrond gecontroleerd. Door privacybeperkingen van Apple kan live voortgang hier niet worden weergegeven.",
        "pl": "Czas przed ekranem jest automatycznie sprawdzany w tle. Ze względu na ograniczenia prywatności Apple, nie można tu wyświetlić podglądu na żywo.",
        "pt": "O tempo de tela é verificado automaticamente em segundo plano. Devido a restrições de privacidade da Apple, o progresso ao vivo não pode ser exibido.",
        "ru": "Экранное время автоматически проверяется в фоновом режиме. Из-за ограничений конфиденциальности Apple отображение текущего прогресса недоступно.",
        "tr": "Ekran süresi arka planda otomatik olarak kontrol edilir. Apple'ın gizlilik kısıtlamaları nedeniyle canlı ilerleme burada görüntülenemez.",
        "zh-Hans": "系统会在后台自动检查屏幕使用时间。由于 Apple 的隐私限制，此处无法显示实时进度。",
        "zh-Hant": "系統會在後台自動檢查螢幕使用時間。由於 Apple 的隱私限制，此處無法顯示實時進度。"
    }
}

with open("Garten_Simulation/Localizable.xcstrings", "r", encoding="utf-8") as f:
    data = json.load(f)

for key, val_dict in translations.items():
    if key in data["strings"]:
        locs = data["strings"][key].get("localizations", {})
        for lang, translation in val_dict.items():
            locs[lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translation
                }
            }

with open("Garten_Simulation/Localizable.xcstrings", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected real translations for screen time keys.")
