import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "screenTime.layer4.title": {
        "en": "Always Blocked",
        "de": "Immer blockiert",
        "es": "Siempre bloqueado",
        "fr": "Toujours bloqué",
        "it": "Sempre bloccato",
        "pt": "Sempre bloqueado",
        "nl": "Altijd geblokkeerd",
        "pl": "Zawsze zablokowane",
        "ru": "Всегда заблокировано",
        "tr": "Her zaman engellenmiş",
        "ja": "常にブロック",
        "ko": "항상 차단됨",
        "zh-Hans": "始终阻止",
        "zh-Hant": "始終阻止",
        "hi": "हमेशा ब्लॉक"
    },
    "screenTime.layer4.desc": {
        "en": "These apps and websites are always blocked and can only be unlocked via Emergency Unlock.",
        "de": "Diese Apps und Websites sind immer blockiert und können nur über die Notfall-Entsperrung geöffnet werden.",
        "es": "Estas aplicaciones y sitios web siempre están bloqueados y solo se pueden desbloquear mediante el Desbloqueo de emergencia.",
        "fr": "Ces applications et sites web sont toujours bloqués et ne peuvent être débloqués que via le Déblocage d'urgence.",
        "it": "Queste app e siti web sono sempre bloccati e possono essere sbloccati solo tramite Sblocco di emergenza.",
        "pt": "Esses aplicativos e sites estão sempre bloqueados e só podem ser desbloqueados através do Desbloqueio de Emergência.",
        "nl": "Deze apps en websites zijn altijd geblokkeerd en kunnen alleen worden ontgrendeld via Noodontgrendeling.",
        "pl": "Te aplikacje i strony internetowe są zawsze zablokowane i można je odblokować tylko przez Odblokowanie awaryjne.",
        "ru": "Эти приложения и веб-сайты всегда заблокированы и могут быть разблокированы только с помощью экстренной разблокировки.",
        "tr": "Bu uygulamalar ve web siteleri her zaman engellenir ve yalnızca Acil Kilit Açma ile açılabilir.",
        "ja": "これらのアプリとウェブサイトは常にブロックされており、緊急ロック解除からのみ解除できます。",
        "ko": "이러한 앱과 웹사이트는 항상 차단되며 긴급 잠금 해제를 통해서만 잠금을 해제할 수 있습니다.",
        "zh-Hans": "这些应用和网站始终被阻止，只能通过紧急解锁来解锁。",
        "zh-Hant": "這些應用和網站在始終被阻止，只能透過緊急解鎖來解鎖。",
        "hi": "ये ऐप और वेबसाइट हमेशा ब्लॉक रहते हैं और केवल आपातकालीन अनलॉक के माध्यम से अनलॉक किए जा सकते हैं।"
    },
    "paywall.feature.pro_gardener.title": {
        "en": "Pro Gardener Benefits",
        "de": "Pro-Gärtner Vorteile",
        "es": "Beneficios de Jardinero Pro",
        "fr": "Avantages Jardinier Pro",
        "it": "Vantaggi del Giardiniere Pro",
        "pt": "Benefícios do Jardineiro Pro",
        "nl": "Voordelen voor Pro Tuinier",
        "pl": "Korzyści dla Pro Ogrodnika",
        "ru": "Преимущества Pro-садовода",
        "tr": "Pro Bahçıvan Avantajları",
        "ja": "プロガーデナーの特典",
        "ko": "프로 정원사 혜택",
        "zh-Hans": "专业园丁福利",
        "zh-Hant": "專業園丁福利",
        "hi": "प्रो माली के लाभ"
    },
    "paywall.feature.weekly_report.bullet1": {
        "en": "Discover which days you are most productive.",
        "de": "Entdecke, an welchen Tagen du am produktivsten bist.",
        "es": "Descubre en qué días eres más productivo.",
        "fr": "Découvrez quels jours vous êtes le plus productif.",
        "it": "Scopri in quali giorni sei più produttivo.",
        "pt": "Descubra em quais dias você é mais produtivo.",
        "nl": "Ontdek op welke dagen je het meest productief bent.",
        "pl": "Odkryj, w które dni jesteś najbardziej produktywny.",
        "ru": "Узнайте, в какие дни вы наиболее продуктивны.",
        "tr": "Hangi günlerde en verimli olduğunuzu keşfedin.",
        "ja": "最も生産的な曜日を発見しましょう。",
        "ko": "가장 생산적인 요일을 알아보세요.",
        "zh-Hans": "发现您最高效的日子。",
        "zh-Hant": "發現您最高效的日子。",
        "hi": "खोजें कि आप किन दिनों में सबसे अधिक उत्पादक हैं।"
    },
    "paywall.feature.weekly_report.bullet2": {
        "en": "Track your progress with interactive graphs.",
        "de": "Verfolge deinen Fortschritt mit interaktiven Graphen.",
        "es": "Sigue tu progreso con gráficos interactivos.",
        "fr": "Suivez vos progrès avec des graphiques interactifs.",
        "it": "Tieni traccia dei tuoi progressi con grafici interattivi.",
        "pt": "Acompanhe seu progresso com gráficos interativos.",
        "nl": "Houd je voortgang bij met interactieve grafieken.",
        "pl": "Śledź swoje postępy za pomocą interaktywnych wykresów.",
        "ru": "Отслеживайте свой прогресс с помощью интерактивных графиков.",
        "tr": "İnteraktif grafiklerle ilerlemenizi takip edin.",
        "ja": "インタラクティブなグラフで進捗を追跡します。",
        "ko": "대화형 그래프로 진행 상황을 추적하세요.",
        "zh-Hans": "通过交互式图表跟踪您的进度。",
        "zh-Hant": "透過互動式圖表追蹤您的進度。",
        "hi": "इंटरैक्टिव ग्राफ़ के साथ अपनी प्रगति को ट्रैक करें।"
    },
    "paywall.feature.weekly_report.bullet3": {
        "en": "Optimize your workflow based on your data.",
        "de": "Optimiere deinen Workflow basierend auf deinen Daten.",
        "es": "Optimiza tu flujo de trabajo en base a tus datos.",
        "fr": "Optimisez votre flux de travail en fonction de vos données.",
        "it": "Ottimizza il tuo flusso di lavoro in base ai tuoi dati.",
        "pt": "Otimize seu fluxo de trabalho com base em seus dados.",
        "nl": "Optimaliseer je workflow op basis van je gegevens.",
        "pl": "Zoptymalizuj swój przepływ pracy w oparciu o swoje dane.",
        "ru": "Оптимизируйте рабочий процесс на основе своих данных.",
        "tr": "İş akışınızı verilerinize göre optimize edin.",
        "ja": "データに基づいてワークフローを最適化します。",
        "ko": "데이터를 기반으로 워크플로우를 최적화하세요.",
        "zh-Hans": "根据数据优化您的工作流程。",
        "zh-Hant": "根據數據優化您的工作流程。",
        "hi": "अपने डेटा के आधार पर अपने कार्यप्रवाह को अनुकूलित करें।"
    },
    "paywall.feature.focus_sounds.bullet1": {
        "en": "Access to all scientifically backed sounds.",
        "de": "Zugang zu allen wissenschaftlich belegten Sounds.",
        "es": "Acceso a todos los sonidos respaldados científicamente.",
        "fr": "Accès à tous les sons scientifiquement prouvés.",
        "it": "Accesso a tutti i suoni scientificamente provati.",
        "pt": "Acesso a todos os sons cientificamente comprovados.",
        "nl": "Toegang tot alle wetenschappelijk onderbouwde geluiden.",
        "pl": "Dostęp do wszystkich dźwięków potwierdzonych naukowo.",
        "ru": "Доступ ко всем научно обоснованным звукам.",
        "tr": "Bilimsel olarak desteklenen tüm seslere erişim.",
        "ja": "科学的に裏付けられたすべてのサウンドにアクセス。",
        "ko": "과학적으로 뒷받침되는 모든 사운드에 액세스할 수 있습니다.",
        "zh-Hans": "访问所有科学支持的白噪音。",
        "zh-Hant": "訪問所有科學支持的白噪音。",
        "hi": "वैज्ञानिक रूप से समर्थित सभी ध्वनियों तक पहुँच।"
    },
    "paywall.feature.focus_sounds.bullet2": {
        "en": "Get your brain into the flow state faster.",
        "de": "Bringe dein Gehirn schneller in den Flow-Zustand.",
        "es": "Lleva tu cerebro al estado de flujo más rápido.",
        "fr": "Amenez votre cerveau dans l'état de flux plus rapidement.",
        "it": "Porta il tuo cervello nello stato di flusso più velocemente.",
        "pt": "Leve o seu cérebro ao estado de fluxo mais rapidamente.",
        "nl": "Breng je hersenen sneller in de flow-staat.",
        "pl": "Szybciej wprowadź swój mózg w stan flow.",
        "ru": "Быстрее введите свой мозг в состояние потока.",
        "tr": "Beyninizi daha hızlı akış durumuna getirin.",
        "ja": "脳をより早くフロー状態にします。",
        "ko": "뇌를 더 빨리 몰입 상태로 만드세요.",
        "zh-Hans": "让您的大脑更快进入心流状态。",
        "zh-Hant": "讓您的大腦更快進入心流狀態。",
        "hi": "अपने दिमाग को तेज़ी से फ्लो स्टेट में लाएं।"
    },
    "paywall.feature.focus_sounds.bullet3": {
        "en": "Effectively block out distracting background noise.",
        "de": "Blende störende Hintergrundgeräusche effektiv aus.",
        "es": "Bloquea eficazmente el ruido de fondo que distrae.",
        "fr": "Bloquez efficacement les bruits de fond distrayants.",
        "it": "Blocca efficacemente il rumore di fondo che distrae.",
        "pt": "Bloqueie eficazmente o ruído de fundo distrativo.",
        "nl": "Blokkeer storende achtergrondgeluiden effectief.",
        "pl": "Skutecznie zablokuj rozpraszający hałas w tle.",
        "ru": "Эффективно блокируйте отвлекающий фоновый шум.",
        "tr": "Dikkat dağıtıcı arka plan gürültüsünü etkili bir şekilde engelleyin.",
        "ja": "気を散らす背景ノイズを効果的に遮断します。",
        "ko": "주의를 산만하게 하는 배경 소음을 효과적으로 차단합니다.",
        "zh-Hans": "有效屏蔽分散注意力的背景噪音。",
        "zh-Hant": "有效屏蔽分散注意力的背景噪音。",
        "hi": "विचलित करने वाले पृष्ठभूमि शोर को प्रभावी ढंग से रोकें।"
    },
    "paywall.feature.pro_gardener.bullet3": {
        "en": "Unlock rare decorations much faster.",
        "de": "Schalte seltene Dekorationen viel schneller frei.",
        "es": "Desbloquea decoraciones raras mucho más rápido.",
        "fr": "Débloquez des décorations rares beaucoup plus rapidement.",
        "it": "Sblocca decorazioni rare molto più velocemente.",
        "pt": "Desbloqueie decorações raras muito mais rápido.",
        "nl": "Ontgrendel zeldzame decoraties veel sneller.",
        "pl": "Odblokuj rzadkie dekoracje znacznie szybciej.",
        "ru": "Разблокируйте редкие украшения гораздо быстрее.",
        "tr": "Nadir dekorasyonların kilidini çok daha hızlı açın.",
        "ja": "レアな装飾をはるかに早くロック解除します。",
        "ko": "희귀한 장식을 훨씬 더 빨리 잠금 해제하세요.",
        "zh-Hans": "更快地解锁稀有装饰。",
        "zh-Hant": "更快地解鎖稀有裝飾。",
        "hi": "दुर्लभ सजावट को बहुत तेज़ी से अनलॉक करें।"
    },
    "smart.weekly.tip.no_focus": {
        "en": "You haven't used any focus sessions this week. Build fixed focus times into your daily life. Reserve 25 minutes at the same time every day (e.g. right after breakfast) to develop a routine.",
        "de": "Du hast diese Woche keine Fokus-Sessions genutzt. Baue feste Fokus-Zeiten in deinen Alltag ein. Reserviere dir jeden Tag zur selben Uhrzeit (z.B. direkt nach dem Frühstück) 25 Minuten, um eine Routine zu entwickeln.",
        "es": "No has utilizado ninguna sesión de concentración esta semana. Integra tiempos fijos de concentración en tu rutina. Reserva 25 minutos a la misma hora todos los días (p.ej. justo después del desayuno) para desarrollar una rutina.",
        "fr": "Vous n'avez utilisé aucune session de concentration cette semaine. Intégrez des temps de concentration fixes dans votre vie quotidienne. Réservez 25 minutes à la même heure chaque jour (ex. juste après le petit-déjeuner) pour créer une routine.",
        "it": "Non hai utilizzato alcuna sessione di focus questa settimana. Inserisci momenti di focus fissi nella tua giornata. Riserva 25 minuti alla stessa ora ogni giorno (es. subito dopo colazione) per sviluppare una routine.",
        "pt": "Você não usou nenhuma sessão de foco esta semana. Integre tempos de foco fixos na sua vida diária. Reserve 25 minutos no mesmo horário todos os dias (ex. logo após o café da manhã) para desenvolver uma rotina.",
        "nl": "Je hebt deze week geen focussessies gebruikt. Bouw vaste focustijden in je dagelijks leven in. Reserveer elke dag 25 minuten op hetzelfde tijdstip (bijv. direct na het ontbijt) om een routine te ontwikkelen.",
        "pl": "W tym tygodniu nie korzystałeś z żadnych sesji skupienia. Wbuduj stałe czasy skupienia w swoje codzienne życie. Zarezerwuj 25 minut o tej samej porze każdego dnia (np. tuż po śniadaniu), aby wypracować rutynę.",
        "ru": "На этой неделе вы не использовали ни одного сеанса фокуса. Внедрите фиксированное время для фокуса в свою повседневную жизнь. Резервируйте 25 минут в одно и то же время каждый день (например, сразу после завтрака), чтобы выработать рутину.",
        "tr": "Bu hafta hiç odaklanma oturumu kullanmadınız. Günlük hayatınıza sabit odaklanma süreleri ekleyin. Bir rutin oluşturmak için her gün aynı saatte (örneğin kahvaltıdan hemen sonra) 25 dakika ayırın.",
        "ja": "今週はフォーカスセッションを使用していません。日常生活に固定のフォーカス時間を組み込みましょう。ルーティンを作るために、毎日同じ時間（例：朝食直後）に25分間確保してください。",
        "ko": "이번 주에 포커스 세션을 사용하지 않았습니다. 일상생활에 고정된 집중 시간을 만드세요. 루틴을 개발하기 위해 매일 같은 시간(예: 아침 식사 직후)에 25분을 예약하세요.",
        "zh-Hans": "本周您还没有使用过专注周期。将固定的专注时间融入您的日常生活中。每天在同一时间（例如早餐后）预留25分钟来养成习惯。",
        "zh-Hant": "本周您還沒有使用過專注週期。將固定的專注時間融入您的日常生活中。每天在同一時間（例如早餐後）預留25分鐘來養成習慣。",
        "hi": "आपने इस सप्ताह किसी भी फ़ोकस सत्र का उपयोग नहीं किया है। अपने दैनिक जीवन में निश्चित फ़ोकस समय बनाएँ। एक दिनचर्या विकसित करने के लिए हर दिन एक ही समय पर (उदा. नाश्ते के ठीक बाद) 25 मिनट आरक्षित करें।"
    },
    "widget_water_alltime": {
        "en": "TOTAL",
        "de": "GESAMT",
        "es": "TOTAL",
        "fr": "TOTAL",
        "it": "TOTALE",
        "pt": "TOTAL",
        "nl": "TOTAAL",
        "pl": "RAZEM",
        "ru": "ВСЕГО",
        "tr": "TOPLAM",
        "ja": "合計",
        "ko": "총합",
        "zh-Hans": "总计",
        "zh-Hant": "總計",
        "hi": "कुल"
    },
    "widget_water_times": {
        "en": "%d times",
        "de": "%d mal",
        "es": "%d veces",
        "fr": "%d fois",
        "it": "%d volte",
        "pt": "%d vezes",
        "nl": "%d keer",
        "pl": "%d razy",
        "ru": "%d раз(а)",
        "tr": "%d kez",
        "ja": "%d 回",
        "ko": "%d 번",
        "zh-Hans": "%d 次",
        "zh-Hant": "%d 次",
        "hi": "%d बार"
    },
    "common.minutes.short": {
        "en": "Min",
        "de": "Min.",
        "es": "Min",
        "fr": "Min",
        "it": "Min",
        "pt": "Min",
        "nl": "Min",
        "pl": "Min",
        "ru": "Мин.",
        "tr": "Dk",
        "ja": "分",
        "ko": "분",
        "zh-Hans": "分钟",
        "zh-Hant": "分鐘",
        "hi": "मिनट"
    }
}

existing_langs = ['pt', 'nl', 'zh-Hans', 'ko', 'ja', 'tr', 'es', 'fr', 'en', 'ru', 'pl', 'it', 'hi', 'de', 'zh-Hant']

# Fix strings
for key, lang_dict in translations.items():
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in existing_langs:
        val = lang_dict.get(lang) or lang_dict.get('en')
        
        if 'localizations' not in data['strings'][key]:
            data['strings'][key]['localizations'] = {}
            
        data['strings'][key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Injected translations successfully!")
