import json

file_path = 'Garten_Simulation/Localizable.xcstrings'
with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

new_strings = {
    "goal.type.year": {
        "en": "Yearly Goal", "de": "Jahresziel", "es": "Objetivo Anual", "fr": "Objectif Annuel", "it": "Obiettivo Annuale", "pt": "Objetivo Anual", "nl": "Jaardoel", "pl": "Cel Roczny", "ru": "Годовая цель", "tr": "Yıllık Hedef", "ja": "年間目標", "ko": "연간 목표", "zh-Hans": "年度目标", "zh-Hant": "年度目標", "hi": "वार्षिक लक्ष्य"
    },
    "goal.type.month": {
        "en": "Monthly Goal", "de": "Monatsziel", "es": "Objetivo Mensual", "fr": "Objectif Mensuel", "it": "Obiettivo Mensile", "pt": "Objetivo Mensal", "nl": "Maanddoel", "pl": "Cel Miesięczny", "ru": "Ежемесячная цель", "tr": "Aylık Hedef", "ja": "月間目標", "ko": "월간 목표", "zh-Hans": "月度目标", "zh-Hant": "月度目標", "hi": "मासिक लक्ष्य"
    },
    "goal.weight.massive": {
        "en": "Massive (20 Pts)", "de": "Massiv (20 Pkt)", "es": "Masivo (20 Pts)", "fr": "Massif (20 Pts)", "it": "Massiccio (20 Pti)", "pt": "Massivo (20 Pts)", "nl": "Massief (20 Ptn)", "pl": "Masywny (20 Pkt)", "ru": "Массивный (20 Очков)", "tr": "Muazzam (20 Puan)", "ja": "大規模 (20 Pt)", "ko": "대규모 (20 Pt)", "zh-Hans": "巨大 (20分)", "zh-Hant": "巨大 (20分)", "hi": "व्यापक (20 अंक)"
    },
    "goal.weight.bit": {
        "en": "A bit (5 Pts)", "de": "Ein bisschen (5 Pkt)", "es": "Un poco (5 Pts)", "fr": "Un peu (5 Pts)", "it": "Un po' (5 Pti)", "pt": "Um pouco (5 Pts)", "nl": "Een beetje (5 Ptn)", "pl": "Trochę (5 Pkt)", "ru": "Немного (5 Очков)", "tr": "Biraz (5 Puan)", "ja": "少し (5 Pt)", "ko": "조금 (5 Pt)", "zh-Hans": "一点 (5分)", "zh-Hant": "一點 (5分)", "hi": "थोड़ा (5 अंक)"
    },
    "goal.template.tech_business": {
        "en": "Build Tech Business", "de": "Tech-Business aufbauen", "es": "Construir Negocio Tecnológico", "fr": "Créer une Entreprise Tech", "it": "Costruire un'Azienda Tech", "pt": "Criar Empresa de Tecnologia", "nl": "Techbedrijf opbouwen", "pl": "Zbuduj firmę technologiczną", "ru": "Создать технологический бизнес", "tr": "Teknoloji İşletmesi Kur", "ja": "テックビジネスを構築", "ko": "테크 비즈니스 구축", "zh-Hans": "建立科技公司", "zh-Hant": "建立科技公司", "hi": "टेक बिजनेस बनाएं"
    },
    "goal.template.top_athlete": {
        "en": "Top Athlete", "de": "Top-Athlet", "es": "Atleta de Élite", "fr": "Athlète de Haut Niveau", "it": "Atleta di Punta", "pt": "Atleta de Topo", "nl": "Topatleet", "pl": "Czołowy Sportowiec", "ru": "Лучший атлет", "tr": "Üst Düzey Sporcu", "ja": "トップアスリート", "ko": "탑 애슬리트", "zh-Hans": "顶尖运动员", "zh-Hant": "頂尖運動員", "hi": "शीर्ष एथलीट"
    },
    "goal.template.mental_mastery": {
        "en": "Mental Mastery", "de": "Mentale Meisterung", "es": "Dominio Mental", "fr": "Maîtrise Mentale", "it": "Maestria Mentale", "pt": "Domínio Mental", "nl": "Mentale Beheersing", "pl": "Mistrzostwo Umysłowe", "ru": "Ментальное мастерство", "tr": "Zihinsel Ustalık", "ja": "メンタルマスタリー", "ko": "멘탈 마스터리", "zh-Hans": "精神大师", "zh-Hant": "精神大師", "hi": "मानसिक महारत"
    }
}

for key, langs in new_strings.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang_code, text in langs.items():
        data["strings"][key]["localizations"][lang_code] = {
            "stringUnit": {
                "state": "translated",
                "value": text
            }
        }

with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Added Goal strings to Localizable.xcstrings successfully!")
