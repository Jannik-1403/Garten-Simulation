import json
import os

FILE_PATH = "Garten_Simulation/Localizable.xcstrings"

new_strings = {
    "onboarding.goal.title": {
        "de": "Was ist dein wichtigstes Jahresziel?",
        "en": "What is your most important yearly goal?",
        "es": "¿Cuál es tu objetivo anual más importante?",
        "fr": "Quel est votre objectif annuel le plus important ?",
        "it": "Qual è il tuo obiettivo annuale più importante?",
        "pt-PT": "Qual é o teu objetivo anual mais importante?",
        "ja": "あなたの最も重要な年間目標は何ですか？",
        "ru": "Какая ваша самая важная годовая цель?",
        "zh-Hans": "你最重要的年度目标是什么？",
        "ko": "가장 중요한 연간 목표는 무엇입니까?",
        "sv": "Vad är ditt viktigaste årliga mål?"
    },
    "goal.template.custom.button": {
        "de": "Eigenes Ziel erstellen",
        "en": "Create Custom Goal",
        "es": "Crear Objetivo Personalizado",
        "fr": "Créer un Objectif Personnalisé",
        "it": "Crea Obiettivo Personalizzato",
        "pt-PT": "Criar Objetivo Personalizado",
        "ja": "カスタム目標を作成",
        "ru": "Создать свою цель",
        "zh-Hans": "创建自定义目标",
        "ko": "맞춤형 목표 만들기",
        "sv": "Skapa Eget Mål"
    },
    "goal.monthly.add": {
        "de": "Neues Monatsziel setzen",
        "en": "Set New Monthly Goal",
        "es": "Establecer Nuevo Objetivo Mensual",
        "fr": "Définir un Nouvel Objectif Mensuel",
        "it": "Imposta Nuovo Obiettivo Mensile",
        "pt-PT": "Definir Novo Objetivo Mensal",
        "ja": "新しい月間目標を設定",
        "ru": "Установить новую ежемесячную цель",
        "zh-Hans": "设定新的月度目标",
        "ko": "새로운 월간 목표 설정",
        "sv": "Sätt Nytt Månadsmål"
    },
    "goal.monthly.prompt": {
        "de": "Was ist dein Fokus diesen Monat?",
        "en": "What is your focus this month?",
        "es": "¿Cuál es tu enfoque este mes?",
        "fr": "Quel est votre objectif ce mois-ci ?",
        "it": "Qual è il tuo focus questo mese?",
        "pt-PT": "Qual é o teu foco este mês?",
        "ja": "今月の目標は何ですか？",
        "ru": "На чем вы сосредоточитесь в этом месяце?",
        "zh-Hans": "你这个月的重点是什么？",
        "ko": "이번 달 당신의 목표는 무엇입니까?",
        "sv": "Vad är ditt fokus denna månad?"
    },
    "goal.monthly.placeholder": {
        "de": "Z.B. 300 Punkte erreichen",
        "en": "E.g. reach 300 points",
        "es": "Ej. alcanzar 300 puntos",
        "fr": "Ex. atteindre 300 points",
        "it": "Es. raggiungere 300 punti",
        "pt-PT": "Ex. atingir 300 pontos",
        "ja": "例：300ポイント達成",
        "ru": "Например, набрать 300 очков",
        "zh-Hans": "例如达到300分",
        "ko": "예: 300 포인트 달성",
        "sv": "T.ex. nå 300 poäng"
    },
    "goal.monthly.title": {
        "de": "Monatsziel",
        "en": "Monthly Goal",
        "es": "Objetivo Mensual",
        "fr": "Objectif Mensuel",
        "it": "Obiettivo Mensile",
        "pt-PT": "Objetivo Mensal",
        "ja": "月間目標",
        "ru": "Ежемесячная Цель",
        "zh-Hans": "月度目标",
        "ko": "월간 목표",
        "sv": "Månadsmål"
    },
    "goal.insights.title": {
        "de": "Ziel-Analysen",
        "en": "Goal Insights",
        "es": "Análisis de Objetivos",
        "fr": "Analyses des Objectifs",
        "it": "Analisi degli Obiettivi",
        "pt-PT": "Análises de Objetivos",
        "ja": "目標の分析",
        "ru": "Анализ Целей",
        "zh-Hans": "目标分析",
        "ko": "목표 분석",
        "sv": "Målinsikter"
    },
    "goal.insights.empty": {
        "de": "Noch keine Punkte in diesem Monat gesammelt. Gieße deine Pflanzen!",
        "en": "No points collected this month yet. Water your plants!",
        "es": "Todavía no has conseguido puntos este mes. ¡Riega tus plantas!",
        "fr": "Aucun point collecté ce mois-ci. Arrosez vos plantes !",
        "it": "Nessun punto raccolto questo mese. Innaffia le tue piante!",
        "pt-PT": "Ainda não acumulaste pontos este mês. Rega as tuas plantas!",
        "ja": "今月はまだポイントがありません。植物に水をやりましょう！",
        "ru": "В этом месяце очки еще не собраны. Поливайте свои растения!",
        "zh-Hans": "这个月还没收集到分数。给你的植物浇水吧！",
        "ko": "이번 달에 아직 포인트를 모으지 않았습니다. 식물에 물을 주세요!",
        "sv": "Inga poäng samlade denna månad ännu. Vattna dina växter!"
    },
    "goal.insights.no_goal": {
        "de": "Kein Monatsziel für Analysen gesetzt.",
        "en": "No monthly goal set for insights.",
        "es": "No hay objetivo mensual establecido para análisis.",
        "fr": "Aucun objectif mensuel défini pour les analyses.",
        "it": "Nessun obiettivo mensile impostato per le analisi.",
        "pt-PT": "Nenhum objetivo mensal definido para análises.",
        "ja": "分析のための月間目標が設定されていません。",
        "ru": "Не установлена ежемесячная цель для анализа.",
        "zh-Hans": "未设定用于分析的月度目标。",
        "ko": "분석을 위한 월간 목표가 설정되지 않았습니다.",
        "sv": "Inget månadsmål inställt för insikter."
    },
    "goal.link.title": {
        "de": "Ziel-Beitrag",
        "en": "Goal Contribution",
        "es": "Contribución al Objetivo",
        "fr": "Contribution à l'Objectif",
        "it": "Contributo all'Obiettivo",
        "pt-PT": "Contribuição para o Objetivo",
        "ja": "目標への貢献",
        "ru": "Вклад в Цель",
        "zh-Hans": "目标贡献",
        "ko": "목표 기여",
        "sv": "Målbeteende"
    },
    "goal.link.question": {
        "de": "Wie stark hilft '%@' deinem Jahresziel '%@'?",
        "en": "How much does '%@' help your yearly goal '%@'?",
        "es": "¿Cuánto ayuda '%@' a tu objetivo anual '%@'?",
        "fr": "Dans quelle mesure '%@' aide-t-il votre objectif annuel '%@' ?",
        "it": "Quanto aiuta '%@' il tuo obiettivo annuale '%@'?",
        "pt-PT": "O quanto '%@' ajuda o teu objetivo anual '%@'?",
        "ja": "'%@' はあなたの年間目標 '%@' にどれくらい役立ちますか？",
        "ru": "Насколько '%@' помогает вашей годовой цели '%@'?",
        "zh-Hans": "'%@' 对你的年度目标 '%@' 有多大帮助？",
        "ko": "'%@'가 귀하의 연간 목표 '%@'에 얼마나 도움이 됩니까?",
        "sv": "Hur mycket hjälper '%@' ditt årliga mål '%@'?"
    },
    "goal.link.none": {
        "de": "Gar nicht (0 Pkt)",
        "en": "Not at all (0 Pts)",
        "es": "Nada (0 Pts)",
        "fr": "Pas du tout (0 Pts)",
        "it": "Per niente (0 Pti)",
        "pt-PT": "Nada (0 Pts)",
        "ja": "全くない（0ポイント）",
        "ru": "Совсем нет (0 очков)",
        "zh-Hans": "完全没有（0分）",
        "ko": "전혀 없음 (0 포인트)",
        "sv": "Inte alls (0 Pts)"
    },
    "goal.link.no_goal": {
        "de": "Kein Jahresziel gesetzt.",
        "en": "No yearly goal set.",
        "es": "No hay objetivo anual establecido.",
        "fr": "Aucun objectif annuel défini.",
        "it": "Nessun obiettivo annuale impostato.",
        "pt-PT": "Nenhum objetivo anual definido.",
        "ja": "年間目標が設定されていません。",
        "ru": "Не установлена годовая цель.",
        "zh-Hans": "未设定年度目标。",
        "ko": "연간 목표가 설정되지 않았습니다.",
        "sv": "Inget årligt mål inställt."
    }
}

def update_xcstrings():
    with open(FILE_PATH, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    for key, localizations in new_strings.items():
        if key not in data["strings"]:
            data["strings"][key] = {
                "extractionState": "manual",
                "localizations": {}
            }
        
        for lang, translation in localizations.items():
            data["strings"][key]["localizations"][lang] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translation
                }
            }
            
    with open(FILE_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
if __name__ == "__main__":
    update_xcstrings()
    print("UI Strings added to Localizable.xcstrings successfully!")
