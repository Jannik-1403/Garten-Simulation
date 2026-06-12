#!/usr/bin/env python3
"""Add specific tips for each bad habit to all 11 language Localizable.strings files."""

import os
import glob

# Specific tips for each trash habit (4 tips each, based on the 4 laws)
# Format: habit_id -> { lang: [tip1, tip2, tip3, tip4] }
# tip1 = Make it invisible (eye.slash.fill)
# tip2 = Make it unattractive (heart.slash.fill) 
# tip3 = Make it difficult (lock.fill)
# tip4 = Make it unsatisfying (hand.thumbsdown.fill)

TIPS = {
    "trash.fast_food_abo": {
        "de": [
            "Entferne alle Fast-Food-Apps von deinem Handy und lösche gespeicherte Lieferadressen.",
            "Schau dir Dokumentationen über die Herstellung von Fast Food an – was wirklich in den Produkten steckt.",
            "Koche am Wochenende gesunde Mahlzeiten vor (Meal Prep), damit du immer eine Alternative griffbereit hast.",
            "Berechne, wie viel Geld du monatlich für Fast Food ausgibst, und lege diesen Betrag sichtbar beiseite."
        ],
        "en": [
            "Delete all fast food apps from your phone and remove saved delivery addresses.",
            "Watch documentaries about how fast food is made – what really goes into those products.",
            "Meal prep healthy food on weekends so you always have a ready alternative.",
            "Calculate how much you spend monthly on fast food and visibly set that money aside."
        ],
        "es": [
            "Elimina todas las apps de comida rápida de tu teléfono y borra las direcciones de entrega guardadas.",
            "Mira documentales sobre cómo se fabrica la comida rápida – lo que realmente contienen esos productos.",
            "Prepara comidas saludables los fines de semana para tener siempre una alternativa lista.",
            "Calcula cuánto gastas al mes en comida rápida y aparta visiblemente ese dinero."
        ],
        "fr": [
            "Supprime toutes les applications de fast-food de ton téléphone et efface les adresses de livraison enregistrées.",
            "Regarde des documentaires sur la fabrication du fast-food – ce qu'il y a vraiment dans ces produits.",
            "Prépare des repas sains le week-end pour toujours avoir une alternative prête.",
            "Calcule combien tu dépenses par mois en fast-food et mets cet argent de côté visiblement."
        ],
        "it": [
            "Elimina tutte le app di fast food dal telefono e cancella gli indirizzi di consegna salvati.",
            "Guarda documentari su come viene prodotto il fast food – cosa contengono davvero quei prodotti.",
            "Prepara pasti sani nel fine settimana per avere sempre un'alternativa pronta.",
            "Calcola quanto spendi al mese per il fast food e metti visibilmente da parte quei soldi."
        ],
        "ja": [
            "スマホからファストフードアプリをすべて削除し、保存された配達先を消去しましょう。",
            "ファストフードの製造過程に関するドキュメンタリーを見てみましょう。",
            "週末にヘルシーな食事を作り置きして、いつでも代替策を用意しましょう。",
            "月にファストフードにいくら使っているか計算し、その金額を目に見える形で貯めましょう。"
        ],
        "ko": [
            "휴대폰에서 패스트푸드 앱을 모두 삭제하고 저장된 배달 주소를 제거하세요.",
            "패스트푸드가 어떻게 만들어지는지 다큐멘터리를 시청하세요.",
            "주말에 건강한 식사를 미리 준비해서 항상 대안을 갖춰두세요.",
            "매달 패스트푸드에 얼마를 쓰는지 계산하고 그 금액을 눈에 보이게 모아두세요."
        ],
        "nl": [
            "Verwijder alle fastfood-apps van je telefoon en wis opgeslagen bezorgadressen.",
            "Bekijk documentaires over hoe fastfood wordt gemaakt – wat er echt in die producten zit.",
            "Bereid in het weekend gezonde maaltijden voor zodat je altijd een alternatief bij de hand hebt.",
            "Bereken hoeveel je maandelijks aan fastfood uitgeeft en leg dat bedrag zichtbaar opzij."
        ],
        "pl": [
            "Usuń wszystkie aplikacje fast food z telefonu i skasuj zapisane adresy dostawy.",
            "Obejrzyj dokumenty o tym, jak powstaje fast food – co naprawdę jest w tych produktach.",
            "Przygotuj zdrowe posiłki w weekend, żebyś zawsze miał alternatywę pod ręką.",
            "Oblicz, ile wydajesz miesięcznie na fast food i odłóż tę kwotę widocznie na bok."
        ],
        "pt": [
            "Apague todos os apps de fast food do celular e remova endereços de entrega salvos.",
            "Assista documentários sobre como o fast food é feito – o que realmente tem nesses produtos.",
            "Prepare refeições saudáveis no fim de semana para ter sempre uma alternativa pronta.",
            "Calcule quanto gasta por mês com fast food e separe visivelmente esse dinheiro."
        ],
        "tr": [
            "Telefonundan tüm fast food uygulamalarını sil ve kayıtlı teslimat adreslerini kaldır.",
            "Fast food'un nasıl üretildiğine dair belgeseller izle – bu ürünlerde gerçekten ne var.",
            "Hafta sonları sağlıklı yemekler hazırla, böylece her zaman hazır bir alternatifin olsun.",
            "Aylık fast food'a ne kadar harcadığını hesapla ve o parayı görünür şekilde kenara koy."
        ]
    },
    "trash.endlos_scroll_tv": {
        "de": [
            "Stelle dein Handy nachts in einen anderen Raum und deaktiviere Push-Benachrichtigungen von Social Media.",
            "Ersetze 10 Minuten Scrollen durch eine kurze Achtsamkeitsübung oder Lesen – spüre den Unterschied.",
            "Setze App-Timer (z.B. 30 Min/Tag) für Social Media und aktiviere den Graustufen-Modus auf deinem Handy.",
            "Notiere dir nach jeder Scroll-Session, wie du dich fühlst – meistens schlechter als vorher."
        ],
        "en": [
            "Put your phone in another room at night and disable push notifications from social media.",
            "Replace 10 minutes of scrolling with a short mindfulness exercise or reading – feel the difference.",
            "Set app timers (e.g. 30 min/day) for social media and enable grayscale mode on your phone.",
            "Write down how you feel after each scrolling session – usually worse than before."
        ],
        "es": [
            "Pon tu teléfono en otra habitación por la noche y desactiva las notificaciones de redes sociales.",
            "Reemplaza 10 minutos de scroll por un breve ejercicio de mindfulness o lectura.",
            "Configura temporizadores de apps (ej. 30 min/día) para redes sociales y activa el modo escala de grises.",
            "Anota cómo te sientes después de cada sesión de scroll – generalmente peor que antes."
        ],
        "fr": [
            "Mets ton téléphone dans une autre pièce la nuit et désactive les notifications des réseaux sociaux.",
            "Remplace 10 minutes de scroll par un court exercice de pleine conscience ou de lecture.",
            "Mets des minuteries d'apps (ex: 30 min/jour) pour les réseaux sociaux et active le mode niveaux de gris.",
            "Note comment tu te sens après chaque session de scroll – en général pire qu'avant."
        ],
        "it": [
            "Metti il telefono in un'altra stanza di notte e disattiva le notifiche dei social media.",
            "Sostituisci 10 minuti di scrolling con un breve esercizio di mindfulness o lettura.",
            "Imposta timer per le app (es. 30 min/giorno) per i social e attiva la modalità scala di grigi.",
            "Annota come ti senti dopo ogni sessione di scrolling – di solito peggio di prima."
        ],
        "ja": [
            "夜はスマホを別の部屋に置き、SNSのプッシュ通知をオフにしましょう。",
            "10分間のスクロールを短いマインドフルネスや読書に置き換えて、違いを感じましょう。",
            "SNSにアプリタイマー（例：1日30分）を設定し、グレースケールモードを有効にしましょう。",
            "スクロール後の気分を記録しましょう。ほとんどの場合、以前より悪くなっています。"
        ],
        "ko": [
            "밤에는 휴대폰을 다른 방에 두고 소셜 미디어 푸시 알림을 비활성화하세요.",
            "10분 스크롤을 짧은 마음챙김 운동이나 독서로 대체하세요.",
            "소셜 미디어에 앱 타이머(예: 하루 30분)를 설정하고 흑백 모드를 활성화하세요.",
            "스크롤 후 기분을 적어보세요 – 대부분 이전보다 나빠집니다."
        ],
        "nl": [
            "Leg je telefoon 's nachts in een andere kamer en schakel pushnotificaties van social media uit.",
            "Vervang 10 minuten scrollen door een korte mindfulness-oefening of lezen.",
            "Stel app-timers in (bijv. 30 min/dag) voor social media en schakel de grijstintenmodus in.",
            "Schrijf op hoe je je voelt na elke scrollsessie – meestal slechter dan daarvoor."
        ],
        "pl": [
            "Na noc odłóż telefon do innego pokoju i wyłącz powiadomienia push z mediów społecznościowych.",
            "Zamień 10 minut scrollowania na krótkie ćwiczenie uważności lub czytanie.",
            "Ustaw timery aplikacji (np. 30 min/dzień) dla mediów społecznościowych i włącz tryb szarości.",
            "Zapisuj, jak się czujesz po każdej sesji scrollowania – zwykle gorzej niż przedtem."
        ],
        "pt": [
            "Coloque o celular em outro cômodo à noite e desative notificações de redes sociais.",
            "Substitua 10 minutos de scroll por um exercício de mindfulness ou leitura.",
            "Defina timers de apps (ex: 30 min/dia) para redes sociais e ative o modo tons de cinza.",
            "Anote como se sente após cada sessão de scroll – geralmente pior do que antes."
        ],
        "tr": [
            "Gece telefonunu başka bir odaya koy ve sosyal medya bildirimlerini kapat.",
            "10 dakikalık scroll'u kısa bir farkındalık egzersizi veya okuma ile değiştir.",
            "Sosyal medya için uygulama zamanlayıcıları (ör. 30 dk/gün) ayarla ve gri tonlama modunu aç.",
            "Her scroll oturumundan sonra nasıl hissettiğini yaz – genellikle öncekinden daha kötü."
        ]
    },
    "trash.luxus_auto": {
        "de": [
            "Entfolge Luxus-Influencern und Autokanälen auf Social Media.",
            "Erinnere dich: Die meisten Luxusgüter verlieren schnell an Wert und bringen keine langfristige Zufriedenheit.",
            "Erstelle ein 30-Tage-Warte-Regel für große Ausgaben – wenn du es nach 30 Tagen noch willst, überdenke es erneut.",
            "Berechne, wie viele Stunden Arbeit nötig sind, um einen Luxuskauf zu finanzieren."
        ],
        "en": [
            "Unfollow luxury influencers and car channels on social media.",
            "Remember: most luxury goods lose value quickly and don't bring lasting satisfaction.",
            "Create a 30-day waiting rule for big purchases – if you still want it after 30 days, reconsider.",
            "Calculate how many hours of work are needed to fund a luxury purchase."
        ],
        "es": ["Deja de seguir a influencers de lujo y canales de autos en redes sociales.", "Recuerda: la mayoría de los artículos de lujo pierden valor rápidamente y no traen satisfacción duradera.", "Crea una regla de espera de 30 días para compras grandes.", "Calcula cuántas horas de trabajo necesitas para financiar una compra de lujo."],
        "fr": ["Désabonne-toi des influenceurs de luxe et des chaînes automobiles sur les réseaux sociaux.", "Rappelle-toi : la plupart des articles de luxe perdent rapidement de la valeur et n'apportent pas de satisfaction durable.", "Crée une règle d'attente de 30 jours pour les gros achats.", "Calcule combien d'heures de travail sont nécessaires pour financer un achat de luxe."],
        "it": ["Smetti di seguire influencer di lusso e canali auto sui social media.", "Ricorda: la maggior parte dei beni di lusso perde valore rapidamente e non porta soddisfazione duratura.", "Crea una regola di attesa di 30 giorni per i grandi acquisti.", "Calcola quante ore di lavoro servono per finanziare un acquisto di lusso."],
        "ja": ["SNSでラグジュアリー系インフルエンサーや車チャンネルのフォローを解除しましょう。", "思い出してください：ほとんどの高級品はすぐに価値が下がり、長期的な満足をもたらしません。", "大きな買い物には30日ルールを作りましょう。", "贅沢品を購入するのに何時間の労働が必要か計算しましょう。"],
        "ko": ["소셜 미디어에서 럭셔리 인플루언서와 자동차 채널을 언팔로우하세요.", "기억하세요: 대부분의 사치품은 빠르게 가치를 잃고 지속적인 만족을 주지 않습니다.", "큰 지출에 대해 30일 대기 규칙을 만드세요.", "사치품 구매에 몇 시간의 근무가 필요한지 계산하세요."],
        "nl": ["Ontvolg luxe influencers en autokanalen op social media.", "Onthoud: de meeste luxegoederen verliezen snel waarde en brengen geen blijvende voldoening.", "Maak een 30-dagen-wachtregel voor grote uitgaven.", "Bereken hoeveel uren werk nodig zijn om een luxeaankoop te financieren."],
        "pl": ["Przestań obserwować influencerów luksusowych i kanały motoryzacyjne w mediach społecznościowych.", "Pamiętaj: większość dóbr luksusowych szybko traci na wartości i nie daje trwałej satysfakcji.", "Stwórz zasadę 30-dniowego oczekiwania na duże zakupy.", "Oblicz, ile godzin pracy potrzebujesz na sfinansowanie luksusowego zakupu."],
        "pt": ["Deixe de seguir influenciadores de luxo e canais de carros nas redes sociais.", "Lembre-se: a maioria dos bens de luxo perde valor rapidamente e não traz satisfação duradoura.", "Crie uma regra de espera de 30 dias para grandes compras.", "Calcule quantas horas de trabalho são necessárias para financiar uma compra de luxo."],
        "tr": ["Sosyal medyada lüks influencer'ları ve araba kanallarını takipten çık.", "Unutma: çoğu lüks eşya hızla değer kaybeder ve kalıcı tatmin getirmez.", "Büyük harcamalar için 30 günlük bekleme kuralı oluştur.", "Bir lüks alışverişi finanse etmek için kaç saat çalışman gerektiğini hesapla."]
    },
    "trash.party_pass": {
        "de": [
            "Lösche Party-Gruppen und Event-Apps, die dich ständig zu Feiern einladen.",
            "Denke daran, wie du dich am nächsten Morgen fühlst: müde, verkatert und unproduktiv.",
            "Plane am Abend bewusst Alternativen: Spieleabend, Kino, Sport mit Freunden.",
            "Zähle die verlorenen produktiven Stunden am nächsten Tag nach jeder Party."
        ],
        "en": ["Delete party groups and event apps that constantly invite you to go out.", "Think about how you feel the next morning: tired, hungover, and unproductive.", "Plan conscious alternatives for evenings: game night, cinema, sports with friends.", "Count the lost productive hours the day after each party."],
        "es": ["Elimina grupos de fiestas y apps de eventos que te invitan constantemente a salir.", "Piensa en cómo te sientes a la mañana siguiente: cansado, con resaca e improductivo.", "Planifica alternativas conscientes para las noches: juegos, cine, deporte con amigos.", "Cuenta las horas productivas perdidas al día siguiente de cada fiesta."],
        "fr": ["Supprime les groupes de fêtes et les apps d'événements qui t'invitent constamment à sortir.", "Pense à comment tu te sens le lendemain matin : fatigué, avec la gueule de bois et improductif.", "Planifie des alternatives conscientes pour les soirées : soirée jeux, cinéma, sport entre amis.", "Compte les heures productives perdues le lendemain de chaque soirée."],
        "it": ["Elimina gruppi di feste e app di eventi che ti invitano costantemente a uscire.", "Pensa a come ti senti la mattina dopo: stanco, con i postumi e improduttivo.", "Pianifica alternative consapevoli per le serate: serata giochi, cinema, sport con amici.", "Conta le ore produttive perse il giorno dopo ogni festa."],
        "ja": ["常にパーティーに誘うグループやイベントアプリを削除しましょう。", "翌朝の気分を思い出してください：疲れ、二日酔い、非生産的。", "夜の代替案を計画しましょう：ゲームナイト、映画、友人とのスポーツ。", "パーティーの翌日に失われた生産的な時間を数えましょう。"],
        "ko": ["끊임없이 외출을 유도하는 파티 그룹과 이벤트 앱을 삭제하세요.", "다음 날 아침 기분을 생각해보세요: 피곤하고, 숙취가 있고, 비생산적입니다.", "저녁에 의식적인 대안을 계획하세요: 보드게임, 영화, 친구와 운동.", "파티 다음 날 잃어버린 생산적인 시간을 세어보세요."],
        "nl": ["Verwijder feestgroepen en evenement-apps die je constant uitnodigen om uit te gaan.", "Denk aan hoe je je de volgende ochtend voelt: moe, katerig en onproductief.", "Plan bewuste alternatieven voor de avond: spelletjesavond, bioscoop, sport met vrienden.", "Tel de verloren productieve uren de dag na elk feest."],
        "pl": ["Usuń grupy imprezowe i aplikacje eventowe, które ciągle zapraszają cię na wyjścia.", "Pomyśl, jak się czujesz następnego ranka: zmęczony, na kacu i nieproduktywny.", "Zaplanuj świadome alternatywy na wieczór: wieczór gier, kino, sport z przyjaciółmi.", "Policz stracone produktywne godziny następnego dnia po każdej imprezie."],
        "pt": ["Apague grupos de festas e apps de eventos que te convidam constantemente para sair.", "Pense em como se sente na manhã seguinte: cansado, de ressaca e improdutivo.", "Planeje alternativas conscientes para as noites: jogos, cinema, esporte com amigos.", "Conte as horas produtivas perdidas no dia seguinte a cada festa."],
        "tr": ["Seni sürekli dışarı çıkmaya davet eden parti gruplarını ve etkinlik uygulamalarını sil.", "Ertesi sabah nasıl hissettiğini düşün: yorgun, akşamdan kalma ve verimsiz.", "Akşamlar için bilinçli alternatifler planla: oyun gecesi, sinema, arkadaşlarla spor.", "Her partiden sonraki gün kaybedilen verimli saatleri say."]
    },
    "trash.energy_drink_kiste": {
        "de": [
            "Kaufe keine Energy Drinks auf Vorrat – wenn sie nicht zuhause sind, trinkst du sie nicht.",
            "Lies die Zutatenliste: Übermäßig viel Zucker und Koffein belasten Herz und Schlaf.",
            "Ersetze Energy Drinks durch grünen Tee oder Wasser mit Zitrone als Energiequelle.",
            "Tracke deine Schlafqualität – du wirst sehen, wie sehr Energy Drinks deinen Schlaf zerstören."
        ],
        "en": ["Don't stock up on energy drinks – if they're not at home, you won't drink them.", "Read the ingredients: excessive sugar and caffeine strain your heart and sleep.", "Replace energy drinks with green tea or lemon water as an energy source.", "Track your sleep quality – you'll see how much energy drinks destroy your sleep."],
        "es": ["No compres bebidas energéticas de reserva – si no están en casa, no las beberás.", "Lee los ingredientes: el exceso de azúcar y cafeína daña tu corazón y sueño.", "Reemplaza las bebidas energéticas con té verde o agua con limón.", "Registra tu calidad de sueño – verás cuánto las bebidas energéticas destruyen tu descanso."],
        "fr": ["N'achète pas de boissons énergisantes en stock – si elles ne sont pas chez toi, tu ne les boiras pas.", "Lis les ingrédients : trop de sucre et de caféine fatiguent le cœur et perturbent le sommeil.", "Remplace les boissons énergisantes par du thé vert ou de l'eau citronnée.", "Suis la qualité de ton sommeil – tu verras à quel point les boissons énergisantes le détruisent."],
        "it": ["Non fare scorta di energy drink – se non sono a casa, non li berrai.", "Leggi gli ingredienti: troppo zucchero e caffeina mettono sotto stress cuore e sonno.", "Sostituisci gli energy drink con tè verde o acqua e limone.", "Monitora la qualità del sonno – vedrai quanto gli energy drink la rovinano."],
        "ja": ["エナジードリンクを買いだめしないこと。家になければ飲みません。", "成分表を読みましょう：過剰な糖分とカフェインは心臓と睡眠に負担をかけます。", "エナジードリンクを緑茶やレモン水に置き換えましょう。", "睡眠の質を追跡しましょう。エナジードリンクがどれだけ睡眠を壊すか分かります。"],
        "ko": ["에너지 드링크를 사재기하지 마세요 – 집에 없으면 마시지 않습니다.", "성분표를 읽어보세요: 과도한 설탕과 카페인은 심장과 수면에 부담을 줍니다.", "에너지 드링크를 녹차나 레몬수로 대체하세요.", "수면 품질을 추적하세요 – 에너지 드링크가 수면을 얼마나 해치는지 알 수 있습니다."],
        "nl": ["Koop geen energiedrankjes op voorraad – als ze niet thuis zijn, drink je ze niet.", "Lees de ingrediënten: overmatig suiker en cafeïne belasten je hart en slaap.", "Vervang energiedrankjes door groene thee of water met citroen.", "Volg je slaapkwaliteit – je zult zien hoeveel energiedrankjes je slaap verstoren."],
        "pl": ["Nie kupuj napojów energetycznych na zapas – jeśli ich nie ma w domu, nie będziesz pić.", "Przeczytaj skład: nadmiar cukru i kofeiny obciąża serce i sen.", "Zastąp napoje energetyczne zieloną herbatą lub wodą z cytryną.", "Śledź jakość snu – zobaczysz, jak bardzo napoje energetyczne niszczą twój sen."],
        "pt": ["Não estoque energéticos – se não estiverem em casa, você não vai beber.", "Leia os ingredientes: excesso de açúcar e cafeína sobrecarregam coração e sono.", "Substitua energéticos por chá verde ou água com limão.", "Acompanhe a qualidade do sono – você verá como os energéticos destroem seu descanso."],
        "tr": ["Enerji içeceklerini stokta tutma – evde yoksa içmezsin.", "İçindekiler listesini oku: aşırı şeker ve kafein kalbe ve uykuya zarar verir.", "Enerji içeceklerini yeşil çay veya limonlu su ile değiştir.", "Uyku kaliteni takip et – enerji içeceklerinin uykunu ne kadar bozduğunu göreceksin."]
    },
    "trash.zigaretten_automat": {
        "de": [
            "Meide Orte, an denen du normalerweise rauchst, und entferne alle Aschenbecher und Feuerzeuge.",
            "Sieh dir Bilder von Raucherorganen an – das ist das, was du deinem Körper antust.",
            "Ersetze den Griff zur Zigarette durch einen Spaziergang, Kaugummi oder tiefes Atmen.",
            "Berechne die jährlichen Kosten deines Rauchens und stell dir vor, was du damit kaufen könntest."
        ],
        "en": ["Avoid places where you normally smoke and remove all ashtrays and lighters.", "Look at pictures of smoker organs – that's what you're doing to your body.", "Replace reaching for a cigarette with a walk, gum, or deep breathing.", "Calculate the annual cost of your smoking and imagine what you could buy with it."],
        "es": ["Evita los lugares donde normalmente fumas y elimina todos los ceniceros y encendedores.", "Mira fotos de órganos de fumadores – eso es lo que le haces a tu cuerpo.", "Reemplaza el gesto de fumar con un paseo, chicle o respiración profunda.", "Calcula el costo anual de fumar e imagina qué podrías comprar con ese dinero."],
        "fr": ["Évite les endroits où tu fumes habituellement et retire tous les cendriers et briquets.", "Regarde des images d'organes de fumeurs – c'est ce que tu fais à ton corps.", "Remplace le geste de fumer par une marche, un chewing-gum ou une respiration profonde.", "Calcule le coût annuel de ta cigarette et imagine ce que tu pourrais acheter avec."],
        "it": ["Evita i luoghi dove fumi di solito e rimuovi tutti i posacenere e accendini.", "Guarda foto di organi di fumatori – è quello che stai facendo al tuo corpo.", "Sostituisci il gesto di fumare con una passeggiata, gomma da masticare o respirazione profonda.", "Calcola il costo annuale del fumo e immagina cosa potresti comprare."],
        "ja": ["普段喫煙する場所を避け、灰皿やライターをすべて撤去しましょう。", "喫煙者の臓器の写真を見てみましょう。それがあなたの体にしていることです。", "タバコに手を伸ばす代わりに、散歩、ガム、深呼吸をしましょう。", "喫煙の年間コストを計算し、そのお金で何が買えるか想像しましょう。"],
        "ko": ["평소 담배를 피우는 장소를 피하고 모든 재떨이와 라이터를 제거하세요.", "흡연자 장기 사진을 보세요 – 그것이 당신의 몸에 하는 일입니다.", "담배 대신 산책, 껌, 심호흡으로 대체하세요.", "흡연의 연간 비용을 계산하고 그 돈으로 무엇을 살 수 있을지 상상하세요."],
        "nl": ["Vermijd plekken waar je normaal rookt en verwijder alle asbakken en aanstekers.", "Bekijk foto's van rokersorganen – dat is wat je je lichaam aandoet.", "Vervang het grijpen naar een sigaret door een wandeling, kauwgom of diepe ademhaling.", "Bereken de jaarlijkse kosten van je roken en stel je voor wat je ermee zou kunnen kopen."],
        "pl": ["Unikaj miejsc, gdzie zwykle palisz, i usuń wszystkie popielniczki i zapalniczki.", "Obejrzyj zdjęcia organów palaczy – to jest to, co robisz swojemu ciału.", "Zamień sięganie po papierosa na spacer, gumę do żucia lub głębokie oddychanie.", "Oblicz roczne koszty palenia i wyobraź sobie, co mógłbyś za to kupić."],
        "pt": ["Evite locais onde normalmente fuma e remova todos os cinzeiros e isqueiros.", "Veja fotos de órgãos de fumantes – é isso que você está fazendo ao seu corpo.", "Substitua pegar um cigarro por uma caminhada, chiclete ou respiração profunda.", "Calcule o custo anual do seu tabagismo e imagine o que poderia comprar."],
        "tr": ["Normalde sigara içtiğin yerlere gitme ve tüm küllükleri ve çakmakları kaldır.", "Sigara içenlerin organ fotoğraflarına bak – vücuduna bunu yapıyorsun.", "Sigara yerine yürüyüş, sakız veya derin nefes almayı dene.", "Sigaranın yıllık maliyetini hesapla ve o parayla ne alabileceğini hayal et."]
    },
    "trash.online_shopping_app": {
        "de": [
            "Lösche Shopping-Apps und deaktiviere Werbe-E-Mails und Newsletter von Online-Shops.",
            "Frage dich bei jedem Kauf: Brauche ich das wirklich oder will ich nur den Dopamin-Kick?",
            "Entferne gespeicherte Kreditkarten aus Online-Shops, damit jeder Kauf bewusst sein muss.",
            "Lass ungeöffnete Pakete 48 Stunden liegen – wenn du sie dann noch willst, behalte sie."
        ],
        "en": ["Delete shopping apps and unsubscribe from promotional emails and newsletters.", "Ask yourself with every purchase: do I really need this or do I just want the dopamine hit?", "Remove saved credit cards from online shops so every purchase requires conscious effort.", "Leave unopened packages for 48 hours – if you still want them, keep them."],
        "es": ["Elimina las apps de compras y cancela los correos promocionales y newsletters.", "Pregúntate con cada compra: ¿realmente lo necesito o solo quiero el golpe de dopamina?", "Elimina las tarjetas guardadas de las tiendas online para que cada compra sea consciente.", "Deja los paquetes sin abrir 48 horas – si aún los quieres, quédatelos."],
        "fr": ["Supprime les apps de shopping et désabonne-toi des e-mails promotionnels.", "Demande-toi à chaque achat : en ai-je vraiment besoin ou est-ce juste pour le shot de dopamine ?", "Retire les cartes bancaires enregistrées des boutiques en ligne.", "Laisse les colis non ouverts pendant 48h – si tu les veux encore, garde-les."],
        "it": ["Elimina le app di shopping e cancellati dalle email promozionali.", "Chiediti ad ogni acquisto: ne ho davvero bisogno o voglio solo il colpo di dopamina?", "Rimuovi le carte salvate dai negozi online per rendere ogni acquisto consapevole.", "Lascia i pacchi non aperti per 48 ore – se li vuoi ancora, tienili."],
        "ja": ["ショッピングアプリを削除し、プロモーションメールの配信を停止しましょう。", "買い物のたびに自問しましょう：本当に必要？それともドーパミンが欲しいだけ？", "オンラインショップから保存済みクレジットカードを削除しましょう。", "未開封のパッケージを48時間置いてみましょう。まだ欲しければ、保管しましょう。"],
        "ko": ["쇼핑 앱을 삭제하고 프로모션 이메일과 뉴스레터를 구독 취소하세요.", "매 구매마다 자문하세요: 정말 필요한가, 아니면 도파민 쾌감을 원하는 건가?", "온라인 상점에서 저장된 카드를 제거해 모든 구매를 의식적으로 만드세요.", "미개봉 택배를 48시간 두세요 – 그래도 원하면 보관하세요."],
        "nl": ["Verwijder shopping-apps en meld je af voor promotionele e-mails.", "Vraag jezelf bij elke aankoop: heb ik dit echt nodig of wil ik alleen de dopamine-kick?", "Verwijder opgeslagen creditcards uit webwinkels.", "Laat ongeopende pakketjes 48 uur liggen – als je ze dan nog wilt, houd ze."],
        "pl": ["Usuń aplikacje zakupowe i wypisz się z promocyjnych e-maili.", "Zapytaj siebie przy każdym zakupie: czy tego naprawdę potrzebuję, czy chcę tylko zastrzyk dopaminy?", "Usuń zapisane karty z sklepów internetowych.", "Zostaw nieotwarte paczki na 48 godzin – jeśli nadal je chcesz, zatrzymaj."],
        "pt": ["Apague apps de compras e cancele e-mails promocionais e newsletters.", "Pergunte-se a cada compra: realmente preciso disso ou só quero o hit de dopamina?", "Remova cartões salvos das lojas online para que cada compra exija esforço consciente.", "Deixe pacotes fechados por 48 horas – se ainda quiser, fique com eles."],
        "tr": ["Alışveriş uygulamalarını sil ve promosyon e-postalarından çık.", "Her alışverişte kendine sor: buna gerçekten ihtiyacım var mı yoksa sadece dopamin mi istiyorum?", "Online mağazalardan kayıtlı kredi kartlarını kaldır.", "Açılmamış paketleri 48 saat beklet – hala istiyorsan, sakla."]
    },
    "trash.junk_mail_abo": {
        "de": [
            "Deaktiviere alle unnötigen E-Mail-Benachrichtigungen und Newsletter sofort.",
            "Jede Spam-Mail kostet dich 30 Sekunden Aufmerksamkeit – hochgerechnet sind das Stunden pro Monat.",
            "Nutze einen E-Mail-Filter oder eine App wie Unroll.me, um Abos automatisch zu verwalten.",
            "Setze feste Zeiten zum E-Mail-Checken (z.B. 2x täglich) statt ständig zu reagieren."
        ],
        "en": ["Unsubscribe from all unnecessary email notifications and newsletters immediately.", "Every spam email costs you 30 seconds of attention – that adds up to hours per month.", "Use an email filter or app like Unroll.me to manage subscriptions automatically.", "Set fixed times for checking email (e.g. twice daily) instead of constantly reacting."],
        "es": ["Cancela todas las notificaciones de correo innecesarias y newsletters de inmediato.", "Cada correo spam te cuesta 30 segundos de atención – eso suma horas al mes.", "Usa un filtro de correo o una app para gestionar suscripciones automáticamente.", "Fija horarios para revisar el correo (ej. 2 veces al día) en vez de reaccionar constantemente."],
        "fr": ["Désabonne-toi de toutes les notifications email et newsletters inutiles immédiatement.", "Chaque spam te coûte 30 secondes d'attention – ça fait des heures par mois.", "Utilise un filtre email ou une app pour gérer automatiquement tes abonnements.", "Fixe des horaires pour vérifier tes emails (ex: 2 fois par jour) au lieu de réagir constamment."],
        "it": ["Cancellati da tutte le notifiche email e newsletter inutili immediatamente.", "Ogni email spam ti costa 30 secondi di attenzione – in totale sono ore al mese.", "Usa un filtro email o un'app per gestire automaticamente gli abbonamenti.", "Imposta orari fissi per controllare le email (es. 2 volte al giorno) invece di reagire costantemente."],
        "ja": ["不要なメール通知やニュースレターからすぐに配信停止しましょう。", "スパムメール1通で30秒の注意力を奪われます。月に換算すると何時間にもなります。", "メールフィルターやアプリを使って購読を自動管理しましょう。", "メールチェックの時間を決めましょう（例：1日2回）。常に反応するのをやめましょう。"],
        "ko": ["불필요한 이메일 알림과 뉴스레터를 즉시 구독 취소하세요.", "스팸 메일 하나에 30초의 주의력이 소요됩니다 – 한 달이면 몇 시간입니다.", "이메일 필터나 앱을 사용해 구독을 자동으로 관리하세요.", "이메일 확인 시간을 정하세요(예: 하루 2번). 계속 반응하는 것을 멈추세요."],
        "nl": ["Schrijf je meteen uit voor alle onnodige e-mailnotificaties en nieuwsbrieven.", "Elke spam-mail kost je 30 seconden aandacht – dat telt op tot uren per maand.", "Gebruik een e-mailfilter of app om abonnementen automatisch te beheren.", "Stel vaste tijden in om e-mail te checken (bijv. 2x per dag) in plaats van constant te reageren."],
        "pl": ["Natychmiast wypisz się ze wszystkich niepotrzebnych powiadomień e-mail i newsletterów.", "Każdy spam kosztuje cię 30 sekund uwagi – to godziny miesięcznie.", "Użyj filtra e-mail lub aplikacji do automatycznego zarządzania subskrypcjami.", "Ustal stałe pory na sprawdzanie maili (np. 2x dziennie) zamiast ciągłego reagowania."],
        "pt": ["Cancele todas as notificações de email e newsletters desnecessárias imediatamente.", "Cada email spam custa 30 segundos de atenção – isso soma horas por mês.", "Use um filtro de email ou app para gerenciar inscrições automaticamente.", "Defina horários fixos para verificar emails (ex: 2x por dia) em vez de reagir constantemente."],
        "tr": ["Tüm gereksiz e-posta bildirimlerini ve bültenleri hemen iptal et.", "Her spam e-posta 30 saniyelik dikkatine mal olur – ayda saatlere denk gelir.", "Abonelikleri otomatik yönetmek için e-posta filtresi veya uygulama kullan.", "E-posta kontrolü için sabit saatler belirle (ör. günde 2 kez)."]
    },
    "trash.nacht_snack_box": {
        "de": [
            "Räume alle Snacks aus dem Schlafzimmer und der Küche weg, damit sie nicht sichtbar sind.",
            "Nächtliches Essen stört deinen Schlaf und führt zu Gewichtszunahme – dein Körper braucht nachts Ruhe.",
            "Putze nach dem Abendessen die Zähne – das signalisiert deinem Gehirn: Essen ist vorbei.",
            "Führe ein Snack-Tagebuch: Schreib auf, was du wann isst, und erkenne die Muster."
        ],
        "en": ["Remove all snacks from the bedroom and kitchen so they're not visible.", "Night eating disrupts sleep and causes weight gain – your body needs rest at night.", "Brush your teeth after dinner – it signals your brain: eating is done.", "Keep a snack journal: write down what you eat and when, and recognize patterns."],
        "es": ["Retira todos los snacks del dormitorio y la cocina para que no estén visibles.", "Comer de noche altera el sueño y causa aumento de peso – tu cuerpo necesita descanso.", "Lávate los dientes después de cenar – le señala a tu cerebro que ya terminaste de comer.", "Lleva un diario de snacks: anota qué comes y cuándo, y reconoce los patrones."],
        "fr": ["Retire tous les snacks de la chambre et de la cuisine pour qu'ils ne soient pas visibles.", "Manger la nuit perturbe le sommeil et fait prendre du poids – ton corps a besoin de repos.", "Brosse-toi les dents après le dîner – ça signale à ton cerveau que c'est fini.", "Tiens un journal de snacks : note ce que tu manges et quand, et identifie les schémas."],
        "it": ["Togli tutti gli snack dalla camera e dalla cucina per non vederli.", "Mangiare di notte disturba il sonno e fa ingrassare – il corpo ha bisogno di riposo.", "Lavati i denti dopo cena – segnala al cervello che hai finito di mangiare.", "Tieni un diario degli snack: annota cosa mangi e quando, e riconosci i pattern."],
        "ja": ["寝室やキッチンからスナックをすべて片付けて、見えないようにしましょう。", "夜食は睡眠を妨げ、体重増加につながります。体は夜に休息が必要です。", "夕食後に歯を磨きましょう。脳に「食事は終わり」と信号を送ります。", "スナック日記をつけましょう：いつ何を食べたか記録し、パターンを認識しましょう。"],
        "ko": ["침실과 부엌에서 모든 간식을 치워 보이지 않게 하세요.", "야식은 수면을 방해하고 체중 증가를 유발합니다.", "저녁 식사 후 양치하세요 – 뇌에 '식사 끝' 신호를 보냅니다.", "간식 일기를 쓰세요: 무엇을 언제 먹었는지 기록하고 패턴을 인식하세요."],
        "nl": ["Haal alle snacks uit de slaapkamer en keuken zodat ze niet zichtbaar zijn.", "Nachtelijk eten verstoort je slaap en veroorzaakt gewichtstoename.", "Poets je tanden na het avondeten – dat signaleert je brein: eten is klaar.", "Houd een snackdagboek bij: schrijf op wat je eet en wanneer, en herken patronen."],
        "pl": ["Usuń wszystkie przekąski z sypialni i kuchni, żeby nie były widoczne.", "Jedzenie nocne zaburza sen i prowadzi do przytycia.", "Myj zęby po kolacji – to sygnał dla mózgu, że jedzenie się skończyło.", "Prowadź dziennik przekąsek: zapisuj co i kiedy jesz, i rozpoznawaj wzorce."],
        "pt": ["Retire todos os lanches do quarto e cozinha para não ficarem visíveis.", "Comer à noite atrapalha o sono e causa ganho de peso.", "Escove os dentes após o jantar – sinaliza ao cérebro que a alimentação acabou.", "Mantenha um diário de lanches: anote o que come e quando, e reconheça padrões."],
        "tr": ["Yatak odasından ve mutfaktan tüm atıştırmalıkları kaldır.", "Gece yemek yemek uykuyu bozar ve kilo almaya yol açar.", "Akşam yemeğinden sonra dişlerini fırçala – beynine 'yemek bitti' sinyali gönderir.", "Atıştırma günlüğü tut: ne yediğini ve ne zaman yediğini yaz, kalıpları tanı."]
    },
    "trash.alkohol_flatrate": {
        "de": [
            "Halte keinen Alkohol zuhause und meide Bars, in denen du normalerweise trinkst.",
            "Schau dir an, was Alkohol mit Leber, Gehirn und Haut macht – auch in kleinen Mengen.",
            "Bestelle immer zuerst ein alkoholfreies Getränk, wenn du ausgehst.",
            "Zähle die Kalorien: Ein Bier hat ~250 kcal – rechne hoch, wie viel das pro Woche ist."
        ],
        "en": ["Don't keep alcohol at home and avoid bars where you normally drink.", "Look at what alcohol does to your liver, brain, and skin – even in small amounts.", "Always order a non-alcoholic drink first when going out.", "Count the calories: one beer has ~250 kcal – calculate how much that is per week."],
        "es": ["No tengas alcohol en casa y evita los bares donde normalmente bebes.", "Mira lo que el alcohol le hace a tu hígado, cerebro y piel – incluso en pequeñas cantidades.", "Pide siempre primero una bebida sin alcohol cuando salgas.", "Cuenta las calorías: una cerveza tiene ~250 kcal – calcula cuánto es por semana."],
        "fr": ["Ne garde pas d'alcool chez toi et évite les bars où tu bois habituellement.", "Regarde ce que l'alcool fait à ton foie, ton cerveau et ta peau – même en petites quantités.", "Commande toujours d'abord une boisson non-alcoolisée quand tu sors.", "Compte les calories : une bière fait ~250 kcal – calcule combien ça fait par semaine."],
        "it": ["Non tenere alcol in casa e evita i bar dove bevi di solito.", "Guarda cosa fa l'alcol a fegato, cervello e pelle – anche in piccole quantità.", "Ordina sempre prima una bevanda analcolica quando esci.", "Conta le calorie: una birra ha ~250 kcal – calcola quanto fa a settimana."],
        "ja": ["家にアルコールを置かず、普段飲むバーを避けましょう。", "アルコールが肝臓、脳、肌に何をするか見てみましょう。少量でも影響があります。", "外出時はまずノンアルコール飲料を注文しましょう。", "カロリーを数えましょう：ビール1杯で約250kcal。週間でいくらになるか計算しましょう。"],
        "ko": ["집에 술을 보관하지 말고 평소 마시는 바를 피하세요.", "알코올이 간, 뇌, 피부에 미치는 영향을 살펴보세요.", "외출 시 항상 무알코올 음료를 먼저 주문하세요.", "칼로리를 세세요: 맥주 한 잔은 약 250kcal – 주당 얼마인지 계산하세요."],
        "nl": ["Bewaar geen alcohol thuis en vermijd bars waar je normaal drinkt.", "Bekijk wat alcohol doet met je lever, hersenen en huid – zelfs in kleine hoeveelheden.", "Bestel altijd eerst een alcoholvrij drankje als je uitgaat.", "Tel de calorieën: een biertje heeft ~250 kcal – reken uit hoeveel dat per week is."],
        "pl": ["Nie trzymaj alkoholu w domu i unikaj barów, w których zwykle pijesz.", "Zobacz, co alkohol robi z wątrobą, mózgiem i skórą – nawet w małych ilościach.", "Zawsze najpierw zamów napój bezalkoholowy, gdy wychodzisz.", "Policz kalorie: jedno piwo to ~250 kcal – przelicz, ile to na tydzień."],
        "pt": ["Não tenha álcool em casa e evite bares onde costuma beber.", "Veja o que o álcool faz ao fígado, cérebro e pele – mesmo em pequenas quantidades.", "Sempre peça uma bebida sem álcool primeiro ao sair.", "Conte as calorias: uma cerveja tem ~250 kcal – calcule quanto é por semana."],
        "tr": ["Evde alkol bulundurma ve normalde içki içtiğin barlardan uzak dur.", "Alkolün karaciğere, beyne ve cilde ne yaptığına bak – küçük miktarlarda bile.", "Dışarı çıktığında her zaman önce alkolsüz bir içecek sipariş et.", "Kalorileri say: bir bira ~250 kcal – haftalık ne kadar yaptığını hesapla."]
    },
    "trash.doomscrolling_handy": {
        "de": [
            "Lege dein Handy vor dem Schlafengehen mindestens 1 Stunde weg und lade es außerhalb des Schlafzimmers.",
            "Negative Nachrichten aktivieren dein Stresssystem – du schädigst aktiv deine mentale Gesundheit.",
            "Installiere eine App, die deine Bildschirmzeit begrenzt und nach 20 Minuten sperrt.",
            "Ersetze Doomscrolling durch ein physisches Buch – du wirst besser schlafen und ruhiger sein."
        ],
        "en": ["Put your phone away at least 1 hour before bed and charge it outside the bedroom.", "Negative news activates your stress system – you're actively harming your mental health.", "Install an app that limits screen time and locks after 20 minutes.", "Replace doomscrolling with a physical book – you'll sleep better and feel calmer."],
        "es": ["Deja tu teléfono al menos 1 hora antes de dormir y cárgalo fuera del dormitorio.", "Las noticias negativas activan tu sistema de estrés – dañas activamente tu salud mental.", "Instala una app que limite el tiempo de pantalla y bloquee después de 20 minutos.", "Reemplaza el doomscrolling con un libro físico – dormirás mejor y estarás más tranquilo."],
        "fr": ["Pose ton téléphone au moins 1 heure avant de dormir et charge-le hors de la chambre.", "Les actualités négatives activent ton système de stress – tu nuis activement à ta santé mentale.", "Installe une app qui limite le temps d'écran et bloque après 20 minutes.", "Remplace le doomscrolling par un livre physique – tu dormiras mieux et seras plus calme."],
        "it": ["Metti via il telefono almeno 1 ora prima di dormire e caricalo fuori dalla camera.", "Le notizie negative attivano il sistema dello stress – stai danneggiando la tua salute mentale.", "Installa un'app che limita il tempo schermo e blocca dopo 20 minuti.", "Sostituisci il doomscrolling con un libro fisico – dormirai meglio e sarai più calmo."],
        "ja": ["就寝の1時間前にはスマホを手放し、寝室の外で充電しましょう。", "ネガティブなニュースはストレスシステムを活性化し、メンタルヘルスに悪影響を与えます。", "スクリーンタイムを制限し、20分後にロックするアプリをインストールしましょう。", "ドゥームスクローリングを紙の本に置き換えましょう。よく眠れ、穏やかになります。"],
        "ko": ["잠자기 최소 1시간 전에 휴대폰을 치우고 침실 밖에서 충전하세요.", "부정적 뉴스는 스트레스 시스템을 활성화합니다 – 정신 건강을 해치고 있습니다.", "스크린 타임을 제한하고 20분 후 잠기는 앱을 설치하세요.", "둠스크롤링을 종이책으로 대체하세요 – 더 잘 자고 더 차분해질 겁니다."],
        "nl": ["Leg je telefoon minstens 1 uur voor het slapengaan weg en laad hem buiten de slaapkamer.", "Negatief nieuws activeert je stresssysteem – je schaadt actief je mentale gezondheid.", "Installeer een app die je schermtijd beperkt en na 20 minuten blokkeert.", "Vervang doomscrolling door een fysiek boek – je slaapt beter en bent rustiger."],
        "pl": ["Odłóż telefon co najmniej 1 godzinę przed snem i ładuj go poza sypialnią.", "Negatywne wiadomości aktywują twój system stresu – aktywnie szkodzisz swojemu zdrowiu psychicznemu.", "Zainstaluj aplikację ograniczającą czas ekranowy i blokującą po 20 minutach.", "Zamień doomscrolling na fizyczną książkę – będziesz lepiej spać i czuć się spokojniej."],
        "pt": ["Guarde o celular pelo menos 1 hora antes de dormir e carregue-o fora do quarto.", "Notícias negativas ativam seu sistema de estresse – você prejudica ativamente sua saúde mental.", "Instale um app que limite o tempo de tela e bloqueie após 20 minutos.", "Substitua o doomscrolling por um livro físico – você dormirá melhor e ficará mais calmo."],
        "tr": ["Yatmadan en az 1 saat önce telefonunu bırak ve yatak odasının dışında şarj et.", "Olumsuz haberler stres sistemini harekete geçirir – ruh sağlığına aktif olarak zarar veriyorsun.", "Ekran süresini sınırlayan ve 20 dakika sonra kilitleyen bir uygulama yükle.", "Doomscrolling'i fiziksel bir kitapla değiştir – daha iyi uyuyacak ve sakin olacaksın."]
    },
    "trash.binge_streaming": {
        "de": [
            "Deaktiviere die Autoplay-Funktion bei allen Streaming-Diensten.",
            "Binge-Watching stiehlt dir Stunden, die du nie zurückbekommst – jede Episode kostet dich Lebenszeit.",
            "Setze dir ein Limit: maximal 1-2 Episoden pro Tag, dann Gerät ausschalten.",
            "Beobachte, wie leer du dich nach einer 4-Stunden-Session fühlst – das ist kein Genuss, das ist Betäubung."
        ],
        "en": ["Disable autoplay on all streaming services.", "Binge-watching steals hours you'll never get back – every episode costs you life time.", "Set a limit: max 1-2 episodes per day, then turn off the device.", "Notice how empty you feel after a 4-hour session – that's not enjoyment, that's numbing."],
        "es": ["Desactiva la reproducción automática en todos los servicios de streaming.", "El binge-watching te roba horas que nunca recuperarás.", "Ponte un límite: máximo 1-2 episodios por día, luego apaga el dispositivo.", "Observa lo vacío que te sientes después de una sesión de 4 horas – eso no es disfrute, es adormecimiento."],
        "fr": ["Désactive la lecture automatique sur tous les services de streaming.", "Le binge-watching te vole des heures que tu ne récupéreras jamais.", "Fixe-toi une limite : max 1-2 épisodes par jour, puis éteins l'appareil.", "Observe le vide que tu ressens après une session de 4 heures – ce n'est pas du plaisir, c'est de l'engourdissement."],
        "it": ["Disattiva l'autoplay su tutti i servizi di streaming.", "Il binge-watching ti ruba ore che non riavrai mai.", "Metti un limite: max 1-2 episodi al giorno, poi spegni il dispositivo.", "Nota quanto ti senti vuoto dopo una sessione di 4 ore – non è piacere, è intorpidimento."],
        "ja": ["すべてのストリーミングサービスで自動再生を無効にしましょう。", "一気見は二度と戻らない時間を奪います。", "制限を設けましょう：1日最大1〜2エピソード、その後デバイスをオフ。", "4時間のセッション後の空虚感に気づきましょう。それは楽しみではなく、麻痺です。"],
        "ko": ["모든 스트리밍 서비스에서 자동 재생을 비활성화하세요.", "몰아보기는 되돌릴 수 없는 시간을 훔칩니다.", "하루 최대 1-2편으로 제한하고 기기를 끄세요.", "4시간 시청 후 얼마나 공허한지 관찰하세요 – 즐거움이 아닌 마비입니다."],
        "nl": ["Schakel autoplay uit bij alle streamingdiensten.", "Binge-watching steelt uren die je nooit terugkrijgt.", "Stel een limiet: max 1-2 afleveringen per dag, dan apparaat uit.", "Merk op hoe leeg je je voelt na een 4-uursessie – dat is geen genot, dat is verdoving."],
        "pl": ["Wyłącz autoodtwarzanie we wszystkich serwisach streamingowych.", "Binge-watching kradnie ci godziny, których nigdy nie odzyskasz.", "Ustaw limit: max 1-2 odcinki dziennie, potem wyłącz urządzenie.", "Zauważ, jak pusto się czujesz po 4-godzinnej sesji – to nie przyjemność, to odrętwienie."],
        "pt": ["Desative a reprodução automática em todos os serviços de streaming.", "Binge-watching rouba horas que nunca vai recuperar.", "Defina um limite: máximo 1-2 episódios por dia, depois desligue o aparelho.", "Observe como se sente vazio após uma sessão de 4 horas – isso não é prazer, é entorpecimento."],
        "tr": ["Tüm yayın hizmetlerinde otomatik oynatmayı kapat.", "Dizi maratonu asla geri alamayacağın saatler çalıyor.", "Günde en fazla 1-2 bölüm sınırı koy, sonra cihazı kapat.", "4 saatlik bir oturumdan sonra ne kadar boş hissettiğine dikkat et – bu zevk değil, uyuşma."]
    },
    "trash.fastfood_lieferdienst": {
        "de": [
            "Lösche alle Lieferdienst-Apps (Lieferando, UberEats etc.) und gespeicherte Zahlungsmethoden.",
            "Die Fotos in den Apps sind Fake – das echte Essen sieht nie so aus und ist ungesund.",
            "Bestelle Zutaten statt fertiges Essen – in 20 Minuten kochst du gesünder und günstiger.",
            "Addiere alle Liefergebühren eines Monats – das Geld hättest du sinnvoller nutzen können."
        ],
        "en": ["Delete all delivery apps and saved payment methods.", "The photos in the apps are fake – the real food never looks like that and is unhealthy.", "Order ingredients instead of ready meals – in 20 minutes you cook healthier and cheaper.", "Add up all delivery fees for a month – you could have used that money better."],
        "es": ["Elimina todas las apps de delivery y los métodos de pago guardados.", "Las fotos en las apps son falsas – la comida real nunca se ve así y es poco saludable.", "Pide ingredientes en vez de comida preparada – en 20 minutos cocinas más sano y barato.", "Suma todas las tarifas de envío de un mes – podrías haber usado ese dinero mejor."],
        "fr": ["Supprime toutes les apps de livraison et les méthodes de paiement enregistrées.", "Les photos dans les apps sont fausses – la vraie nourriture ne ressemble jamais à ça.", "Commande des ingrédients plutôt que des plats préparés – en 20 min tu cuisines plus sainement.", "Additionne tous les frais de livraison d'un mois – tu aurais pu mieux utiliser cet argent."],
        "it": ["Elimina tutte le app di delivery e i metodi di pagamento salvati.", "Le foto nelle app sono false – il cibo vero non è mai così ed è poco sano.", "Ordina ingredienti invece di piatti pronti – in 20 minuti cucini più sano e risparmi.", "Somma tutte le spese di consegna di un mese – avresti potuto usare quei soldi meglio."],
        "ja": ["すべてのデリバリーアプリと保存された支払い方法を削除しましょう。", "アプリの写真はフェイクです。実際の食べ物はああは見えず、不健康です。", "出来合いの食事の代わりに食材を注文しましょう。20分でより健康的に安く調理できます。", "1ヶ月の配達料金を合計してみましょう。そのお金をもっと有意義に使えたはずです。"],
        "ko": ["모든 배달 앱과 저장된 결제 수단을 삭제하세요.", "앱의 사진은 가짜입니다 – 실제 음식은 절대 그렇지 않고 건강에 좋지 않습니다.", "완성된 음식 대신 재료를 주문하세요 – 20분이면 더 건강하고 저렴하게 요리합니다.", "한 달 동안의 배달비를 합산해보세요 – 그 돈을 더 잘 쓸 수 있었습니다."],
        "nl": ["Verwijder alle bezorg-apps en opgeslagen betaalmethodes.", "De foto's in de apps zijn nep – het echte eten ziet er nooit zo uit en is ongezond.", "Bestel ingrediënten in plaats van kant-en-klare maaltijden – in 20 min kook je gezonder en goedkoper.", "Tel alle bezorgkosten van een maand op – dat geld had je beter kunnen gebruiken."],
        "pl": ["Usuń wszystkie aplikacje dostawy i zapisane metody płatności.", "Zdjęcia w aplikacjach są fałszywe – prawdziwe jedzenie nigdy tak nie wygląda.", "Zamawiaj składniki zamiast gotowych dań – w 20 minut gotujesz zdrowiej i taniej.", "Zsumuj wszystkie opłaty za dostawę z miesiąca – te pieniądze mogłeś wykorzystać lepiej."],
        "pt": ["Apague todos os apps de delivery e métodos de pagamento salvos.", "As fotos nos apps são falsas – a comida real nunca é assim e é prejudicial.", "Peça ingredientes em vez de comida pronta – em 20 minutos você cozinha mais saudável e barato.", "Some todas as taxas de entrega de um mês – poderia ter usado esse dinheiro melhor."],
        "tr": ["Tüm teslimat uygulamalarını ve kayıtlı ödeme yöntemlerini sil.", "Uygulamalardaki fotoğraflar sahte – gerçek yemek asla öyle görünmez ve sağlıksızdır.", "Hazır yemek yerine malzeme sipariş et – 20 dakikada daha sağlıklı ve ucuz pişirirsin.", "Bir aylık tüm teslimat ücretlerini topla – o parayı daha iyi kullanabilirdin."]
    },
    "trash.lootbox_zockerabo": {
        "de": [
            "Deinstalliere Spiele mit Lootboxen und Mikrotransaktionen von allen deinen Geräten.",
            "Lootboxen sind so designt wie Spielautomaten – sie nutzen deine Psychologie gegen dich aus.",
            "Richte eine Ausgabenlimite bei deinem App Store ein und entferne hinterlegte Kreditkarten.",
            "Rechne nach: Wie viel echtes Geld hast du schon für virtuelle Items ausgegeben, die du nicht besitzt?"
        ],
        "en": ["Uninstall games with loot boxes and microtransactions from all devices.", "Loot boxes are designed like slot machines – they exploit your psychology.", "Set spending limits in your app store and remove saved credit cards.", "Calculate: how much real money have you spent on virtual items you don't own?"],
        "es": ["Desinstala juegos con loot boxes y microtransacciones de todos tus dispositivos.", "Las loot boxes están diseñadas como máquinas tragamonedas – explotan tu psicología.", "Configura límites de gasto en tu tienda de apps y elimina las tarjetas guardadas.", "Calcula: ¿cuánto dinero real has gastado en items virtuales que no posees?"],
        "fr": ["Désinstalle les jeux avec des loot boxes et microtransactions de tous tes appareils.", "Les loot boxes sont conçues comme des machines à sous – elles exploitent ta psychologie.", "Mets des limites de dépenses dans ton app store et retire les cartes enregistrées.", "Calcule : combien d'argent réel as-tu dépensé pour des objets virtuels que tu ne possèdes pas ?"],
        "it": ["Disinstalla giochi con loot box e microtransazioni da tutti i dispositivi.", "Le loot box sono progettate come slot machine – sfruttano la tua psicologia.", "Imposta limiti di spesa nell'app store e rimuovi le carte salvate.", "Calcola: quanti soldi veri hai speso per oggetti virtuali che non possiedi?"],
        "ja": ["すべてのデバイスからルートボックスとマイクロトランザクションのあるゲームをアンインストールしましょう。", "ルートボックスはスロットマシンのように設計されています。あなたの心理を悪用します。", "アプリストアで支出制限を設定し、保存されたクレジットカードを削除しましょう。", "計算してみましょう：所有していない仮想アイテムにいくらの実際のお金を使いましたか？"],
        "ko": ["모든 기기에서 루트박스와 소액결제가 있는 게임을 삭제하세요.", "루트박스는 슬롯머신처럼 설계되어 있습니다 – 당신의 심리를 이용합니다.", "앱 스토어에서 지출 한도를 설정하고 저장된 카드를 제거하세요.", "계산해보세요: 소유하지 않는 가상 아이템에 얼마의 실제 돈을 썼나요?"],
        "nl": ["Verwijder games met lootboxen en microtransacties van alle apparaten.", "Lootboxen zijn ontworpen als gokkasten – ze misbruiken je psychologie.", "Stel bestedingslimieten in bij je app store en verwijder opgeslagen creditcards.", "Reken na: hoeveel echt geld heb je al uitgegeven aan virtuele items die je niet bezit?"],
        "pl": ["Odinstaluj gry z lootboxami i mikrotransakcjami ze wszystkich urządzeń.", "Lootboxy są zaprojektowane jak automaty do gier – wykorzystują twoją psychologię.", "Ustaw limity wydatków w sklepie z aplikacjami i usuń zapisane karty.", "Policz: ile prawdziwych pieniędzy wydałeś na wirtualne przedmioty, których nie posiadasz?"],
        "pt": ["Desinstale jogos com loot boxes e microtransações de todos os dispositivos.", "Loot boxes são projetadas como caça-níqueis – exploram sua psicologia.", "Configure limites de gastos na app store e remova cartões salvos.", "Calcule: quanto dinheiro real já gastou em itens virtuais que não possui?"],
        "tr": ["Tüm cihazlardan loot box ve mikro işlem içeren oyunları kaldır.", "Loot box'lar kumar makineleri gibi tasarlanmıştır – psikolojini sömürür.", "Uygulama mağazanda harcama limitleri belirle ve kayıtlı kartları kaldır.", "Hesapla: sahip olmadığın sanal eşyalar için ne kadar gerçek para harcadın?"]
    },
    "trash.luxus_uhr": {
        "de": [
            "Entfolge Luxus-Uhren-Kanälen und -Foren auf Social Media.",
            "Eine Uhr für tausende Euro zeigt die gleiche Zeit wie eine für 30 € – es ist reines Status-Denken.",
            "Erstelle eine Liste, was du dir mit dem Geld Sinnvolles kaufen könntest.",
            "Erinnere dich: Niemanden beeindruckt deine Uhr so sehr, wie du denkst."
        ],
        "en": ["Unfollow luxury watch channels and forums on social media.", "A watch worth thousands shows the same time as one for $30 – it's pure status thinking.", "Make a list of meaningful things you could buy with that money.", "Remember: nobody is as impressed by your watch as you think."],
        "es": ["Deja de seguir canales y foros de relojes de lujo.", "Un reloj de miles muestra la misma hora que uno de 30€ – es puro pensamiento de estatus.", "Haz una lista de cosas significativas que podrías comprar con ese dinero.", "Recuerda: nadie se impresiona tanto con tu reloj como tú crees."],
        "fr": ["Désabonne-toi des chaînes et forums de montres de luxe.", "Une montre à des milliers d'euros donne la même heure qu'une à 30€ – c'est du pur statut.", "Fais une liste de choses utiles que tu pourrais acheter avec cet argent.", "Rappelle-toi : personne n'est aussi impressionné par ta montre que tu le penses."],
        "it": ["Smetti di seguire canali e forum di orologi di lusso.", "Un orologio da migliaia di euro segna la stessa ora di uno da 30€ – è puro status.", "Fai una lista di cose significative che potresti comprare con quei soldi.", "Ricorda: nessuno è impressionato dal tuo orologio quanto pensi."],
        "ja": ["SNSで高級時計チャンネルやフォーラムのフォローを解除しましょう。", "数千ドルの時計も30ドルの時計も同じ時間を示します。それは純粋なステータス思考です。", "そのお金で買える有意義なもののリストを作りましょう。", "覚えておきましょう：あなたが思うほど、誰もあなたの時計に感銘を受けていません。"],
        "ko": ["소셜 미디어에서 럭셔리 시계 채널과 포럼을 언팔로우하세요.", "수천 달러 시계도 30달러 시계와 같은 시간을 보여줍니다 – 순수한 지위 사고입니다.", "그 돈으로 살 수 있는 의미 있는 것들의 목록을 만드세요.", "기억하세요: 당신이 생각하는 만큼 아무도 당신의 시계에 감동받지 않습니다."],
        "nl": ["Ontvolg luxe horlogekanalen en -forums op social media.", "Een horloge van duizenden euro's geeft dezelfde tijd als eentje van €30 – het is puur statusdenken.", "Maak een lijst van nuttige dingen die je met dat geld zou kunnen kopen.", "Onthoud: niemand is zo onder de indruk van je horloge als je denkt."],
        "pl": ["Przestań obserwować kanały i fora luksusowych zegarków.", "Zegarek za tysiące pokazuje ten sam czas co za 30€ – to czyste myślenie statusowe.", "Stwórz listę sensownych rzeczy, które mógłbyś kupić za te pieniądze.", "Pamiętaj: nikt nie jest tak pod wrażeniem twojego zegarka, jak ci się wydaje."],
        "pt": ["Deixe de seguir canais e fóruns de relógios de luxo.", "Um relógio de milhares mostra a mesma hora que um de 30€ – é puro status.", "Faça uma lista de coisas significativas que poderia comprar com esse dinheiro.", "Lembre-se: ninguém fica tão impressionado com seu relógio quanto você pensa."],
        "tr": ["Sosyal medyada lüks saat kanallarını ve forumlarını takipten çık.", "Binlerce liralık bir saat, 30 liralık biriyle aynı saati gösterir – bu saf statü düşüncesidir.", "O parayla alabileceğin anlamlı şeylerin bir listesini yap.", "Unutma: kimse saatinden senin düşündüğün kadar etkilenmiyor."]
    },
    "trash.couch_abo": {
        "de": [
            "Stelle die Fernbedienung weit weg und lege stattdessen Sportschuhe neben die Couch.",
            "Zu viel Sitzen erhöht das Risiko für Herzerkrankungen, Diabetes und Depressionen.",
            "Setze einen Timer, der dich alle 30 Minuten daran erinnert, aufzustehen und dich zu bewegen.",
            "Tracke deine tägliche Bewegung – du wirst schockiert sein, wie wenig es an Couch-Tagen ist."
        ],
        "en": ["Put the remote control far away and place sneakers next to the couch instead.", "Too much sitting increases risk of heart disease, diabetes, and depression.", "Set a timer to remind you to stand up and move every 30 minutes.", "Track your daily movement – you'll be shocked how little it is on couch days."],
        "es": ["Pon el mando lejos y coloca zapatillas deportivas junto al sofá.", "Estar sentado demasiado aumenta el riesgo de enfermedades cardíacas, diabetes y depresión.", "Pon un temporizador que te recuerde levantarte y moverte cada 30 minutos.", "Registra tu movimiento diario – te sorprenderá lo poco que es en días de sofá."],
        "fr": ["Mets la télécommande loin et place des baskets à côté du canapé.", "Trop de sédentarité augmente les risques de maladies cardiaques, diabète et dépression.", "Mets un minuteur pour te rappeler de te lever et bouger toutes les 30 minutes.", "Suis tes mouvements quotidiens – tu seras choqué de voir combien c'est peu les jours de canapé."],
        "it": ["Metti il telecomando lontano e metti scarpe da ginnastica accanto al divano.", "Stare troppo seduti aumenta il rischio di malattie cardiache, diabete e depressione.", "Imposta un timer che ti ricordi di alzarti e muoverti ogni 30 minuti.", "Monitora il tuo movimento giornaliero – sarai scioccato da quanto è poco nei giorni da divano."],
        "ja": ["リモコンを遠くに置き、代わりにスニーカーをソファの横に置きましょう。", "座りすぎは心臓病、糖尿病、うつ病のリスクを高めます。", "30分ごとに立ち上がって動くリマインダーを設定しましょう。", "日々の運動量を追跡しましょう。ソファの日がいかに少ないか驚くでしょう。"],
        "ko": ["리모컨을 멀리 두고 대신 운동화를 소파 옆에 놓으세요.", "너무 많이 앉아있으면 심장병, 당뇨병, 우울증 위험이 높아집니다.", "30분마다 일어나서 움직이라고 알려주는 타이머를 설정하세요.", "일일 활동량을 추적하세요 – 소파 데이에 얼마나 적은지 충격받을 겁니다."],
        "nl": ["Leg de afstandsbediening ver weg en zet sportschoenen naast de bank.", "Te veel zitten verhoogt het risico op hartziekten, diabetes en depressie.", "Stel een timer in die je elke 30 minuten herinnert om op te staan en te bewegen.", "Volg je dagelijkse beweging – je zult geschokt zijn hoe weinig het is op bankdagen."],
        "pl": ["Odłóż pilota daleko i postaw buty sportowe obok kanapy.", "Zbyt dużo siedzenia zwiększa ryzyko chorób serca, cukrzycy i depresji.", "Ustaw timer, który co 30 minut przypomni ci o wstaniu i ruchu.", "Śledź codzienną aktywność – będziesz zszokowany, jak mała jest w dni na kanapie."],
        "pt": ["Coloque o controle remoto longe e ponha tênis ao lado do sofá.", "Ficar sentado demais aumenta risco de doenças cardíacas, diabetes e depressão.", "Configure um timer para lembrar de levantar e se mover a cada 30 minutos.", "Acompanhe seu movimento diário – ficará chocado com o pouco que é nos dias de sofá."],
        "tr": ["Kumandayı uzağa koy ve kanepenin yanına spor ayakkabılarını yerleştir.", "Çok oturmak kalp hastalığı, diyabet ve depresyon riskini artırır.", "Her 30 dakikada ayağa kalkmayı hatırlatan bir zamanlayıcı kur.", "Günlük hareketini takip et – kanepe günlerinde ne kadar az olduğuna şok olacaksın."]
    },
    "trash.doener_dauerkarte": {
        "de": [
            "Vermeide den Weg an deinem Lieblings-Döner-Laden vorbei – wähle eine andere Route.",
            "Ein Döner hat oft 700+ Kalorien und viel Fett – denke daran, bevor du bestellst.",
            "Bereite ein schnelles gesundes Wrap vor (dauert nur 5 Min), bevor der Hunger zuschlägt.",
            "Fotografiere jedes Mal, wenn du Döner isst, und schau dir die Galerie am Monatsende an."
        ],
        "en": ["Avoid walking past your favorite doner shop – choose a different route.", "A doner often has 700+ calories and lots of fat – think about that before ordering.", "Prepare a quick healthy wrap (only 5 min) before hunger strikes.", "Take a photo every time you eat doner and look at the gallery at month's end."],
        "es": ["Evita pasar por tu kebab favorito – elige otra ruta.", "Un kebab tiene a menudo 700+ calorías y mucha grasa – piénsalo antes de pedir.", "Prepara un wrap saludable rápido (solo 5 min) antes de que llegue el hambre.", "Toma una foto cada vez que comas kebab y mira la galería a fin de mes."],
        "fr": ["Évite de passer devant ton kebab préféré – choisis un autre chemin.", "Un kebab a souvent 700+ calories et beaucoup de gras – penses-y avant de commander.", "Prépare un wrap sain rapide (5 min) avant que la faim ne frappe.", "Prends une photo chaque fois que tu manges un kebab et regarde la galerie en fin de mois."],
        "it": ["Evita di passare davanti al tuo kebab preferito – scegli un percorso diverso.", "Un kebab ha spesso 700+ calorie e tanto grasso – pensaci prima di ordinare.", "Prepara un wrap sano veloce (solo 5 min) prima che arrivi la fame.", "Scatta una foto ogni volta che mangi kebab e guarda la galleria a fine mese."],
        "ja": ["お気に入りのドネル屋さんの前を通らないようにしましょう。別のルートを選びましょう。", "ドネルは700カロリー以上で脂肪が多いことが多いです。注文前に考えましょう。", "空腹が来る前に、素早くヘルシーなラップを準備しましょう（5分だけ）。", "ドネルを食べるたびに写真を撮り、月末にギャラリーを見ましょう。"],
        "ko": ["좋아하는 도너 가게 앞을 지나가지 마세요 – 다른 길을 선택하세요.", "도너는 종종 700+ 칼로리와 많은 지방을 함유합니다 – 주문 전 생각하세요.", "배고프기 전에 건강한 랩을 빠르게 준비하세요(5분이면 됩니다).", "도너를 먹을 때마다 사진을 찍고 월말에 갤러리를 확인하세요."],
        "nl": ["Vermijd langs je favoriete döner te lopen – kies een andere route.", "Een döner heeft vaak 700+ calorieën en veel vet – denk daaraan voor je bestelt.", "Bereid een snelle gezonde wrap voor (maar 5 min) voordat de honger toeslaat.", "Maak elke keer een foto als je döner eet en bekijk de galerie aan het einde van de maand."],
        "pl": ["Unikaj przechodzenia obok ulubionego kebaba – wybierz inną trasę.", "Kebab ma często 700+ kalorii i dużo tłuszczu – pomyśl o tym przed zamówieniem.", "Przygotuj szybki zdrowy wrap (5 minut), zanim uderzy głód.", "Rób zdjęcie za każdym razem, gdy jesz kebaba, i obejrzyj galerię na koniec miesiąca."],
        "pt": ["Evite passar pela sua lanchonete favorita – escolha outra rota.", "Um döner frequentemente tem 700+ calorias e muita gordura – pense nisso antes de pedir.", "Prepare um wrap saudável rápido (só 5 min) antes que a fome chegue.", "Tire uma foto toda vez que comer döner e veja a galeria no final do mês."],
        "tr": ["En sevdiğin dönerci yolundan geçmekten kaçın – farklı bir rota seç.", "Bir döner genellikle 700+ kalori ve çok yağ içerir – sipariş vermeden önce düşün.", "Açlık vurmadan hızlı sağlıklı bir wrap hazırla (sadece 5 dk).", "Her döner yediğinde fotoğraf çek ve ay sonunda galeriye bak."]
    },
    "trash.negativitaets_feed": {
        "de": [
            "Schalte alle Nachrichten-Benachrichtigungen aus und folge nur konstruktiven Medien.",
            "Jede negative Nachricht aktiviert deine Amygdala – du trainierst dein Gehirn auf Angst.",
            "Beschränke News-Konsum auf max. 10 Minuten pro Tag zu einer festen Uhrzeit.",
            "Frage dich nach jedem Nachrichtenkonsum: Kann ich etwas daran ändern? Wenn nein, lass es los."
        ],
        "en": ["Turn off all news notifications and follow only constructive media.", "Every negative news activates your amygdala – you're training your brain for fear.", "Limit news consumption to max 10 minutes per day at a fixed time.", "Ask yourself after consuming news: can I change anything about this? If not, let it go."],
        "es": ["Desactiva todas las notificaciones de noticias y sigue solo medios constructivos.", "Cada noticia negativa activa tu amígdala – entrenas tu cerebro para el miedo.", "Limita el consumo de noticias a máx. 10 minutos al día a una hora fija.", "Pregúntate tras consumir noticias: ¿puedo cambiar algo? Si no, déjalo ir."],
        "fr": ["Coupe toutes les notifications d'actualités et ne suis que des médias constructifs.", "Chaque nouvelle négative active ton amygdale – tu entraînes ton cerveau à la peur.", "Limite ta consommation d'actualités à max 10 min par jour à heure fixe.", "Demande-toi après chaque consommation d'actualités : puis-je changer quelque chose ? Si non, lâche prise."],
        "it": ["Disattiva tutte le notifiche delle notizie e segui solo media costruttivi.", "Ogni notizia negativa attiva la tua amigdala – stai allenando il cervello alla paura.", "Limita il consumo di notizie a max 10 minuti al giorno a un orario fisso.", "Chiediti dopo ogni consumo di notizie: posso cambiare qualcosa? Se no, lascia andare."],
        "ja": ["すべてのニュース通知をオフにし、建設的なメディアのみフォローしましょう。", "ネガティブなニュースは扁桃体を活性化します。脳を恐怖に向けて訓練しています。", "ニュース消費を1日最大10分、決まった時間に制限しましょう。", "ニュースを見た後に自問しましょう：何か変えられるか？変えられないなら、手放しましょう。"],
        "ko": ["모든 뉴스 알림을 끄고 건설적인 미디어만 팔로우하세요.", "부정적인 뉴스는 편도체를 활성화합니다 – 뇌를 두려움으로 훈련시키고 있습니다.", "뉴스 소비를 하루 최대 10분, 고정 시간으로 제한하세요.", "뉴스 소비 후 자문하세요: 이것에 대해 바꿀 수 있는가? 아니라면, 놓아주세요."],
        "nl": ["Schakel alle nieuwsmeldingen uit en volg alleen constructieve media.", "Elk negatief nieuwsbericht activeert je amygdala – je traint je brein op angst.", "Beperk nieuwsconsumptie tot max 10 minuten per dag op een vast tijdstip.", "Vraag jezelf na elk nieuws: kan ik hier iets aan veranderen? Zo niet, laat het los."],
        "pl": ["Wyłącz wszystkie powiadomienia o wiadomościach i śledź tylko konstruktywne media.", "Każda negatywna wiadomość aktywuje twoją amygdalę – trenujesz mózg do strachu.", "Ogranicz konsumpcję wiadomości do max. 10 minut dziennie o stałej porze.", "Zapytaj siebie po każdym czytaniu wiadomości: czy mogę coś zmienić? Jeśli nie, puść to."],
        "pt": ["Desative todas as notificações de notícias e siga apenas mídia construtiva.", "Cada notícia negativa ativa sua amígdala – você treina seu cérebro para o medo.", "Limite o consumo de notícias a máx. 10 minutos por dia em horário fixo.", "Pergunte-se após consumir notícias: posso mudar algo? Se não, deixe ir."],
        "tr": ["Tüm haber bildirimlerini kapat ve sadece yapıcı medyayı takip et.", "Her olumsuz haber amigdalanı harekete geçirir – beynini korkuya eğitiyorsun.", "Haber tüketimini günde en fazla 10 dakika ile sabit bir saatte sınırla.", "Haber okuduktan sonra kendine sor: bunu değiştirebilir miyim? Değilse, bırak gitsin."]
    },
    "trash.schlaf_killer_koffein": {
        "de": [
            "Trinke nach 14 Uhr keinen Kaffee mehr – Koffein wirkt bis zu 8 Stunden in deinem Körper.",
            "Koffein blockiert Adenosin (dein Müdigkeitssignal) – du schläfst weniger tief und erholst dich schlechter.",
            "Ersetze Nachmittagskaffee durch entkoffeinierten Kaffee oder Kräutertee.",
            "Tracke deine Schlafqualität mit und ohne Koffein – der Unterschied wird dich überzeugen."
        ],
        "en": ["Don't drink coffee after 2 PM – caffeine stays active in your body for up to 8 hours.", "Caffeine blocks adenosine (your tiredness signal) – you sleep less deeply and recover worse.", "Replace afternoon coffee with decaf or herbal tea.", "Track your sleep quality with and without caffeine – the difference will convince you."],
        "es": ["No tomes café después de las 14h – la cafeína actúa hasta 8 horas en tu cuerpo.", "La cafeína bloquea la adenosina (señal de cansancio) – duermes menos profundo y te recuperas peor.", "Reemplaza el café de la tarde con descafeinado o infusiones.", "Registra tu calidad de sueño con y sin cafeína – la diferencia te convencerá."],
        "fr": ["Ne bois plus de café après 14h – la caféine agit jusqu'à 8 heures dans ton corps.", "La caféine bloque l'adénosine (ton signal de fatigue) – tu dors moins profondément.", "Remplace le café de l'après-midi par du décaféiné ou une tisane.", "Suis la qualité de ton sommeil avec et sans caféine – la différence te convaincra."],
        "it": ["Non bere caffè dopo le 14 – la caffeina resta attiva nel corpo fino a 8 ore.", "La caffeina blocca l'adenosina (il segnale di stanchezza) – dormi meno profondamente.", "Sostituisci il caffè pomeridiano con decaffeinato o tisane.", "Monitora la qualità del sonno con e senza caffeina – la differenza ti convincerà."],
        "ja": ["午後2時以降はコーヒーを飲まないでください。カフェインは体内で最大8時間作用します。", "カフェインはアデノシン（眠気信号）をブロックし、深い睡眠と回復を妨げます。", "午後のコーヒーをデカフェやハーブティーに置き換えましょう。", "カフェインありなしの睡眠の質を追跡しましょう。その違いがあなたを納得させます。"],
        "ko": ["오후 2시 이후에는 커피를 마시지 마세요 – 카페인은 최대 8시간 작용합니다.", "카페인은 아데노신(피로 신호)을 차단합니다 – 더 얕게 자고 회복이 나빠집니다.", "오후 커피를 디카페인이나 허브차로 대체하세요.", "카페인 있을 때와 없을 때의 수면 품질을 추적하세요 – 차이가 설득할 것입니다."],
        "nl": ["Drink na 14 uur geen koffie meer – cafeïne werkt tot 8 uur in je lichaam.", "Cafeïne blokkeert adenosine (je moedheidssignaal) – je slaapt minder diep.", "Vervang middagkoffie door cafeïnevrije koffie of kruidenthee.", "Volg je slaapkwaliteit met en zonder cafeïne – het verschil zal je overtuigen."],
        "pl": ["Nie pij kawy po 14:00 – kofeina działa w twoim ciele do 8 godzin.", "Kofeina blokuje adenozynę (sygnał zmęczenia) – śpisz mniej głęboko.", "Zamień popołudniową kawę na bezkofeinową lub herbatkę ziołową.", "Śledź jakość snu z kofeiną i bez – różnica cię przekona."],
        "pt": ["Não beba café após as 14h – a cafeína fica ativa no corpo por até 8 horas.", "A cafeína bloqueia a adenosina (sinal de cansaço) – você dorme menos profundamente.", "Substitua o café da tarde por descafeinado ou chá de ervas.", "Acompanhe a qualidade do sono com e sem cafeína – a diferença vai convencê-lo."],
        "tr": ["Öğleden sonra 2'den sonra kahve içme – kafein vücudunda 8 saate kadar etkili kalır.", "Kafein adenozini (yorgunluk sinyalini) engeller – daha az derin uyursun.", "Öğleden sonra kahvesini kafeinsiz veya bitki çayı ile değiştir.", "Kafeinli ve kafeinsiz uyku kaliteni takip et – fark seni ikna edecek."]
    }
}

