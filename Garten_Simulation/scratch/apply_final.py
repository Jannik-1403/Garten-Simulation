import json

patch = [
  {
    "key": "schwierigkeit.bestaetigen",
    "language": "tr",
    "translated_text": "Zorluğu onayla"
  },
  {
    "key": "trash.alkohol_flatrate.impact",
    "language": "tr",
    "translated_text": "Bu alışkanlık (Alkol içmek) uzun vadede sana enerji, zaman ve para kaybettirir. Tam potansiyeline ulaşmanı engeller."
  },
  {
    "key": "trash.doener_dauerkarte.impact",
    "language": "ja",
    "translated_text": "この習慣（ファストフードの食べ過ぎ）は、長期的にエネルギー、時間、お金の無駄になります。あなたの潜在能力を最大限に発揮するのを妨げます。"
  },
  {
    "key": "trash.doener_dauerkarte.impact",
    "language": "ko",
    "translated_text": "이 습관(패스트푸드 과식)은 장기적으로 당신의 에너지, 시간, 돈을 낭비하게 합니다. 당신의 잠재력을 최대한 발휘하는 것을 방해합니다."
  },
  {
    "key": "trash.junk_mail_abo.tips",
    "language": "ja",
    "translated_text": "**悪い習慣を断ち切る（スパムと気晴らし）**\n1. 見えないようにする：トリガーを視界から取り除く。\n2. 魅力的にしない：否定的な結果を意識する。\n3. 難しくする：ハードルを設ける（アプリの削除、プラグを抜くなど）。\n4. 満足できないようにする：実行と罰を結びつける。\n\n**良い習慣を確立する（デジタルデトックス）**\n1. はっきりさせる：トリガーを見やすい場所に配置する。\n2. 魅力的にする：好きなことと結びつける。\n3. 簡単にする：ハードルを最小限に抑える（例：2分間だけ）。\n4. 満足できるものにする：実行した直後に自分にご褒美をあげる。"
  },
  {
    "key": "Wiederherstellung erfolgreich",
    "language": "ja",
    "translated_text": "復元に成功しました"
  },
  {
    "key": "Wiederherstellung erfolgreich",
    "language": "ko",
    "translated_text": "복원 성공"
  },
  {
    "key": "Wiederherstellung erfolgreich",
    "language": "tr",
    "translated_text": "Geri yükleme başarılı"
  }
]

catalog_file = "Localizable.xcstrings"
with open(catalog_file, "r") as f:
    catalog = json.load(f)

count = 0
for p in patch:
    key = p["key"]
    lang = p["language"]
    translated = p["translated_text"]
    
    if key in catalog["strings"]:
        if "localizations" not in catalog["strings"][key]:
            catalog["strings"][key]["localizations"] = {}
        if lang not in catalog["strings"][key]["localizations"]:
            catalog["strings"][key]["localizations"][lang] = {}
        
        catalog["strings"][key]["localizations"][lang]["stringUnit"] = {
            "state": "translated",
            "value": translated
        }
        count += 1
    else:
        print(f"Warning: Key {key} not found in catalog!")

with open(catalog_file, "w") as f:
    json.dump(catalog, f, indent=2, ensure_ascii=False)

print(f"Successfully applied {count} patches.")
