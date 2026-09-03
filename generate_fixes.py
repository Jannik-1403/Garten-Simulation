import json

base_texts = {
  "assessment.health.q11.d": "Ich bin viel draußen, schaue aber auch beim Gehen zu %@ auf mein Smartphone.",
  "assessment.lifestyle.q11.a": "Ich konsumiere zu %@. Ich scrolle nur durch die Leben anderer Leute.",
  "focus.generic.reward": "Fokus-Session: %@",
  "focus.giveup.walkofshame.sentence2": "[Achtung] Ich bin zu schwach für neunundneunzig Prozent meiner Aufgaben. Ich breche ab: X-Y-Z statt A-B-C. Mein Fokus sinkt auf null Punkt null; ich wähle #Versagen über #Wachstum. Warum? Weil mein Dopamin-Spiegel < zehn Prozent ist.",
  "assessment.fitness.q1.d": "Ich fluche, stehe auf, friere und ziehe das geplante Workout zu %@ durch.",
  "boost.blinkist.discount": "%@ Rabatt",
  "developer.nutrients.reset": "Alle Nährstoffe zurücksetzen",
  "developer.section.nutrients": "Nährstoff-Testdaten",
  "notification.wait.3.title": "Vergiss \"%@\" nicht!",
  "pfad.ice.desc": "Das Streak-Eis schützt deinen Streak. Du verlierst ihn nicht, wenn du an einem Tag nicht gießt.\n\nDu erhältst 1 neues Eis für jede vollendete Woche (7 Tage Ring). Maximal 3 Eis können gleichzeitig aktiv sein.",
  "developer.nutrients.inject_vitamins": "Vitamine mit Testdaten befüllen",
  "developer.nutrients.inject_fiber": "Ballaststoffe mit Testdaten befüllen",
  "focus.generic.subtitle": "Was möchtest du in dieser Session erreichen?",
  "developer.nutrients.inject_minerals": "Mineralstoffe mit Testdaten befüllen",
  "assessment.mental.q13": "Du bist in einer hitzigen Diskussion. Fünf Leute vertreten lautstark Meinung A. Du weißt zu %@, dass Meinung B richtig ist."
}

langs = ["en", "es", "fr", "hi", "it", "ja", "ko", "nl", "pl", "pt", "pt-BR", "ru", "tr", "zh-Hans", "zh-Hant"]

