import json
import sys
import os

json_data = """
{
  "vitamin_c": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin C",
      "en": "Vitamin C",
      "fr": "Vitamine C",
      "it": "Vitamina C",
      "nl": "Vitamine C",
      "pl": "Witamina C",
      "pt": "Vitamina C",
      "pt-BR": "Vitamina C",
      "ru": "Витамин C",
      "es": "Vitamina C",
      "tr": "Vitamin C",
      "zh-Hans": "维生素C",
      "zh-Hant": "維生素C",
      "ja": "ビタミンC",
      "ko": "비타민 C",
      "hi": "विटामिन सी"
    },
    "sources": {
      "de": [
        "Paprika",
        "Orangen",
        "Brokkoli",
        "Schwarze Johannisbeeren"
      ],
      "en": [
        "Bell peppers",
        "Oranges",
        "Broccoli",
        "Blackcurrants"
      ],
      "fr": [
        "Poivrons",
        "Oranges",
        "Brocoli",
        "Cassis"
      ],
      "it": [
        "Peperoni",
        "Arance",
        "Broccoli",
        "Ribes nero"
      ],
      "nl": [
        "Paprika's",
        "Sinaasappels",
        "Broccoli",
        "Zwarte bessen"
      ],
      "pl": [
        "Papryka",
        "Pomarańcze",
        "Brokuły",
        "Czarne porzeczki"
      ],
      "pt": [
        "Pimentos",
        "Laranjas",
        "Brócolos",
        "Groselha-preta"
      ],
      "pt-BR": [
        "Pimentões",
        "Laranjas",
        "Brócolis",
        "Cassis"
      ],
      "ru": [
        "Болгарский перец",
        "Апельсины",
        "Брокколи",
        "Чёрная смородина"
      ],
      "es": [
        "Pimientos",
        "Naranjas",
        "Brócoli",
        "Grosellas negras"
      ],
      "tr": [
        "Dolmalık biber",
        "Portakal",
        "Brokoli",
        "Frenk üzümü (siyah)"
      ],
      "zh-Hans": [
        "甜椒",
        "橙子",
        "西兰花",
        "黑加仑"
      ],
      "zh-Hant": [
        "甜椒",
        "柳橙",
        "綠花椰菜",
        "黑醋栗"
      ],
      "ja": [
        "パプリカ",
        "オレンジ",
        "ブロッコリー",
        "カシス"
      ],
      "ko": [
        "파프리카",
        "오렌지",
        "브로콜리",
        "블랙커런트"
      ],
      "hi": [
        "शिमला मिर्च",
        "संतरा",
        "ब्रोकली",
        "ब्लैककरंट"
      ]
    }
  },
  "vitamin_a": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin A",
      "en": "Vitamin A",
      "fr": "Vitamine A",
      "it": "Vitamina A",
      "nl": "Vitamine A",
      "pl": "Witamina A",
      "pt": "Vitamina A",
      "pt-BR": "Vitamina A",
      "ru": "Витамин A",
      "es": "Vitamina A",
      "tr": "Vitamin A",
      "zh-Hans": "维生素A",
      "zh-Hant": "維生素A",
      "ja": "ビタミンA",
      "ko": "비타민 A",
      "hi": "विटामिन ए"
    },
    "sources": {
      "de": [
        "Leber",
        "Karotten",
        "Süßkartoffeln",
        "Grünkohl"
      ],
      "en": [
        "Liver",
        "Carrots",
        "Sweet potatoes",
        "Kale"
      ],
      "fr": [
        "Foie",
        "Carottes",
        "Patates douces",
        "Chou frisé"
      ],
      "it": [
        "Fegato",
        "Carote",
        "Patate dolci",
        "Cavolo riccio"
      ],
      "nl": [
        "Lever",
        "Wortelen",
        "Zoete aardappelen",
        "Boerenkool"
      ],
      "pl": [
        "Wątróbka",
        "Marchew",
        "Bataty",
        "Jarmuż"
      ],
      "pt": [
        "Fígado",
        "Cenouras",
        "Batata-doce",
        "Couve-galega"
      ],
      "pt-BR": [
        "Fígado",
        "Cenouras",
        "Batata-doce",
        "Couve"
      ],
      "ru": [
        "Печень",
        "Морковь",
        "Батат",
        "Кейл (листовая капуста)"
      ],
      "es": [
        "Hígado",
        "Zanahorias",
        "Boniatos",
        "Col rizada"
      ],
      "tr": [
        "Karaciğer",
        "Havuç",
        "Tatlı patates",
        "Kara lahana"
      ],
      "zh-Hans": [
        "肝脏",
        "胡萝卜",
        "红薯",
        "羽衣甘蓝"
      ],
      "zh-Hant": [
        "肝臟",
        "胡蘿蔔",
        "地瓜",
        "羽衣甘藍"
      ],
      "ja": [
        "レバー",
        "にんじん",
        "サツマイモ",
        "ケール"
      ],
      "ko": [
        "간",
        "당근",
        "고구마",
        "케일"
      ],
      "hi": [
        "कलेजी (लिवर)",
        "गाजर",
        "शकरकंद",
        "केल"
      ]
    }
  },
  "folic_acid": {
    "category": "vitamin",
    "name": {
      "de": "Folsäure",
      "en": "Folic acid",
      "fr": "Acide folique",
      "it": "Acido folico",
      "nl": "Foliumzuur",
      "pl": "Kwas foliowy",
      "pt": "Ácido fólico",
      "pt-BR": "Ácido fólico",
      "ru": "Фолиевая кислота",
      "es": "Ácido fólico",
      "tr": "Folik asit",
      "zh-Hans": "叶酸",
      "zh-Hant": "葉酸",
      "ja": "葉酸",
      "ko": "엽산",
      "hi": "फोलिक एसिड"
    },
    "sources": {
      "de": [
        "Grünes Blattgemüse",
        "Hülsenfrüchte",
        "Spargel",
        "Leber"
      ],
      "en": [
        "Leafy greens",
        "Legumes",
        "Asparagus",
        "Liver"
      ],
      "fr": [
        "Légumes à feuilles vertes",
        "Légumineuses",
        "Asperges",
        "Foie"
      ],
      "it": [
        "Verdure a foglia verde",
        "Legumi",
        "Asparagi",
        "Fegato"
      ],
      "nl": [
        "Bladgroenten",
        "Peulvruchten",
        "Asperges",
        "Lever"
      ],
      "pl": [
        "Warzywa liściaste",
        "Rośliny strączkowe",
        "Szparagi",
        "Wątróbka"
      ],
      "pt": [
        "Vegetais de folhas verdes",
        "Leguminosas",
        "Espargos",
        "Fígado"
      ],
      "pt-BR": [
        "Folhas verdes",
        "Leguminosas",
        "Aspargos",
        "Fígado"
      ],
      "ru": [
        "Листовая зелень",
        "Бобовые",
        "Спаржа",
        "Печень"
      ],
      "es": [
        "Verduras de hoja verde",
        "Legumbres",
        "Espárragos",
        "Hígado"
      ],
      "tr": [
        "Yeşil yapraklı sebzeler",
        "Baklagiller",
        "Kuşkonmaz",
        "Karaciğer"
      ],
      "zh-Hans": [
        "绿叶蔬菜",
        "豆类",
        "芦笋",
        "肝脏"
      ],
      "zh-Hant": [
        "綠葉蔬菜",
        "豆類",
        "蘆筍",
        "肝臟"
      ],
      "ja": [
        "葉物野菜",
        "豆類",
        "アスパラガス",
        "レバー"
      ],
      "ko": [
        "잎채소",
        "콩류",
        "아스파라거스",
        "간"
      ],
      "hi": [
        "हरी पत्तेदार सब्जियाँ",
        "दालें (फलियां)",
        "शतावरी",
        "कलेजी (लिवर)"
      ]
    }
  },
  "vitamin_k": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin K",
      "en": "Vitamin K",
      "fr": "Vitamine K",
      "it": "Vitamina K",
      "nl": "Vitamine K",
      "pl": "Witamina K",
      "pt": "Vitamina K",
      "pt-BR": "Vitamina K",
      "ru": "Витамин K",
      "es": "Vitamina K",
      "tr": "Vitamin K",
      "zh-Hans": "维生素K",
      "zh-Hant": "維生素K",
      "ja": "ビタミンK",
      "ko": "비타민 K",
      "hi": "विटामिन के"
    },
    "sources": {
      "de": [
        "Grünkohl",
        "Spinat",
        "Brokkoli",
        "Sauerkraut"
      ],
      "en": [
        "Kale",
        "Spinach",
        "Broccoli",
        "Sauerkraut"
      ],
      "fr": [
        "Chou frisé",
        "Épinards",
        "Brocoli",
        "Choucroute"
      ],
      "it": [
        "Cavolo riccio",
        "Spinaci",
        "Broccoli",
        "Crauti"
      ],
      "nl": [
        "Boerenkool",
        "Spinazie",
        "Broccoli",
        "Zuurkool"
      ],
      "pl": [
        "Jarmuż",
        "Szpinak",
        "Brokuły",
        "Kiszona kapusta"
      ],
      "pt": [
        "Couve-galega",
        "Espinafre",
        "Brócolos",
        "Chucrute"
      ],
      "pt-BR": [
        "Couve",
        "Espinafre",
        "Brócolis",
        "Chucrute"
      ],
      "ru": [
        "Кейл (листовая капуста)",
        "Шпинат",
        "Брокколи",
        "Квашеная капуста"
      ],
      "es": [
        "Col rizada",
        "Espinacas",
        "Brócoli",
        "Chucrut"
      ],
      "tr": [
        "Kara lahana",
        "Ispanak",
        "Brokoli",
        "Lahana turşusu"
      ],
      "zh-Hans": [
        "羽衣甘蓝",
        "菠菜",
        "西兰花",
        "酸菜"
      ],
      "zh-Hant": [
        "羽衣甘藍",
        "菠菜",
        "綠花椰菜",
        "酸菜"
      ],
      "ja": [
        "ケール",
        "ほうれん草",
        "ブロッコリー",
        "ザワークラウト"
      ],
      "ko": [
        "케일",
        "시금치",
        "브로콜리",
        "사워크라우트"
      ],
      "hi": [
        "केल",
        "पालक",
        "ब्रोकली",
        "खट्टी पत्तागोभी"
      ]
    }
  },
  "thiamin": {
    "category": "vitamin",
    "name": {
      "de": "Thiamin",
      "en": "Thiamine (Vitamin B1)",
      "fr": "Thiamine",
      "it": "Tiamina",
      "nl": "Thiamine",
      "pl": "Tiamina",
      "pt": "Tiamina",
      "pt-BR": "Tiamina",
      "ru": "Тиамин",
      "es": "Tiamina",
      "tr": "Tiamin",
      "zh-Hans": "硫胺素（维生素B1）",
      "zh-Hant": "硫胺素（維生素B1）",
      "ja": "チアミン（ビタミンB1）",
      "ko": "티아민(비타민 B1)",
      "hi": "थायमिन"
    },
    "sources": {
      "de": [
        "Vollkornprodukte",
        "Schweinefleisch",
        "Hülsenfrüchte",
        "Nüsse"
      ],
      "en": [
        "Whole grains",
        "Pork",
        "Legumes",
        "Nuts"
      ],
      "fr": [
        "Céréales complètes",
        "Porc",
        "Légumineuses",
        "Fruits à coque"
      ],
      "it": [
        "Cereali integrali",
        "Carne di maiale",
        "Legumi",
        "Frutta secca"
      ],
      "nl": [
        "Volkoren producten",
        "Varkensvlees",
        "Peulvruchten",
        "Noten"
      ],
      "pl": [
        "Produkty pełnoziarniste",
        "Wieprzowina",
        "Rośliny strączkowe",
        "Orzechy"
      ],
      "pt": [
        "Cereais integrais",
        "Carne de porco",
        "Leguminosas",
        "Frutos secos"
      ],
      "pt-BR": [
        "Grãos integrais",
        "Carne de porco",
        "Leguminosas",
        "Castanhas e nozes"
      ],
      "ru": [
        "Цельнозерновые продукты",
        "Свинина",
        "Бобовые",
        "Орехи"
      ],
      "es": [
        "Cereales integrales",
        "Cerdo",
        "Legumbres",
        "Frutos secos"
      ],
      "tr": [
        "Tam tahıllar",
        "Domuz eti",
        "Baklagiller",
        "Kuruyemişler"
      ],
      "zh-Hans": [
        "全谷物",
        "猪肉",
        "豆类",
        "坚果"
      ],
      "zh-Hant": [
        "全穀類",
        "豬肉",
        "豆類",
        "堅果"
      ],
      "ja": [
        "全粒穀物",
        "豚肉",
        "豆類",
        "ナッツ"
      ],
      "ko": [
        "통곡물",
        "돼지고기",
        "콩류",
        "견과류"
      ],
      "hi": [
        "साबुत अनाज",
        "सूअर का मांस",
        "दालें (फलियां)",
        "मेवे (नट्स)"
      ]
    }
  },
  "riboflavin": {
    "category": "vitamin",
    "name": {
      "de": "Riboflavin",
      "en": "Riboflavin (Vitamin B2)",
      "fr": "Riboflavine",
      "it": "Riboflavina",
      "nl": "Riboflavine",
      "pl": "Ryboflawina",
      "pt": "Riboflavina",
      "pt-BR": "Riboflavina",
      "ru": "Рибофлавин",
      "es": "Riboflavina",
      "tr": "Riboflavin",
      "zh-Hans": "核黄素（维生素B2）",
      "zh-Hant": "核黃素（維生素B2）",
      "ja": "リボフラビン（ビタミンB2）",
      "ko": "리보플라빈(비타민 B2)",
      "hi": "राइबोफ्लेविन"
    },
    "sources": {
      "de": [
        "Milchprodukte",
        "Eier",
        "Mandeln",
        "Leber"
      ],
      "en": [
        "Dairy products",
        "Eggs",
        "Almonds",
        "Liver"
      ],
      "fr": [
        "Produits laitiers",
        "Œufs",
        "Amandes",
        "Foie"
      ],
      "it": [
        "Latticini",
        "Uova",
        "Mandorle",
        "Fegato"
      ],
      "nl": [
        "Zuivelproducten",
        "Eieren",
        "Amandelen",
        "Lever"
      ],
      "pl": [
        "Produkty mleczne",
        "Jajka",
        "Migdały",
        "Wątróbka"
      ],
      "pt": [
        "Laticínios",
        "Ovos",
        "Amêndoas",
        "Fígado"
      ],
      "pt-BR": [
        "Laticínios",
        "Ovos",
        "Amêndoas",
        "Fígado"
      ],
      "ru": [
        "Молочные продукты",
        "Яйца",
        "Миндаль",
        "Печень"
      ],
      "es": [
        "Lácteos",
        "Huevos",
        "Almendras",
        "Hígado"
      ],
      "tr": [
        "Süt ürünleri",
        "Yumurta",
        "Badem",
        "Karaciğer"
      ],
      "zh-Hans": [
        "乳制品",
        "鸡蛋",
        "杏仁",
        "肝脏"
      ],
      "zh-Hant": [
        "乳製品",
        "雞蛋",
        "杏仁",
        "肝臟"
      ],
      "ja": [
        "乳製品",
        "卵",
        "アーモンド",
        "レバー"
      ],
      "ko": [
        "유제품",
        "달걀",
        "아몬드",
        "간"
      ],
      "hi": [
        "डेयरी उत्पाद",
        "अंडे",
        "बादाम",
        "कलेजी (लिवर)"
      ]
    }
  },
  "niacin": {
    "category": "vitamin",
    "name": {
      "de": "Niacin",
      "en": "Niacin (Vitamin B3)",
      "fr": "Niacine",
      "it": "Niacina",
      "nl": "Niacine",
      "pl": "Niacyna",
      "pt": "Niacina",
      "pt-BR": "Niacina",
      "ru": "Ниацин",
      "es": "Niacina",
      "tr": "Niasin",
      "zh-Hans": "烟酸（维生素B3）",
      "zh-Hant": "菸鹼酸（維生素B3）",
      "ja": "ナイアシン（ビタミンB3）",
      "ko": "나이아신(비타민 B3)",
      "hi": "नियासिन"
    },
    "sources": {
      "de": [
        "Geflügel",
        "Fisch",
        "Erdnüsse",
        "Vollkornprodukte"
      ],
      "en": [
        "Poultry",
        "Fish",
        "Peanuts",
        "Whole grains"
      ],
      "fr": [
        "Volaille",
        "Poisson",
        "Cacahuètes",
        "Céréales complètes"
      ],
      "it": [
        "Pollame",
        "Pesce",
        "Arachidi",
        "Cereali integrali"
      ],
      "nl": [
        "Gevogelte",
        "Vis",
        "Pinda's",
        "Volkoren producten"
      ],
      "pl": [
        "Drób",
        "Ryby",
        "Orzeszki ziemne",
        "Produkty pełnoziarniste"
      ],
      "pt": [
        "Aves",
        "Peixe",
        "Amendoins",
        "Cereais integrais"
      ],
      "pt-BR": [
        "Aves",
        "Peixe",
        "Amendoim",
        "Grãos integrais"
      ],
      "ru": [
        "Птица",
        "Рыба",
        "Арахис",
        "Цельнозерновые продукты"
      ],
      "es": [
        "Aves de corral",
        "Pescado",
        "Cacahuetes",
        "Cereales integrales"
      ],
      "tr": [
        "Kanatlı et",
        "Balık",
        "Yer fıstığı",
        "Tam tahıllar"
      ],
      "zh-Hans": [
        "禽肉",
        "鱼类",
        "花生",
        "全谷物"
      ],
      "zh-Hant": [
        "禽肉",
        "魚類",
        "花生",
        "全穀類"
      ],
      "ja": [
        "鶏肉などの家禽",
        "魚",
        "ピーナッツ",
        "全粒穀物"
      ],
      "ko": [
        "가금류",
        "생선",
        "땅콩",
        "통곡물"
      ],
      "hi": [
        "पोल्ट्री (मुर्गा)",
        "मछली",
        "मूंगफली",
        "साबुत अनाज"
      ]
    }
  },
  "vitamin_b5": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin B5 (Pantothensäure)",
      "en": "Vitamin B5 (Pantothenic acid)",
      "fr": "Vitamine B5 (acide pantothénique)",
      "it": "Vitamina B5 (acido pantotenico)",
      "nl": "Vitamine B5 (pantotheenzuur)",
      "pl": "Witamina B5 (kwas pantotenowy)",
      "pt": "Vitamina B5 (ácido pantoténico)",
      "pt-BR": "Vitamina B5 (ácido pantotênico)",
      "ru": "Витамин B5 (пантотеновая кислота)",
      "es": "Vitamina B5 (ácido pantoténico)",
      "tr": "Vitamin B5 (pantotenik asit)",
      "zh-Hans": "维生素B5（泛酸）",
      "zh-Hant": "維生素B5（泛酸）",
      "ja": "ビタミンB5（パントテン酸）",
      "ko": "비타민 B5(판토텐산)",
      "hi": "विटामिन बी5 (पैंटोथेनिक एसिड)"
    },
    "sources": {
      "de": [
        "Eier",
        "Avocado",
        "Vollkornprodukte",
        "Pilze"
      ],
      "en": [
        "Eggs",
        "Avocado",
        "Whole grains",
        "Mushrooms"
      ],
      "fr": [
        "Œufs",
        "Avocat",
        "Céréales complètes",
        "Champignons"
      ],
      "it": [
        "Uova",
        "Avocado",
        "Cereali integrali",
        "Funghi"
      ],
      "nl": [
        "Eieren",
        "Avocado",
        "Volkoren producten",
        "Paddenstoelen"
      ],
      "pl": [
        "Jajka",
        "Awokado",
        "Produkty pełnoziarniste",
        "Grzyby"
      ],
      "pt": [
        "Ovos",
        "Abacate",
        "Cereais integrais",
        "Cogumelos"
      ],
      "pt-BR": [
        "Ovos",
        "Abacate",
        "Grãos integrais",
        "Cogumelos"
      ],
      "ru": [
        "Яйца",
        "Авокадо",
        "Цельнозерновые продукты",
        "Грибы"
      ],
      "es": [
        "Huevos",
        "Aguacate",
        "Cereales integrales",
        "Setas"
      ],
      "tr": [
        "Yumurta",
        "Avokado",
        "Tam tahıllar",
        "Mantar"
      ],
      "zh-Hans": [
        "鸡蛋",
        "牛油果",
        "全谷物",
        "蘑菇"
      ],
      "zh-Hant": [
        "雞蛋",
        "酪梨",
        "全穀類",
        "蘑菇"
      ],
      "ja": [
        "卵",
        "アボカド",
        "全粒穀物",
        "きのこ"
      ],
      "ko": [
        "달걀",
        "아보카도",
        "통곡물",
        "버섯"
      ],
      "hi": [
        "अंडे",
        "एवोकाडो",
        "साबुत अनाज",
        "मशरूम"
      ]
    }
  },
  "vitamin_b6": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin B6",
      "en": "Vitamin B6",
      "fr": "Vitamine B6",
      "it": "Vitamina B6",
      "nl": "Vitamine B6",
      "pl": "Witamina B6",
      "pt": "Vitamina B6",
      "pt-BR": "Vitamina B6",
      "ru": "Витамин B6",
      "es": "Vitamina B6",
      "tr": "Vitamin B6",
      "zh-Hans": "维生素B6",
      "zh-Hant": "維生素B6",
      "ja": "ビタミンB6",
      "ko": "비타민 B6",
      "hi": "विटामिन बी6"
    },
    "sources": {
      "de": [
        "Geflügel",
        "Kartoffeln",
        "Bananen",
        "Fisch"
      ],
      "en": [
        "Poultry",
        "Potatoes",
        "Bananas",
        "Fish"
      ],
      "fr": [
        "Volaille",
        "Pommes de terre",
        "Bananes",
        "Poisson"
      ],
      "it": [
        "Pollame",
        "Patate",
        "Banane",
        "Pesce"
      ],
      "nl": [
        "Gevogelte",
        "Aardappelen",
        "Bananen",
        "Vis"
      ],
      "pl": [
        "Drób",
        "Ziemniaki",
        "Banany",
        "Ryby"
      ],
      "pt": [
        "Aves",
        "Batatas",
        "Bananas",
        "Peixe"
      ],
      "pt-BR": [
        "Aves",
        "Batatas",
        "Bananas",
        "Peixe"
      ],
      "ru": [
        "Птица",
        "Картофель",
        "Бананы",
        "Рыба"
      ],
      "es": [
        "Aves de corral",
        "Patatas",
        "Plátanos",
        "Pescado"
      ],
      "tr": [
        "Kanatlı et",
        "Patates",
        "Muz",
        "Balık"
      ],
      "zh-Hans": [
        "禽肉",
        "土豆",
        "香蕉",
        "鱼类"
      ],
      "zh-Hant": [
        "禽肉",
        "馬鈴薯",
        "香蕉",
        "魚類"
      ],
      "ja": [
        "鶏肉などの家禽",
        "じゃがいも",
        "バナナ",
        "魚"
      ],
      "ko": [
        "가금류",
        "감자",
        "바나나",
        "생선"
      ],
      "hi": [
        "पोल्ट्री (मुर्गा)",
        "आलू",
        "केला",
        "मछली"
      ]
    }
  },
  "biotin": {
    "category": "vitamin",
    "name": {
      "de": "Biotin",
      "en": "Biotin",
      "fr": "Biotine",
      "it": "Biotina",
      "nl": "Biotine",
      "pl": "Biotyna",
      "pt": "Biotina",
      "pt-BR": "Biotina",
      "ru": "Биотин",
      "es": "Biotina",
      "tr": "Biyotin",
      "zh-Hans": "生物素",
      "zh-Hant": "生物素",
      "ja": "ビオチン",
      "ko": "비오틴",
      "hi": "बायोटिन"
    },
    "sources": {
      "de": [
        "Eier",
        "Nüsse",
        "Leber",
        "Haferflocken"
      ],
      "en": [
        "Eggs",
        "Nuts",
        "Liver",
        "Oats"
      ],
      "fr": [
        "Œufs",
        "Fruits à coque",
        "Foie",
        "Flocons d'avoine"
      ],
      "it": [
        "Uova",
        "Frutta secca",
        "Fegato",
        "Fiocchi d'avena"
      ],
      "nl": [
        "Eieren",
        "Noten",
        "Lever",
        "Havermout"
      ],
      "pl": [
        "Jajka",
        "Orzechy",
        "Wątróbka",
        "Płatki owsiane"
      ],
      "pt": [
        "Ovos",
        "Frutos secos",
        "Fígado",
        "Aveia"
      ],
      "pt-BR": [
        "Ovos",
        "Castanhas e nozes",
        "Fígado",
        "Aveia"
      ],
      "ru": [
        "Яйца",
        "Орехи",
        "Печень",
        "Овсянка"
      ],
      "es": [
        "Huevos",
        "Frutos secos",
        "Hígado",
        "Avena"
      ],
      "tr": [
        "Yumurta",
        "Kuruyemişler",
        "Karaciğer",
        "Yulaf"
      ],
      "zh-Hans": [
        "鸡蛋",
        "坚果",
        "肝脏",
        "燕麦"
      ],
      "zh-Hant": [
        "雞蛋",
        "堅果",
        "肝臟",
        "燕麥"
      ],
      "ja": [
        "卵",
        "ナッツ",
        "レバー",
        "オーツ麦"
      ],
      "ko": [
        "달걀",
        "견과류",
        "간",
        "귀리"
      ],
      "hi": [
        "अंडे",
        "मेवे (नट्स)",
        "कलेजी (लिवर)",
        "जई (ओट्स)"
      ]
    }
  },
  "vitamin_b12": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin B12",
      "en": "Vitamin B12",
      "fr": "Vitamine B12",
      "it": "Vitamina B12",
      "nl": "Vitamine B12",
      "pl": "Witamina B12",
      "pt": "Vitamina B12",
      "pt-BR": "Vitamina B12",
      "ru": "Витамин B12",
      "es": "Vitamina B12",
      "tr": "Vitamin B12",
      "zh-Hans": "维生素B12",
      "zh-Hant": "維生素B12",
      "ja": "ビタミンB12",
      "ko": "비타민 B12",
      "hi": "विटामिन बी12"
    },
    "sources": {
      "de": [
        "Fleisch",
        "Fisch",
        "Milchprodukte",
        "Eier"
      ],
      "en": [
        "Meat",
        "Fish",
        "Dairy products",
        "Eggs"
      ],
      "fr": [
        "Viande",
        "Poisson",
        "Produits laitiers",
        "Œufs"
      ],
      "it": [
        "Carne",
        "Pesce",
        "Latticini",
        "Uova"
      ],
      "nl": [
        "Vlees",
        "Vis",
        "Zuivelproducten",
        "Eieren"
      ],
      "pl": [
        "Mięso",
        "Ryby",
        "Produkty mleczne",
        "Jajka"
      ],
      "pt": [
        "Carne",
        "Peixe",
        "Laticínios",
        "Ovos"
      ],
      "pt-BR": [
        "Carne",
        "Peixe",
        "Laticínios",
        "Ovos"
      ],
      "ru": [
        "Мясо",
        "Рыба",
        "Молочные продукты",
        "Яйца"
      ],
      "es": [
        "Carne",
        "Pescado",
        "Lácteos",
        "Huevos"
      ],
      "tr": [
        "Et",
        "Balık",
        "Süt ürünleri",
        "Yumurta"
      ],
      "zh-Hans": [
        "肉类",
        "鱼类",
        "乳制品",
        "鸡蛋"
      ],
      "zh-Hant": [
        "肉類",
        "魚類",
        "乳製品",
        "雞蛋"
      ],
      "ja": [
        "肉",
        "魚",
        "乳製品",
        "卵"
      ],
      "ko": [
        "육류",
        "생선",
        "유제품",
        "달걀"
      ],
      "hi": [
        "मांस",
        "मछली",
        "डेयरी उत्पाद",
        "अंडे"
      ]
    }
  },
  "vitamin_d": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin D",
      "en": "Vitamin D",
      "fr": "Vitamine D",
      "it": "Vitamina D",
      "nl": "Vitamine D",
      "pl": "Witamina D",
      "pt": "Vitamina D",
      "pt-BR": "Vitamina D",
      "ru": "Витамин D",
      "es": "Vitamina D",
      "tr": "Vitamin D",
      "zh-Hans": "维生素D",
      "zh-Hant": "維生素D",
      "ja": "ビタミンD",
      "ko": "비타민 D",
      "hi": "विटामिन डी"
    },
    "sources": {
      "de": [
        "Fetter Fisch",
        "Eigelb",
        "Pilze",
        "Angereicherte Milch"
      ],
      "en": [
        "Fatty fish",
        "Egg yolk",
        "Mushrooms",
        "Fortified milk"
      ],
      "fr": [
        "Poissons gras",
        "Jaune d'œuf",
        "Champignons",
        "Lait enrichi"
      ],
      "it": [
        "Pesce grasso",
        "Tuorlo d'uovo",
        "Funghi",
        "Latte fortificato"
      ],
      "nl": [
        "Vette vis",
        "Eidooier",
        "Paddenstoelen",
        "Verrijkte melk"
      ],
      "pl": [
        "Tłuste ryby",
        "Żółtko jaja",
        "Grzyby",
        "Wzbogacone mleko"
      ],
      "pt": [
        "Peixes gordos",
        "Gema de ovo",
        "Cogumelos",
        "Leite fortificado"
      ],
      "pt-BR": [
        "Peixes gordurosos",
        "Gema de ovo",
        "Cogumelos",
        "Leite enriquecido"
      ],
      "ru": [
        "Жирная рыба",
        "Яичный желток",
        "Грибы",
        "Обогащённое молоко"
      ],
      "es": [
        "Pescado graso",
        "Yema de huevo",
        "Setas",
        "Leche enriquecida"
      ],
      "tr": [
        "Yağlı balık",
        "Yumurta sarısı",
        "Mantar",
        "Zenginleştirilmiş süt"
      ],
      "zh-Hans": [
        "富含脂肪的鱼类",
        "蛋黄",
        "蘑菇",
        "强化牛奶"
      ],
      "zh-Hant": [
        "富含脂肪的魚類",
        "蛋黃",
        "蘑菇",
        "強化牛奶"
      ],
      "ja": [
        "脂の多い魚",
        "卵黄",
        "きのこ",
        "強化牛乳"
      ],
      "ko": [
        "기름진 생선",
        "달걀노른자",
        "버섯",
        "강화우유"
      ],
      "hi": [
        "वसायुक्त मछली",
        "अंडे की जर्दी",
        "मशरूम",
        "फोर्टिफाइड दूध"
      ]
    }
  },
  "vitamin_e": {
    "category": "vitamin",
    "name": {
      "de": "Vitamin E",
      "en": "Vitamin E",
      "fr": "Vitamine E",
      "it": "Vitamina E",
      "nl": "Vitamine E",
      "pl": "Witamina E",
      "pt": "Vitamina E",
      "pt-BR": "Vitamina E",
      "ru": "Витамин E",
      "es": "Vitamina E",
      "tr": "Vitamin E",
      "zh-Hans": "维生素E",
      "zh-Hant": "維生素E",
      "ja": "ビタミンE",
      "ko": "비타민 E",
      "hi": "विटामिन ई"
    },
    "sources": {
      "de": [
        "Pflanzenöle",
        "Nüsse",
        "Samen",
        "Spinat"
      ],
      "en": [
        "Vegetable oils",
        "Nuts",
        "Seeds",
        "Spinach"
      ],
      "fr": [
        "Huiles végétales",
        "Fruits à coque",
        "Graines",
        "Épinards"
      ],
      "it": [
        "Oli vegetali",
        "Frutta secca",
        "Semi",
        "Spinaci"
      ],
      "nl": [
        "Plantaardige oliën",
        "Noten",
        "Zaden",
        "Spinazie"
      ],
      "pl": [
        "Oleje roślinne",
        "Orzechy",
        "Nasiona",
        "Szpinak"
      ],
      "pt": [
        "Óleos vegetais",
        "Frutos secos",
        "Sementes",
        "Espinafre"
      ],
      "pt-BR": [
        "Óleos vegetais",
        "Castanhas e nozes",
        "Sementes",
        "Espinafre"
      ],
      "ru": [
        "Растительные масла",
        "Орехи",
        "Семена",
        "Шпинат"
      ],
      "es": [
        "Aceites vegetales",
        "Frutos secos",
        "Semillas",
        "Espinacas"
      ],
      "tr": [
        "Bitkisel yağlar",
        "Kuruyemişler",
        "Tohumlar",
        "Ispanak"
      ],
      "zh-Hans": [
        "植物油",
        "坚果",
        "种子",
        "菠菜"
      ],
      "zh-Hant": [
        "植物油",
        "堅果",
        "種子",
        "菠菜"
      ],
      "ja": [
        "植物油",
        "ナッツ",
        "種子",
        "ほうれん草"
      ],
      "ko": [
        "식물성 기름",
        "견과류",
        "씨앗",
        "시금치"
      ],
      "hi": [
        "वनस्पति तेल",
        "मेवे (नट्स)",
        "बीज",
        "पालक"
      ]
    }
  },
  "potassium": {
    "category": "mineral",
    "name": {
      "de": "Kalium",
      "en": "Potassium",
      "fr": "Potassium",
      "it": "Potassio",
      "nl": "Kalium",
      "pl": "Potas",
      "pt": "Potássio",
      "pt-BR": "Potássio",
      "ru": "Калий",
      "es": "Potasio",
      "tr": "Potasyum",
      "zh-Hans": "钾",
      "zh-Hant": "鉀",
      "ja": "カリウム",
      "ko": "칼륨",
      "hi": "पोटैशियम"
    },
    "sources": {
      "de": [
        "Bananen",
        "Kartoffeln",
        "Spinat",
        "Hülsenfrüchte"
      ],
      "en": [
        "Bananas",
        "Potatoes",
        "Spinach",
        "Legumes"
      ],
      "fr": [
        "Bananes",
        "Pommes de terre",
        "Épinards",
        "Légumineuses"
      ],
      "it": [
        "Banane",
        "Patate",
        "Spinaci",
        "Legumi"
      ],
      "nl": [
        "Bananen",
        "Aardappelen",
        "Spinazie",
        "Peulvruchten"
      ],
      "pl": [
        "Banany",
        "Ziemniaki",
        "Szpinak",
        "Rośliny strączkowe"
      ],
      "pt": [
        "Bananas",
        "Batatas",
        "Espinafre",
        "Leguminosas"
      ],
      "pt-BR": [
        "Bananas",
        "Batatas",
        "Espinafre",
        "Leguminosas"
      ],
      "ru": [
        "Бананы",
        "Картофель",
        "Шпинат",
        "Бобовые"
      ],
      "es": [
        "Plátanos",
        "Patatas",
        "Espinacas",
        "Legumbres"
      ],
      "tr": [
        "Muz",
        "Patates",
        "Ispanak",
        "Baklagiller"
      ],
      "zh-Hans": [
        "香蕉",
        "土豆",
        "菠菜",
        "豆类"
      ],
      "zh-Hant": [
        "香蕉",
        "馬鈴薯",
        "菠菜",
        "豆類"
      ],
      "ja": [
        "バナナ",
        "じゃがいも",
        "ほうれん草",
        "豆類"
      ],
      "ko": [
        "바나나",
        "감자",
        "시금치",
        "콩류"
      ],
      "hi": [
        "केला",
        "आलू",
        "पालक",
        "दालें (फलियां)"
      ]
    }
  },
  "magnesium": {
    "category": "mineral",
    "name": {
      "de": "Magnesium",
      "en": "Magnesium",
      "fr": "Magnésium",
      "it": "Magnesio",
      "nl": "Magnesium",
      "pl": "Magnez",
      "pt": "Magnésio",
      "pt-BR": "Magnésio",
      "ru": "Магний",
      "es": "Magnesio",
      "tr": "Magnezyum",
      "zh-Hans": "镁",
      "zh-Hant": "鎂",
      "ja": "マグネシウム",
      "ko": "마그네슘",
      "hi": "मैग्नीशियम"
    },
    "sources": {
      "de": [
        "Nüsse",
        "Vollkornprodukte",
        "Dunkle Schokolade",
        "Grünes Blattgemüse"
      ],
      "en": [
        "Nuts",
        "Whole grains",
        "Dark chocolate",
        "Leafy greens"
      ],
      "fr": [
        "Fruits à coque",
        "Céréales complètes",
        "Chocolat noir",
        "Légumes à feuilles vertes"
      ],
      "it": [
        "Frutta secca",
        "Cereali integrali",
        "Cioccolato fondente",
        "Verdure a foglia verde"
      ],
      "nl": [
        "Noten",
        "Volkoren producten",
        "Pure chocolade",
        "Bladgroenten"
      ],
      "pl": [
        "Orzechy",
        "Produkty pełnoziarniste",
        "Gorzka czekolada",
        "Warzywa liściaste"
      ],
      "pt": [
        "Frutos secos",
        "Cereais integrais",
        "Chocolate preto",
        "Vegetais de folhas verdes"
      ],
      "pt-BR": [
        "Castanhas e nozes",
        "Grãos integrais",
        "Chocolate amargo",
        "Folhas verdes"
      ],
      "ru": [
        "Орехи",
        "Цельнозерновые продукты",
        "Тёмный шоколад",
        "Листовая зелень"
      ],
      "es": [
        "Frutos secos",
        "Cereales integrales",
        "Chocolate negro",
        "Verduras de hoja verde"
      ],
      "tr": [
        "Kuruyemişler",
        "Tam tahıllar",
        "Bitter çikolata",
        "Yeşil yapraklı sebzeler"
      ],
      "zh-Hans": [
        "坚果",
        "全谷物",
        "黑巧克力",
        "绿叶蔬菜"
      ],
      "zh-Hant": [
        "堅果",
        "全穀類",
        "黑巧克力",
        "綠葉蔬菜"
      ],
      "ja": [
        "ナッツ",
        "全粒穀物",
        "ダークチョコレート",
        "葉物野菜"
      ],
      "ko": [
        "견과류",
        "통곡물",
        "다크초콜릿",
        "잎채소"
      ],
      "hi": [
        "मेवे (नट्स)",
        "साबुत अनाज",
        "डार्क चॉकलेट",
        "हरी पत्तेदार सब्जियाँ"
      ]
    }
  },
  "calcium": {
    "category": "mineral",
    "name": {
      "de": "Kalzium",
      "en": "Calcium",
      "fr": "Calcium",
      "it": "Calcio",
      "nl": "Calcium",
      "pl": "Wapń",
      "pt": "Cálcio",
      "pt-BR": "Cálcio",
      "ru": "Кальций",
      "es": "Calcio",
      "tr": "Kalsiyum",
      "zh-Hans": "钙",
      "zh-Hant": "鈣",
      "ja": "カルシウム",
      "ko": "칼슘",
      "hi": "कैल्शियम"
    },
    "sources": {
      "de": [
        "Milchprodukte",
        "Grünes Blattgemüse",
        "Mandeln",
        "Sesam"
      ],
      "en": [
        "Dairy products",
        "Leafy greens",
        "Almonds",
        "Sesame seeds"
      ],
      "fr": [
        "Produits laitiers",
        "Légumes à feuilles vertes",
        "Amandes",
        "Graines de sésame"
      ],
      "it": [
        "Latticini",
        "Verdure a foglia verde",
        "Mandorle",
        "Semi di sesamo"
      ],
      "nl": [
        "Zuivelproducten",
        "Bladgroenten",
        "Amandelen",
        "Sesamzaad"
      ],
      "pl": [
        "Produkty mleczne",
        "Warzywa liściaste",
        "Migdały",
        "Nasiona sezamu"
      ],
      "pt": [
        "Laticínios",
        "Vegetais de folhas verdes",
        "Amêndoas",
        "Sementes de sésamo"
      ],
      "pt-BR": [
        "Laticínios",
        "Folhas verdes",
        "Amêndoas",
        "Gergelim"
      ],
      "ru": [
        "Молочные продукты",
        "Листовая зелень",
        "Миндаль",
        "Кунжут"
      ],
      "es": [
        "Lácteos",
        "Verduras de hoja verde",
        "Almendras",
        "Semillas de sésamo"
      ],
      "tr": [
        "Süt ürünleri",
        "Yeşil yapraklı sebzeler",
        "Badem",
        "Susam"
      ],
      "zh-Hans": [
        "乳制品",
        "绿叶蔬菜",
        "杏仁",
        "芝麻"
      ],
      "zh-Hant": [
        "乳製品",
        "綠葉蔬菜",
        "杏仁",
        "芝麻"
      ],
      "ja": [
        "乳製品",
        "葉物野菜",
        "アーモンド",
        "ごま"
      ],
      "ko": [
        "유제품",
        "잎채소",
        "아몬드",
        "참깨"
      ],
      "hi": [
        "डेयरी उत्पाद",
        "हरी पत्तेदार सब्जियाँ",
        "बादाम",
        "तिल"
      ]
    }
  },
  "chloride": {
    "category": "mineral",
    "name": {
      "de": "Chlorid",
      "en": "Chloride",
      "fr": "Chlorure",
      "it": "Cloruro",
      "nl": "Chloride",
      "pl": "Chlorek",
      "pt": "Cloreto",
      "pt-BR": "Cloreto",
      "ru": "Хлорид",
      "es": "Cloruro",
      "tr": "Klorür",
      "zh-Hans": "氯化物",
      "zh-Hant": "氯化物",
      "ja": "塩化物",
      "ko": "염화물",
      "hi": "क्लोराइड"
    },
    "sources": {
      "de": [
        "Speisesalz",
        "Oliven",
        "Tomaten",
        "Sellerie"
      ],
      "en": [
        "Table salt",
        "Olives",
        "Tomatoes",
        "Celery"
      ],
      "fr": [
        "Sel de table",
        "Olives",
        "Tomates",
        "Céleri"
      ],
      "it": [
        "Sale da cucina",
        "Olive",
        "Pomodori",
        "Sedano"
      ],
      "nl": [
        "Tafelzout",
        "Olijven",
        "Tomaten",
        "Selderij"
      ],
      "pl": [
        "Sól kuchenna",
        "Oliwki",
        "Pomidory",
        "Seler"
      ],
      "pt": [
        "Sal de cozinha",
        "Azeitonas",
        "Tomates",
        "Aipo"
      ],
      "pt-BR": [
        "Sal de cozinha",
        "Azeitonas",
        "Tomates",
        "Aipo"
      ],
      "ru": [
        "Поваренная соль",
        "Оливки",
        "Помидоры",
        "Сельдерей"
      ],
      "es": [
        "Sal de mesa",
        "Aceitunas",
        "Tomates",
        "Apio"
      ],
      "tr": [
        "Sofra tuzu",
        "Zeytin",
        "Domates",
        "Kereviz"
      ],
      "zh-Hans": [
        "食盐",
        "橄榄",
        "西红柿",
        "芹菜"
      ],
      "zh-Hant": [
        "食鹽",
        "橄欖",
        "番茄",
        "芹菜"
      ],
      "ja": [
        "食塩",
        "オリーブ",
        "トマト",
        "セロリ"
      ],
      "ko": [
        "식탁용 소금",
        "올리브",
        "토마토",
        "셀러리"
      ],
      "hi": [
        "नमक",
        "जैतून",
        "टमाटर",
        "अजवाइन"
      ]
    }
  },
  "copper": {
    "category": "mineral",
    "name": {
      "de": "Kupfer",
      "en": "Copper",
      "fr": "Cuivre",
      "it": "Rame",
      "nl": "Koper",
      "pl": "Miedź",
      "pt": "Cobre",
      "pt-BR": "Cobre",
      "ru": "Медь",
      "es": "Cobre",
      "tr": "Bakır",
      "zh-Hans": "铜",
      "zh-Hant": "銅",
      "ja": "銅",
      "ko": "구리",
      "hi": "तांबा"
    },
    "sources": {
      "de": [
        "Nüsse",
        "Meeresfrüchte",
        "Vollkornprodukte",
        "Kakao"
      ],
      "en": [
        "Nuts",
        "Seafood",
        "Whole grains",
        "Cocoa"
      ],
      "fr": [
        "Fruits à coque",
        "Fruits de mer",
        "Céréales complètes",
        "Cacao"
      ],
      "it": [
        "Frutta secca",
        "Frutti di mare",
        "Cereali integrali",
        "Cacao"
      ],
      "nl": [
        "Noten",
        "Zeevruchten",
        "Volkoren producten",
        "Cacao"
      ],
      "pl": [
        "Orzechy",
        "Owoce morza",
        "Produkty pełnoziarniste",
        "Kakao"
      ],
      "pt": [
        "Frutos secos",
        "Marisco",
        "Cereais integrais",
        "Cacau"
      ],
      "pt-BR": [
        "Castanhas e nozes",
        "Frutos do mar",
        "Grãos integrais",
        "Cacau"
      ],
      "ru": [
        "Орехи",
        "Морепродукты",
        "Цельнозерновые продукты",
        "Какао"
      ],
      "es": [
        "Frutos secos",
        "Mariscos",
        "Cereales integrales",
        "Cacao"
      ],
      "tr": [
        "Kuruyemişler",
        "Deniz ürünleri",
        "Tam tahıllar",
        "Kakao"
      ],
      "zh-Hans": [
        "坚果",
        "海鲜",
        "全谷物",
        "可可"
      ],
      "zh-Hant": [
        "堅果",
        "海鮮",
        "全穀類",
        "可可"
      ],
      "ja": [
        "ナッツ",
        "シーフード",
        "全粒穀物",
        "カカオ"
      ],
      "ko": [
        "견과류",
        "해산물",
        "통곡물",
        "코코아"
      ],
      "hi": [
        "मेवे (नट्स)",
        "समुद्री भोजन",
        "साबुत अनाज",
        "कोको"
      ]
    }
  },
  "iodine": {
    "category": "mineral",
    "name": {
      "de": "Jod",
      "en": "Iodine",
      "fr": "Iode",
      "it": "Iodio",
      "nl": "Jodium",
      "pl": "Jod",
      "pt": "Iodo",
      "pt-BR": "Iodo",
      "ru": "Йод",
      "es": "Yodo",
      "tr": "İyot",
      "zh-Hans": "碘",
      "zh-Hant": "碘",
      "ja": "ヨウ素",
      "ko": "요오드",
      "hi": "आयोडीन"
    },
    "sources": {
      "de": [
        "Meeresalgen",
        "Fisch",
        "Jodsalz",
        "Milchprodukte"
      ],
      "en": [
        "Seaweed",
        "Fish",
        "Iodized salt",
        "Dairy products"
      ],
      "fr": [
        "Algues marines",
        "Poisson",
        "Sel iodé",
        "Produits laitiers"
      ],
      "it": [
        "Alghe marine",
        "Pesce",
        "Sale iodato",
        "Latticini"
      ],
      "nl": [
        "Zeewier",
        "Vis",
        "Gejodeerd zout",
        "Zuivelproducten"
      ],
      "pl": [
        "Wodorosty morskie",
        "Ryby",
        "Sól jodowana",
        "Produkty mleczne"
      ],
      "pt": [
        "Algas marinhas",
        "Peixe",
        "Sal iodado",
        "Laticínios"
      ],
      "pt-BR": [
        "Algas marinhas",
        "Peixe",
        "Sal iodado",
        "Laticínios"
      ],
      "ru": [
        "Морские водоросли",
        "Рыба",
        "Йодированная соль",
        "Молочные продукты"
      ],
      "es": [
        "Algas marinas",
        "Pescado",
        "Sal yodada",
        "Lácteos"
      ],
      "tr": [
        "Deniz yosunu",
        "Balık",
        "İyotlu tuz",
        "Süt ürünleri"
      ],
      "zh-Hans": [
        "海藻",
        "鱼类",
        "碘盐",
        "乳制品"
      ],
      "zh-Hant": [
        "海藻",
        "魚類",
        "碘鹽",
        "乳製品"
      ],
      "ja": [
        "海藻",
        "魚",
        "ヨウ素添加塩",
        "乳製品"
      ],
      "ko": [
        "해조류",
        "생선",
        "요오드화 소금",
        "유제품"
      ],
      "hi": [
        "समुद्री शैवाल",
        "मछली",
        "आयोडीन युक्त नमक",
        "डेयरी उत्पाद"
      ]
    }
  },
  "iron": {
    "category": "mineral",
    "name": {
      "de": "Eisen",
      "en": "Iron",
      "fr": "Fer",
      "it": "Ferro",
      "nl": "IJzer",
      "pl": "Żelazo",
      "pt": "Ferro",
      "pt-BR": "Ferro",
      "ru": "Железо",
      "es": "Hierro",
      "tr": "Demir",
      "zh-Hans": "铁",
      "zh-Hant": "鐵",
      "ja": "鉄",
      "ko": "철분",
      "hi": "आयरन"
    },
    "sources": {
      "de": [
        "Rotes Fleisch",
        "Hülsenfrüchte",
        "Spinat",
        "Leber"
      ],
      "en": [
        "Red meat",
        "Legumes",
        "Spinach",
        "Liver"
      ],
      "fr": [
        "Viande rouge",
        "Légumineuses",
        "Épinards",
        "Foie"
      ],
      "it": [
        "Carne rossa",
        "Legumi",
        "Spinaci",
        "Fegato"
      ],
      "nl": [
        "Rood vlees",
        "Peulvruchten",
        "Spinazie",
        "Lever"
      ],
      "pl": [
        "Czerwone mięso",
        "Rośliny strączkowe",
        "Szpinak",
        "Wątróbka"
      ],
      "pt": [
        "Carne vermelha",
        "Leguminosas",
        "Espinafre",
        "Fígado"
      ],
      "pt-BR": [
        "Carne vermelha",
        "Leguminosas",
        "Espinafre",
        "Fígado"
      ],
      "ru": [
        "Красное мясо",
        "Бобовые",
        "Шпинат",
        "Печень"
      ],
      "es": [
        "Carne roja",
        "Legumbres",
        "Espinacas",
        "Hígado"
      ],
      "tr": [
        "Kırmızı et",
        "Baklagiller",
        "Ispanak",
        "Karaciğer"
      ],
      "zh-Hans": [
        "红肉",
        "豆类",
        "菠菜",
        "肝脏"
      ],
      "zh-Hant": [
        "紅肉",
        "豆類",
        "菠菜",
        "肝臟"
      ],
      "ja": [
        "赤身肉",
        "豆類",
        "ほうれん草",
        "レバー"
      ],
      "ko": [
        "붉은 고기",
        "콩류",
        "시금치",
        "간"
      ],
      "hi": [
        "लाल मांस",
        "दालें (फलियां)",
        "पालक",
        "कलेजी (लिवर)"
      ]
    }
  },
  "manganese": {
    "category": "mineral",
    "name": {
      "de": "Mangan",
      "en": "Manganese",
      "fr": "Manganèse",
      "it": "Manganese",
      "nl": "Mangaan",
      "pl": "Mangan",
      "pt": "Manganês",
      "pt-BR": "Manganês",
      "ru": "Марганец",
      "es": "Manganeso",
      "tr": "Manganez",
      "zh-Hans": "锰",
      "zh-Hant": "錳",
      "ja": "マンガン",
      "ko": "망간",
      "hi": "मैंगनीज़"
    },
    "sources": {
      "de": [
        "Vollkornprodukte",
        "Nüsse",
        "Hülsenfrüchte",
        "Ananas"
      ],
      "en": [
        "Whole grains",
        "Nuts",
        "Legumes",
        "Pineapple"
      ],
      "fr": [
        "Céréales complètes",
        "Fruits à coque",
        "Légumineuses",
        "Ananas"
      ],
      "it": [
        "Cereali integrali",
        "Frutta secca",
        "Legumi",
        "Ananas"
      ],
      "nl": [
        "Volkoren producten",
        "Noten",
        "Peulvruchten",
        "Ananas"
      ],
      "pl": [
        "Produkty pełnoziarniste",
        "Orzechy",
        "Rośliny strączkowe",
        "Ananas"
      ],
      "pt": [
        "Cereais integrais",
        "Frutos secos",
        "Leguminosas",
        "Ananás"
      ],
      "pt-BR": [
        "Grãos integrais",
        "Castanhas e nozes",
        "Leguminosas",
        "Abacaxi"
      ],
      "ru": [
        "Цельнозерновые продукты",
        "Орехи",
        "Бобовые",
        "Ананас"
      ],
      "es": [
        "Cereales integrales",
        "Frutos secos",
        "Legumbres",
        "Piña"
      ],
      "tr": [
        "Tam tahıllar",
        "Kuruyemişler",
        "Baklagiller",
        "Ananas"
      ],
      "zh-Hans": [
        "全谷物",
        "坚果",
        "豆类",
        "菠萝"
      ],
      "zh-Hant": [
        "全穀類",
        "堅果",
        "豆類",
        "鳳梨"
      ],
      "ja": [
        "全粒穀物",
        "ナッツ",
        "豆類",
        "パイナップル"
      ],
      "ko": [
        "통곡물",
        "견과류",
        "콩류",
        "파인애플"
      ],
      "hi": [
        "साबुत अनाज",
        "मेवे (नट्स)",
        "दालें (फलियां)",
        "अनानास"
      ]
    }
  },
  "molybdenum": {
    "category": "mineral",
    "name": {
      "de": "Molybdän",
      "en": "Molybdenum",
      "fr": "Molybdène",
      "it": "Molibdeno",
      "nl": "Molybdeen",
      "pl": "Molibden",
      "pt": "Molibdénio",
      "pt-BR": "Molibdênio",
      "ru": "Молибден",
      "es": "Molibdeno",
      "tr": "Molibden",
      "zh-Hans": "钼",
      "zh-Hant": "鉬",
      "ja": "モリブデン",
      "ko": "몰리브덴",
      "hi": "मोलिब्डेनम"
    },
    "sources": {
      "de": [
        "Hülsenfrüchte",
        "Vollkornprodukte",
        "Nüsse",
        "Innereien"
      ],
      "en": [
        "Legumes",
        "Whole grains",
        "Nuts",
        "Organ meats"
      ],
      "fr": [
        "Légumineuses",
        "Céréales complètes",
        "Fruits à coque",
        "Abats"
      ],
      "it": [
        "Legumi",
        "Cereali integrali",
        "Frutta secca",
        "Frattaglie"
      ],
      "nl": [
        "Peulvruchten",
        "Volkoren producten",
        "Noten",
        "Orgaanvlees"
      ],
      "pl": [
        "Rośliny strączkowe",
        "Produkty pełnoziarniste",
        "Orzechy",
        "Podroby"
      ],
      "pt": [
        "Leguminosas",
        "Cereais integrais",
        "Frutos secos",
        "Vísceras"
      ],
      "pt-BR": [
        "Leguminosas",
        "Grãos integrais",
        "Castanhas e nozes",
        "Miúdos"
      ],
      "ru": [
        "Бобовые",
        "Цельнозерновые продукты",
        "Орехи",
        "Субпродукты"
      ],
      "es": [
        "Legumbres",
        "Cereales integrales",
        "Frutos secos",
        "Vísceras"
      ],
      "tr": [
        "Baklagiller",
        "Tam tahıllar",
        "Kuruyemişler",
        "Sakatat"
      ],
      "zh-Hans": [
        "豆类",
        "全谷物",
        "坚果",
        "动物内脏"
      ],
      "zh-Hant": [
        "豆類",
        "全穀類",
        "堅果",
        "動物內臟"
      ],
      "ja": [
        "豆類",
        "全粒穀物",
        "ナッツ",
        "内臓肉"
      ],
      "ko": [
        "콩류",
        "통곡물",
        "견과류",
        "내장육"
      ],
      "hi": [
        "दालें (फलियां)",
        "साबुत अनाज",
        "मेवे (नट्स)",
        "ऑर्गन मीट"
      ]
    }
  },
  "phosphorus": {
    "category": "mineral",
    "name": {
      "de": "Phosphor",
      "en": "Phosphorus",
      "fr": "Phosphore",
      "it": "Fosforo",
      "nl": "Fosfor",
      "pl": "Fosfor",
      "pt": "Fósforo",
      "pt-BR": "Fósforo",
      "ru": "Фосфор",
      "es": "Fósforo",
      "tr": "Fosfor",
      "zh-Hans": "磷",
      "zh-Hant": "磷",
      "ja": "リン",
      "ko": "인",
      "hi": "फॉस्फोरस"
    },
    "sources": {
      "de": [
        "Milchprodukte",
        "Fleisch",
        "Fisch",
        "Nüsse"
      ],
      "en": [
        "Dairy products",
        "Meat",
        "Fish",
        "Nuts"
      ],
      "fr": [
        "Produits laitiers",
        "Viande",
        "Poisson",
        "Fruits à coque"
      ],
      "it": [
        "Latticini",
        "Carne",
        "Pesce",
        "Frutta secca"
      ],
      "nl": [
        "Zuivelproducten",
        "Vlees",
        "Vis",
        "Noten"
      ],
      "pl": [
        "Produkty mleczne",
        "Mięso",
        "Ryby",
        "Orzechy"
      ],
      "pt": [
        "Laticínios",
        "Carne",
        "Peixe",
        "Frutos secos"
      ],
      "pt-BR": [
        "Laticínios",
        "Carne",
        "Peixe",
        "Castanhas e nozes"
      ],
      "ru": [
        "Молочные продукты",
        "Мясо",
        "Рыба",
        "Орехи"
      ],
      "es": [
        "Lácteos",
        "Carne",
        "Pescado",
        "Frutos secos"
      ],
      "tr": [
        "Süt ürünleri",
        "Et",
        "Balık",
        "Kuruyemişler"
      ],
      "zh-Hans": [
        "乳制品",
        "肉类",
        "鱼类",
        "坚果"
      ],
      "zh-Hant": [
        "乳製品",
        "肉類",
        "魚類",
        "堅果"
      ],
      "ja": [
        "乳製品",
        "肉",
        "魚",
        "ナッツ"
      ],
      "ko": [
        "유제품",
        "육류",
        "생선",
        "견과류"
      ],
      "hi": [
        "डेयरी उत्पाद",
        "मांस",
        "मछली",
        "मेवे (नट्स)"
      ]
    }
  },
  "selenium": {
    "category": "mineral",
    "name": {
      "de": "Selen",
      "en": "Selenium",
      "fr": "Sélénium",
      "it": "Selenio",
      "nl": "Selenium",
      "pl": "Selen",
      "pt": "Selénio",
      "pt-BR": "Selênio",
      "ru": "Селен",
      "es": "Selenio",
      "tr": "Selenyum",
      "zh-Hans": "硒",
      "zh-Hant": "硒",
      "ja": "セレン",
      "ko": "셀레늄",
      "hi": "सेलेनियम"
    },
    "sources": {
      "de": [
        "Paranüsse",
        "Fisch",
        "Eier",
        "Vollkornprodukte"
      ],
      "en": [
        "Brazil nuts",
        "Fish",
        "Eggs",
        "Whole grains"
      ],
      "fr": [
        "Noix du Brésil",
        "Poisson",
        "Œufs",
        "Céréales complètes"
      ],
      "it": [
        "Noci del Brasile",
        "Pesce",
        "Uova",
        "Cereali integrali"
      ],
      "nl": [
        "Paranoten",
        "Vis",
        "Eieren",
        "Volkoren producten"
      ],
      "pl": [
        "Orzechy brazylijskie",
        "Ryby",
        "Jajka",
        "Produkty pełnoziarniste"
      ],
      "pt": [
        "Castanha-do-pará",
        "Peixe",
        "Ovos",
        "Cereais integrais"
      ],
      "pt-BR": [
        "Castanha-do-pará",
        "Peixe",
        "Ovos",
        "Grãos integrais"
      ],
      "ru": [
        "Бразильский орех",
        "Рыба",
        "Яйца",
        "Цельнозерновые продукты"
      ],
      "es": [
        "Nueces de Brasil",
        "Pescado",
        "Huevos",
        "Cereales integrales"
      ],
      "tr": [
        "Brezilya cevizi",
        "Balık",
        "Yumurta",
        "Tam tahıllar"
      ],
      "zh-Hans": [
        "巴西坚果",
        "鱼类",
        "鸡蛋",
        "全谷物"
      ],
      "zh-Hant": [
        "巴西堅果",
        "魚類",
        "雞蛋",
        "全穀類"
      ],
      "ja": [
        "ブラジルナッツ",
        "魚",
        "卵",
        "全粒穀物"
      ],
      "ko": [
        "브라질너트",
        "생선",
        "달걀",
        "통곡물"
      ],
      "hi": [
        "ब्राज़ील नट",
        "मछली",
        "अंडे",
        "साबुत अनाज"
      ]
    }
  },
  "sodium": {
    "category": "mineral",
    "name": {
      "de": "Natrium",
      "en": "Sodium",
      "fr": "Sodium",
      "it": "Sodio",
      "nl": "Natrium",
      "pl": "Sód",
      "pt": "Sódio",
      "pt-BR": "Sódio",
      "ru": "Натрий",
      "es": "Sodio",
      "tr": "Sodyum",
      "zh-Hans": "钠",
      "zh-Hant": "鈉",
      "ja": "ナトリウム",
      "ko": "나트륨",
      "hi": "सोडियम"
    },
    "sources": {
      "de": [
        "Speisesalz",
        "Verarbeitete Lebensmittel",
        "Käse",
        "Brot"
      ],
      "en": [
        "Table salt",
        "Processed foods",
        "Cheese",
        "Bread"
      ],
      "fr": [
        "Sel de table",
        "Aliments transformés",
        "Fromage",
        "Pain"
      ],
      "it": [
        "Sale da cucina",
        "Alimenti trasformati",
        "Formaggio",
        "Pane"
      ],
      "nl": [
        "Tafelzout",
        "Bewerkte voedingsmiddelen",
        "Kaas",
        "Brood"
      ],
      "pl": [
        "Sól kuchenna",
        "Żywność przetworzona",
        "Ser",
        "Chleb"
      ],
      "pt": [
        "Sal de cozinha",
        "Alimentos processados",
        "Queijo",
        "Pão"
      ],
      "pt-BR": [
        "Sal de cozinha",
        "Alimentos processados",
        "Queijo",
        "Pão"
      ],
      "ru": [
        "Поваренная соль",
        "Обработанные продукты",
        "Сыр",
        "Хлеб"
      ],
      "es": [
        "Sal de mesa",
        "Alimentos procesados",
        "Queso",
        "Pan"
      ],
      "tr": [
        "Sofra tuzu",
        "İşlenmiş gıdalar",
        "Peynir",
        "Ekmek"
      ],
      "zh-Hans": [
        "食盐",
        "加工食品",
        "奶酪",
        "面包"
      ],
      "zh-Hant": [
        "食鹽",
        "加工食品",
        "起司",
        "麵包"
      ],
      "ja": [
        "食塩",
        "加工食品",
        "チーズ",
        "パン"
      ],
      "ko": [
        "식탁용 소금",
        "가공식품",
        "치즈",
        "빵"
      ],
      "hi": [
        "नमक",
        "प्रसंस्कृत खाद्य पदार्थ",
        "पनीर",
        "ब्रेड"
      ]
    }
  },
  "zinc": {
    "category": "mineral",
    "name": {
      "de": "Zink",
      "en": "Zinc",
      "fr": "Zinc",
      "it": "Zinco",
      "nl": "Zink",
      "pl": "Cynk",
      "pt": "Zinco",
      "pt-BR": "Zinco",
      "ru": "Цинк",
      "es": "Zinc",
      "tr": "Çinko",
      "zh-Hans": "锌",
      "zh-Hant": "鋅",
      "ja": "亜鉛",
      "ko": "아연",
      "hi": "ज़िंक"
    },
    "sources": {
      "de": [
        "Rotes Fleisch",
        "Austern",
        "Kürbiskerne",
        "Hülsenfrüchte"
      ],
      "en": [
        "Red meat",
        "Oysters",
        "Pumpkin seeds",
        "Legumes"
      ],
      "fr": [
        "Viande rouge",
        "Huîtres",
        "Graines de courge",
        "Légumineuses"
      ],
      "it": [
        "Carne rossa",
        "Ostriche",
        "Semi di zucca",
        "Legumi"
      ],
      "nl": [
        "Rood vlees",
        "Oesters",
        "Pompoenpitten",
        "Peulvruchten"
      ],
      "pl": [
        "Czerwone mięso",
        "Ostrygi",
        "Pestki dyni",
        "Rośliny strączkowe"
      ],
      "pt": [
        "Carne vermelha",
        "Ostras",
        "Sementes de abóbora",
        "Leguminosas"
      ],
      "pt-BR": [
        "Carne vermelha",
        "Ostras",
        "Sementes de abóbora",
        "Leguminosas"
      ],
      "ru": [
        "Красное мясо",
        "Устрицы",
        "Тыквенные семечки",
        "Бобовые"
      ],
      "es": [
        "Carne roja",
        "Ostras",
        "Semillas de calabaza",
        "Legumbres"
      ],
      "tr": [
        "Kırmızı et",
        "İstiridye",
        "Kabak çekirdeği",
        "Baklagiller"
      ],
      "zh-Hans": [
        "红肉",
        "牡蛎",
        "南瓜籽",
        "豆类"
      ],
      "zh-Hant": [
        "紅肉",
        "牡蠣",
        "南瓜籽",
        "豆類"
      ],
      "ja": [
        "赤身肉",
        "カキ",
        "かぼちゃの種",
        "豆類"
      ],
      "ko": [
        "붉은 고기",
        "굴",
        "호박씨",
        "콩류"
      ],
      "hi": [
        "लाल मांस",
        "सीप",
        "कद्दू के बीज",
        "दालें (फलियां)"
      ]
    }
  },
  "chromium": {
    "category": "mineral",
    "name": {
      "de": "Chrom",
      "en": "Chromium",
      "fr": "Chrome",
      "it": "Cromo",
      "nl": "Chroom",
      "pl": "Chrom",
      "pt": "Crómio",
      "pt-BR": "Cromo",
      "ru": "Хром",
      "es": "Cromo",
      "tr": "Krom",
      "zh-Hans": "铬",
      "zh-Hant": "鉻",
      "ja": "クロム",
      "ko": "크롬",
      "hi": "क्रोमियम"
    },
    "sources": {
      "de": [
        "Vollkornprodukte",
        "Brokkoli",
        "Trauben",
        "Nüsse"
      ],
      "en": [
        "Whole grains",
        "Broccoli",
        "Grapes",
        "Nuts"
      ],
      "fr": [
        "Céréales complètes",
        "Brocoli",
        "Raisins",
        "Fruits à coque"
      ],
      "it": [
        "Cereali integrali",
        "Broccoli",
        "Uva",
        "Frutta secca"
      ],
      "nl": [
        "Volkoren producten",
        "Broccoli",
        "Druiven",
        "Noten"
      ],
      "pl": [
        "Produkty pełnoziarniste",
        "Brokuły",
        "Winogrona",
        "Orzechy"
      ],
      "pt": [
        "Cereais integrais",
        "Brócolos",
        "Uvas",
        "Frutos secos"
      ],
      "pt-BR": [
        "Grãos integrais",
        "Brócolis",
        "Uvas",
        "Castanhas e nozes"
      ],
      "ru": [
        "Цельнозерновые продукты",
        "Брокколи",
        "Виноград",
        "Орехи"
      ],
      "es": [
        "Cereales integrales",
        "Brócoli",
        "Uvas",
        "Frutos secos"
      ],
      "tr": [
        "Tam tahıllar",
        "Brokoli",
        "Üzüm",
        "Kuruyemişler"
      ],
      "zh-Hans": [
        "全谷物",
        "西兰花",
        "葡萄",
        "坚果"
      ],
      "zh-Hant": [
        "全穀類",
        "綠花椰菜",
        "葡萄",
        "堅果"
      ],
      "ja": [
        "全粒穀物",
        "ブロッコリー",
        "ぶどう",
        "ナッツ"
      ],
      "ko": [
        "통곡물",
        "브로콜리",
        "포도",
        "견과류"
      ],
      "hi": [
        "साबुत अनाज",
        "ब्रोकली",
        "अंगूर",
        "मेवे (नट्स)"
      ]
    }
  },
  "fiber": {
    "category": "fiber",
    "name": {
      "de": "Ballaststoffe",
      "en": "Dietary fiber",
      "fr": "Fibres alimentaires",
      "it": "Fibra alimentare",
      "nl": "Voedingsvezels",
      "pl": "Błonnik pokarmowy",
      "pt": "Fibra alimentar",
      "pt-BR": "Fibra alimentar",
      "ru": "Пищевые волокна",
      "es": "Fibra dietética",
      "tr": "Diyet lifi",
      "zh-Hans": "膳食纤维",
      "zh-Hant": "膳食纖維",
      "ja": "食物繊維",
      "ko": "식이섬유",
      "hi": "आहार फाइबर"
    },
    "sources": {
      "de": [
        "Vollkornprodukte",
        "Hülsenfrüchte",
        "Gemüse",
        "Obst"
      ],
      "en": [
        "Whole grains",
        "Legumes",
        "Vegetables",
        "Fruit"
      ],
      "fr": [
        "Céréales complètes",
        "Légumineuses",
        "Légumes",
        "Fruits"
      ],
      "it": [
        "Cereali integrali",
        "Legumi",
        "Verdure",
        "Frutta"
      ],
      "nl": [
        "Volkoren producten",
        "Peulvruchten",
        "Groenten",
        "Fruit"
      ],
      "pl": [
        "Produkty pełnoziarniste",
        "Rośliny strączkowe",
        "Warzywa",
        "Owoce"
      ],
      "pt": [
        "Cereais integrais",
        "Leguminosas",
        "Vegetais",
        "Fruta"
      ],
      "pt-BR": [
        "Grãos integrais",
        "Leguminosas",
        "Vegetais",
        "Frutas"
      ],
      "ru": [
        "Цельнозерновые продукты",
        "Бобовые",
        "Овощи",
        "Фрукты"
      ],
      "es": [
        "Cereales integrales",
        "Legumbres",
        "Verduras",
        "Fruta"
      ],
      "tr": [
        "Tam tahıllar",
        "Baklagiller",
        "Sebzeler",
        "Meyve"
      ],
      "zh-Hans": [
        "全谷物",
        "豆类",
        "蔬菜",
        "水果"
      ],
      "zh-Hant": [
        "全穀類",
        "豆類",
        "蔬菜",
        "水果"
      ],
      "ja": [
        "全粒穀物",
        "豆類",
        "野菜",
        "果物"
      ],
      "ko": [
        "통곡물",
        "콩류",
        "채소",
        "과일"
      ],
      "hi": [
        "साबुत अनाज",
        "दालें (फलियां)",
        "सब्जियाँ",
        "फल"
      ]
    }
  }
}
"""

