import json
import sys

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
    "de": "Beispiel: %d von %d %@ → %@ erledigt.",
    "en": "Example: %d of %d %@ → %@ completed.",
    "es": "Ejemplo: %d de %d %@ → %@ completado.",
    "fr": "Exemple : %d sur %d %@ → %@ terminé.",
    "hi": "उदाहरण: %d में से %d %@ → %@ पूर्ण।",
    "it": "Esempio: %d di %d %@ → %@ completato.",
    "ja": "例: %2$d 中 %1$d 回の %3$@ → %4$@ 完了。",
    "ko": "예시: %2$d 중 %1$d회 %3$@ → %4$@ 완료.",
    "nl": "Voorbeeld: %d van de %d %@ → %@ voltooid.",
    "pl": "Przykład: %d z %d %@ → %@ ukończono.",
    "pt": "Exemplo: %d de %d %@ → %@ concluído.",
    "pt-BR": "Exemplo: %d de %d %@ → %@ concluído.",
    "ru": "Пример: %d из %d %@ → %@ выполнено.",
    "tr": "Örnek: %2$d %@'den %1$d'si → %4$@ tamamlandı.",
    "zh-Hans": "示例：%2$d 个 %3$@ 中的 %1$d 个 → 已完成 %4$@。",
    "zh-Hant": "範例：%2$d 個 %3$@ 中的 %1$d 個 → 已完成 %4$@。"
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
  }
}

try:
    with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
        data = json.load(f)
except Exception as e:
    print(f"Error loading file: {e}")
    sys.exit(1)

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

try:
    with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print("Done applying all translations!")
except Exception as e:
    print(f"Error writing file: {e}")
