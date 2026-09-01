import json
import urllib.request
import urllib.parse
from concurrent.futures import ThreadPoolExecutor, as_completed

def translate_text(text, target_lang):
    if not text.strip(): return ""
    url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=de&tl={target_lang}&dt=t&q={urllib.parse.quote(text)}"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            res = json.loads(response.read().decode())
            translated = "".join([x[0] for x in res[0] if x[0]])
            return translated
    except Exception as e:
        print(f"Error translating '{text[:20]}': {e}")
        return None

with open("fake_strings.json", "r") as f:
    fake_dict = json.load(f)

print(f"Translating {len(fake_dict)} strings to zh-CN and zh-TW...")

translations = {} # { key: (zh-Hans, zh-Hant) }

def process_key(key, source):
    zh_cn = translate_text(source, "zh-CN")
    zh_tw = translate_text(source, "zh-TW")
    return key, zh_cn, zh_tw

with ThreadPoolExecutor(max_workers=5) as executor:
    futures = [executor.submit(process_key, k, v) for k, v in fake_dict.items()]
    for future in as_completed(futures):
        k, cn, tw = future.result()
        if cn and tw:
            translations[k] = (cn, tw)

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

count = 0
for k, (cn, tw) in translations.items():
    if k in data["strings"]:
        if "localizations" not in data["strings"][k]:
            data["strings"][k]["localizations"] = {}
        data["strings"][k]["localizations"]["zh-Hans"] = {"stringUnit": {"state": "translated", "value": cn}}
        data["strings"][k]["localizations"]["zh-Hant"] = {"stringUnit": {"state": "translated", "value": tw}}
        count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Successfully patched {count} strings in Localizable.xcstrings.")