translations = {
  "assessment.health.q11.d": {
    "en": "I spend a lot of time outdoors, but I also look at my smartphone %@ of the time while walking.",
    "es": "Paso mucho tiempo al aire libre, pero también miro mi smartphone el %@ del tiempo mientras camino.",
    "fr": "Je passe beaucoup de temps dehors, mais je regarde aussi mon smartphone %@ du temps en marchant.",
    "hi": "मैं बाहर बहुत समय बिताता हूँ, लेकिन चलते समय %@ बार अपने स्मार्टफोन को भी देखता हूँ।",
    "it": "Passo molto tempo all'aperto, ma guardo anche il mio smartphone il %@ del tempo mentre cammino.",
    "ja": "私はよく外に出ますが、歩きながら%@の割合でスマートフォンを見てしまいます。",
    "ko": "저는 야외에서 많은 시간을 보내지만, 걸을 때 %@의 비율로 스마트폰을 봅니다.",
    "nl": "Ik ben veel buiten, maar ik kijk ook %@ van de tijd op mijn smartphone tijdens het lopen.",
    "pl": "Spędzam dużo czasu na zewnątrz, ale podczas chodzenia przez %@ czasu patrzę też w smartfona.",
    "pt": "Passo muito tempo ao ar livre, mas também olho para o meu smartphone %@ do tempo enquanto caminho.",
    "pt-BR": "Passo muito tempo ao ar livre, mas também olho para o meu smartphone %@ do tempo enquanto caminho.",
    "ru": "Я провожу много времени на улице, но при ходьбе также смотрю в свой смартфон %@ времени.",
    "tr": "Dışarıda çok zaman geçiririm ama yürürken de zamanımın %@'sini akıllı telefonuma bakarak geçiririm.",
    "zh-Hans": "我花很多时间在户外，但在走路时我也有 %@ 的时间在看智能手机。",
    "zh-Hant": "我花很多時間在戶外，但在走路時我也有 %@ 的時間在看智慧型手機。"
  },
  "assessment.lifestyle.q11.a": {
    "en": "I consume %@ of the time. I just scroll through other people's lives.",
    "es": "Consumo el %@ del tiempo. Solo desplazo por la vida de otras personas.",
    "fr": "Je consomme %@ du temps. Je ne fais que faire défiler la vie des autres.",
    "hi": "मैं %@ समय उपभोग करता हूँ। मैं बस दूसरों के जीवन को स्क्रॉल करता हूँ।",
    "it": "Consumo il %@ del tempo. Scorro semplicemente le vite di altre persone.",
    "ja": "私は%@の時間を消費しています。他の人の人生をスクロールしているだけです。",
    "ko": "저는 %@의 시간을 소비합니다. 다른 사람들의 삶을 스크롤할 뿐입니다.",
    "nl": "Ik consumeer %@ van de tijd. Ik scroll gewoon door de levens van andere mensen.",
    "pl": "Konsumuję przez %@ czasu. Przeglądam tylko życia innych ludzi.",
    "pt": "Eu consumo %@ do tempo. Apenas faço scroll pelas vidas de outras pessoas.",
    "pt-BR": "Eu consumo %@ do tempo. Apenas faço scroll pelas vidas de outras pessoas.",
    "ru": "Я потребляю %@ времени. Я просто пролистываю жизни других людей.",
    "tr": "Zamanımın %@'sini tüketiyorum. Sadece diğer insanların hayatlarında kaydırıyorum.",
    "zh-Hans": "我消耗了 %@ 的时间。我只是在滑动别人的生活。",
    "zh-Hant": "我消耗了 %@ 的時間。我只是在滑動別人的生活。"
  },
  "focus.generic.reward": {
    "en": "Focus session: %@",
    "es": "Sesión de enfoque: %@",
    "fr": "Session de concentration : %@",
    "hi": "फोकस सत्र: %@",
    "it": "Sessione di focus: %@",
    "ja": "フォーカスセッション: %@",
    "ko": "포커스 세션: %@",
    "nl": "Focussessie: %@",
    "pl": "Sesja skupienia: %@",
    "pt": "Sessão de foco: %@",
    "pt-BR": "Sessão de foco: %@",
    "ru": "Фокус-сессия: %@",
    "tr": "Odak seansı: %@",
    "zh-Hans": "专注环节：%@",
    "zh-Hant": "專注環節： %@ "
  },
  "focus.giveup.walkofshame.sentence2": {
    "en": "[Warning] I am too weak for ninety-nine percent of my tasks. I cancel: X-Y-Z instead of A-B-C. My focus drops to zero point zero; I choose #Failure over #Growth. Why? Because my dopamine level is < ten percent.",
    "es": "[Advertencia] Soy demasiado débil para el noventa y nueve por ciento de mis tareas. Cancelo: X-Y-Z en lugar de A-B-C. Mi enfoque cae a cero punto cero; elijo el #Fracaso sobre el #Crecimiento. ¿Por qué? Porque mi nivel de dopamina es < diez por ciento.",
    "fr": "[Attention] Je suis trop faible pour quatre-vingt-dix-neuf pour cent de mes tâches. J'annule : X-Y-Z au lieu de A-B-C. Ma concentration tombe à zéro virgule zéro ; je choisis l'#Échec plutôt que la #Croissance. Pourquoi ? Parce que mon taux de dopamine est < dix pour cent.",
    "hi": "[चेतावनी] मैं अपने निन्यानवे प्रतिशत कार्यों के लिए बहुत कमजोर हूँ। मैं रद्द करता हूँ: A-B-C के बजाय X-Y-Z। मेरा फोकस शून्य बिंदु शून्य तक गिर जाता है; मैं #विकास के बजाय #विफलता चुनता हूँ। क्यों? क्योंकि मेरा डोपामाइन स्तर < दस प्रतिशत है।",
    "it": "[Attenzione] Sono troppo debole per il novantanove percento dei miei compiti. Annulla: X-Y-Z invece di A-B-C. La mia concentrazione scende a zero virgola zero; scelgo il #Fallimento rispetto alla #Crescita. Perché? Perché il mio livello di dopamina è < del dieci percento.",
    "ja": "[警告] 私はタスクの99パーセントに対して弱すぎます。キャンセルします：A-B-CではなくX-Y-Z。私の集中力は0.0に低下します。私は#成長よりも#失敗を選びます。なぜですか？私のドーパミンレベルが10パーセント未満だからです。",
    "ko": "[경고] 저는 제 작업의 99퍼센트에 너무 약합니다. 취소합니다: A-B-C 대신 X-Y-Z. 제 집중력은 0.0으로 떨어집니다. 저는 #성장보다 #실패를 선택합니다. 왜 그럴까요? 제 도파민 수치가 10퍼센트 미만이기 때문입니다.",
    "nl": "[Waarschuwing] Ik ben te zwak voor negenennegentig procent van mijn taken. Ik breek af: X-Y-Z in plaats van A-B-C. Mijn focus zakt naar nul komma nul; ik kies #Falen boven #Groei. Waarom? Omdat mijn dopaminespiegel < tien procent is.",
    "pl": "[Ostrzeżenie] Jestem zbyt słaby na dziewięćdziesiąt dziewięć procent moich zadań. Anuluję: X-Y-Z zamiast A-B-C. Moje skupienie spada do zera przecinek zero; wybieram #Porażkę zamiast #Wzrostu. Dlaczego? Ponieważ mój poziom dopaminy wynosi < dziesięć procent.",
    "pt": "[Aviso] Sou fraco demais para noventa e nove por cento das minhas tarefas. Cancelo: X-Y-Z em vez de A-B-C. Meu foco cai para zero vírgula zero; escolho o #Fracasso em vez do #Crescimento. Por quê? Porque meu nível de dopamina é < dez por cento.",
    "pt-BR": "[Aviso] Sou fraco demais para noventa e nove por cento das minhas tarefas. Cancelo: X-Y-Z em vez de A-B-C. Meu foco cai para zero vírgula zero; escolho o #Fracasso em vez do #Crescimento. Por quê? Porque meu nível de dopamina é < dez por cento.",
    "ru": "[Внимание] Я слишком слаб для девяноста девяти процентов своих задач. Я отменяю: X-Y-Z вместо A-B-C. Мой фокус падает до ноля целых ноль десятых; я выбираю #Провал вместо #Роста. Почему? Потому что мой уровень дофамина < десяти процентов.",
    "tr": "[Uyarı] Görevlerimin yüzde doksan dokuzu için çok zayıfım. İptal ediyorum: A-B-C yerine X-Y-Z. Odak noktam sıfır nokta sıfıra düşüyor; #Büyüme yerine #Başarısızlık'ı seçiyorum. Neden mi? Çünkü dopamin seviyem yüzde ondan düşük.",
    "zh-Hans": "[警告] 我对百分之九十九的任务来说太软弱了。我取消：X-Y-Z 而不是 A-B-C。我的专注力降至零点零；我选择 #失败 而不是 #成长。为什么？因为我的多巴胺水平 < 百分之十。",
    "zh-Hant": "[警告] 我對百分之九十九的任務來說太軟弱了。我取消：X-Y-Z 而不是 A-B-C。我的專注力降至零點零；我選擇 #失敗 而不是 #成長。為什麼？因為我的多巴胺水平 < 百分之十。"
  },
  "assessment.fitness.q1.d": {
    "en": "I curse, get up, freeze, and power through the planned workout %@ of the time.",
    "es": "Maldigo, me levanto, me congelo y logro completar el entrenamiento planificado el %@ del tiempo.",
    "fr": "Je jure, je me lève, j'ai froid et je viens à bout de l'entraînement prévu %@ du temps.",
    "hi": "मैं कोसता हूँ, उठता हूँ, जमता हूँ और योजनाबद्ध कसरत को %@ बार पूरा करता हूँ।",
    "it": "Impreco, mi alzo, mi congelo e porto a termine l'allenamento previsto il %@ delle volte.",
    "ja": "文句を言い、起き上がり、凍えながら、予定されたワークアウトを%@の割合でやり遂げます。",
    "ko": "욕을 하고, 일어나서, 얼어붙으면서도 예정된 운동을 %@의 비율로 해냅니다.",
    "nl": "Ik vloek, sta op, heb het koud en zet de geplande workout voor %@ door.",
    "pl": "Przeklinam, wstaję, marznę i wykonuję zaplanowany trening przez %@ czasu.",
    "pt": "Amaldiçoo, levanto-me, congelo e consigo completar o treino planeado %@ do tempo.",
    "pt-BR": "Eu xingo, me levanto, congelo e consigo completar o treino planejado %@ do tempo.",
    "ru": "Я ругаюсь, встаю, мерзну и выполняю запланированную тренировку на %@.",
    "tr": "Küfrediyorum, kalkıyorum, donuyorum ve planlanan antrenmanı zamanın %@'sinde tamamlıyorum.",
    "zh-Hans": "我咒骂、起床、挨冻，并在 %@ 的时间里坚持完成计划的锻炼。",
    "zh-Hant": "我咒罵、起床、挨凍，並在 %@ 的時間裡堅持完成計劃的鍛煉。"
  },
  "boost.blinkist.discount": {
    "en": "%@ Discount", "es": "%@ de Descuento", "fr": "%@ de réduction", "hi": "%@ छूट", "it": "Sconto %@ ", "ja": "%@ 割引", "ko": "%@ 할인", "nl": "%@ Korting", "pl": "%@ zniżki", "pt": "%@ de Desconto", "pt-BR": "%@ de Desconto", "ru": "Скидка %@", "tr": "%@ İndirim", "zh-Hans": "%@ 折扣", "zh-Hant": "%@ 折扣"
  },
  "developer.nutrients.reset": {
    "en": "Reset all nutrients", "es": "Restablecer todos los nutrientes", "fr": "Réinitialiser tous les nutriments", "hi": "सभी पोषक तत्वों को रीसेट करें", "it": "Reimposta tutti i nutrienti", "ja": "すべての栄養素をリセット", "ko": "모든 영양소 재설정", "nl": "Alle voedingsstoffen resetten", "pl": "Zresetuj wszystkie składniki odżywcze", "pt": "Redefinir todos os nutrientes", "pt-BR": "Redefinir todos os nutrientes", "ru": "Сбросить все питательные вещества", "tr": "Tüm besinleri sıfırla", "zh-Hans": "重置所有营养素", "zh-Hant": "重置所有營養素"
  },
  "developer.section.nutrients": {
    "en": "Nutrient Test Data", "es": "Datos de prueba de nutrientes", "fr": "Données de test des nutriments", "hi": "पोषक तत्व परीक्षण डेटा", "it": "Dati test nutrienti", "ja": "栄養素テストデータ", "ko": "영양소 테스트 데이터", "nl": "Voedingsstoffen testgegevens", "pl": "Dane testowe składników odżywczych", "pt": "Dados de teste de nutrientes", "pt-BR": "Dados de teste de nutrientes", "ru": "Тестовые данные питательных веществ", "tr": "Besin Test Verileri", "zh-Hans": "营养素测试数据", "zh-Hant": "營養素測試數據"
  },
  "notification.wait.3.title": {
    "en": "Don't forget \"%@\"!", "es": "¡No olvides \"%@\"!", "fr": "N'oublie pas \"%@\" !", "hi": "\"%@\" को न भूलें!", "it": "Non dimenticare \"%@\"!", "ja": "「%@」を忘れないで！", "ko": "\"%@\"을(를) 잊지 마세요!", "nl": "Vergeet \"%@\" niet!", "pl": "Nie zapomnij o \"%@\"!", "pt": "Não te esqueças de \"%@\"!", "pt-BR": "Não se esqueça de \"%@\"!", "ru": "Не забудьте \"%@\"!", "tr": "\"%@\" öğesini unutma!", "zh-Hans": "别忘了“%@”！", "zh-Hant": "別忘了「%@」！"
  },
  "pfad.ice.desc": {
    "en": "The Streak Ice protects your streak. You won't lose it if you miss watering for one day.\n\nYou earn 1 new Ice for every completed week (7-day ring). A maximum of 3 Ice can be active at the same time.",
    "es": "El Hielo de Racha protege tu racha. No la perderás si te olvidas de regar un día.\n\nGanas 1 hielo nuevo por cada semana completada (anillo de 7 días). Puede haber un máximo de 3 hielos activos al mismo tiempo.",
    "fr": "La Glace de Série protège ta série. Tu ne la perdras pas si tu oublies d'arroser un jour.\n\nTu gagnes 1 nouvelle glace pour chaque semaine complétée (anneau de 7 jours). Un maximum de 3 glaces peuvent être actives en même temps.",
    "hi": "स्ट्राक आइस आपके स्ट्रीक की रक्षा करता है। अगर आप एक दिन पानी देना भूल जाते हैं, तो आप इसे नहीं खोएंगे।\n\nआप प्रत्येक पूर्ण सप्ताह (7-दिन की रिंग) के लिए 1 नया आइस कमाते हैं। एक ही समय में अधिकतम 3 आइस सक्रिय हो सकते हैं।",
    "it": "Il Ghiaccio della Serie protegge la tua serie. Non la perderai se salti un giorno di annaffiatura.\n\nGuadagni 1 nuovo ghiaccio per ogni settimana completata (anello di 7 giorni). Un massimo di 3 ghiacci possono essere attivi contemporaneamente.",
    "ja": "ストリークアイスはあなたのストリークを保護します。1日水やりを忘れてもストリークは失われません。\n\n1週間（7日間のリング）を完了するごとに新しいアイスを1つ獲得します。同時に最大3つのアイスをアクティブにできます。",
    "ko": "스트릭 얼음은 연속 기록을 보호합니다. 하루 물주기를 건너뛰어도 연속 기록을 잃지 않습니다.\n\n완료된 매주(7일 링)마다 1개의 새로운 얼음을 얻습니다. 동시에 최대 3개의 얼음을 활성화할 수 있습니다.",
    "nl": "Het Streak-IJs beschermt je streak. Je verliest hem niet als je een dag niet water geeft.\n\nJe verdient 1 nieuw ijs voor elke voltooide week (7-dagen ring). Maximaal 3 ijsjes kunnen tegelijkertijd actief zijn.",
    "pl": "Lód Serii chroni Twoją serię. Nie stracisz jej, jeśli zapomnisz podlać przez jeden dzień.\n\nZdobywasz 1 nowy lód za każdy ukończony tydzień (7-dniowy pierścień). Maksymalnie 3 lody mogą być aktywne w tym samym czasie.",
    "pt": "O Gelo de Sequência protege a tua sequência. Não a perdes se não regares durante um dia.\n\nGanhas 1 gelo novo por cada semana completada (anel de 7 dias). Um máximo de 3 gelos podem estar ativos ao mesmo tempo.",
    "pt-BR": "O Gelo de Sequência protege a sua sequência. Você não a perde se deixar de regar por um dia.\n\nVocê ganha 1 gelo novo para cada semana concluída (anel de 7 dias). No máximo 3 gelos podem estar ativos ao mesmo tempo.",
    "ru": "Лед для серии защищает вашу серию. Вы не потеряете ее, если пропустите день полива.\n\nВы получаете 1 новый лед за каждую завершенную неделю (7-дневное кольцо). Одновременно может быть активно не более 3 льдов.",
    "tr": "Seri Buzu serinizi korur. Bir gün sulamayı kaçırırsanız serinizi kaybetmezsiniz.\n\nTamamlanan her hafta (7 günlük halka) için 1 yeni buz kazanırsınız. Aynı anda maksimum 3 buz aktif olabilir.",
    "zh-Hans": "连击冰可以保护您的连击。如果您某天没有浇水，您不会失去连击。\n\n每完成一周（7天连击圈），您将获得1个新冰。最多可以同时激活3个冰。",
    "zh-Hant": "連擊冰可以保護您的連擊。如果您某天沒有澆水，您不會失去連擊。\n\n每完成一週（7天連擊圈），您將獲得1個新冰。最多可以同時啟動3個冰。"
  },
  "developer.nutrients.inject_vitamins": {
    "en": "Inject vitamins with test data", "es": "Inyectar vitaminas con datos de prueba", "fr": "Injecter des vitamines avec des données de test", "hi": "विटामिन को परीक्षण डेटा के साथ इंजेक्ट करें", "it": "Inserisci vitamine con dati di test", "ja": "テストデータでビタミンを注入", "ko": "테스트 데이터로 비타민 주입", "nl": "Vitaminen injecteren met testgegevens", "pl": "Wprowadź witaminy z danymi testowymi", "pt": "Injetar vitaminas com dados de teste", "pt-BR": "Injetar vitaminas com dados de teste", "ru": "Ввести витамины с тестовыми данными", "tr": "Test verileriyle vitaminleri enjekte et", "zh-Hans": "使用测试数据注入维生素", "zh-Hant": "使用測試數據注入維生素"
  },
  "developer.nutrients.inject_fiber": {
    "en": "Inject fiber with test data", "es": "Inyectar fibra con datos de prueba", "fr": "Injecter des fibres avec des données de test", "hi": "फाइबर को परीक्षण डेटा के साथ इंजेक्ट करें", "it": "Inserisci fibre con dati di test", "ja": "テストデータで食物繊維を注入", "ko": "테스트 데이터로 식이섬유 주입", "nl": "Vezels injecteren met testgegevens", "pl": "Wprowadź błonnik z danymi testowymi", "pt": "Injetar fibra com dados de teste", "pt-BR": "Injetar fibra com dados de teste", "ru": "Ввести клетчатку с тестовыми данными", "tr": "Test verileriyle lifi enjekte et", "zh-Hans": "使用测试数据注入膳食纤维", "zh-Hant": "使用測試數據注入膳食纖維"
  },
  "focus.generic.subtitle": {
    "en": "What do you want to achieve in this session?", "es": "¿Qué quieres lograr en esta sesión?", "fr": "Que souhaites-tu accomplir pendant cette session ?", "hi": "आप इस सत्र में क्या हासिल करना चाहते हैं?", "it": "Cosa vuoi ottenere in questa sessione?", "ja": "このセッションで何を達成したいですか？", "ko": "이 세션에서 무엇을 달성하고 싶으신가요?", "nl": "Wat wil je bereiken in deze sessie?", "pl": "Co chcesz osiągnąć podczas tej sesji?", "pt": "O que queres alcançar nesta sessão?", "pt-BR": "O que você deseja alcançar nesta sessão?", "ru": "Чего вы хотите достичь на этой сессии?", "tr": "Bu seansta ne başarmak istiyorsun?", "zh-Hans": "您想在本次环节中实现什么目标？", "zh-Hant": "您想在本次環節中實現什麼目標？"
  },
  "developer.nutrients.inject_minerals": {
    "en": "Inject minerals with test data", "es": "Inyectar minerales con datos de prueba", "fr": "Injecter des minéraux avec des données de test", "hi": "खनिजों को परीक्षण डेटा के साथ इंजेक्ट करें", "it": "Inserisci minerali con dati di test", "ja": "テストデータでミネラルを注入", "ko": "테스트 데이터로 미네랄 주입", "nl": "Mineralen injecteren met testgegevens", "pl": "Wprowadź minerały z danymi testowymi", "pt": "Injetar minerais com dados de teste", "pt-BR": "Injetar minerais com dados de teste", "ru": "Ввести минералы с тестовыми данными", "tr": "Test verileriyle mineralleri enjekte et", "zh-Hans": "使用测试数据注入矿物质", "zh-Hant": "使用測試數據注入礦物質"
  },
  "assessment.mental.q13": {
    "en": "You are in a heated discussion. Five people loudly argue for opinion A. You know to %@ that opinion B is correct.",
    "es": "Estás en una discusión acalorada. Cinco personas defienden en voz alta la opinión A. Sabes al %@ que la opinión B es correcta.",
    "fr": "Tu es dans une discussion animée. Cinq personnes défendent bruyamment l'opinion A. Tu sais à %@ que l'opinion B est correcte.",
    "hi": "आप एक गरमागरम चर्चा में हैं। पाँच लोग ज़ोर-शोर से राय A का समर्थन कर रहे हैं। आप %@ जानते हैं कि राय B सही है।",
    "it": "Sei in una discussione accesa. Cinque persone sostengono ad alta voce l'opinione A. Sai al %@ che l'opinione B è corretta.",
    "ja": "白熱した議論をしています。5人が声高に意見Aを主張しています。あなたは意見Bが正しいことを%@確信しています。",
    "ko": "격렬한 토론 중입니다. 다섯 명이 큰 소리로 의견 A를 주장합니다. 당신은 의견 B가 맞다는 것을 %@ 알고 있습니다.",
    "nl": "Je zit in een verhitte discussie. Vijf mensen verdedigen luidruchtig mening A. Je weet voor %@ zeker dat mening B juist is.",
    "pl": "Jesteś w trakcie gorącej dyskusji. Pięć osób głośno broni opinii A. W %@ wiesz, że opinia B jest poprawna.",
    "pt": "Estás numa discussão acesa. Cinco pessoas defendem em voz alta a opinião A. Tu sabes com %@ de certeza que a opinião B está correta.",
    "pt-BR": "Você está em uma discussão acalorada. Cinco pessoas defendem em voz alta a opinião A. Você sabe com %@ de certeza que a opinião B está correta.",
    "ru": "Вы находитесь в жаркой дискуссии. Пять человек громко отстаивают мнение А. Вы на %@ знаете, что мнение Б правильное.",
    "tr": "Ateşli bir tartışmanın içindesiniz. Beş kişi yüksek sesle A fikrini savunuyor. B fikrinin doğru olduğunu %@ biliyorsunuz.",
    "zh-Hans": "您正处于一场激烈的讨论中。五个人大声支持观点 A。您有 %@ 确定观点 B 是正确的。",
    "zh-Hant": "您正處於一場激烈的討論中。五個人大聲支持觀點 A。您有 %@ 確定觀點 B 是正確的。"
  }
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    xc_data = json.load(f)
    
xc_strings = xc_data.get("strings", {})

count = 0
for key, lang_dict in translations.items():
    if key in xc_strings:
        for lang, val in lang_dict.items():
            if "localizations" not in xc_strings[key]:
                xc_strings[key]["localizations"] = {}
            if lang not in xc_strings[key]["localizations"]:
                xc_strings[key]["localizations"][lang] = {"stringUnit": {}}
            xc_strings[key]["localizations"][lang]["stringUnit"]["state"] = "translated"
            xc_strings[key]["localizations"][lang]["stringUnit"]["value"] = val
            count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(xc_data, f, indent=2, ensure_ascii=False)

print(f"Fixed {count} translations for 15 keys!")