ID_MAP = {
    "folic_acid": "folate",
    "thiamin": "vitamin_b1",
    "riboflavin": "vitamin_b2",
    "niacin": "vitamin_b3",
    "biotin": "vitamin_b7"
}

data = json.loads(json_data)
strings_file = 'Garten_Simulation/Localizable.xcstrings'
with open(strings_file, 'r') as f:
    xcstrings = json.load(f)

if 'strings' not in xcstrings:
    xcstrings['strings'] = {}

languages = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

for nut_id, nut_info in data.items():
    actual_id = ID_MAP.get(nut_id, nut_id)
    
    name_key = f"nutrient.{actual_id}"
    sources_key = f"nutrient.sources.{actual_id}"
    
    if name_key not in xcstrings['strings']:
        xcstrings['strings'][name_key] = {"extractionState": "manual", "localizations": {}}
    
    if sources_key not in xcstrings['strings']:
        xcstrings['strings'][sources_key] = {"extractionState": "manual", "localizations": {}}
        
    for lang in languages:
        # names
        name_val = nut_info['name'].get(lang, nut_info['name']['en'])
        
        # Add to localizations if missing
        if 'localizations' not in xcstrings['strings'][name_key]:
            xcstrings['strings'][name_key]['localizations'] = {}
        
        xcstrings['strings'][name_key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": name_val
            }
        }
        
        # sources
        sources_list = nut_info['sources'].get(lang, nut_info['sources']['en'])
        sources_val = ", ".join(sources_list)
        
        if 'localizations' not in xcstrings['strings'][sources_key]:
            xcstrings['strings'][sources_key]['localizations'] = {}
            
        xcstrings['strings'][sources_key]['localizations'][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": sources_val
            }
        }

with open(strings_file, 'w') as f:
    json.dump(xcstrings, f, indent=2, ensure_ascii=False)
