import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

new_strings = [
    {
        "key": "screenTime.blocked.title",
        "translations": {
            "de": "Bildschirmzeit blockiert",
            "en": "Screen Time Blocked",
            "nl": "Schermtijd geblokkeerd",
            "fr": "Temps d'écran bloqué",
            "it": "Tempo di utilizzo bloccato",
            "ja": "スクリーンタイムがブロックされました",
            "ko": "화면 시간 차단됨",
            "pl": "Czas przed ekranem zablokowany",
            "pt": "Tempo de ecrã bloqueado",
            "es": "Tiempo en pantalla bloqueado",
            "tr": "Ekran Süresi Engellendi"
        }
    },
    {
        "key": "screenTime.blocked.desc",
        "translations": {
            "de": "Du befindest dich gerade in deiner aktiven Block-Zeit. Du kannst diese Einstellungen erst ändern, wenn die Block-Zeit abgelaufen ist.",
            "en": "You are currently in your active block time. You can only change these settings when the block time has expired.",
            "nl": "Je bevindt je momenteel in je actieve blokkeertijd. Je kunt deze instellingen pas wijzigen als de blokkeertijd is verstreken.",
            "fr": "Vous êtes actuellement dans votre temps de blocage actif. Vous ne pourrez modifier ces paramètres qu'une fois le temps écoulé.",
            "it": "Ti trovi attualmente nel tuo tempo di blocco attivo. Puoi modificare queste impostazioni solo al termine del blocco.",
            "ja": "現在アクティブなブロック時間中です。ブロック時間が終了するまでこの設定は変更できません。",
            "ko": "현재 활성 차단 시간입니다. 차단 시간이 만료된 후에만 이 설정을 변경할 수 있습니다.",
            "pl": "Obecnie znajdujesz się w aktywnym czasie blokady. Możesz zmienić te ustawienia dopiero po upływie czasu blokady.",
            "pt": "Encontra-se atualmente no seu tempo de bloqueio ativo. Só pode alterar estas definições quando o tempo expirar.",
            "es": "Actualmente te encuentras en tu tiempo de bloqueo activo. Solo puedes cambiar estos ajustes cuando el tiempo expire.",
            "tr": "Şu anda aktif engelleme sürenizdesiniz. Bu ayarları ancak engelleme süresi dolduğunda değiştirebilirsiniz."
        }
    },
    {
        "key": "screenTime.auth.request",
        "translations": {
            "de": "Bildschirmzeit-Zugriff erlauben",
            "en": "Allow Screen Time Access",
            "nl": "Schermtijd toegang toestaan",
            "fr": "Autoriser l'accès au temps d'écran",
            "it": "Consenti l'accesso al tempo di utilizzo",
            "ja": "スクリーンタイムのアクセスを許可する",
            "ko": "화면 시간 액세스 허용",
            "pl": "Zezwól na dostęp do czasu przed ekranem",
            "pt": "Permitir acesso ao Tempo de Ecrã",
            "es": "Permitir acceso al tiempo en pantalla",
            "tr": "Ekran Süresi erişimine izin ver"
        }
    },
    {
        "key": "screenTime.schedule.active",
        "translations": {
            "de": "Block-Zeitplan aktivieren",
            "en": "Activate Block Schedule",
            "nl": "Blokkeerschema activeren",
            "fr": "Activer le programme de blocage",
            "it": "Attiva programma di blocco",
            "ja": "ブロックスケジュールを有効にする",
            "ko": "차단 일정 활성화",
            "pl": "Aktywuj harmonogram blokady",
            "pt": "Ativar horário de bloqueio",
            "es": "Activar horario de bloqueo",
            "tr": "Engelleme Programını Etkinleştir"
        }
    },
    {
        "key": "screenTime.schedule.start",
        "translations": {
            "de": "Startzeit", "en": "Start Time", "nl": "Starttijd", "fr": "Heure de début", "it": "Ora di inizio", "ja": "開始時間", "ko": "시작 시간", "pl": "Czas rozpoczęcia", "pt": "Hora de início", "es": "Hora de inicio", "tr": "Başlangıç Zamanı"
        }
    },
    {
        "key": "screenTime.schedule.end",
        "translations": {
            "de": "Endzeit", "en": "End Time", "nl": "Eindtijd", "fr": "Heure de fin", "it": "Ora di fine", "ja": "終了時間", "ko": "종료 시간", "pl": "Czas zakończenia", "pt": "Hora de fim", "es": "Hora de finalización", "tr": "Bitiş Zamanı"
        }
    },
    {
        "key": "screenTime.info.title",
        "translations": {
            "de": "Wie funktioniert das?", "en": "How does it work?", "nl": "Hoe werkt het?", "fr": "Comment ça marche ?", "it": "Come funziona?", "ja": "どのように機能しますか？", "ko": "어떻게 작동하나요?", "pl": "Jak to działa?", "pt": "Como funciona?", "es": "¿Cómo funciona?", "tr": "Nasıl çalışır?"
        }
    },
    {
        "key": "screenTime.info.desc",
        "translations": {
            "de": "Während der aktiven Block-Zeit kannst du den Blocker hier nicht mehr deaktivieren. Wenn du ein Tagesziel überschreitest, wird automatisch die Gewohnheit 'Zu viel Bildschirmzeit' gekauft/abgehakt. Hältst du das Ziel ein, wird deine Pflanze automatisch am Tagesende gegossen.",
            "en": "During the active block time, you cannot deactivate the blocker here. If you exceed a daily limit, the 'Too much screen time' habit will automatically be bought/checked off. If you stick to the limit, your plant will be watered automatically at the end of the day.",
            "nl": "Tijdens de actieve blokkeertijd kun je de blokkering hier niet deactiveren. Als je een dagelijkse limiet overschrijdt, wordt automatisch de gewoonte 'Te veel schermtijd' afgevinkt. Als je je aan de limiet houdt, wordt je plant aan het einde van de dag automatisch water gegeven.",
            "fr": "Pendant le temps de blocage, vous ne pouvez pas désactiver le bloqueur ici. Si vous dépassez une limite, l'habitude 'Trop de temps d'écran' sera cochée. Si vous respectez la limite, votre plante sera arrosée à la fin de la journée.",
            "it": "Durante il tempo di blocco, non puoi disattivare il blocco qui. Se superi un limite, verrà aggiunta l'abitudine 'Troppo tempo di utilizzo'. Se rispetti il limite, la tua pianta verrà annaffiata a fine giornata.",
            "ja": "ブロック中はブロッカーを無効にできません。制限を超えると「スクリーンタイムの使いすぎ」の習慣が記録されます。制限を守れば、一日の終わりに植物に水が与えられます。",
            "ko": "차단 중에는 차단기를 비활성화할 수 없습니다. 제한을 초과하면 '화면 너무 많이 사용' 습관이 확인됩니다. 제한을 지키면 하루가 끝날 때 식물에 물을 줍니다.",
            "pl": "Podczas aktywnej blokady nie możesz jej wyłączyć tutaj. Jeśli przekroczysz limit, zostanie odhaczony nawyk 'Za dużo czasu przed ekranem'. Jeśli go przestrzegasz, roślina zostanie podlana pod koniec dnia.",
            "pt": "Durante o tempo de bloqueio, não pode desativá-lo aqui. Se exceder um limite, o hábito 'Demasiado tempo de ecrã' será registado. Se respeitar o limite, a sua planta será regada no final do dia.",
            "es": "Durante el tiempo de bloqueo, no puedes desactivarlo aquí. Si excedes un límite, se marcará el hábito 'Demasiado tiempo en pantalla'. Si respetas el límite, tu planta se regará al final del día.",
            "tr": "Engelleme sırasında engelleyiciyi devre dışı bırakamazsınız. Sınırı aşarsanız, 'Çok fazla ekran süresi' alışkanlığı kaydedilir. Sınıra uyarsanız, günün sonunda bitkiniz sulanır."
        }
    },
    {
        "key": "screenTime.title",
        "translations": {
            "de": "Bildschirmzeit", "en": "Screen Time", "nl": "Schermtijd", "fr": "Temps d'écran", "it": "Tempo di utilizzo", "ja": "スクリーンタイム", "ko": "화면 시간", "pl": "Czas przed ekranem", "pt": "Tempo de ecrã", "es": "Tiempo en pantalla", "tr": "Ekran Süresi"
        }
    },
    {
        "key": "settings.screenTime.instruction",
        "translations": {
            "de": "Verwalte Block-Zeiten und Limits.", "en": "Manage block times and limits.", "nl": "Beheer blokkeertijden en limieten.", "fr": "Gérer les temps et limites de blocage.", "it": "Gestisci orari e limiti di blocco.", "ja": "ブロック時間と制限を管理する", "ko": "차단 시간 및 제한 관리", "pl": "Zarządzaj czasem blokady i limitami.", "pt": "Gerir tempos e limites de bloqueio.", "es": "Gestionar tiempos de bloqueo y límites.", "tr": "Engelleme sürelerini ve sınırları yönetin."
        }
    },
    {
        "key": "habit.screen_time.name",
        "translations": {
            "de": "Bildschirmzeit", "en": "Screen Time", "nl": "Schermtijd", "fr": "Temps d'écran", "it": "Tempo di utilizzo", "ja": "スクリーンタイム", "ko": "화면 시간", "pl": "Czas przed ekranem", "pt": "Tempo de ecrã", "es": "Tiempo en pantalla", "tr": "Ekran Süresi"
        }
    },
    {
        "key": "habit.screen_time.desc",
        "translations": {
            "de": "Digital Detox", "en": "Digital Detox", "nl": "Digital Detox", "fr": "Désintoxication numérique", "it": "Detox digitale", "ja": "デジタルデトックス", "ko": "디지털 디톡스", "pl": "Cyfrowy detoks", "pt": "Desintoxicação digital", "es": "Desintoxicación digital", "tr": "Dijital Detoks"
        }
    },
    {
        "key": "screenTime.target.label",
        "translations": {
            "de": "Limit (Std)", "en": "Limit (Hrs)", "nl": "Limiet (Uur)", "fr": "Limite (H)", "it": "Limite (Ore)", "ja": "制限（時間）", "ko": "제한 (시간)", "pl": "Limit (Godz)", "pt": "Limite (Hrs)", "es": "Límite (Hrs)", "tr": "Sınır (Saat)"
        }
    },
    {
        "key": "screenTime.reason.exceeded",
        "translations": {
            "de": "Tageslimit überschritten", "en": "Daily limit exceeded", "nl": "Dagelijkse limiet overschreden", "fr": "Limite quotidienne dépassée", "it": "Limite giornaliero superato", "ja": "一日の制限を超過しました", "ko": "일일 한도 초과됨", "pl": "Dzienny limit przekroczony", "pt": "Limite diário excedido", "es": "Límite diario superado", "tr": "Günlük sınır aşıldı"
        }
    },
    {
        "key": "bad_habit.screen_time.name",
        "translations": {
            "de": "Zu viel Bildschirmzeit", "en": "Too much screen time", "nl": "Te veel schermtijd", "fr": "Trop de temps d'écran", "it": "Troppo tempo di utilizzo", "ja": "スクリーンタイムの使いすぎ", "ko": "화면 너무 많이 사용", "pl": "Za dużo czasu przed ekranem", "pt": "Demasiado tempo de ecrã", "es": "Demasiado tiempo en pantalla", "tr": "Çok fazla ekran süresi"
        }
    },
    {
        "key": "bad_habit.screen_time.desc",
        "translations": {
            "de": "Rückfall", "en": "Relapse", "nl": "Terugval", "fr": "Rechute", "it": "Ricaduta", "ja": "再発", "ko": "재발", "pl": "Nawrót", "pt": "Recaída", "es": "Recaída", "tr": "Nüksetme"
        }
    },
    {
        "key": "note.auto.screentime_success",
        "translations": {
            "de": "Bildschirmzeit eingehalten", "en": "Screen time limit respected", "nl": "Schermtijdlimiet gerespecteerd", "fr": "Limite de temps d'écran respectée", "it": "Limite tempo di utilizzo rispettato", "ja": "スクリーンタイム制限を守りました", "ko": "화면 시간 제한 준수됨", "pl": "Przestrzegano limitu czasu ekranu", "pt": "Limite de tempo de ecrã respeitado", "es": "Límite de tiempo en pantalla respetado", "tr": "Ekran süresi sınırına uyuldu"
        }
    }
]

for item in new_strings:
    key = item["key"]
    translations = item["translations"]
    
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}

    for lang, text in translations.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings added to Localizable.xcstrings successfully!")
