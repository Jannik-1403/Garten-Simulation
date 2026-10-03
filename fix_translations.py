import json

translations = {
  "tracking.days.preset.daily": {
    "de": "Täglich", "en": "Daily", "es": "Diario", "fr": "Quotidien", "hi": "दैनिक", "it": "Quotidiano", "ja": "毎日", "ko": "매일", "nl": "Dagelijks", "pl": "Codziennie", "pt": "Diariamente", "pt-BR": "Diariamente", "ru": "Ежедневно", "tr": "Günlük", "zh-Hans": "每天", "zh-Hant": "每天"
  },
  "tracking.days.preset.weekdays": {
    "de": "Werktags", "en": "Weekdays", "es": "Días laborables", "fr": "Jours ouvrables", "hi": "सप्ताह के दिन", "it": "Giorni feriali", "ja": "平日", "ko": "평일", "nl": "Werkdagen", "pl": "Dni powszednie", "pt": "Dias úteis", "pt-BR": "Dias úteis", "ru": "Будни", "tr": "Hafta içi", "zh-Hans": "工作日", "zh-Hant": "工作日"
  },
  "tracking.days.preset.weekend": {
    "de": "Wochenende", "en": "Weekend", "es": "Fin de semana", "fr": "Week-end", "hi": "सप्ताहांत", "it": "Fine settimana", "ja": "週末", "ko": "주말", "nl": "Weekend", "pl": "Weekend", "pt": "Fim de semana", "pt-BR": "Fim de semana", "ru": "Выходные", "tr": "Hafta sonu", "zh-Hans": "周末", "zh-Hant": "週末"
  },
  "tracking.mode.counter.example": {
    "de": "Beispiel: 20 von 50 Liegestütze → 40% erledigt.",
    "en": "Example: 20 of 50 Push-ups → 40% completed.",
    "es": "Ejemplo: 20 de 50 Flexiones → 40% completado.",
    "fr": "Exemple: 20 sur 50 Pompes → 40% terminé.",
    "hi": "उदाहरण: 50 में से 20 पुश-अप्स → 40% पूर्ण।",
    "it": "Esempio: 20 di 50 Flessioni → 40% completato.",
    "ja": "例: 50回の腕立て伏せのうち20回 → 40% 完了。",
    "ko": "예시: 푸시업 50회 중 20회 → 40% 완료.",
    "nl": "Voorbeeld: 20 van de 50 Push-ups → 40% voltooid.",
    "pl": "Przykład: 20 z 50 Pompki → 40% ukończono.",
    "pt": "Exemplo: 20 de 50 Flexões → 40% concluído.",
    "pt-BR": "Exemplo: 20 de 50 Flexões → 40% concluído.",
    "ru": "Пример: 20 из 50 Отжимания → 40% выполнено.",
    "tr": "Örnek: 50 Şınavdan 20'si → %40 tamamlandı.",
    "zh-Hans": "示例：50 个俯卧撑中的 20 个 → 已完成 40%。",
    "zh-Hant": "範例：50 個伏地挺身中的 20 個 → 已完成 40%。"
  },
  "tracking.mode.slider.example": {
    "de": "Beispiel: Regler auf 60% → die Gewohnheit ist zu 60% erledigt.",
    "en": "Example: Slider at 60% → habit is 60% completed.",
    "es": "Ejemplo: Deslizador al 60% → el hábito está 60% completado.",
    "fr": "Exemple : Curseur à 60 % → l'habitude est terminée à 60 %.",
    "hi": "उदाहरण: स्लाइडर 60% पर → आदत 60% पूर्ण हो गई है।",
    "it": "Esempio: Cursore al 60% → l'abitudine è completata al 60%.",
    "ja": "例: スライダーが 60% → 習慣が 60% 完了しました。",
    "ko": "예: 슬라이더를 60%로 설정 → 습관이 60% 완료되었습니다.",
    "nl": "Voorbeeld: Schuifregelaar op 60% → de gewoonte is voor 60% voltooid.",
    "pl": "Przykład: Suwak na 60% → nawyk jest w 60% wykonany.",
    "pt": "Exemplo: Controle deslizante em 60% → o hábito está 60% concluído.",
    "pt-BR": "Exemplo: Controle deslizante em 60% → o hábito está 60% concluído.",
    "ru": "Пример: Ползунок на 60% → привычка выполнена на 60%.",
    "tr": "Örnek: Kaydırıcı %60'ta → alışkanlığın %60'ı tamamlandı.",
    "zh-Hans": "示例：滑块处于 60% → 习惯已完成 60%。",
    "zh-Hant": "範例：滑桿位於 60% → 習慣已完成 60%。"
  },
  "tracking.settings.days.example": {
    "de": "Fällig am %@. An allen anderen Tagen hast du frei – dein Streak läuft weiter.",
    "en": "Due on %@. You are free on all other days – your streak continues.",
    "es": "Vence el %@. Tienes libre los demás días – tu racha continúa.",
    "fr": "À faire le %@. Vous êtes libre tous les autres jours – votre série continue.",
    "hi": "%@ को देय। आप अन्य सभी दिनों में स्वतंत्र हैं - आपका स्ट्रीक जारी है।",
    "it": "Scade il %@. Sei libero tutti gli altri giorni – la tua serie continua.",
    "ja": "%@ が期限です。他のすべての日はお休みです - 連続記録は継続します。",
    "ko": "%@ 마감입니다. 다른 날은 쉬는 날입니다 - 연속 기록은 계속됩니다.",
    "nl": "Vervalt op %@. Je bent vrij op alle andere dagen - je reeks gaat door.",
    "pl": "Termin: %@. We wszystkie inne dni masz wolne – twoja passa trwa nadal.",
    "pt": "Vence em %@. Você está livre em todos os outros dias – sua sequência continua.",
    "pt-BR": "Vence em %@. Você está livre em todos os outros dias – sua sequência continua.",
    "ru": "Выполнить %@. Во все остальные дни вы свободны – ваша серия продолжается.",
    "tr": "Son tarih: %@. Diğer tüm günler boşsunuz – seriniz devam ediyor.",
    "zh-Hans": "到期日：%@。您在所有其他日子都空闲——您的连胜记录继续。",
    "zh-Hant": "到期日：%@。您在所有其他日子都空閒——您的連勝記錄繼續。"
  },
  "tracking.settings.days.example.daily": {
    "de": "Jeden Tag fällig – ein verpasster Tag beendet deinen Streak.",
    "en": "Due every day – a missed day ends your streak.",
    "es": "Vence todos los días – un día perdido termina tu racha.",
    "fr": "À faire tous les jours – un jour manqué met fin à votre série.",
    "hi": "हर दिन देय – एक छूटा हुआ दिन आपके स्ट्रीक को समाप्त कर देता है।",
    "it": "Scade ogni giorno – un giorno perso termina la tua serie.",
    "ja": "毎日が期限です – 1 日休むと連続記録が終了します。",
    "ko": "매일 마감 – 하루를 놓치면 연속 기록이 종료됩니다.",
    "nl": "Elke dag vervallen – een gemiste dag beëindigt je reeks.",
    "pl": "Należy wykonać codziennie – opuszczony dzień kończy twoją passę.",
    "pt": "Vence todos os dias – um dia perdido termina sua sequência.",
    "pt-BR": "Vence todos os dias – um dia perdido termina sua sequência.",
    "ru": "Выполнять каждый день – пропущенный день прерывает вашу серию.",
    "tr": "Her gün yapılması gerekiyor - kaçırılan bir gün serinizi sonlandırır.",
    "zh-Hans": "每天到期——错过一天就会结束您的连胜。",
    "zh-Hant": "每天到期——錯過一天就會結束您的連勝。"
  },
  "tracking.settings.unit.default": {
    "de": "Wiederholungen", "en": "Repetitions", "es": "Repeticiones", "fr": "Répétitions", "hi": "पुनरावृत्ति", "it": "Ripetizioni", "ja": "繰り返し", "ko": "반복", "nl": "Herhalingen", "pl": "Powtórzenia", "pt": "Repetições", "pt-BR": "Repetições", "ru": "Повторения", "tr": "Tekrarlar", "zh-Hans": "重复次数", "zh-Hant": "重複次數"
  },
  "tracking.settings.title": {
    "de": "Tracking-Einstellungen", "en": "Tracking Settings", "es": "Configuración de seguimiento", "fr": "Paramètres de suivi", "hi": "ट्रैकिंग सेटिंग्स", "it": "Impostazioni di tracciamento", "ja": "追跡設定", "ko": "추적 설정", "nl": "Trackinginstellingen", "pl": "Ustawienia śledzenia", "pt": "Configurações de rastreamento", "pt-BR": "Configurações de rastreamento", "ru": "Настройки отслеживания", "tr": "İzleme Ayarları", "zh-Hans": "跟踪设置", "zh-Hant": "追蹤設定"
  },
  "tracking.settings.days.header": {
    "de": "Fällige Tage", "en": "Due Days", "es": "Días de vencimiento", "fr": "Jours d'échéance", "hi": "देय दिन", "it": "Giorni di scadenza", "ja": "期限日", "ko": "마감일", "nl": "Vervaldagen", "pl": "Dni wymagalności", "pt": "Dias de vencimento", "pt-BR": "Dias de vencimento", "ru": "Дни выполнения", "tr": "Bitiş Günleri", "zh-Hans": "到期日", "zh-Hant": "到期日"
  },
  "tracking.settings.mode.header": {
    "de": "Fortschritt erfassen", "en": "Track Progress", "es": "Registrar progreso", "fr": "Suivre la progression", "hi": "प्रगति ट्रैक करें", "it": "Traccia progresso", "ja": "進捗を追跡", "ko": "진행 상황 추적", "nl": "Voortgang bijhouden", "pl": "Śledź postępy", "pt": "Acompanhar progresso", "pt-BR": "Acompanhar progresso", "ru": "Отслеживать прогресс", "tr": "İlerlemeyi Takip Et", "zh-Hans": "跟踪进度", "zh-Hant": "追蹤進度"
  },
  "tracking.settings.target": {
    "de": "Tagesziel", "en": "Daily Goal", "es": "Meta diaria", "fr": "Objectif quotidien", "hi": "दैनिक लक्ष्य", "it": "Obiettivo quotidiano", "ja": "毎日の目標", "ko": "일일 목표", "nl": "Dagelijks doel", "pl": "Cel dzienny", "pt": "Meta diária", "pt-BR": "Meta diária", "ru": "Ежедневная цель", "tr": "Günlük Hedef", "zh-Hans": "每日目标", "zh-Hant": "每日目標"
  },
  "tracking.settings.unit.placeholder": {
    "de": "Einheit, z. B. Liegestütze", "en": "Unit, e.g., Push-ups", "es": "Unidad, ej. Flexiones", "fr": "Unité, par ex. Pompes", "hi": "इकाई, उदा. पुश-अप्स", "it": "Unità, es. Flessioni", "ja": "単位（例：腕立て伏せ）", "ko": "단위 (예: 푸시업)", "nl": "Eenheid, bijv. Push-ups", "pl": "Jednostka, np. Pompki", "pt": "Unidade, ex. Flexões", "pt-BR": "Unidade, ex. Flexões", "ru": "Единица, напр. Отжимания", "tr": "Birim, örn. Şınav", "zh-Hans": "单位，例如：俯卧撑", "zh-Hant": "單位，例如：伏地挺身"
  },
  "tracking.settings.counter.footer": {
    "de": "Erreichst du das Tagesziel, gilt die Gewohnheit als erledigt (100 %).", "en": "If you reach the daily goal, the habit is considered completed (100%).", "es": "Si alcanzas la meta diaria, el hábito se considera completado (100%).", "fr": "Si vous atteignez l'objectif quotidien, l'habitude est considérée comme terminée (100%).", "hi": "यदि आप दैनिक लक्ष्य तक पहुँचते हैं, तो आदत को पूरा माना जाता है (100%)।", "it": "Se raggiungi l'obiettivo quotidiano, l'abitudine è considerata completata (100%).", "ja": "毎日の目標に到達すると、習慣は完了とみなされます（100％）。", "ko": "일일 목표에 도달하면 습관이 완료된 것으로 간주됩니다(100%).", "nl": "Als je het dagelijkse doel bereikt, wordt de gewoonte als voltooid beschouwd (100%).", "pl": "Jeśli osiągniesz dzienny cel, nawyk jest uważany za ukończony (100%).", "pt": "Se você atingir a meta diária, o hábito é considerado concluído (100%).", "pt-BR": "Se você atingir a meta diária, o hábito é considerado concluído (100%).", "ru": "Если вы достигнете ежедневной цели, привычка считается выполненной (100%).", "tr": "Günlük hedefe ulaşırsanız, alışkanlık tamamlanmış sayılır (%100).", "zh-Hans": "如果您达到每日目标，该习惯将被视为已完成（100%）。", "zh-Hant": "如果您達到每日目標，該習慣將被視為已完成（100%）。"
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

print("Done translating with hardcoded dict!")
