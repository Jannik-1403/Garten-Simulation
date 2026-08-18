import os

translations = {
    'NSCalendarsFullAccessUsageDescription': {
        'de': 'Grovy benötigt deinen Kalender, damit du Termine per Drag & Drop in deine Timer ziehen kannst.',
        'en': 'Grovy needs access to your calendar so you can drag & drop events into your timers.',
        'es': 'Grovy necesita acceso a tu calendario para que puedas arrastrar y soltar eventos en tus temporizadores.',
        'fr': 'Grovy a besoin d\'accéder à votre calendrier pour que vous puissiez glisser-déposer des événements dans vos minuteurs.',
        'it': 'Grovy ha bisogno di accedere al tuo calendario per permetterti di trascinare gli eventi nei tuoi timer.',
        'ja': 'タイマーに予定をドラッグ＆ドロップできるように、Grovyにカレンダーへのアクセスを許可してください。',
        'ko': '타이머에 이벤트를 드래그 앤 드롭할 수 있도록 Grovy의 캘린더 접근을 허용해주세요.',
        'nl': 'Grovy heeft toegang tot je agenda nodig zodat je afspraken naar je timers kunt slepen.',
        'pl': 'Grovy potrzebuje dostępu do Twojego kalendarza, abyś mógł przeciągać i upuszczać wydarzenia do swoich minutników.',
        'pt': 'O Grovy precisa de acesso ao seu calendário para que você possa arrastar e soltar eventos em seus cronômetros.',
        'tr': 'Grovy\'nin, etkinlikleri zamanlayıcılarınıza sürükleyip bırakabilmeniz için takviminize erişmesi gerekiyor.',
    },
    'NSHealthShareUsageDescription': {
        'de': 'Grovy nutzt Apple Health, um deine Gesundheitsziele (z. B. Schritte, Schlaf) mit deinem Garten-Fortschritt zu synchronisieren.',
        'en': 'Grovy uses Apple Health to synchronize your health goals (e.g. steps, sleep) with your garden progress.',
        'es': 'Grovy usa Apple Health para sincronizar tus metas de salud (ej. pasos, sueño) con el progreso de tu jardín.',
        'fr': 'Grovy utilise Apple Health pour synchroniser vos objectifs de santé (ex. pas, sommeil) avec la progression de votre jardin.',
        'it': 'Grovy usa Apple Health per sincronizzare i tuoi obiettivi di salute (es. passi, sonno) con i progressi del tuo giardino.',
        'ja': 'GrovyはApple Healthを利用して、健康目標（歩数、睡眠など）を庭の成長と同期します。',
        'ko': 'Grovy는 Apple Health를 사용하여 건강 목표(예: 걸음 수, 수면)를 정원의 성장과 동기화합니다.',
        'nl': 'Grovy gebruikt Apple Health om je gezondheidsdoelen (bijv. stappen, slaap) te synchroniseren met de voortgang in je tuin.',
        'pl': 'Grovy korzysta z Apple Health, aby zsynchronizować Twoje cele zdrowotne (np. kroki, sen) z postępami w ogrodzie.',
        'pt': 'O Grovy usa o Apple Health para sincronizar suas metas de saúde (ex. passos, sono) com o progresso do seu jardim.',
        'tr': 'Grovy, sağlık hedeflerinizi (örn. adımlar, uyku) bahçenizin gelişimiyle senkronize etmek için Apple Health\'i kullanır.',
    },
    'NSHealthUpdateUsageDescription': {
        'de': 'Grovy nutzt Apple Health, um deine Gesundheitsziele mit deinem Garten-Fortschritt zu synchronisieren.',
        'en': 'Grovy uses Apple Health to synchronize your health goals with your garden progress.',
        'es': 'Grovy usa Apple Health para sincronizar tus metas de salud con el progreso de tu jardín.',
        'fr': 'Grovy utilise Apple Health pour synchroniser vos objectifs de santé avec la progression de votre jardin.',
        'it': 'Grovy usa Apple Health per sincronizzare i tuoi obiettivi di salute con i progressi del tuo giardino.',
        'ja': 'GrovyはApple Healthを利用して、健康目標を庭の成長と同期します。',
        'ko': 'Grovy는 Apple Health를 사용하여 건강 목표를 정원의 성장과 동기화합니다.',
        'nl': 'Grovy gebruikt Apple Health om je gezondheidsdoelen te synchroniseren met de voortgang in je tuin.',
        'pl': 'Grovy korzysta z Apple Health, aby zsynchronizować Twoje cele zdrowotne z postępami w ogrodzie.',
        'pt': 'O Grovy usa o Apple Health para sincronizar suas metas de saúde com o progresso do seu jardim.',
        'tr': 'Grovy, sağlık hedeflerinizi bahçenizin gelişimiyle senkronize etmek için Apple Health\'i kullanır.',
    },
    'NSPhotoLibraryAddUsageDescription': {
        'de': 'Grovy möchte dein exportiertes Statistik- oder Erfolgsbild direkt in deiner Fotogalerie speichern.',
        'en': 'Grovy would like to save your exported statistics or achievement image directly to your photo gallery.',
        'es': 'Grovy desea guardar la imagen de tus estadísticas o logros exportada directamente en tu galería de fotos.',
        'fr': 'Grovy souhaite enregistrer votre image de statistiques ou de réussite exportée directement dans votre galerie de photos.',
        'it': 'Grovy desidera salvare l\'immagine delle tue statistiche o dei tuoi risultati esportata direttamente nella tua galleria fotografica.',
        'ja': 'Grovyはエクスポートした統計や達成画像の画像を直接フォトギャラリーに保存します。',
        'ko': 'Grovy가 내보낸 통계 또는 달성 이미지를 사진 갤러리에 직접 저장하려고 합니다.',
        'nl': 'Grovy wil je geëxporteerde statistieken of prestatie-afbeelding direct in je fotogalerij opslaan.',
        'pl': 'Grovy chce zapisać wyeksportowane statystyki lub obraz osiągnięcia bezpośrednio w Twojej galerii zdjęć.',
        'pt': 'O Grovy deseja salvar sua imagem exportada de estatísticas ou conquistas diretamente na sua galeria de fotos.',
        'tr': 'Grovy, dışa aktarılan istatistiklerinizi veya başarı görselinizi doğrudan fotoğraf galerinize kaydetmek istiyor.',
    }
}

lproj_dirs = [d for d in os.listdir('Garten_Simulation') if d.endswith('.lproj')]

for lproj in lproj_dirs:
    lang = lproj.replace('.lproj', '')
    if lang == 'Base':
        continue
    
    file_path = os.path.join('Garten_Simulation', lproj, 'InfoPlist.strings')
    
    with open(file_path, 'w', encoding='utf-8') as f:
        for key, lang_dict in translations.items():
            text = lang_dict.get(lang, lang_dict['en']) # Fallback to English
            text = text.replace('"', '\\"')
            f.write(f'"{key}" = "{text}";\n')
    
    print(f"Generated {file_path}")
