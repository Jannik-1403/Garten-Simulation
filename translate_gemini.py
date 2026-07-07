import json
import os
import time
from google import genai
from google.genai import types

API_KEY = "AQ.Ab8RN6JRdPbUZE0-vP-Y5RHYA_JfwJkv6ERBQ_IE7k8yUlqY5g"
client = genai.Client(api_key=API_KEY)

file_path = 'Garten_Simulation/Localizable.xcstrings'

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

langs = {
    'ru': 'Russian',
    'hi': 'Hindi',
    'zh-Hans': 'Simplified Chinese',
    'zh-Hant': 'Traditional Chinese'
}

batch_size = 50

def translate_batch(batch_dict, target_lang_name):
    prompt = f"""You are a professional iOS app translator. Translate the following JSON string values from German to {target_lang_name}.
Keep the JSON keys exactly the same.
CRITICAL RULES:
- NEVER translate format specifiers like %d, %@, %lld, %f, %1$@, etc. They MUST remain exactly as they are in the source string.
- Keep the exact same punctuation and capitalization formatting as the source string.
- Return ONLY valid JSON where keys match the input and values are translated.
Input JSON:
{json.dumps(batch_dict, ensure_ascii=False)}
"""
    retries = 3
    for attempt in range(retries):
        try:
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    temperature=0.1
                )
            )
            return json.loads(response.text)
        except Exception as e:
            print(f"Error on attempt {attempt+1}: {e}")
            time.sleep(2)
    return None

for apple_lang, lang_name in langs.items():
    print(f"Starting {lang_name} ({apple_lang})...")
    
    missing_dict = {}
    
    # Collect all missing
    for key, value in data.get('strings', {}).items():
        locs = value.setdefault('localizations', {})
        if apple_lang not in locs or locs[apple_lang].get('stringUnit', {}).get('state') != 'translated':
            src = key
            if 'de' in locs and locs['de'].get('stringUnit', {}).get('state') == 'translated':
                src = locs['de']['stringUnit']['value']
            
            if src.strip(): # Skip empty strings
                missing_dict[key] = src

    print(f"Total missing for {apple_lang}: {len(missing_dict)}")
    
    # Create batches
    keys_list = list(missing_dict.keys())
    for i in range(0, len(keys_list), batch_size):
        batch_keys = keys_list[i:i+batch_size]
        batch_input = {k: missing_dict[k] for k in batch_keys}
        
        print(f"Translating batch {i//batch_size + 1}/{(len(keys_list) + batch_size - 1)//batch_size}...")
        
        translated_batch = translate_batch(batch_input, lang_name)
        if translated_batch:
            for k in batch_keys:
                if k in translated_batch:
                    # Update data
                    data['strings'][k]['localizations'][apple_lang] = {
                        "stringUnit": {
                            "state": "translated",
                            "value": translated_batch[k]
                        }
                    }
            
            # Save progress
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        
        time.sleep(1) # Small sleep to avoid quota issues

print("All Gemini translations completed!")
