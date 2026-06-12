import os
import re

languages = ["de", "en", "es", "fr", "it", "ja", "ko", "nl", "pl", "pt", "tr"]
base_dir = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation"

translations = {
    "junk_mail_abo": {
        "de": [
            "Setze dir feste App-Limits für TikTok, YouTube Shorts und Handyspiele.",
            "Deinstalliere extrem süchtig machende Spiele oder verstecke sie in einem Ordner.",
            "Lade dein Handy in einem anderen Raum, um endloses Zocken im Bett zu vermeiden.",
            "Ersetze Bildschirmzeit durch physische Hobbys oder das Lesen eines Buches."
        ],
        "en": [
            "Set daily app limits for TikTok, YouTube Shorts, and mobile games.",
            "Uninstall highly addictive mobile games or move them to a hidden folder.",
            "Charge your phone in another room to prevent endless scrolling in bed.",
            "Replace screen time with a physical hobby or reading a book."
        ],
        "es": [
            "Establece límites diarios para TikTok, YouTube Shorts y juegos móviles.",
            "Desinstala los juegos muy adictivos o muévelos a una carpeta oculta.",
            "Carga tu teléfono en otra habitación para evitar usarlo en la cama.",
            "Reemplaza el tiempo de pantalla con un pasatiempo físico o leyendo un libro."
        ],
        "fr": [
            "Définissez des limites quotidiennes pour TikTok, YouTube Shorts et les jeux mobiles.",
            "Désinstallez les jeux très addictifs ou déplacez-les dans un dossier caché.",
            "Rechargez votre téléphone dans une autre pièce pour éviter de l'utiliser au lit.",
            "Remplacez le temps d'écran par une activité physique ou la lecture."
        ],
        "it": [
            "Imposta limiti di tempo per TikTok, YouTube Shorts e giochi per cellulare.",
            "Disinstalla i giochi troppo avvincenti o spostali in una cartella nascosta.",
            "Carica il telefono in un'altra stanza per evitare di usarlo a letto.",
            "Sostituisci il tempo trascorso davanti allo schermo con un hobby fisico o la lettura."
        ],
        "ja": [
            "TikTok、YouTube Shorts、スマホゲームの1日の使用制限を設定しましょう。",
            "中毒性の高いゲームはアンインストールするか、隠しフォルダに移動させましょう。",
            "ベッドでのスマホいじりを防ぐため、別の部屋で充電しましょう。",
            "スクリーンタイムを運動や読書などの趣味に置き換えましょう。"
        ],
        "ko": [
            "TikTok, YouTube Shorts 및 모바일 게임에 대한 일일 앱 제한을 설정하세요.",
            "중독성이 강한 게임을 제거하거나 숨겨진 폴더로 이동시키세요.",
            "침대에서 스마트폰을 보지 않도록 다른 방에서 충전하세요.",
            "화면 보는 시간을 신체 활동이나 독서로 대체하세요."
        ],
        "nl": [
            "Stel dagelijkse app-limieten in voor TikTok, YouTube Shorts en mobiele games.",
            "Verwijder zeer verslavende games of verplaats ze naar een verborgen map.",
            "Laad je telefoon in een andere kamer op om te voorkomen dat je in bed scrollt.",
            "Vervang schermtijd door een fysieke hobby of het lezen van een boek."
        ],
        "pl": [
            "Ustaw dzienne limity dla aplikacji TikTok, YouTube Shorts i gier mobilnych.",
            "Odinstaluj bardzo uzależniające gry lub przenieś je do ukrytego folderu.",
            "Ładuj telefon w innym pokoju, aby uniknąć używania go w łóżku.",
            "Zastąp czas przed ekranem fizycznym hobby lub czytaniem książki."
        ],
        "pt": [
            "Defina limites diários para o TikTok, YouTube Shorts e jogos de celular.",
            "Desinstale jogos muito viciantes ou mova-os para uma pasta oculta.",
            "Carregue o seu telefone noutra divisão para evitar usá-lo na cama.",
            "Substitua o tempo de ecrã por um hobby físico ou pela leitura de um livro."
        ],
        "tr": [
            "TikTok, YouTube Shorts ve mobil oyunlar için günlük uygulama sınırları belirleyin.",
            "Çok bağımlılık yapan oyunları kaldırın veya gizli bir klasöre taşıyın.",
            "Yatakta telefonla oynamamak için telefonunuzu başka bir odada şarj edin.",
            "Ekran süresini fiziksel bir hobiyle veya kitap okuyarak değiştirin."
        ]
    },
    "endlos_scroll_tv": {
        "de": [
            "Zieh den Stecker des Fernsehers oder verstecke die Fernbedienung nach dem Schauen.",
            "Kündige ungenutzte Streaming-Abos, um der Versuchung zu widerstehen.",
            "Entscheide im Voraus, was du schauen willst, statt ziellos herumzuzappen.",
            "Setze dir abends eine feste Uhrzeit, zu der alle Bildschirme ausgeschaltet werden."
        ],
        "en": [
            "Unplug the TV or hide the remote control after watching.",
            "Cancel unused streaming subscriptions to avoid the temptation.",
            "Decide what to watch before turning on the TV, instead of mindlessly browsing.",
            "Set a hard 'screen off' time for the evening to improve your sleep quality."
        ],
        "es": [
            "Desenchufa el televisor o esconde el control remoto después de mirar.",
            "Cancela las suscripciones de streaming que no uses para evitar la tentación.",
            "Decide qué mirar antes de encender el televisor, en lugar de navegar sin rumbo.",
            "Establece una hora fija para apagar las pantallas por la noche."
        ],
        "fr": [
            "Débranchez la télévision ou cachez la télécommande après l'avoir regardée.",
            "Annulez les abonnements de streaming inutilisés pour éviter la tentation.",
            "Décidez de ce que vous allez regarder avant d'allumer la télé.",
            "Fixez une heure stricte pour éteindre les écrans le soir."
        ],
        "it": [
            "Scollega la TV o nascondi il telecomando dopo averla guardata.",
            "Cancella gli abbonamenti di streaming non utilizzati per evitare tentazioni.",
            "Decidi cosa guardare prima di accendere la TV, invece di fare zapping.",
            "Imposta un orario fisso per spegnere tutti gli schermi la sera."
        ],
        "ja": [
            "見終わったらテレビのコンセントを抜くか、リモコンを隠しましょう。",
            "誘惑を避けるため、使っていない動画配信サービスを解約しましょう。",
            "テレビをつける前に、何を見るか決めておきましょう。",
            "夜はスクリーンを消す時間を明確に決めましょう。"
        ],
        "ko": [
            "시청 후에는 TV 플러그를 뽑거나 리모컨을 숨기세요.",
            "유혹을 피하기 위해 사용하지 않는 스트리밍 구독을 취소하세요.",
            "TV를 켜기 전에 무엇을 볼지 미리 결정하세요.",
            "저녁에는 모든 화면을 끄는 시간을 정해두세요."
        ],
        "nl": [
            "Trek de stekker van de tv eruit of verberg de afstandsbediening na het kijken.",
            "Zeg ongebruikte streamingabonnementen op om verleiding te voorkomen.",
            "Beslis wat je wilt kijken voordat je de tv aanzet, in plaats van zomaar te zappen.",
            "Stel een vaste tijd in om schermen 's avonds uit te schakelen."
        ],
        "pl": [
            "Odłącz telewizor lub schowaj pilota po oglądaniu.",
            "Anuluj nieużywane subskrypcje streamingowe, aby uniknąć pokusy.",
            "Zdecyduj, co chcesz obejrzeć, zanim włączysz telewizor.",
            "Ustal sztywną godzinę wyłączania ekranów wieczorem."
        ],
        "pt": [
            "Desligue a TV da tomada ou esconda o comando após assistir.",
            "Cancele assinaturas de streaming não utilizadas para evitar a tentação.",
            "Decida o que assistir antes de ligar a TV, em vez de zapear sem rumo.",
            "Defina um horário fixo para desligar todos os ecrãs à noite."
        ],
        "tr": [
            "İzledikten sonra televizyonun fişini çekin veya kumandayı saklayın.",
            "Cazibeden kaçınmak için kullanılmayan yayın aboneliklerini iptal edin.",
            "Televizyonu açmadan önce ne izleyeceğinize karar verin.",
            "Akşamları tüm ekranları kapatmak için kesin bir saat belirleyin."
        ]
    },
    "doomscrolling_handy": {
        "de": [
            "Stelle dein Handy auf Graustufen, um Social-Media-Feeds weniger reizvoll zu machen.",
            "Lösche Social-Media-Apps vom Handy und nutze sie nur noch am PC.",
            "Nutze Apps, die dich 10 Sekunden warten lassen, bevor du Instagram öffnest.",
            "Entfolge negativen Nachrichten und schalte Konten stumm, die Doomscrolling auslösen."
        ],
        "en": [
            "Turn your phone display to grayscale to make social media feeds less stimulating.",
            "Delete social media apps from your phone and only use them on a computer.",
            "Use apps that force you to wait 10 seconds before opening Instagram or Twitter.",
            "Unfollow negative news outlets and mute accounts that trigger doomscrolling."
        ],
        "es": [
            "Pon la pantalla en escala de grises para que las redes sociales sean menos estimulantes.",
            "Borra las apps de redes sociales del teléfono y úsalas solo en la PC.",
            "Usa aplicaciones que te obliguen a esperar 10 segundos antes de abrir Instagram.",
            "Deja de seguir noticias negativas y silencia cuentas que causen doomscrolling."
        ],
        "fr": [
            "Passez votre écran en niveaux de gris pour rendre les réseaux sociaux moins stimulants.",
            "Supprimez les réseaux sociaux de votre téléphone et utilisez-les sur ordinateur.",
            "Utilisez des applications qui vous font patienter 10 secondes avant d'ouvrir Instagram.",
            "Désabonnez-vous des actualités négatives et masquez les comptes toxiques."
        ],
        "it": [
            "Imposta lo schermo in bianco e nero per rendere i social media meno stimolanti.",
            "Elimina le app dei social dal telefono e usale solo sul computer.",
            "Usa app che ti costringono ad aspettare 10 secondi prima di aprire Instagram.",
            "Smetti di seguire le notizie negative e silenzia gli account che scatenano il doomscrolling."
        ],
        "ja": [
            "スマホを白黒表示にして、SNSの刺激を減らしましょう。",
            "スマホからSNSアプリを削除し、パソコンでのみ使用しましょう。",
            "Instagramを開く前に10秒待たせるアプリを活用しましょう。",
            "ネガティブなニュースのフォローを外し、原因となるアカウントをミュートしましょう。"
        ],
        "ko": [
            "소셜 미디어의 자극을 줄이기 위해 스마트폰 화면을 흑백으로 설정하세요.",
            "스마트폰에서 소셜 미디어 앱을 삭제하고 컴퓨터에서만 사용하세요.",
            "Instagram을 열기 전에 10초를 기다리게 하는 앱을 사용하세요.",
            "부정적인 뉴스를 언팔로우하고 우울감을 유발하는 계정을 숨기세요."
        ],
        "nl": [
            "Zet je scherm op grijstinten om social media minder stimulerend te maken.",
            "Verwijder social media-apps van je telefoon en gebruik ze alleen op de pc.",
            "Gebruik apps die je 10 seconden laten wachten voordat je Instagram opent.",
            "Ontvolg negatief nieuws en negeer accounts die doomscrolling veroorzaken."
        ],
        "pl": [
            "Ustaw ekran telefonu na odcienie szarości, aby media społecznościowe były mniej stymulujące.",
            "Usuń aplikacje społecznościowe z telefonu i używaj ich tylko na komputerze.",
            "Używaj aplikacji, które wymuszają 10 sekund czekania przed otwarciem Instagrama.",
            "Przestań obserwować negatywne wiadomości i wycisz konta wywołujące doomscrolling."
        ],
        "pt": [
            "Coloque a ecrã do seu telefone em tons de cinza para tornar as redes sociais menos estimulantes.",
            "Elimine as aplicações de redes sociais do telemóvel e use-as apenas no computador.",
            "Use aplicações que o obrigam a esperar 10 segundos antes de abrir o Instagram.",
            "Deixe de seguir notícias negativas e silencie contas que desencadeiam o doomscrolling."
        ],
        "tr": [
            "Sosyal medya akışlarını daha az çekici hale getirmek için ekranınızı gri tonlamaya alın.",
            "Sosyal medya uygulamalarını telefonunuzdan silin ve sadece bilgisayarda kullanın.",
            "Instagram'ı açmadan önce 10 saniye beklemenizi sağlayan uygulamalar kullanın.",
            "Olumsuz haberleri takipten çıkın ve doomscrolling'e neden olan hesapları sessize alın."
        ]
    }
}

for lang in languages:
    filepath = os.path.join(base_dir, f"{lang}.lproj", "Localizable.strings")
    if not os.path.exists(filepath):
        print(f"Skipping {lang}, file not found: {filepath}")
        continue
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    for habit_id, lang_dict in translations.items():
        tips = lang_dict.get(lang, lang_dict["en"]) # Fallback to English
        for i in range(4):
            key = f'"trash.{habit_id}.tip.{i+1}"'
            new_val = f'{key} = "{tips[i]}";'
            content = re.sub(rf'{key}\s*=\s*".*?";', new_val, content)
            
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
        
print("Updated tips for junk_mail_abo, endlos_scroll_tv, doomscrolling_handy across all languages.")
