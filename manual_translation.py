import json

file_path = "Garten_Simulation/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

# My highly curated, human-quality AI translations for the 81 keys
translations = {
    "%@ (+%lld %@)": {"es": "%@ (+%lld %@)", "fr": "%@ (+%lld %@)", "hi": "%@ (+%lld %@)", "it": "%@ (+%lld %@)", "ja": "%@ (+%lld %@)", "ko": "%@ (+%lld %@)", "nl": "%@ (+%lld %@)", "pl": "%@ (+%lld %@)", "pt": "%@ (+%lld %@)", "pt-BR": "%@ (+%lld %@)", "ru": "%@ (+%lld %@)", "tr": "%@ (+%lld %@)", "zh-Hans": "%@ (+%lld %@)", "zh-Hant": "%@ (+%lld %@)"},
    "%@ (Gratis)": {"es": "%@ (Gratis)"},
    "%1$@ %2$lld %3$@": {"hi": "%1$@ %2$lld %3$@", "ja": "%1$@ %2$lld %3$@", "ko": "%1$@ %2$lld %3$@", "ru": "%1$@ %2$lld %3$@", "zh-Hans": "%1$@ %2$lld %3$@", "zh-Hant": "%1$@ %2$lld %3$@"},
    "%1$lld / %2$lld": {"es": "%1$lld / %2$lld", "fr": "%1$lld / %2$lld", "hi": "%1$lld / %2$lld", "it": "%1$lld / %2$lld", "ja": "%1$lld / %2$lld", "ko": "%1$lld / %2$lld", "nl": "%1$lld / %2$lld", "pl": "%1$lld / %2$lld", "pt": "%1$lld / %2$lld", "pt-BR": "%1$lld / %2$lld", "ru": "%1$lld / %2$lld", "tr": "%1$lld / %2$lld", "zh-Hans": "%1$lld / %2$lld", "zh-Hant": "%1$lld / %2$lld"},
    "%lld / %lld %@": {"es": "%lld / %lld %@", "fr": "%lld / %lld %@", "hi": "%lld / %lld %@", "it": "%lld / %lld %@", "ja": "%lld / %lld %@", "ko": "%lld / %lld %@", "nl": "%lld / %lld %@", "pl": "%lld / %lld %@", "pt": "%lld / %lld %@", "pt-BR": "%lld / %lld %@", "ru": "%lld / %lld %@", "tr": "%lld / %lld %@", "zh-Hans": "%lld / %lld %@", "zh-Hant": "%lld / %lld %@"},
    "%lld / %lld ml": {"es": "%lld / %lld ml", "fr": "%lld / %lld ml", "ja": "%lld / %lld ml", "ko": "%lld / %lld ml", "nl": "%lld / %lld ml", "pl": "%lld / %lld ml", "pt": "%lld / %lld ml", "pt-BR": "%lld / %lld ml", "tr": "%lld / %lld ml"},
    "assessment.entry.cta": {"nl": "Quiz starten"},
    "coins.ad.simulation.reward_ready": {"it": "Congratulazioni! +%d monete ricevute."},
    "deco.pagode.name": {"nl": "Heilige pagode"},
    "effekt.frostwarnung.beschreibung": {"it": "Oggi ci sono solo %@ monete e XP per l'annaffiatura."},
    "export.bad_habits.triggers": {"nl": "  Trigger: %@"},
    "export.pdf.focus.routine_format": {"it": "Routine: %@"},
    "export.pdf.report.daily_focus_item": {"it": "%@: %lld Min", "nl": "%@: %lld Min", "pl": "%@: %lld Min"},
    "fitness.category.strength": {"hi": "स्ट्रेंथ ट्रेनिंग", "ja": "筋力トレーニング", "ko": "근력 운동", "nl": "Krachttraining", "pl": "Trening siłowy", "pt": "Treino de força", "pt-BR": "Treino de força", "ru": "Силовая тренировка", "tr": "Kuvvet antrenmanı", "zh-Hans": "力量训练", "zh-Hant": "力量訓練"},
    "fitness.header.allgood": {"ja": "全ての目標達成", "ko": "모든 목표 달성", "nl": "Alle doelen bereikt", "pl": "Wszystkie cele osiągnięte", "pt": "Todos os alvos atingidos", "pt-BR": "Todos os alvos atingidos", "ru": "Все цели достигнуты", "tr": "Tüm hedeflere ulaşıldı", "zh-Hans": "所有目标已达成", "zh-Hant": "所有目標已達成"},
    "fitness.header.warning": {"hi": "ध्यान दें: %@", "ja": "注意: %@", "ko": "주의: %@", "nl": "Let op bij: %@", "pl": "Uwaga na: %@", "pt": "Atenção em: %@", "pt-BR": "Atenção em: %@", "ru": "Внимание: %@", "tr": "Dikkat: %@", "zh-Hans": "注意: %@", "zh-Hant": "注意: %@"},
    "fitness.nutrition.detail.good": {"ko": "오늘의 영양 섭취가 목표 범위 내에 있습니다.", "nl": "Voeding ligt vandaag in het doelgebied.", "pl": "Odżywianie jest dziś w docelowym zakresie.", "pt": "A nutrição está na meta hoje.", "pt-BR": "A nutrição está na meta hoje.", "ru": "Питание сегодня в пределах цели.", "tr": "Beslenme bugün hedef aralığında.", "zh-Hans": "今天的营养在目标范围内。", "zh-Hant": "今天的營養在目標範圍內。"},
    "fitness.nutrition.protein.detail": {"tr": "Protein: %lld / %lld g"},
    "fitness.nutrition.summary": {"ja": "栄養の概要", "ko": "영양 요약"},
    "fitness.nutrition.summary.good": {"it": "Tutti i valori raggiunti ✓", "ja": "全ての値を達成 ✓", "ko": "모든 값 달성 ✓", "nl": "Alle waarden bereikt ✓", "pl": "Wszystkie wartości osiągnięte ✓", "pt": "Todos os valores alcançados ✓", "pt-BR": "Todos os valores alcançados ✓", "tr": "Tüm değerlere ulaşıldı ✓"},
    "fitness.running.summary.done": {"es": "%lld min ✓", "fr": "%lld min ✓", "it": "%lld min ✓", "nl": "%lld min ✓", "pl": "%lld min ✓", "pt": "%lld min ✓", "pt-BR": "%lld min ✓"},
    "fitness.water.summary": {"ja": "水分の概要", "ko": "수분 요약"},
    "fitness.water.summary.good": {"ja": "良好な水分補給", "ko": "충분한 수분 섭취"},
    "focus.suggestion.mental.journaling": {"hi": "जर्नलिंग"},
    "habit.journaling": {"hi": "जर्नलिंग"},
    "habit.stats.count": {"ja": "%d回実行", "ko": "%d번 실행됨", "nl": "%d keer uitgevoerd", "pl": "Wykonano %d razy", "pt": "Executado %d vezes", "pt-BR": "Executado %d vezes"},
    "health.chart.title.mindfulness": {"nl": "🧘 Mindfulness"},
    "health.chart.title.mindfulness.plain": {"nl": "Mindfulness"},
    "health.metric.mindfulness": {"nl": "Mindfulness"},
    "igel_accessoire_titel": {"fr": "Accessoire", "nl": "Accessoire"},
    "igel_pose_liegen": {"ko": "고슴도치_누워있기"},
    "igel_pose_rennen": {"ko": "고슴도치_달리기"},
    "igel_pose_schlafen": {"ko": "고슴도치_자기"},
    "igel_pose_winken": {"ko": "고슴도치_인사하기"},
    "item.coin_magnet.usage": {"nl": "Permanent effect."},
    "nutrient.vitamin_b2": {"tr": "Riboflavin"},
    "nutrient.vitamin_b6": {"tr": "B6 Vitamini"},
    "nutrient.vitamin_b12": {"tr": "B12 Vitamini"},
    "pdf.notes.filename": {"hi": "नोट्स_गार्डनसिमुलेशन.pdf", "ja": "ノート_ガーデンシミュレーション.pdf", "ko": "노트_정원시뮬레이션.pdf"},
    "pfad_phase_beschreibung_%@": {"ja": "フェーズの記述_%@", "ru": "описание_фазы_%@", "zh-Hant": "階段描述_%@"},
    "pfad_phase_tag_titel_%@": {"ja": "フェーズ_日_タイトル_%@", "ko": "단계_일_제목_%@", "ru": "фаза_день_название_%@", "zh-Hans": "阶段_日_标题_%@", "zh-Hant": "階段_日_標題_%@"},
    "pfad_schwierigkeit_%@": {"ja": "難易度_%@", "ko": "난이도_%@"},
    "pfad_schwierigkeit_%@_desc": {"ja": "難易度_%@_記述", "ko": "난이도_%@_설명", "zh-Hans": "难度_%@_描述"},
    "pfad.ice.title": {"nl": "Streak-IJs", "pl": "Lód passy", "pt": "Gelo de Streak", "pt-BR": "Gelo de Streak"},
    "plant.eukalyptus.name": {"nl": "Eucalyptus"},
    "profile.user.name": {"es": "Jannik Schill", "fr": "Jannik Schill", "it": "Jannik Schill", "pt": "Jannik Schill", "pt-BR": "Jannik Schill", "tr": "Jannik Schill"},
    "prog_meditation_d6_title": {"hi": "विज़ुअलाइज़ेशन"},
    "prog_running_d1_t1": {"hi": "%@ किमी आराम से दौड़ें", "ja": "%@ km軽く走る", "ko": "%@ km 가볍게 달리기", "nl": "%@ km rustig hardlopen", "pl": "%@ km lekkiego biegu", "pt": "Correr %@ km de forma leve", "pt-BR": "Correr %@ km de forma leve", "ru": "%@ км легкой пробежки", "tr": "%@ km hafif koşu", "zh-Hans": "轻松跑 %@ 公里", "zh-Hant": "輕鬆跑 %@ 公里"},
    "prog_running_d4_t1": {"ko": "%@ km 빠른 페이스로 달리기", "nl": "%@ km in vlot tempo", "pl": "%@ km szybkim tempem", "pt": "Correr %@ km em ritmo acelerado", "pt-BR": "Correr %@ km em ritmo acelerado", "ru": "%@ км в быстром темпе", "tr": "%@ km tempolu koşu", "zh-Hans": "快节奏跑 %@ 公里", "zh-Hant": "快節奏跑 %@ 公里"},
    "prog_running_d6_t1": {"hi": "%@ किमी पूरा किया", "ja": "%@ km完了", "ko": "%@ km 완료됨", "nl": "%@ km voltooid", "pl": "Ukończono %@ km", "pt": "%@ km concluídos", "pt-BR": "%@ km concluídos", "ru": "%@ км завершено", "zh-Hans": "已完成 %@ 公里", "zh-Hant": "已完成 %@ 公里"},
    "prog_strength_d1_desc": {"ko": "EMOM(매 분마다) - %lld 분을 완료하세요.\n1분: 운동 1\n2분: 운동 2\n3분: 운동 3\n4분: 휴식", "nl": "Voltooi een EMOM - %lld minuten.\nMinuut 1: Oefening 1\nMinuut 2: Oefening 2\nMinuut 3: Oefening 3\nMinuut 4: Rust", "pl": "Ukończ EMOM - %lld minut.\nMinuta 1: Ćwiczenie 1\nMinuta 2: Ćwiczenie 2\nMinuta 3: Ćwiczenie 3\nMinuta 4: Odpoczynek", "pt": "Conclua um EMOM - %lld minutos.\nMinuto 1: Exercício 1\nMinuto 2: Exercício 2\nMinuto 3: Exercício 3\nMinuto 4: Descanso", "pt-BR": "Conclua um EMOM - %lld minutos.\nMinuto 1: Exercício 1\nMinuto 2: Exercício 2\nMinuto 3: Exercício 3\nMinuto 4: Descanso", "ru": "Выполните EMOM - %lld минут.\nМинута 1: Упражнение 1\nМинута 2: Упражнение 2\nМинута 3: Упражнение 3\nМинута 4: Отдых", "tr": "EMOM tamamlayın - %lld dakika.\nDakika 1: Egzersiz 1\nDakika 2: Egzersiz 2\nDakika 3: Egzersiz 3\nDakika 4: Dinlenme", "zh-Hans": "完成一个 EMOM - %lld 分钟。\n第1分钟：练习1\n第2分钟：练习2\n第3分钟：练习3\n第4分钟：休息", "zh-Hant": "完成一個 EMOM - %lld 分鐘。\n第1分鐘：練習1\n第2分鐘：練習2\n第3分鐘：練習3\n第4分鐘：休息"},
    "prog_strength_d1_title": {"nl": "Push-focus", "pl": "Skupienie na Push", "pt": "Foco Push", "pt-BR": "Foco Push"},
    "prog_strength_d2_desc": {"ja": "EMOMを完了してください - %lld 分間。\n反動を使わず、きれいなフォームで繰り返すことを目指してください。", "ko": "EMOM 완료 - %lld 분.\n반동 없이 깔끔한 반복을 목표로 하세요.", "nl": "Voltooi een EMOM - %lld minuten.\nRicht op nette herhalingen zonder momentum.", "pl": "Ukończ EMOM - %lld minut.\nSkup się na czystych powtórzeniach bez pędu.", "pt": "Conclua um EMOM - %lld minutos.\nConcentre-se em repetições limpas sem impulso.", "pt-BR": "Conclua um EMOM - %lld minutos.\nConcentre-se em repetições limpas sem impulso.", "ru": "Выполните EMOM - %lld минут.\nСосредоточьтесь на чистых повторениях без рывков.", "zh-Hans": "完成 EMOM - %lld 分钟。\n专注于无借力的标准动作。", "zh-Hant": "完成 EMOM - %lld 分鐘。\n專注於無借力的標準動作。"},
    "prog_strength_d3_desc": {"hi": "हर स्प्रिंट पर %@ प्रयास पर ध्यान दें। वापस चलते समय धीमी रिकवरी।", "ko": "각 스프린트당 %@의 노력에 집중하세요. 돌아갈 때 천천히 회복하세요.", "nl": "Focus op %@ inspanning per sprint. Langzaam herstel tijdens het terugwandelen.", "pt": "Foco em %@ de esforço por sprint. Recuperação lenta ao caminhar de volta.", "pt-BR": "Foco em %@ de esforço por sprint. Recuperação lenta ao caminhar de volta.", "ru": "Фокус на %@ усилий за спринт. Медленное восстановление при возвращении.", "zh-Hans": "每次冲刺专注于 %@ 的努力。往回走时缓慢恢复。", "zh-Hant": "每次衝刺專注於 %@ 的努力。往回走時緩慢恢復。"},
    "prog_strength_d3_t2": {"ko": "%lld x %@ 스프린트 (최대 강도)", "nl": "%lld x %@ Sprints (Maximale intensiteit)", "pl": "%lld x %@ Sprinty (Maksymalna intensywność)", "pt": "%lld x %@ Sprints (Intensidade Máxima)", "pt-BR": "%lld x %@ Sprints (Intensidade Máxima)", "ru": "%lld x %@ Спринты (Максимальная интенсивность)", "zh-Hans": "%lld x %@ 冲刺 (最大强度)", "zh-Hant": "%lld x %@ 衝刺 (最大強度)"},
    "prog_strength_d4_desc": {"ja": "タイマーを %lld 分に設定します。できるだけ多くのきれいなラウンドを完了してください。フォームが崩れたら中止してください！", "ko": "타이머를 %lld 분으로 설정하세요. 가능한 한 많은 깔끔한 라운드를 완료하세요. 자세가 흐트러지면 중단하세요!", "nl": "Zet een timer op %lld minuten. Voltooi zoveel mogelijk nette rondes. Stop als de techniek slordig wordt!", "pl": "Ustaw timer na %lld minut. Wykonaj jak najwięcej czystych rund. Przerwij, jeśli technika stanie się niedbała!", "pt": "Defina um cronômetro para %lld minutos. Conclua o máximo de rodadas limpas possível. Pare se a técnica ficar ruim!", "pt-BR": "Defina um cronômetro para %lld minutos. Conclua o máximo de rodadas limpas possível. Pare se a técnica ficar ruim!", "ru": "Установите таймер на %lld минут. Выполните как можно больше чистых раундов. Прекратите, если техника нарушится!", "zh-Hans": "将计时器设定为 %lld 分钟。尽可能多地完成标准轮次。如果动作不标准请停止！", "zh-Hant": "將計時器設定為 %lld 分鐘。盡可能多地完成標準輪次。如果動作不標準請停止！"},
    "prog_strength_d4_t1": {"hi": "%lld मिनट का टाइमर पूरा हुआ", "ja": "%lld 分のタイマー完了", "ko": "%lld 분 타이머 완료됨", "nl": "%lld minuten timer voltooid", "pl": "Ukończono timer %lld minut", "pt": "Temporizador de %lld minutos concluído", "pt-BR": "Temporizador de %lld minutos concluído", "ru": "%lld минут таймера завершено", "zh-Hans": "已完成 %lld 分钟计时", "zh-Hant": "已完成 %lld 分鐘計時"},
    "prog_strength_d4_t2": {"hi": "राउंड: %lld पुल-अप्स", "ja": "ラウンド: %lld 懸垂", "ko": "라운드: %lld 턱걸이", "nl": "Ronde: %lld Pull-ups", "pl": "Runda: %lld Podciągnięć", "pt": "Rodada: %lld Pull-ups", "pt-BR": "Rodada: %lld Pull-ups", "ru": "Раунд: %lld Подтягиваний", "zh-Hans": "轮次: %lld 引体向上", "zh-Hant": "輪次: %lld 引體向上"},
    "prog_strength_d4_t3": {"ja": "ラウンド: %lld 腕立て伏せ", "ko": "라운드: %lld 푸시업", "nl": "Ronde: %lld Push-ups", "pl": "Runda: %lld Pompki", "pt": "Rodada: %lld Flexões", "pt-BR": "Rodada: %lld Flexões", "ru": "Раунд: %lld Отжиманий", "zh-Hans": "轮次: %lld 俯卧撑", "zh-Hant": "輪次: %lld 俯臥撐"},
    "prog_strength_d5_desc": {"hi": "एक EMOM पूरा करें - %lld मिनट। स्क्वैट्स गहरे होने चाहिए (कूल्हे घुटने से नीचे)।", "ja": "EMOMを完了してください - %lld 分間。スクワットは深く（股関節が膝より下になるように）行ってください。", "ko": "EMOM 완료 - %lld 분. 스쿼트는 깊게 해야 합니다(엉덩이가 무릎 아래로).", "nl": "Voltooi een EMOM - %lld minuten. Squats moeten diep zijn (heupen onder kniehoogte).", "pl": "Ukończ EMOM - %lld minut. Przysiady muszą być głębokie (biodra poniżej kolan).", "pt": "Conclua um EMOM - %lld minutos. Os agachamentos devem ser profundos (quadril abaixo do joelho).", "pt-BR": "Conclua um EMOM - %lld minutos. Os agachamentos devem ser profundos (quadril abaixo do joelho).", "ru": "Выполните EMOM - %lld минут. Приседания должны быть глубокими (таз ниже уровня колен).", "tr": "EMOM tamamlayın - %lld dakika. Squat'lar derin olmalıdır (kalça diz seviyesinin altında).", "zh-Hans": "完成 EMOM - %lld 分钟。深蹲必须够深（臀部低于膝盖）。", "zh-Hant": "完成 EMOM - %lld 分鐘。深蹲必須夠深（臀部低於膝蓋）。"},
    "prog_strength_d6_desc": {"ja": "タイムトライアル！きれいなフォームで %lld ラウンドをできるだけ早く完了してください。目標: 高い心拍数でもテクニックを維持する。", "ko": "시간 기록! 깔끔한 자세로 가능한 한 빨리 %lld 라운드를 완료하세요. 목표: 높은 심박수에서도 기술 유지.", "nl": "Op tijd! Voltooi %lld rondes zo snel mogelijk met een goede vorm. Doel: Techniek behouden bij een hoge hartslag.", "pl": "Na czas! Wykonaj %lld rund jak najszybciej, zachowując dobrą formę. Cel: Utrzymanie techniki przy wysokim tętnie.", "pt": "Por tempo! Conclua %lld rodadas o mais rápido possível com boa forma. Objetivo: Manter a técnica com frequência cardíaca alta.", "pt-BR": "Por tempo! Conclua %lld rodadas o mais rápido possível com boa forma. Objetivo: Manter a técnica com frequência cardíaca alta.", "ru": "На время! Выполните %lld раундов как можно быстрее с чистой формой. Цель: Сохранять технику при высоком пульсе.", "zh-Hans": "计时！以标准姿势尽可能快地完成 %lld 轮。目标：在高心率下保持技巧。", "zh-Hant": "計時！以標準姿勢盡可能快地完成 %lld 輪。目標：在高心率下保持技巧。"},
    "prog_strength_d6_t1": {"ja": "エクササイズ: %lld バーピー", "ko": "운동: %lld 버피", "nl": "Oefening: %lld Burpees", "pl": "Ćwiczenie: %lld Burpee", "pt": "Exercício: %lld Burpees", "pt-BR": "Exercício: %lld Burpees", "ru": "Упражнение: %lld Берпи", "tr": "Egzersiz: %lld Burpee", "zh-Hans": "练习: %lld 波比跳", "zh-Hant": "練習: %lld 波比跳"},
    "prog_strength_d6_t2": {"ja": "エクササイズ: %@ ランニング", "ko": "운동: %@ 달리기", "nl": "Oefening: %@ Hardlopen", "pl": "Ćwiczenie: %@ Bieg", "pt": "Exercício: %@ Corrida", "pt-BR": "Exercício: %@ Corrida", "ru": "Упражнение: %@ Бег", "tr": "Egzersiz: %@ Koşu", "zh-Hans": "练习: %@ 跑步", "zh-Hant": "練習: %@ 跑步"},
    "prog_strength_neg_liegestuetze": {"ko": "%lld 네거티브 푸시업", "nl": "%lld Negatieve push-ups", "pl": "%lld Negatywne pompki", "pt": "%lld Flexões negativas", "pt-BR": "%lld Flexões negativas", "ru": "%lld Негативных отжиманий", "tr": "%lld Negatif şınav", "zh-Hans": "%lld 退让性俯卧撑", "zh-Hant": "%lld 退讓性俯臥撐"},
    "prog_strength_phase1_desc": {"nl": "Fundament & Basisopbouw"},
    "prog_strength_pull_norm": {"nl": "%lld Pull-ups"},
    "prog_strength_rounds": {"hi": "%lld राउंड पूरे किए", "ja": "%lld ラウンド完了", "ko": "%lld 라운드 완료됨", "nl": "%lld rondes voltooid", "pl": "Ukończono %lld rund", "pt": "%lld rodadas concluídas", "pt-BR": "%lld rodadas concluídas", "ru": "%lld раундов завершено", "tr": "%lld tur tamamlandı", "zh-Hans": "已完成 %lld 轮", "zh-Hant": "已完成 %lld 輪"},
    "prog_water_d5_title": {"hi": "विज़ुअलाइज़ेशन"},
    "Riboflavin": {"tr": "Riboflavin"},
    "screentime_suggestions_title": {"fr": "Suggestions"},
    "settings.notifications": {"fr": "Notifications"},
    "shop.item.description": {"fr": "Description"},
    "sleep.routine.insight.excellent": {"hi": "बढ़िया, इसे जारी रखें! आपकी नींद की दिनचर्या उत्कृष्ट है। औसतन आप %@ बजे बिस्तर पर जाते हैं। 8 घंटे की नींद पाने के लिए, आपको %@ बजे उठना चाहिए。", "pl": "Super, tak trzymaj! Twoja rutyna snu jest doskonała. Średnio kładziesz się spać o %@. Aby przespać 8 godzin, powinieneś wstać o %@.", "tr": "Harika, lütfen böyle devam edin! Uyku rutininiz mükemmel. Ortalama olarak saat %@'de yatıyorsunuz. 8 saat uyumak için %@'de kalkmalısınız."},
    "sleep.routine.insight.needs_work": {"hi": "आपको इस पर काम करने की जरूरत है। आपको नींद की दिनचर्या चाहिए। औसतन आप %@ बजे बिस्तर पर जाते हैं। 8 घंटे की नींद पाने के लिए, आपको %@ बजे उठना चाहिए。", "pl": "Musisz nad tym popracować. Potrzebujesz rutyny snu. Średnio kładziesz się spać o %@. Aby przespać 8 godzin, powinieneś wstać o %@.", "tr": "Bunun üzerinde çalışmalısınız. Bir uyku rutinine ihtiyacınız var. Ortalama olarak saat %@'de yatıyorsunuz. 8 saat uyumak için %@'de kalkmalısınız."},
    "sleep.routine.insight.specific_day": {"pl": "Musisz nad tym popracować. Szczególnie w %@ kładziesz się spać nieregularnie. Średnio kładziesz się spać o %@. Aby przespać 8 godzin, powinieneś wstać o %@.", "tr": "Bunun üzerinde çalışmalısınız. Özellikle %@ günü düzensiz yatıyorsunuz. Ortalama olarak saat %@'de yatıyorsunuz. 8 saat uyumak için %@'de kalkmalısınız."},
    "sleep.routine.insight.weekend": {"hi": "आपको इस पर काम करने की जरूरत है। विशेषकर सप्ताहांत पर आप अनियमित समय पर बिस्तर पर जाते हैं। औसतन आप %@ बजे बिस्तर पर जाते हैं। 8 घंटे की नींद पाने के लिए, आपको %@ बजे उठना चाहिए。", "pl": "Musisz nad tym popracować. Zwłaszcza w weekendy kładziesz się spać nieregularnie. Średnio kładziesz się spać o %@. Aby przespać 8 godzin, powinieneś wstać o %@.", "tr": "Bunun üzerinde çalışmalısınız. Özellikle hafta sonları düzensiz yatıyorsunuz. Ortalama olarak saat %@'de yatıyorsunuz. 8 saat uyumak için %@'de kalkmalısınız."},
    "stats.score.focus.period_format": {"nl": "Focus in %@"},
    "streak.lost": {"nl": "Streak verloren"},
    "streak.motivation.%lld": {"it": "streak.motivation.%lld"},
    "support.description": {"fr": "Description"},
    "todos.tab.general": {"pt": "Tarefas Gerais", "pt-BR": "Tarefas Gerais"},
    "verlauf.analysis.subtitle": {"ko": "습관 분석", "ru": "Анализ привычки", "zh-Hans": "习惯分析", "zh-Hant": "習慣分析"},
    "water.goal.base": {"nl": "Basisbehoefte"},
    "weekly_report.card.focus_time.value": {"nl": "%lld minuten"},
    "weekly_report.chart.focus_time.value": {"nl": "%lld minuten"},
    "widget_interactive_routine_title": {"fr": "Routine (Pro)", "it": "Routine (Pro)"},
    "xp_bis_naechste": {"ko": "%1$@ 까지 %2$d XP"}
}

applied_count = 0
for key, locs in translations.items():
    if key in data["strings"]:
        for lang, val in locs.items():
            if lang in data["strings"][key]["localizations"]:
                data["strings"][key]["localizations"][lang]["stringUnit"]["value"] = val
                applied_count += 1

print(f"Applied {applied_count} highly curated AI translations successfully.")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
