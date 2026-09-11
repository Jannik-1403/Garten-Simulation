import json

path = "Garten_Simulation/Localizable.xcstrings"

translations = {
    "water.goal.explanation": {
        "de": "Dein Tagesziel berechnet sich dynamisch: Dein Körpergewicht × 33 ml als Basisbedarf. Pro 1.000 Schritte (ab 8.000) kommen 150 ml hinzu. Pro 15 Min. Ausdauer gibt es +400 ml und pro 15 Min. Krafttraining +200 ml. Du kannst es aber auch manuell überschreiben.",
        "en": "Your daily goal is calculated dynamically: Your body weight × 33 ml as a baseline. For every 1,000 steps (above 8,000), 150 ml are added. Every 15 min of endurance adds +400 ml, and every 15 min of strength training adds +200 ml. You can also overwrite it manually.",
        "es": "Tu objetivo diario se calcula dinámicamente: tu peso corporal × 33 ml como base. Por cada 1.000 pasos (a partir de 8.000), se añaden 150 ml. Cada 15 min de resistencia añade +400 ml, y cada 15 min de entrenamiento de fuerza añade +200 ml. También puedes sobrescribirlo manualmente.",
        "fr": "Votre objectif quotidien est calculé dynamiquement : votre poids × 33 ml comme base. Pour chaque 1 000 pas (au-delà de 8 000), 150 ml sont ajoutés. Chaque 15 min d'endurance ajoute +400 ml, et chaque 15 min de musculation ajoute +200 ml. Vous pouvez également le modifier manuellement.",
        "hi": "आपका दैनिक लक्ष्य गतिशील रूप से गणना किया जाता है: आपके शरीर का वजन × 33 मिली बेसलाइन के रूप में। प्रत्येक 1,000 कदम (8,000 से ऊपर) पर 150 मिली जोड़ा जाता है। प्रत्येक 15 मिनट की सहनशक्ति +400 मिली जोड़ती है, और प्रत्येक 15 मिनट की ताकत प्रशिक्षण +200 मिली जोड़ती है। आप इसे मैन्युअल रूप से भी ओवरराइट कर सकते हैं।",
        "it": "Il tuo obiettivo giornaliero è calcolato dinamicamente: il tuo peso corporeo × 33 ml come base. Per ogni 1.000 passi (oltre gli 8.000), vengono aggiunti 150 ml. Ogni 15 minuti di resistenza aggiungono +400 ml e ogni 15 minuti di allenamento per la forza aggiungono +200 ml. Puoi anche sovrascriverlo manualmente.",
        "ja": "1日の目標は動的に計算されます。基準として体重×33ml。8,000歩以上の1,000歩ごとに150mlが追加されます。持久力トレーニング15分ごとに+400ml、筋力トレーニング15分ごとに+200mlが追加されます。手動で上書きすることも可能です。",
        "ko": "일일 목표는 동적으로 계산됩니다. 체중 × 33ml가 기준입니다. 8,000보 이상의 1,000보마다 150ml가 추가됩니다. 지구력 훈련 15분마다 +400ml, 근력 훈련 15분마다 +200ml가 추가됩니다. 수동으로 덮어쓸 수도 있습니다.",
        "nl": "Je dagelijkse doel wordt dynamisch berekend: je lichaamsgewicht × 33 ml als basis. Voor elke 1.000 stappen (boven 8.000) wordt 150 ml toegevoegd. Elke 15 min uithoudingsvermogen voegt +400 ml toe, en elke 15 min krachttraining voegt +200 ml toe. Je kunt het ook handmatig overschrijven.",
        "pl": "Twój dzienny cel jest obliczany dynamicznie: Twoja masa ciała × 33 ml jako podstawa. Za każde 1000 kroków (powyżej 8000) dodawane jest 150 ml. Każde 15 min treningu wytrzymałościowego to dodatkowe +400 ml, a 15 min treningu siłowego to +200 ml. Możesz go również nadpisać ręcznie.",
        "pt": "O seu objetivo diário é calculado dinamicamente: o seu peso corporal × 33 ml como base. Por cada 1.000 passos (acima de 8.000), são adicionados 150 ml. Cada 15 min de resistência adiciona +400 ml, e cada 15 min de treino de força adiciona +200 ml. Também pode sobrescrevê-lo manualmente.",
        "pt-BR": "O seu objetivo diário é calculado dinamicamente: o seu peso corporal × 33 ml como base. Por cada 1.000 passos (acima de 8.000), são adicionados 150 ml. Cada 15 min de resistência adiciona +400 ml, e cada 15 min de treino de força adiciona +200 ml. Também pode sobrescrevê-lo manualmente.",
        "ru": "Ваша ежедневная цель рассчитывается динамически: ваш вес × 33 мл в качестве базы. За каждые 1000 шагов (свыше 8000) добавляется 150 мл. Каждые 15 минут выносливости добавляют +400 мл, а каждые 15 минут силовых тренировок - +200 мл. Вы также можете переопределить это значение вручную.",
        "tr": "Günlük hedefiniz dinamik olarak hesaplanır: temel olarak vücut ağırlığınız × 33 ml. 8.000'in üzerindeki her 1.000 adım için 150 ml eklenir. Her 15 dakikalık dayanıklılık +400 ml, her 15 dakikalık kuvvet antrenmanı ise +200 ml ekler. Ayrıca manuel olarak üzerine yazabilirsiniz.",
        "zh-Hans": "您的每日目标是动态计算的：体重×33毫升作为基准。超过8000步后，每1000步增加150毫升。每15分钟耐力训练增加+400毫升，每15分钟力量训练增加+200毫升。您也可以手动覆盖。",
        "zh-Hant": "您的每日目標是動態計算的：體重×33毫升作為基準。超過8000步後，每1000步增加150毫升。每15分鐘耐力訓練增加+400毫升，每15分鐘力量訓練增加+200毫升。您也可以手動覆蓋。"
    }
}

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

for key, langs in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {}
        }
    
    for lang, val in langs.items():
        data["strings"][key]["localizations"][lang] = {
            "stringUnit": {
                "state": "translated",
                "value": val
            }
        }

with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write('\n')

print("Explanation updated!")
