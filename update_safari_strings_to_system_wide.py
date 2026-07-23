import json

file_path = "Garten_Simulation/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "screenTime.safariFilter.title": {
        "en": "System-wide Adult Filter",
        "de": "Systemweiter Erwachsenen-Filter",
        "es": "Filtro de adultos en todo el sistema",
        "fr": "Filtre adulte à l'échelle du système",
        "it": "Filtro per adulti a livello di sistema",
        "pt": "Filtro Adulto em Todo o Sistema",
        "pt-BR": "Filtro Adulto em Todo o Sistema",
        "nl": "Systeembrede filter voor volwassenen",
        "pl": "Ogólnosystemowy filtr dla dorosłych",
        "ru": "Общесистемный фильтр для взрослых",
        "tr": "Sistem Çapında Yetişkin Filtresi",
        "hi": "सिस्टम-व्यापी वयस्क फ़िल्टर",
        "ja": "システム全体のアダルトフィルター",
        "ko": "시스템 전체 성인 필터",
        "zh-Hans": "全系统成人过滤器",
        "zh-Hant": "全系統成人過濾器"
    },
    "screenTime.safariFilter.desc": {
        "en": "Blocks adult content and malware system-wide across all browsers (Chrome, Edge, Safari, etc.) via Cloudflare Family DNS.",
        "de": "Blockiert nicht jugendfreie Inhalte und Malware systemweit in allen Browsern (Chrome, Edge, Safari etc.) über Cloudflare Family DNS.",
        "es": "Bloquea contenido para adultos y malware en todo el sistema y en todos los navegadores a través de Cloudflare Family DNS.",
        "fr": "Bloque le contenu pour adultes et les malwares à l'échelle du système sur tous les navigateurs via Cloudflare Family DNS.",
        "it": "Blocca contenuti per adulti e malware a livello di sistema su tutti i browser tramite Cloudflare Family DNS.",
        "pt": "Bloqueia conteúdo adulto e malware em todo o sistema, em todos os navegadores, através do Cloudflare Family DNS.",
        "pt-BR": "Bloqueia conteúdo adulto e malware em todo o sistema, em todos os navegadores, através do Cloudflare Family DNS.",
        "nl": "Blokkeert inhoud voor volwassenen en malware systeembreed in alle browsers via Cloudflare Family DNS.",
        "pl": "Blokuje treści dla dorosłych i złośliwe oprogramowanie ogólnosystemowo we wszystkich przeglądarkach przez Cloudflare Family DNS.",
        "ru": "Блокирует контент для взрослых и вредоносное ПО во всех браузерах с помощью Cloudflare Family DNS.",
        "tr": "Cloudflare Family DNS ile tüm tarayıcılarda sistem genelinde yetişkinlere yönelik içeriği ve kötü amaçlı yazılımları engeller.",
        "hi": "क्लाउडफ्लेयर फैमिली डीएनएस के माध्यम से सभी ब्राउज़रों में वयस्क सामग्री को ब्लॉक करता है।",
        "ja": "Cloudflare Family DNSを使用して、すべてのブラウザでアダルトコンテンツとマルウェアをシステム全体でブロックします。",
        "ko": "Cloudflare Family DNS를 통해 모든 브라우저에서 성인 콘텐츠 및 맬웨어를 시스템 전체에서 차단합니다.",
        "zh-Hans": "通过 Cloudflare Family DNS 在所有浏览器中全系统拦截成人内容和恶意软件。",
        "zh-Hant": "透過 Cloudflare Family DNS 在所有瀏覽器中全系統攔截成人內容和惡意軟體。"
    },
    "screenTime.safariFilter.button.inactive": {
        "en": "Activate System Filter",
        "de": "System-Filter aktivieren",
        "es": "Activar filtro del sistema",
        "fr": "Activer le filtre système",
        "it": "Attiva filtro di sistema",
        "pt": "Ativar Filtro do Sistema",
        "pt-BR": "Ativar Filtro do Sistema",
        "nl": "Systeemfilter activeren",
        "pl": "Aktywuj filtr systemowy",
        "ru": "Активировать системный фильтр",
        "tr": "Sistem Filtresini Etkinleştir",
        "hi": "सिस्टम फ़िल्टर सक्रिय करें",
        "ja": "システムフィルターを有効にする",
        "ko": "시스템 필터 활성화",
        "zh-Hans": "激活系统过滤器",
        "zh-Hant": "啟用系統過濾器"
    }
}

for key, trans in translations.items():
    if key in data["strings"]:
        for lang, text in trans.items():
            if lang in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = text
            else:
                data["strings"][key]["localizations"][lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": text
                    }
                }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Strings updated to reflect system-wide functionality.")
