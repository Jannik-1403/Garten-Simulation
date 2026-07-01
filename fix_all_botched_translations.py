import json

path = "Garten_Simulation/Localizable.xcstrings"
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "paywall.subtitle": {
        "de": "Schalte das volle Potenzial deines Gartens frei.", "en": "Unlock the full potential of your garden.",
        "ko": "정원의 모든 잠재력을 잠금 해제하세요.", "ja": "庭の可能性を最大限に引き出しましょう。",
        "es": "Desbloquea todo el potencial de tu jardín.", "fr": "Libérez tout le potentiel de votre jardin.",
        "it": "Sblocca tutto il potenziale del tuo giardino.", "pt": "Desbloqueie todo o potencial do seu jardim.",
        "pl": "Odblokuj pełny potencjał swojego ogrodu.", "nl": "Ontgrendel het volledige potentieel van uw tuin.",
        "tr": "Bahçenizin tüm potansiyelini ortaya çıkarın."
    },
    "paywall.feature.health.desc": {
        "de": "Verknüpfe deine Schritte und Wasserziele direkt mit dem Garten.", "en": "Link your steps and water goals directly to the garden.",
        "ko": "걸음 수와 물 목표를 정원에 직접 연결하세요.", "ja": "歩数と水の目標を庭に直接リンクします。",
        "es": "Vincula tus pasos y objetivos de agua directamente con el jardín.", "fr": "Liez vos pas et vos objectifs d'eau directement au jardin.",
        "it": "Collega i tuoi passi e gli obiettivi dell'acqua direttamente al giardino.", "pt": "Vincule seus passos e metas de água diretamente ao jardim.",
        "pl": "Połącz swoje kroki i cele związane z wodą bezpośrednio z ogrodem.", "nl": "Koppel uw stappen en waterdoelen rechtstreeks aan de tuin.",
        "tr": "Adımlarınızı ve su hedeflerinizi doğrudan bahçeye bağlayın."
    },
    "paywall.button.unlock": {
        "de": "Jetzt Freischalten", "en": "Unlock Now", "ko": "지금 잠금 해제", "ja": "今すぐロック解除",
        "es": "Desbloquear ahora", "fr": "Débloquer maintenant", "it": "Sblocca ora", "pt": "Desbloquear agora",
        "pl": "Odblokuj teraz", "nl": "Ontgrendel nu", "tr": "Şimdi Kilidi Aç"
    },
    "paywall.description.lifetime": {
        "de": "Einmalzahlung. Lifetime Zugriff.", "en": "One-time payment. Lifetime access.",
        "ko": "일회성 결제. 평생 이용.", "ja": "1回払い。生涯アクセス。",
        "es": "Pago único. Acceso de por vida.", "fr": "Paiement unique. Accès à vie.",
        "it": "Pagamento unico. Accesso a vita.", "pt": "Pagamento único. Acesso vitalício.",
        "pl": "Płatność jednorazowa. Dożywotni dostęp.", "nl": "Eenmalige betaling. Levenslange toegang.",
        "tr": "Tek seferlik ödeme. Ömür boyu erişim."
    },
    "paywall.loading": {
        "de": "Lade Produkte...", "en": "Loading Products...", "ko": "제품 불러오는 중...", "ja": "製品を読み込み中...",
        "es": "Cargando productos...", "fr": "Chargement des produits...", "it": "Caricamento prodotti...",
        "pt": "Carregando produtos...", "pl": "Ładowanie produktów...", "nl": "Producten laden...", "tr": "Ürünler Yükleniyor..."
    },
    "settings.pro.unlock": {
        "de": "Grovy Pro freischalten", "en": "Unlock Grovy Pro", "ko": "Grovy Pro 잠금 해제", "ja": "Grovy Proのロック解除",
        "es": "Desbloquear Grovy Pro", "fr": "Débloquer Grovy Pro", "it": "Sblocca Grovy Pro",
        "pt": "Desbloquear Grovy Pro", "pl": "Odblokuj Grovy Pro", "nl": "Ontgrendel Grovy Pro", "tr": "Grovy Pro Kilidini Aç"
    },
    "settings.pro.subtitle": {
        "de": "Erhalte vollen Zugriff", "en": "Get full access", "ko": "전체 권한 얻기", "ja": "フルアクセスを取得",
        "es": "Obtén acceso completo", "fr": "Obtenir un accès complet", "it": "Ottieni accesso completo",
        "pt": "Obter acesso total", "pl": "Uzyskaj pełny dostęp", "nl": "Krijg volledige toegang", "tr": "Tam erişim edinin"
    },
    "settings.section.integrations": {
        "de": "Integrationen", "en": "Integrations", "ko": "연동", "ja": "統合",
        "es": "Integraciones", "fr": "Intégrations", "it": "Integrazioni", "pt": "Integrações",
        "pl": "Integracje", "nl": "Integraties", "tr": "Entegrasyonlar"
    },
    "settings.health.today": {
        "de": "Heutige Health-Daten", "en": "Today's Health Data", "ko": "오늘의 건강 데이터", "ja": "今日のヘルスデータ",
        "es": "Datos de salud de hoy", "fr": "Données de santé du jour", "it": "Dati sanitari di oggi",
        "pt": "Dados de saúde de hoje", "pl": "Dzisiejsze dane zdrowotne", "nl": "Gezondheidsgegevens van vandaag", "tr": "Bugünün Sağlık Verileri"
    },
    "health.metric.steps": {"de": "Schritte", "en": "Steps", "ko": "걸음 수", "ja": "歩数", "es": "Pasos", "fr": "Pas", "it": "Passi", "pt": "Passos", "pl": "Kroki", "nl": "Stappen", "tr": "Adımlar"},
    "health.metric.water": {"de": "Wasser", "en": "Water", "ko": "물", "ja": "水", "es": "Agua", "fr": "Eau", "it": "Acqua", "pt": "Água", "pl": "Woda", "nl": "Water", "tr": "Su"},
    "health.metric.sleep": {"de": "Schlaf", "en": "Sleep", "ko": "수면", "ja": "睡眠", "es": "Sueño", "fr": "Sommeil", "it": "Sonno", "pt": "Sono", "pl": "Sen", "nl": "Slaap", "tr": "Uyku"},
    "health.metric.mindfulness": {"de": "Achtsamkeit", "en": "Mindfulness", "ko": "마음챙김", "ja": "マインドフルネス", "es": "Atención plena", "fr": "Pleine conscience", "it": "Consapevolezza", "pt": "Atenção plena", "pl": "Uważność", "nl": "Mindfulness", "tr": "Farkındalık"},
    "health.metric.running": {"de": "Joggen", "en": "Running", "ko": "달리기", "ja": "ランニング", "es": "Correr", "fr": "Course à pied", "it": "Corsa", "pt": "Corrida", "pl": "Bieganie", "nl": "Hardlopen", "tr": "Koşu"},
    "health.metric.strengthTraining": {"de": "Krafttraining", "en": "Strength Training", "ko": "근력 운동", "ja": "筋力トレーニング", "es": "Entrenamiento de fuerza", "fr": "Musculation", "it": "Allenamento di forza", "pt": "Treino de força", "pl": "Trening siłowy", "nl": "Krachttraining", "tr": "Güç Antrenmanı"},
    
    "settings.health.steps": {"de": "Schritte", "en": "Steps", "ko": "걸음 수", "ja": "歩数", "es": "Pasos", "fr": "Pas", "it": "Passi", "pt": "Passos", "pl": "Kroki", "nl": "Stappen", "tr": "Adımlar"},
    "settings.health.water": {"de": "Wasser", "en": "Water", "ko": "물", "ja": "水", "es": "Agua", "fr": "Eau", "it": "Acqua", "pt": "Água", "pl": "Woda", "nl": "Water", "tr": "Su"},
    
    "plant.detail.custom_tracker.title": {
        "de": "Eigener Tracker", "en": "Custom Tracker", "ko": "맞춤형 트래커", "ja": "カスタムトラッカー", "es": "Rastreador personalizado",
        "fr": "Traqueur personnalisé", "it": "Tracker personalizzato", "pt": "Rastreador personalizado", "pl": "Własny tracker", "nl": "Aangepaste tracker", "tr": "Özel İzleyici"
    }
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {"extractionState": "manual", "localizations": {}}
    for lang, val in lang_dict.items():
        if lang not in data["strings"][key]["localizations"]:
            data["strings"][key]["localizations"][lang] = {"stringUnit": {"state": "translated", "value": val}}
        else:
            data["strings"][key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
