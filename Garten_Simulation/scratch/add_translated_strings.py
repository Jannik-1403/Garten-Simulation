import json
import time

path = '/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localizable.xcstrings'

with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

translations = {
    "tour_plant_todos_title": {
        "de": "To-Dos", "en": "To-Dos", "es": "Tareas", "fr": "Tâches", 
        "it": "Cose da fare", "nl": "Taken", "pl": "Zadania", "pt": "Tarefas", 
        "ru": "Задачи", "tr": "Görevler", "hi": "कार्य", "ja": "タスク", 
        "ko": "할 일", "zh-Hans": "待办事项", "zh-Hant": "待辦事項"
    },
    "tour_plant_todos_desc": {
        "de": "Füge kleine Aufgaben für deine Gewohnheit hinzu.",
        "en": "Add small tasks for your habit.",
        "es": "Añade pequeñas tareas para tu hábito.",
        "fr": "Ajoutez de petites tâches pour votre habitude.",
        "it": "Aggiungi piccoli compiti per la tua abitudine.",
        "nl": "Voeg kleine taken toe voor je gewoonte.",
        "pl": "Dodaj małe zadania do swojego nawyku.",
        "pt": "Adicione pequenas tarefas para o seu hábito.",
        "ru": "Добавьте небольшие задачи для вашей привычки.",
        "tr": "Alışkanlığınız için küçük görevler ekleyin.",
        "hi": "अपनी आदत के लिए छोटे कार्य जोड़ें।",
        "ja": "習慣に小さなタスクを追加します。",
        "ko": "습관에 대한 작은 할 일을 추가하세요.",
        "zh-Hans": "为你的习惯添加小任务。",
        "zh-Hant": "為你的習慣添加小任務。"
    },
    "tour_plant_notes_title": {
        "de": "Notizen", "en": "Notes", "es": "Notas", "fr": "Notes",
        "it": "Note", "nl": "Notities", "pl": "Notatki", "pt": "Notas",
        "ru": "Заметки", "tr": "Notlar", "hi": "टिप्पणियाँ", "ja": "メモ",
        "ko": "노트", "zh-Hans": "笔记", "zh-Hant": "筆記"
    },
    "tour_plant_notes_desc": {
        "de": "Halte wichtige Gedanken oder Fortschritte fest.",
        "en": "Keep track of important thoughts or progress.",
        "es": "Haz un seguimiento de pensamientos importantes o progresos.",
        "fr": "Gardez une trace des pensées importantes ou de vos progrès.",
        "it": "Tieni traccia di pensieri importanti o progressi.",
        "nl": "Houd belangrijke gedachten of vooruitgang bij.",
        "pl": "Śledź ważne myśli lub postępy.",
        "pt": "Acompanhe pensamentos importantes ou progressos.",
        "ru": "Отслеживайте важные мысли или прогресс.",
        "tr": "Önemli düşünceleri veya ilerlemeyi takip edin.",
        "hi": "महत्वपूर्ण विचारों या प्रगति पर नज़र रखें।",
        "ja": "重要な考えや進捗状況を記録します。",
        "ko": "중요한 생각이나 진행 상황을 기록하세요.",
        "zh-Hans": "记录重要的想法或进展。",
        "zh-Hant": "記錄重要的想法或進展。"
    },
    "tour_plant_timer_title": {
        "de": "Daily Reminder", "en": "Daily Reminder", "es": "Recordatorio",
        "fr": "Rappel", "it": "Promemoria", "nl": "Herinnering", "pl": "Przypomnienie",
        "pt": "Lembrete", "ru": "Напоминание", "tr": "Hatırlatıcı", "hi": "अनुस्मारक",
        "ja": "リマインダー", "ko": "리마인더", "zh-Hans": "提醒", "zh-Hant": "提醒"
    },
    "tour_plant_timer_desc": {
        "de": "Stelle Erinnerungen ein, damit du diese Gewohnheit nicht vergisst.",
        "en": "Set reminders so you don't forget this habit.",
        "es": "Establece recordatorios para que no olvides este hábito.",
        "fr": "Définissez des rappels pour ne pas oublier cette habitude.",
        "it": "Imposta promemoria per non dimenticare questa abitudine.",
        "nl": "Stel herinneringen in zodat je deze gewoonte niet vergeet.",
        "pl": "Ustaw przypomnienia, aby nie zapomnieć o tym nawyku.",
        "pt": "Defina lembretes para não esquecer esse hábito.",
        "ru": "Установите напоминания, чтобы не забыть эту привычку.",
        "tr": "Bu alışkanlığı unutmamak için hatırlatıcılar ayarlayın.",
        "hi": "अनुस्मारक सेट करें ताकि आप इस आदत को न भूलें।",
        "ja": "この習慣を忘れないようにリマインダーを設定してください。",
        "ko": "이 습관을 잊지 않도록 알림을 설정하세요。",
        "zh-Hans": "设置提醒，这样你就不会忘记这个习惯了。",
        "zh-Hant": "設置提醒，這樣你就不會忘記這個習慣了。"
    },
    "tour_plant_health_title": {
        "de": "Apple Health", "en": "Apple Health", "es": "Apple Health",
        "fr": "Santé Apple", "it": "Salute Apple", "nl": "Apple Health", "pl": "Apple Health",
        "pt": "Saúde Apple", "ru": "Apple Health", "tr": "Apple Sağlık", "hi": "Apple Health",
        "ja": "Apple ヘルスケア", "ko": "Apple 건강", "zh-Hans": "Apple 健康", "zh-Hant": "Apple 健康"
    },
    "tour_plant_health_desc": {
        "de": "Verbinde Apple Health, um den Fortschritt automatisch zu tracken.",
        "en": "Connect Apple Health to track progress automatically.",
        "es": "Conecta Apple Health para seguir el progreso automáticamente.",
        "fr": "Connectez Santé Apple pour suivre les progrès automatiquement.",
        "it": "Connetti Salute Apple per monitorare automaticamente i progressi.",
        "nl": "Verbind Apple Health om de voortgang automatisch bij te houden.",
        "pl": "Połącz Apple Health, aby automatycznie śledzić postępy.",
        "pt": "Conecte a Saúde Apple para monitorar o progresso automaticamente.",
        "ru": "Подключите Apple Health для автоматического отслеживания прогресса.",
        "tr": "İlerlemeyi otomatik olarak izlemek için Apple Sağlık'ı bağlayın.",
        "hi": "प्रगति को स्वचालित रूप से ट्रैक करने के लिए Apple Health कनेक्ट करें।",
        "ja": "進捗状況を自動的に追跡するには、Appleヘルスケアを接続します。",
        "ko": "진행 상황을 자동으로 추적하려면 Apple 건강을 연결하세요.",
        "zh-Hans": "连接 Apple 健康以自动跟踪进度。",
        "zh-Hant": "連接 Apple 健康以自動跟踪進度。"
    },
    "tour_todo_prompt_desc": {
        "de": "Hier findest du alle deine Aufgaben.",
        "en": "Here you will find all your tasks.",
        "es": "Aquí encontrarás todas tus tareas.",
        "fr": "Ici, vous trouverez toutes vos tâches.",
        "it": "Qui troverai tutte le tue attività.",
        "nl": "Hier vind je al je taken.",
        "pl": "Tutaj znajdziesz wszystkie swoje zadania.",
        "pt": "Aqui você encontrará todas as suas tarefas.",
        "ru": "Здесь вы найдете все свои задачи.",
        "tr": "Burada tüm görevlerinizi bulacaksınız.",
        "hi": "यहाँ आपको अपने सभी कार्य मिलेंगे।",
        "ja": "ここにすべてのタスクがあります。",
        "ko": "여기에서 모든 할 일을 찾을 수 있습니다.",
        "zh-Hans": "在这里你会找到你所有的任务。",
        "zh-Hant": "在這裡你會找到你所有的任務。"
    },
    "tour_todo_intro_title": {
        "de": "To-Dos", "en": "To-Dos", "es": "Tareas", "fr": "Tâches",
        "it": "Cose da fare", "nl": "Taken", "pl": "Zadania", "pt": "Tarefas",
        "ru": "Задачи", "tr": "Görevler", "hi": "कार्य", "ja": "タスク",
        "ko": "할 일", "zh-Hans": "待办事项", "zh-Hant": "待辦事項"
    },
    "tour_todo_intro_desc": {
        "de": "Erstelle tägliche To-Dos und hake sie ab, um XP zu sammeln!",
        "en": "Create daily to-dos and check them off to earn XP!",
        "es": "¡Crea tareas diarias y márcalas para ganar XP!",
        "fr": "Créez des tâches quotidiennes et cochez-les pour gagner de l'XP !",
        "it": "Crea compiti giornalieri e spuntali per guadagnare XP!",
        "nl": "Maak dagelijkse taken en vink ze af om XP te verdienen!",
        "pl": "Twórz codzienne zadania i odhaczaj je, aby zdobywać XP!",
        "pt": "Crie tarefas diárias e marque-as para ganhar XP!",
        "ru": "Создавайте ежедневные задачи и отмечайте их, чтобы зарабатывать XP!",
        "tr": "Günlük görevler oluşturun ve XP kazanmak için onları işaretleyin!",
        "hi": "दैनिक कार्य बनाएं और XP कमाने के लिए उन्हें जांचें!",
        "ja": "毎日のタスクを作成し、チェックしてXPを獲得しましょう！",
        "ko": "일일 할 일을 만들고 완료하여 XP를 얻으세요!",
        "zh-Hans": "创建日常待办事项并勾选它们以赚取经验值！",
        "zh-Hant": "創建日常待辦事項並勾選它們以賺取經驗值！"
    }
}

xcode_target_langs = ['ru', 'en', 'ko', 'es', 'pl', 'zh-Hans', 'zh-Hant', 'hi', 'de', 'nl', 'pt', 'tr', 'fr', 'ja', 'it']

strings = data.setdefault('strings', {})

for key, lang_dict in translations.items():
    if key not in strings:
        strings[key] = {"localizations": {}}
        
    locs = strings[key]["localizations"]
    
    for lang in xcode_target_langs:
        val = lang_dict.get(lang, lang_dict.get('en', ''))
        locs[lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    
print("Translations inserted successfully!")
