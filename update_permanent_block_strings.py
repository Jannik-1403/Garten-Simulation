import json

path = "Garten_Simulation/Localizable.xcstrings"

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

langs = ["de", "nl", "en", "fr", "it", "ja", "ko", "pl", "pt", "es", "tr"]

# Dict format: key: {lang: translation}
translations = {
    "screenTime.permanent.title": {
        "de": "Für immer blockieren",
        "en": "Block permanently",
        "es": "Bloquear permanentemente",
        "fr": "Bloquer définitivement",
        "it": "Blocca permanentemente",
        "ja": "永久にブロック",
        "ko": "영구적으로 차단",
        "nl": "Permanent blokkeren",
        "pl": "Zablokuj na stałe",
        "pt": "Bloquear permanentemente",
        "tr": "Kalıcı olarak engelle"
    },
    "screenTime.permanent.desc": {
        "de": "Diese Apps & Kategorien sind unabhängig vom Zeitplan immer gesperrt.",
        "en": "These apps & categories are always blocked regardless of the schedule.",
        "es": "Estas aplicaciones y categorías siempre están bloqueadas independientemente del horario.",
        "fr": "Ces applications et catégories sont toujours bloquées quel que soit le programme.",
        "it": "Queste app e categorie sono sempre bloccate indipendentemente dal programma.",
        "ja": "これらのアプリとカテゴリは、スケジュールに関係なく常にブロックされます。",
        "ko": "이러한 앱과 카테고리는 일정에 관계없이 항상 차단됩니다.",
        "nl": "Deze apps en categorieën zijn altijd geblokkeerd, ongeacht het schema.",
        "pl": "Te aplikacje i kategorie są zawsze blokowane bez względu na harmonogram.",
        "pt": "Esses aplicativos e categorias estão sempre bloqueados, independentemente da programação.",
        "tr": "Bu uygulamalar ve kategoriler programdan bağımsız olarak her zaman engellenir."
    },
    "screenTime.suggestions.title": {
        "de": "Vorschläge zum Blockieren",
        "en": "Suggestions to block",
        "es": "Sugerencias para bloquear",
        "fr": "Suggestions à bloquer",
        "it": "Suggerimenti da bloccare",
        "ja": "ブロックの提案",
        "ko": "차단 제안",
        "nl": "Suggesties om te blokkeren",
        "pl": "Propozycje do zablokowania",
        "pt": "Sugestões para bloquear",
        "tr": "Engelleme önerileri"
    },
    "screenTime.suggestions.adult.title": {
        "de": "Erwachsenen-Inhalte",
        "en": "Adult Content",
        "es": "Contenido para adultos",
        "fr": "Contenu pour adultes",
        "it": "Contenuti per adulti",
        "ja": "アダルトコンテンツ",
        "ko": "성인 콘텐츠",
        "nl": "Inhoud voor volwassenen",
        "pl": "Treści dla dorosłych",
        "pt": "Conteúdo adulto",
        "tr": "Yetişkin İçeriği"
    },
    "screenTime.suggestions.social.title": {
        "de": "Social Media (TikTok etc.)",
        "en": "Social Media (TikTok etc.)",
        "es": "Redes Sociales (TikTok etc.)",
        "fr": "Réseaux Sociaux (TikTok etc.)",
        "it": "Social Media (TikTok ecc.)",
        "ja": "ソーシャルメディア（TikTokなど）",
        "ko": "소셜 미디어 (TikTok 등)",
        "nl": "Social Media (TikTok etc.)",
        "pl": "Media społecznościowe (TikTok itp.)",
        "pt": "Mídia Social (TikTok etc.)",
        "tr": "Sosyal Medya (TikTok vb.)"
    },
    "screenTime.suggestions.casino.title": {
        "de": "Glücksspiel & Casino",
        "en": "Gambling & Casino",
        "es": "Apuestas y Casino",
        "fr": "Jeux d'argent et Casino",
        "it": "Gioco d'azzardo e Casinò",
        "ja": "ギャンブル＆カジノ",
        "ko": "도박 및 카지노",
        "nl": "Gokken & Casino",
        "pl": "Hazard i Kasyno",
        "pt": "Apostas e Cassino",
        "tr": "Kumar ve Casino"
    },
    "screenTime.suggestions.food.title": {
        "de": "Lieferdienste",
        "en": "Food Delivery",
        "es": "Entrega de comida",
        "fr": "Livraison de nourriture",
        "it": "Consegna di cibo",
        "ja": "フードデリバリー",
        "ko": "음식 배달",
        "nl": "Maaltijdbezorging",
        "pl": "Dostawa jedzenia",
        "pt": "Entrega de comida",
        "tr": "Yemek Siparişi"
    },
    "screenTime.suggestions.instruction": {
        "de": "Apple erlaubt aus Datenschutzgründen keine automatische Sperrung. Bitte tippe bei 'Für immer blockieren' auf Hinzufügen, suche nach %@ und wähle es aus.",
        "en": "For privacy reasons, Apple does not allow automatic blocking. Please tap Add under 'Block permanently', search for %@ and select it.",
        "es": "Por razones de privacidad, Apple no permite el bloqueo automático. Toca Añadir en 'Bloquear permanentemente', busca %@ y selecciónalo.",
        "fr": "Pour des raisons de confidentialité, Apple n'autorise pas le blocage automatique. Veuillez appuyer sur Ajouter sous 'Bloquer définitivement', rechercher %@ et le sélectionner.",
        "it": "Per motivi di privacy, Apple non consente il blocco automatico. Tocca Aggiungi in 'Blocca permanentemente', cerca %@ e selezionalo.",
        "ja": "プライバシー保護のため、Appleは自動ブロックを許可していません。「永久にブロック」の下の「追加」をタップし、%@を検索して選択してください。",
        "ko": "개인 정보 보호를 위해 Apple은 자동 차단을 허용하지 않습니다. '영구적으로 차단' 아래의 추가를 탭하고 %@을(를) 검색하여 선택하십시오.",
        "nl": "Om privacyredenen staat Apple automatische blokkering niet toe. Tik op Toevoegen onder 'Permanent blokkeren', zoek naar %@ en selecteer het.",
        "pl": "Ze względów prywatności Apple nie zezwala na automatyczne blokowanie. Stuknij Dodaj pod 'Zablokuj na stałe', wyszukaj %@ i wybierz.",
        "pt": "Por motivos de privacidade, a Apple não permite o bloqueio automático. Toque em Adicionar em 'Bloquear permanentemente', procure %@ e selecione-o.",
        "tr": "Gizlilik nedenlerinden dolayı, Apple otomatik engellemeye izin vermez. Lütfen 'Kalıcı olarak engelle' altındaki Ekle'ye dokunun, %@ uygulamasını arayın ve seçin."
    }
}

for key, lang_dict in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang in langs:
        val = lang_dict.get(lang, lang_dict["en"])
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
            
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings updated successfully.")
