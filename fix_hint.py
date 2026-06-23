import re

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

with open(file_path, "r") as f:
    content = f.read()

new_string = """
        "iap_restore_hint": [
            "de": "⚠️ WICHTIG: 'Käufe wiederherstellen' funktioniert bei Apple NUR für Einmalkäufe (wie die Sonnenbrille). Münzen (Consumables) können laut Apple-Regeln niemals wiederhergestellt werden.",
            "en": "⚠️ IMPORTANT: 'Restore Purchases' ONLY works for non-consumables (like the sunglasses). Coins (consumables) can never be restored according to Apple rules.",
            "es": "⚠️ IMPORTANTE: 'Restaurar compras' SOLO funciona para compras no consumibles (como las gafas de sol). Las monedas no se pueden restaurar.",
            "fr": "⚠️ IMPORTANT : 'Restaurer les achats' fonctionne UNIQUEMENT pour les achats non consommables (comme les lunettes). Les pièces ne peuvent pas être restaurées.",
            "it": "⚠️ IMPORTANTE: 'Ripristina acquisti' funziona SOLO per articoli non di consumo (come gli occhiali da sole). Le monete non possono essere ripristinate.",
            "pt": "⚠️ IMPORTANTE: 'Restaurar Compras' funciona APENAS para não consumíveis (como óculos de sol). Moedas nunca podem ser restauradas.",
            "ja": "⚠️ 重要: 「購入の復元」は、非消耗品（サングラスなど）にのみ機能します。コインは復元できません。",
            "ko": "⚠️ 중요: '구매 복원'은 비소모품(선글라스 등)에만 적용됩니다. 코인은 복원할 수 없습니다.",
            "pl": "⚠️ WAŻNE: 'Przywróć zakupy' działa TYLKO dla przedmiotów jednorazowych (jak okulary). Monet nie można przywrócić.",
            "nl": "⚠️ BELANGRIJK: 'Aankopen herstellen' werkt ALLEEN voor niet-verbruiksartikelen (zoals zonnebrillen). Munten kunnen niet worden hersteld.",
            "tr": "⚠️ ÖNEMLİ: 'Satın Alınanları Geri Yükle' SADECE güneş gözlüğü gibi kalıcı öğeler için çalışır. Jetonlar geri yüklenemez."
        ],"""

# insert right before "iap_restore_btn"
if '"iap_restore_btn"' in content:
    content = content.replace('"iap_restore_btn"', new_string.lstrip() + '\n        "iap_restore_btn"')
    with open(file_path, "w") as f:
        f.write(content)
    print("Added iap_restore_hint")
else:
    print("Could not find iap_restore_btn")
