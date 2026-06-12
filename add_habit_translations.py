import os

translations = {
    "de": {
        "habit.stats.title": "Statistiken",
        "habit.stats.count": "Bisher: %d",
        "habit.stats.streak": "Streak (Tage ohne)",
        "habit.stats.total": "Gesamt",
        "habit.stats.month": "Dieser Monat",
        "habit.stats.impact": "Negativer Effekt",
        "habit.impact.title": "Die 1%-Methode",
        "habit.impact.explanation": "Laut James Clears 'Die 1%-Methode' wirst du durch diese Gewohnheit jedes Mal 1% schlechter (0,99). Dies hat auf lange Sicht einen immensen negativen Effekt auf dein Leben.",
        "habit.tips.title": "Tipps (Die 4 Gesetze)",
        "habit.tip.1": "Auslöser unsichtbar machen: Entferne alle Reize, die diese Gewohnheit auslösen, aus deiner Umgebung.",
        "habit.tip.2": "Verlangen unattraktiv machen: Führe dir die negativen Folgen vor Augen, um die Gewohnheit gedanklich abzuwerten.",
        "habit.tip.3": "Reaktion schwierig machen: Erhöhe die Hürden und Schritte, die nötig sind, um die Gewohnheit auszuführen.",
        "habit.tip.4": "Belohnung unbefriedigend machen: Führe eine sofortige Bestrafung oder einen Rechenschaftspartner ein.",
        "habit.relapse.report": "Rückfall melden",
    },
    "en": {
        "habit.stats.title": "Statistics",
        "habit.stats.count": "So far: %d",
        "habit.stats.streak": "Streak (Days without)",
        "habit.stats.total": "Total",
        "habit.stats.month": "This Month",
        "habit.stats.impact": "Negative Impact",
        "habit.impact.title": "The 1% Method",
        "habit.impact.explanation": "According to James Clear's 'Atomic Habits', you become 1% worse (0.99) every time you execute this habit. This has an immense negative compound effect on your life in the long run.",
        "habit.tips.title": "Tips (The 4 Laws)",
        "habit.tip.1": "Make it invisible: Remove all cues that trigger this habit from your environment.",
        "habit.tip.2": "Make it unattractive: Focus on the negative consequences to mentally devalue the habit.",
        "habit.tip.3": "Make it difficult: Increase the friction and steps required to execute the habit.",
        "habit.tip.4": "Make it unsatisfying: Introduce an immediate punishment or an accountability partner.",
        "habit.relapse.report": "Report Relapse",
    },
    "es": {
        "habit.stats.title": "Estadísticas",
        "habit.stats.count": "Hasta ahora: %d",
        "habit.stats.streak": "Racha (Días sin)",
        "habit.stats.total": "Total",
        "habit.stats.month": "Este mes",
        "habit.stats.impact": "Impacto negativo",
        "habit.impact.title": "El método del 1%",
        "habit.impact.explanation": "Según 'Hábitos Atómicos' de James Clear, te vuelves un 1% peor (0,99) cada vez que ejecutas este hábito. Esto tiene un enorme efecto negativo compuesto en tu vida a largo plazo.",
        "habit.tips.title": "Consejos (Las 4 leyes)",
        "habit.tip.1": "Hazlo invisible: Elimina de tu entorno todas las señales que desencadenan este hábito.",
        "habit.tip.2": "Hazlo poco atractivo: Concéntrate en las consecuencias negativas para devaluar mentalmente el hábito.",
        "habit.tip.3": "Hazlo difícil: Aumenta la fricción y los pasos necesarios para ejecutar el hábito.",
        "habit.tip.4": "Hazlo insatisfactorio: Introduce un castigo inmediato o un compañero de responsabilidad.",
        "habit.relapse.report": "Reportar recaída",
    },
    "fr": {
        "habit.stats.title": "Statistiques",
        "habit.stats.count": "Jusqu'ici : %d",
        "habit.stats.streak": "Série (Jours sans)",
        "habit.stats.total": "Total",
        "habit.stats.month": "Ce mois",
        "habit.stats.impact": "Impact négatif",
        "habit.impact.title": "La méthode des 1%",
        "habit.impact.explanation": "Selon 'Un rien peut tout changer' de James Clear, tu deviens 1% pire (0,99) à chaque fois que tu exécutes cette habitude. Cela a un immense effet négatif composé sur ta vie à long terme.",
        "habit.tips.title": "Conseils (Les 4 lois)",
        "habit.tip.1": "Rends-le invisible : Supprime de ton environnement tous les déclencheurs de cette habitude.",
        "habit.tip.2": "Rends-le peu attrayant : Concentre-toi sur les conséquences négatives pour dévaluer mentalement l'habitude.",
        "habit.tip.3": "Rends-le difficile : Augmente les obstacles et les étapes nécessaires pour exécuter l'habitude.",
        "habit.tip.4": "Rends-le insatisfaisant : Introduis une punition immédiate ou un partenaire de responsabilité.",
        "habit.relapse.report": "Signaler une rechute",
    },
    "it": {
        "habit.stats.title": "Statistiche",
        "habit.stats.count": "Finora: %d",
        "habit.stats.streak": "Serie (Giorni senza)",
        "habit.stats.total": "Totale",
        "habit.stats.month": "Questo mese",
        "habit.stats.impact": "Impatto negativo",
        "habit.impact.title": "Il metodo dell'1%",
        "habit.impact.explanation": "Secondo 'Piccole Abitudini per Grandi Cambiamenti' di James Clear, diventi l'1% peggiore (0,99) ogni volta che esegui questa abitudine. Questo ha un immenso effetto negativo composto sulla tua vita a lungo termine.",
        "habit.tips.title": "Consigli (Le 4 leggi)",
        "habit.tip.1": "Rendilo invisibile: Rimuovi dal tuo ambiente tutti gli stimoli che innescano questa abitudine.",
        "habit.tip.2": "Rendilo poco attraente: Concentrati sulle conseguenze negative per svalutare mentalmente l'abitudine.",
        "habit.tip.3": "Rendilo difficile: Aumenta l'attrito e i passaggi necessari per eseguire l'abitudine.",
        "habit.tip.4": "Rendilo insoddisfacente: Introduci una punizione immediata o un partner di responsabilità.",
        "habit.relapse.report": "Segnala ricaduta",
    },
    "pt": {
        "habit.stats.title": "Estatísticas",
        "habit.stats.count": "Até agora: %d",
        "habit.stats.streak": "Sequência (Dias sem)",
        "habit.stats.total": "Total",
        "habit.stats.month": "Este mês",
        "habit.stats.impact": "Impacto negativo",
        "habit.impact.title": "O método de 1%",
        "habit.impact.explanation": "Segundo 'Hábitos Atômicos' de James Clear, você fica 1% pior (0,99) toda vez que executa este hábito. Isso tem um imenso efeito negativo composto na sua vida a longo prazo.",
        "habit.tips.title": "Dicas (As 4 leis)",
        "habit.tip.1": "Torne invisível: Remova do seu ambiente todos os gatilhos que desencadeiam este hábito.",
        "habit.tip.2": "Torne pouco atraente: Concentre-se nas consequências negativas para desvalorizar mentalmente o hábito.",
        "habit.tip.3": "Torne difícil: Aumente a fricção e os passos necessários para executar o hábito.",
        "habit.tip.4": "Torne insatisfatório: Introduza uma punição imediata ou um parceiro de responsabilidade.",
        "habit.relapse.report": "Reportar recaída",
    },
    "ja": {
        "habit.stats.title": "統計",
        "habit.stats.count": "これまで: %d",
        "habit.stats.streak": "連続記録（日数）",
        "habit.stats.total": "合計",
        "habit.stats.month": "今月",
        "habit.stats.impact": "悪影響",
        "habit.impact.title": "1%の法則",
        "habit.impact.explanation": "ジェームズ・クリアの『ジェームズ・クリア式 複利で伸びる1つの習慣』によると、この習慣を実行するたびに1%悪くなります（0.99）。これは長期的に人生に莫大な悪影響を及ぼします。",
        "habit.tips.title": "ヒント（4つの法則）",
        "habit.tip.1": "見えなくする：この習慣を引き起こすすべてのきっかけを環境から取り除く。",
        "habit.tip.2": "魅力をなくす：悪い結果に焦点を当て、習慣の価値を精神的に下げる。",
        "habit.tip.3": "難しくする：習慣を実行するために必要な摩擦とステップを増やす。",
        "habit.tip.4": "満足できなくする：即座の罰や説明責任パートナーを導入する。",
        "habit.relapse.report": "再発を報告",
    },
    "ko": {
        "habit.stats.title": "통계",
        "habit.stats.count": "지금까지: %d",
        "habit.stats.streak": "연속 기록 (일수)",
        "habit.stats.total": "전체",
        "habit.stats.month": "이번 달",
        "habit.stats.impact": "부정적 영향",
        "habit.impact.title": "1% 법칙",
        "habit.impact.explanation": "제임스 클리어의 '아주 작은 습관의 힘'에 따르면, 이 습관을 실행할 때마다 1% 나빠집니다 (0.99). 이것은 장기적으로 삶에 엄청난 부정적 복리 효과를 미칩니다.",
        "habit.tips.title": "팁 (4가지 법칙)",
        "habit.tip.1": "보이지 않게 만들기: 이 습관을 유발하는 모든 단서를 환경에서 제거하세요.",
        "habit.tip.2": "매력 없게 만들기: 부정적인 결과에 집중하여 정신적으로 습관의 가치를 떨어뜨리세요.",
        "habit.tip.3": "어렵게 만들기: 습관을 실행하는 데 필요한 마찰과 단계를 늘리세요.",
        "habit.tip.4": "불만족스럽게 만들기: 즉각적인 벌칙이나 책임 파트너를 도입하세요.",
        "habit.relapse.report": "재발 보고",
    },
    "nl": {
        "habit.stats.title": "Statistieken",
        "habit.stats.count": "Tot nu toe: %d",
        "habit.stats.streak": "Reeks (Dagen zonder)",
        "habit.stats.total": "Totaal",
        "habit.stats.month": "Deze maand",
        "habit.stats.impact": "Negatieve impact",
        "habit.impact.title": "De 1%-methode",
        "habit.impact.explanation": "Volgens James Clears 'Atomic Habits' word je elke keer dat je deze gewoonte uitvoert 1% slechter (0,99). Dit heeft op de lange termijn een enorm negatief samengesteld effect op je leven.",
        "habit.tips.title": "Tips (De 4 wetten)",
        "habit.tip.1": "Maak het onzichtbaar: Verwijder alle prikkels die deze gewoonte triggeren uit je omgeving.",
        "habit.tip.2": "Maak het onaantrekkelijk: Focus op de negatieve gevolgen om de gewoonte mentaal te devalueren.",
        "habit.tip.3": "Maak het moeilijk: Vergroot de weerstand en stappen die nodig zijn om de gewoonte uit te voeren.",
        "habit.tip.4": "Maak het onbevredigend: Voer een directe straf of een verantwoordelijkheidspartner in.",
        "habit.relapse.report": "Terugval melden",
    },
    "pl": {
        "habit.stats.title": "Statystyki",
        "habit.stats.count": "Do tej pory: %d",
        "habit.stats.streak": "Seria (Dni bez)",
        "habit.stats.total": "Łącznie",
        "habit.stats.month": "Ten miesiąc",
        "habit.stats.impact": "Negatywny wpływ",
        "habit.impact.title": "Metoda 1%",
        "habit.impact.explanation": "Według 'Atomowych nawyków' Jamesa Cleara, za każdym razem gdy wykonujesz ten nawyk, stajesz się o 1% gorszy (0,99). Ma to ogromny negatywny efekt złożony na twoje życie w dłuższej perspektywie.",
        "habit.tips.title": "Wskazówki (4 prawa)",
        "habit.tip.1": "Uczyń to niewidocznym: Usuń ze swojego otoczenia wszystkie bodźce, które wywołują ten nawyk.",
        "habit.tip.2": "Uczyń to nieatrakcyjnym: Skup się na negatywnych konsekwencjach, aby mentalnie zdewaluować nawyk.",
        "habit.tip.3": "Uczyń to trudnym: Zwiększ opór i kroki potrzebne do wykonania nawyku.",
        "habit.tip.4": "Uczyń to niesatysfakcjonującym: Wprowadź natychmiastową karę lub partnera odpowiedzialności.",
        "habit.relapse.report": "Zgłoś nawrót",
    },
    "tr": {
        "habit.stats.title": "İstatistikler",
        "habit.stats.count": "Şimdiye kadar: %d",
        "habit.stats.streak": "Seri (Gün sayısı)",
        "habit.stats.total": "Toplam",
        "habit.stats.month": "Bu ay",
        "habit.stats.impact": "Olumsuz etki",
        "habit.impact.title": "%1 Yöntemi",
        "habit.impact.explanation": "James Clear'ın 'Atomik Alışkanlıklar' kitabına göre, bu alışkanlığı her uyguladığında %1 daha kötü olursun (0,99). Bu, uzun vadede hayatın üzerinde muazzam bir olumsuz bileşik etkiye sahiptir.",
        "habit.tips.title": "İpuçları (4 Yasa)",
        "habit.tip.1": "Görünmez kıl: Bu alışkanlığı tetikleyen tüm ipuçlarını çevrenden kaldır.",
        "habit.tip.2": "Çekici olmaktan çıkar: Olumsuz sonuçlara odaklanarak alışkanlığı zihinsel olarak değersizleştir.",
        "habit.tip.3": "Zor kıl: Alışkanlığı uygulamak için gereken sürtünmeyi ve adımları artır.",
        "habit.tip.4": "Tatminsiz kıl: Anında bir ceza veya hesap verebilirlik ortağı belirle.",
        "habit.relapse.report": "Nüks bildir",
    },
}