LANGUAGES = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "tr"]

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

def find_strings_file(lang):
    pattern = os.path.join(BASE_DIR, f"Garten_Simulation/{lang}.lproj/Localizable.strings")
    files = glob.glob(pattern)
    return files[0] if files else None

def add_tips_to_file(filepath, lang):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_entries = []
    for habit_id, translations in TIPS.items():
        if lang not in translations:
            continue
        tips = translations[lang]
        for i, tip in enumerate(tips, 1):
            key = f"{habit_id}.tip.{i}"
            if key not in content:
                escaped = tip.replace('"', '\\"')
                new_entries.append(f'"{key}" = "{escaped}";')
    
    if new_entries:
        header = "\n// MARK: - Bad Habit Specific Tips\n"
        addition = header + "\n".join(new_entries) + "\n"
        content += addition
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✅ {lang}: Added {len(new_entries)} tip entries")
    else:
        print(f"  ⏭️ {lang}: All tips already present")

def main():
    print("Adding habit-specific tips to all languages...")
    for lang in LANGUAGES:
        filepath = find_strings_file(lang)
        if filepath:
            add_tips_to_file(filepath, lang)
        else:
            print(f"  ❌ {lang}: Localizable.strings not found")
    print("\nDone!")

if __name__ == "__main__":
    main()
