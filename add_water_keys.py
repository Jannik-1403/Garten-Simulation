import json

path = "Garten_Simulation/Localizable.xcstrings"

translations = {
    "water.goal.explanation": {
        "de": "Dein Tagesziel berechnet sich dynamisch anhand deines Körpergewichts und deiner Aktivität. Du kannst es aber auch manuell festlegen.",
        "en": "Your daily goal is calculated dynamically based on your body weight and activity. You can also set it manually.",
        "es": "Tu objetivo diario se calcula dinámicamente en función de tu peso corporal y actividad. También puedes establecerlo manualmente.",
        "fr": "Votre objectif quotidien est calculé dynamiquement en fonction de votre poids et de votre activité. Vous pouvez également le définir manuellement.",
        "hi": "आपका दैनिक लक्ष्य आपके शरीर के वजन और गतिविधि के आधार पर गतिशील रूप से गणना की जाती है। आप इसे मैन्युअल रूप से भी सेट कर सकते हैं।",
        "it": "Il tuo obiettivo giornaliero è calcolato dinamicamente in base al tuo peso corporeo e alla tua attività. Puoi anche impostarlo manualmente.",
        "ja": "1日の目標は、体重と活動量に基づいて動的に計算されます。手動で設定することもできます。",
        "ko": "일일 목표는 체중과 활동량에 따라 동적으로 계산됩니다. 수동으로 설정할 수도 있습니다.",
        "nl": "Je dagelijkse doel wordt dynamisch berekend op basis van je lichaamsgewicht en activiteit. Je kunt het ook handmatig instellen.",
        "pl": "Twój dzienny cel jest obliczany dynamicznie na podstawie masy ciała i aktywności. Możesz go również ustawić ręcznie.",
        "pt": "Seu objetivo diário é calculado dinamicamente com base no seu peso corporal e atividade. Você também pode defini-lo manualmente.",
        "pt-BR": "Seu objetivo diário é calculado dinamicamente com base no seu peso corporal e atividade. Você também pode defini-lo manualmente.",
        "ru": "Ваша ежедневная цель рассчитывается динамически на основе вашего веса и активности. Вы также можете установить ее вручную.",
        "tr": "Günlük hedefiniz vücut ağırlığınıza ve aktivitenize göre dinamik olarak hesaplanır. Manuel olarak da ayarlayabilirsiniz.",
        "zh-Hans": "您的每日目标是根据您的体重和活动动态计算的。您也可以手动设置。",
        "zh-Hant": "您的每日目標是根據您的體重和活動動態計算的。您也可以手動設置。"
    },
    "water.goal.manual_active": {
        "de": "Manuelles Ziel ist aktiv.",
        "en": "Manual goal is active.",
        "es": "El objetivo manual está activo.",
        "fr": "L'objectif manuel est actif.",
        "hi": "मैन्युअल लक्ष्य सक्रिय है।",
        "it": "L'obiettivo manuale è attivo.",
        "ja": "手動目標がアクティブです。",
        "ko": "수동 목표가 활성화되었습니다.",
        "nl": "Handmatig doel is actief.",
        "pl": "Ręczny cel jest aktywny.",
        "pt": "O objetivo manual está ativo.",
        "pt-BR": "O objetivo manual está ativo.",
        "ru": "Ручная цель активна.",
        "tr": "Manuel hedef aktif.",
        "zh-Hans": "手动目标处于活动状态。",
        "zh-Hant": "手動目標處於活動狀態。"
    },
    "water.goal.edit_button": {
        "de": "Ziel manuell bearbeiten",
        "en": "Edit goal manually",
        "es": "Editar objetivo manualmente",
        "fr": "Modifier l'objectif manuellement",
        "hi": "लक्ष्य को मैन्युअल रूप से संपादित करें",
        "it": "Modifica l'obiettivo manualmente",
        "ja": "手動で目標を編集",
        "ko": "수동으로 목표 편집",
        "nl": "Doel handmatig bewerken",
        "pl": "Edytuj cel ręcznie",
        "pt": "Editar objetivo manualmente",
        "pt-BR": "Editar objetivo manualmente",
        "ru": "Изменить цель вручную",
        "tr": "Hedefi manuel olarak düzenle",
        "zh-Hans": "手动编辑目标",
        "zh-Hant": "手動編輯目標"
    },
    "water.goal.edit_title": {
        "de": "Manuelles Tagesziel",
        "en": "Manual Daily Goal",
        "es": "Objetivo Diario Manual",
        "fr": "Objectif Quotidien Manuel",
        "hi": "मैन्युअल दैनिक लक्ष्य",
        "it": "Obiettivo Giornaliero Manuale",
        "ja": "手動の1日の目標",
        "ko": "수동 일일 목표",
        "nl": "Handmatig Dagelijks Doel",
        "pl": "Ręczny Dzienny Cel",
        "pt": "Objetivo Diário Manual",
        "pt-BR": "Objetivo Diário Manual",
        "ru": "Ручная Ежедневная Цель",
        "tr": "Manuel Günlük Hedef",
        "zh-Hans": "手动每日目标",
        "zh-Hant": "手動每日目標"
    },
    "water.goal.edit_desc": {
        "de": "Überschreibe die automatische Berechnung mit einem festen Ziel in ml.",
        "en": "Overwrite the automatic calculation with a fixed goal in ml.",
        "es": "Sobrescriba el cálculo automático con un objetivo fijo en ml.",
        "fr": "Remplacer le calcul automatique par un objectif fixe en ml.",
        "hi": "एमएल में एक निश्चित लक्ष्य के साथ स्वचालित गणना को अधिलेखित करें।",
        "it": "Sovrascrivi il calcolo automatico con un obiettivo fisso in ml.",
        "ja": "自動計算をml単位の固定目標で上書きします。",
        "ko": "ml 단위의 고정된 목표로 자동 계산을 덮어씁니다.",
        "nl": "Overschrijf de automatische berekening met een vast doel in ml.",
        "pl": "Zastąp automatyczne obliczenia stałym celem w ml.",
        "pt": "Substitua o cálculo automático por um objetivo fixo em ml.",
        "pt-BR": "Substitua o cálculo automático por um objetivo fixo em ml.",
        "ru": "Перезапишите автоматический расчет фиксированной целью в мл.",
        "tr": "Otomatik hesaplamayı ml cinsinden sabit bir hedefle üzerine yazın.",
        "zh-Hans": "用毫升的固定目标覆盖自动计算。",
        "zh-Hant": "用毫升的固定目標覆蓋自動計算。"
    },
    "water.goal.edit_placeholder": {
        "de": "Z.B. 2500",
        "en": "E.g. 2500",
        "es": "P. ej. 2500",
        "fr": "Ex. 2500",
        "hi": "उदा. 2500",
        "it": "Es. 2500",
        "ja": "例: 2500",
        "ko": "예: 2500",
        "nl": "Bijv. 2500",
        "pl": "N.p. 2500",
        "pt": "Ex. 2500",
        "pt-BR": "Ex. 2500",
        "ru": "Напр. 2500",
        "tr": "Örn. 2500",
        "zh-Hans": "例如 2500",
        "zh-Hant": "例如 2500"
    },
    "water.goal.edit_reset": {
        "de": "Auf automatisch zurücksetzen",
        "en": "Reset to automatic",
        "es": "Restablecer a automático",
        "fr": "Réinitialiser à automatique",
        "hi": "स्वचालित पर रीसेट करें",
        "it": "Ripristina ad automatico",
        "ja": "自動にリセット",
        "ko": "자동으로 재설정",
        "nl": "Resetten naar automatisch",
        "pl": "Zresetuj na automatyczny",
        "pt": "Redefinir para automático",
        "pt-BR": "Redefinir para automático",
        "ru": "Сброс на автоматический",
        "tr": "Otomatik olarak sıfırla",
        "zh-Hans": "重置为自动",
        "zh-Hant": "重置為自動"
    }
}

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, val in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Localization injected!")