lproj_dir = "Garten_Simulation"

for lproj in sorted(os.listdir(lproj_dir)):
    if not lproj.endswith(".lproj"):
        continue
    
    lang = lproj.replace(".lproj", "")
    file_path = os.path.join(lproj_dir, lproj, "Localizable.strings")
    if not os.path.exists(file_path):
        continue
    
    # Read existing content to check for duplicate keys
    with open(file_path, "r") as f:
        existing = f.read()
    
    keys_to_use = translations.get(lang, translations["en"])  # Fallback to English
    
    # Remove any previously added keys (from the old script run)
    lines_to_remove = set()
    for key in keys_to_use:
        lines_to_remove.add(f'"{key}"')
    
    cleaned_lines = []
    for line in existing.split("\n"):
        skip = False
        for marker in lines_to_remove:
            if line.strip().startswith(marker):
                skip = True
                break
        if not skip:
            cleaned_lines.append(line)
    
    # Remove trailing empty lines
    while cleaned_lines and cleaned_lines[-1].strip() == "":
        cleaned_lines.pop()
    
    # Write back cleaned + new keys
    with open(file_path, "w") as f:
        f.write("\n".join(cleaned_lines))
        f.write("\n\n")
        for k, v in keys_to_use.items():
            # Escape quotes in values
            escaped_v = v.replace('"', '\\"')
            f.write(f'"{k}" = "{escaped_v}";\n')
    
    print(f"✅ {lang}: Updated {file_path}")
