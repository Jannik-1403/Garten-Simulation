new_keys = """
        "common.timeline": ["de": "Zeitleiste", "en": "Timeline", "es": "Línea de tiempo", "fr": "Chronologie", "it": "Cronologia", "pt": "Linha do tempo", "ja": "タイムライン", "ko": "타임라인", "pl": "Oś czasu", "nl": "Tijdlijn", "tr": "Zaman çizelgesi"],
        "common.saved_to_photos": ["de": "In Fotos gespeichert", "en": "Saved to Photos", "es": "Guardado en fotos", "fr": "Enregistré dans les photos", "it": "Salvato nelle foto", "pt": "Salvo em fotos", "ja": "写真に保存されました", "ko": "사진에 저장됨", "pl": "Zapisano w zdjęciach", "nl": "Opgeslagen in foto's", "tr": "Fotoğraflara kaydedildi"],
        "common.day_format": ["de": "Tag %@", "en": "Day %@", "es": "Día %@", "fr": "Jour %@", "it": "Giorno %@", "pt": "Dia %@", "ja": "%@日目", "ko": "%@일차", "pl": "Dzień %@", "nl": "Dag %@", "tr": "%@. Gün"],
        "path.day_progress_format": ["de": "Tag %@ / 90", "en": "Day %@ / 90", "es": "Día %@ / 90", "fr": "Jour %@ / 90", "it": "Giorno %@ / 90", "pt": "Dia %@ / 90", "ja": "%@日目 / 90", "ko": "%@일차 / 90", "pl": "Dzień %@ / 90", "nl": "Dag %@ / 90", "tr": "%@. Gün / 90"],
        "settings.improve_your_life": ["de": "Improve your life", "en": "Improve your life", "es": "Improve your life", "fr": "Improve your life", "it": "Improve your life", "pt": "Improve your life", "ja": "Improve your life", "ko": "Improve your life", "pl": "Improve your life", "nl": "Improve your life", "tr": "Improve your life"],
        "common.cancel": ["de": "Abbrechen", "en": "Cancel", "es": "Cancelar", "fr": "Annuler", "it": "Annulla", "pt": "Cancelar", "ja": "キャンセル", "ko": "취소", "pl": "Anuluj", "nl": "Annuleren", "tr": "İptal"],
        "shop.buy_for_coins_format": ["de": "Für %@ Münzen kaufen", "en": "Buy for %@ coins", "es": "Comprar por %@ monedas", "fr": "Acheter pour %@ pièces", "it": "Compra per %@ monete", "pt": "Comprar por %@ moedas", "ja": "%@コインで購入", "ko": "%@코인으로 구매", "pl": "Kup za %@ monet", "nl": "Koop voor %@ munten", "tr": "%@ jeton ile satın al"],
"""

with open("Localization/AppStrings.swift", "r") as f:
    content = f.read()

import re
match = re.search(r'("stats\.score\.msg\.low": \[.*?\],)', content)
if match:
    new_content = content[:match.end()] + "\n" + new_keys + content[match.end():]
    with open("Localization/AppStrings.swift", "w") as f:
        f.write(new_content)
    print("Inserted remaining keys.")
else:
    print("Failed")
