import json

# Der Pfad zu deiner exklusiven StoreKit-Datei
file_path = "Products.storekit"

# Hier definierst du ein einziges Mal zentral alle deine Übersetzungen
# 11 Projektsprachen: DE, NL, EN, FR, IT, JA, KO, PL, PT, ES, TR
translations = {
    "com.jannik.grovy.pro.monthly": {
        "en": {"displayName": "Grovy Pro Monthly", "description": "Monthly pro access to your garden."},
        "de": {"displayName": "Grovy Pro Monatlich", "description": "Monatlicher Pro-Zugang für deinen Garten."},
        "es": {"displayName": "Grovy Pro Mensual", "description": "Acceso pro mensual para tu jardín."},
        "fr": {"displayName": "Grovy Pro Mensuel", "description": "Accès pro mensuel pour votre jardin."},
        "it": {"displayName": "Grovy Pro Mensile", "description": "Accesso pro mensile per il tuo giardino."},
        "nl": {"displayName": "Grovy Pro Maandelijks", "description": "Maandelijkse pro-toegang voor je tuin."},
        "ja": {"displayName": "Grovy Pro マンスリー", "description": "庭への毎月のプロアクセス。"},
        "ko": {"displayName": "Grovy Pro 월간", "description": "정원에 대한 월간 프로 액세스."},
        "pl": {"displayName": "Grovy Pro Miesięcznie", "description": "Miesięczny dostęp pro do twojego ogrodu."},
        "pt": {"displayName": "Grovy Pro Mensal", "description": "Acesso pro mensal para o seu jardim."},
        "tr": {"displayName": "Grovy Pro Aylık", "description": "Bahçeniz için aylık pro erişimi."}
    },
    "com.jannik.grovy.pro.yearly": {
        "en": {"displayName": "Grovy Pro Yearly", "description": "Yearly pro access."},
        "de": {"displayName": "Grovy Pro Jährlich", "description": "Jährlicher Pro-Zugang."},
        "es": {"displayName": "Grovy Pro Anual", "description": "Acceso pro anual."},
        "fr": {"displayName": "Grovy Pro Annuel", "description": "Accès pro annuel."},
        "it": {"displayName": "Grovy Pro Annuale", "description": "Accesso pro annuale."},
        "nl": {"displayName": "Grovy Pro Jaarlijks", "description": "Jaarlijkse pro-toegang."},
        "ja": {"displayName": "Grovy Pro 年間", "description": "年間プロアクセス。"},
        "ko": {"displayName": "Grovy Pro 연간", "description": "연간 프로 액세스."},
        "pl": {"displayName": "Grovy Pro Rocznie", "description": "Roczny dostęp pro."},
        "pt": {"displayName": "Grovy Pro Anual", "description": "Acesso pro anual."},
        "tr": {"displayName": "Grovy Pro Yıllık", "description": "Yıllık pro erişimi."}
    },
    "com.jannik.grovy.pro.lifetime": {
        "en": {"displayName": "Grovy Pro Lifetime", "description": "Unlock the full potential forever."},
        "de": {"displayName": "Grovy Pro Lifetime", "description": "Schalte das volle Potenzial für immer frei."},
        "es": {"displayName": "Grovy Pro de por vida", "description": "Desbloquea todo el potencial para siempre."},
        "fr": {"displayName": "Grovy Pro à vie", "description": "Débloquez tout le potentiel pour toujours."},
        "it": {"displayName": "Grovy Pro a vita", "description": "Sblocca l'intero potenziale per sempre."},
        "nl": {"displayName": "Grovy Pro Levenslang", "description": "Ontgrendel het volledige potentieel voor altijd."},
        "ja": {"displayName": "Grovy Pro ライフタイム", "description": "永遠に最大限の可能性を解き放ちます。"},
        "ko": {"displayName": "Grovy Pro 평생", "description": "영원히 모든 잠재력을 잠금 해제하십시오."},
        "pl": {"displayName": "Grovy Pro Dożywotnio", "description": "Odblokuj pełny potencjał na zawsze."},
        "pt": {"displayName": "Grovy Pro Vitalício", "description": "Desbloqueie todo o potencial para sempre."},
        "tr": {"displayName": "Grovy Pro Ömür Boyu", "description": "Tüm potansiyeli sonsuza dek ortaya çıkarın."}
    },
    "com.jannik.grovy.cosmetics.glasses": {
        "en": {"displayName": "Premium Glasses", "description": "Stylish glasses for your characters."},
        "de": {"displayName": "Premium Brille", "description": "Stylische Brille für deine Charaktere."},
        "es": {"displayName": "Gafas Premium", "description": "Gafas elegantes para tus personajes."},
        "fr": {"displayName": "Lunettes Premium", "description": "Lunettes élégantes pour vos personnages."},
        "it": {"displayName": "Occhiali Premium", "description": "Occhiali alla moda per i tuoi personaggi."},
        "nl": {"displayName": "Premium Bril", "description": "Stijlvolle bril voor je personages."},
        "ja": {"displayName": "プレミアムメガネ", "description": "キャラクター向けのスタイリッシュなメガネ。"},
        "ko": {"displayName": "프리미엄 안경", "description": "캐릭터를 위한 세련된 안경."},
        "pl": {"displayName": "Okulary Premium", "description": "Stylowe okulary dla twoich postaci."},
        "pt": {"displayName": "Óculos Premium", "description": "Óculos elegantes para seus personagens."},
        "tr": {"displayName": "Premium Gözlük", "description": "Karakterleriniz için şık gözlükler."}
    },
    "com.jannik.grovy.coins.pack_small": {
        "en": {"displayName": "Small Coin Pack", "description": "A small pile of coins."},
        "de": {"displayName": "Kleines Münzpaket", "description": "Ein kleiner Haufen Münzen."},
        "es": {"displayName": "Paquete Pequeño de Monedas", "description": "Una pequeña pila de monedas."},
        "fr": {"displayName": "Petit Pack de Pièces", "description": "Une petite pile de pièces."},
        "it": {"displayName": "Piccolo Pacchetto di Monete", "description": "Un piccolo mucchio di monete."},
        "nl": {"displayName": "Klein Muntenpakket", "description": "Een kleine stapel munten."},
        "ja": {"displayName": "小さなコインパック", "description": "小さなコインの山。"},
        "ko": {"displayName": "작은 코인 팩", "description": "작은 동전 더미."},
        "pl": {"displayName": "Mały Pakiet Monet", "description": "Mały stos monet."},
        "pt": {"displayName": "Pequeno Pacote de Moedas", "description": "Uma pequena pilha de moedas."},
        "tr": {"displayName": "Küçük Jeton Paketi", "description": "Küçük bir jeton yığını."}
    },
    "com.jannik.grovy.coins.pack_medium": {
        "en": {"displayName": "Medium Coin Pack", "description": "A decent amount of coins."},
        "de": {"displayName": "Mittleres Münzpaket", "description": "Eine ordentliche Menge Münzen."},
        "es": {"displayName": "Paquete Mediano de Monedas", "description": "Una cantidad decente de monedas."},
        "fr": {"displayName": "Pack de Pièces Moyen", "description": "Une quantité décente de pièces."},
        "it": {"displayName": "Pacchetto Medio di Monete", "description": "Una discreta quantità di monete."},
        "nl": {"displayName": "Middelgroot Muntenpakket", "description": "Een behoorlijke hoeveelheid munten."},
        "ja": {"displayName": "中くらいのコインパック", "description": "まともな量のコイン。"},
        "ko": {"displayName": "중간 코인 팩", "description": "적당한 양의 동전."},
        "pl": {"displayName": "Średni Pakiet Monet", "description": "Przyzwoita ilość monet."},
        "pt": {"displayName": "Pacote Médio de Moedas", "description": "Uma quantidade decente de moedas."},
        "tr": {"displayName": "Orta Jeton Paketi", "description": "İyi miktarda jeton."}
    },
    "com.jannik.grovy.coins.pack_large": {
        "en": {"displayName": "Large Coin Pack", "description": "A massive pile of coins."},
        "de": {"displayName": "Großes Münzpaket", "description": "Ein riesiger Haufen Münzen."},
        "es": {"displayName": "Paquete Grande de Monedas", "description": "Una pila masiva de monedas."},
        "fr": {"displayName": "Grand Pack de Pièces", "description": "Une pile massive de pièces."},
        "it": {"displayName": "Grande Pacchetto di Monete", "description": "Un'enorme pila di monete."},
        "nl": {"displayName": "Groot Muntenpakket", "description": "Een enorme stapel munten."},
        "ja": {"displayName": "大きなコインパック", "description": "大量のコインの山。"},
        "ko": {"displayName": "큰 코인 팩", "description": "거대한 동전 더미."},
        "pl": {"displayName": "Duży Pakiet Monet", "description": "Ogromny stos monet."},
        "pt": {"displayName": "Grande Pacote de Moedas", "description": "Uma enorme pilha de moedas."},
        "tr": {"displayName": "Büyük Jeton Paketi", "description": "Büyük bir jeton yığını."}
    }
}

try:
    with open(file_path, "r") as f:
        data = json.load(f)

    # 1. Übersetze reguläre Produkte (Coins, Cosmetics, Lifetime)
    for product in data.get("products", []):
        pid = product.get("productID")
        if pid in translations:
            locs = []
            for locale, texts in translations[pid].items():
                locs.append({"locale": locale, "displayName": texts["displayName"], "description": texts["description"]})
            product["localizations"] = locs

    # 2. Übersetze Abos (Monthly, Yearly) in den Subscription Groups
    for group in data.get("subscriptionGroups", []):
        for sub in group.get("subscriptions", []):
            pid = sub.get("productID")
            if pid in translations:
                locs = []
                for locale, texts in translations[pid].items():
                    locs.append({"locale": locale, "displayName": texts["displayName"], "description": texts["description"]})
                sub["localizations"] = locs

    with open(file_path, "w") as f:
        json.dump(data, f, indent=2)

    print("✅ StoreKit-Datei erfolgreich und sicher mit neuen Sprachen aktualisiert!")
    
except Exception as e:
    print(f"❌ Fehler beim Aktualisieren: {e}")
