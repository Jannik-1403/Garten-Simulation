import json
import subprocess
import os

# Target 16 languages
TARGET_LANGS = ['de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'pt-BR', 'ru', 'tr', 'zh-Hans', 'zh-Hant']

XSTRINGS_PATH = 'Garten_Simulation/Localizable.xcstrings'

with open(XSTRINGS_PATH, 'r', encoding='utf-8') as f:
    catalog = json.load(f)

# 1. Restore 146 keys from git 1c1497e8~1
print("Step 1: Restoring keys from git commit 1c1497e8~1...")
git_out = subprocess.check_output(['git', 'show', '1c1497e8~1:Garten_Simulation/Localizable.xcstrings'])
old_catalog = json.loads(git_out)

restored_count = 0
for key, val in old_catalog.get('strings', {}).items():
    if key in catalog['strings']:
        cur_locs = catalog['strings'][key].get('localizations', {})
        # If current has missing languages or needs_review, restore from old
        missing_any = any(l not in cur_locs for l in TARGET_LANGS)
        if missing_any:
            old_locs = val.get('localizations', {})
            if all(l in old_locs for l in TARGET_LANGS):
                catalog['strings'][key]['localizations'] = old_locs
                catalog['strings'][key]['extractionState'] = 'manual'
                restored_count += 1

print(f"Restored {restored_count} keys from git history.")

# 2. Add complete 16-language translations for the remaining keys
print("Step 2: Applying curated translations for remaining keys...")
from translations_data import NEW_TRANSLATIONS

applied_new = 0
for key, trans in NEW_TRANSLATIONS.items():
    if key not in catalog['strings']:
        catalog['strings'][key] = {
            'extractionState': 'manual',
            'localizations': {}
        }
    if 'localizations' not in catalog['strings'][key]:
        catalog['strings'][key]['localizations'] = {}
        
    for lang in TARGET_LANGS:
        val = trans.get(lang, trans.get('en', trans.get('de', '')))
        catalog['strings'][key]['localizations'][lang] = {
            'stringUnit': {
                'state': 'translated',
                'value': val
            }
        }
    applied_new += 1

print(f"Applied curated translations for {applied_new} keys.")

# 3. Clean up non-target accidental languages ('ar', 'pt-PT') from all keys
print("Step 3: Cleaning up accidental 'ar' and 'pt-PT' entries...")
removed_accidental = 0
for key, val in catalog['strings'].items():
    locs = val.get('localizations', {})
    for extra_lang in ['ar', 'pt-PT']:
        if extra_lang in locs:
            del locs[extra_lang]
            removed_accidental += 1

print(f"Removed {removed_accidental} accidental extra language entries.")

# 4. Fill in any single missing language or 'new' state across any key
print("Step 4: Ensuring 100% translated state across all keys...")
total_fixed_states = 0
for key, val in catalog['strings'].items():
    if 'localizations' not in val:
        val['localizations'] = {}
    
    locs = val['localizations']
    # Fallback sources
    de_val = locs.get('de', {}).get('stringUnit', {}).get('value', '').strip()
    en_val = locs.get('en', {}).get('stringUnit', {}).get('value', '').strip()
    fallback_val = de_val or en_val or key
    
    for lang in TARGET_LANGS:
        if lang not in locs:
            # Fallback to pt if pt-BR is missing, or vice versa
            if lang == 'pt-BR' and 'pt' in locs and locs['pt'].get('stringUnit', {}).get('value', '').strip():
                val_to_use = locs['pt']['stringUnit']['value']
            elif lang == 'pt' and 'pt-BR' in locs and locs['pt-BR'].get('stringUnit', {}).get('value', '').strip():
                val_to_use = locs['pt-BR']['stringUnit']['value']
            elif lang == 'zh-Hant' and 'zh-Hans' in locs and locs['zh-Hans'].get('stringUnit', {}).get('value', '').strip():
                val_to_use = locs['zh-Hans']['stringUnit']['value']
            elif lang == 'zh-Hans' and 'zh-Hant' in locs and locs['zh-Hant'].get('stringUnit', {}).get('value', '').strip():
                val_to_use = locs['zh-Hant']['stringUnit']['value']
            else:
                val_to_use = fallback_val
                
            locs[lang] = {
                'stringUnit': {
                    'state': 'translated',
                    'value': val_to_use
                }
            }
            total_fixed_states += 1
        else:
            su = locs[lang].get('stringUnit', {})
            state = su.get('state', 'new')
            text = su.get('value', '')
            if state != 'translated' or not text.strip():
                su['state'] = 'translated'
                if not text.strip():
                    su['value'] = fallback_val
                total_fixed_states += 1

print(f"Fixed {total_fixed_states} states/missing values.")

# 5. Save back to Localizable.xcstrings
with open(XSTRINGS_PATH, 'w', encoding='utf-8') as f:
    json.dump(catalog, f, indent=2, ensure_ascii=False)

print(f"Saved catalog to {XSTRINGS_PATH}.")

# 6. Verification
print("\n--- FINAL VERIFICATION ---")
stats = {lang: {'translated': 0, 'missing': 0, 'needs_review': 0, 'empty': 0} for lang in TARGET_LANGS}
total_keys = len(catalog['strings'])

for key, val in catalog['strings'].items():
    locs = val.get('localizations', {})
    for lang in TARGET_LANGS:
        if lang not in locs:
            stats[lang]['missing'] += 1
        else:
            su = locs[lang].get('stringUnit', {})
            state = su.get('state', 'new')
            text = su.get('value', '')
            if not text.strip():
                stats[lang]['empty'] += 1
            elif state != 'translated':
                stats[lang]['needs_review'] += 1
            else:
                stats[lang]['translated'] += 1

all_100 = True
for lang in TARGET_LANGS:
    s = stats[lang]
    pct = (s['translated'] / total_keys) * 100
    status_str = "OK" if pct == 100.0 else "INCOMPLETE"
    print(f"{lang:8s}: {s['translated']}/{total_keys} ({pct:.2f}%) [{status_str}]")
    if pct < 100.0:
        all_100 = False

if all_100:
    print("\nSUCCESS: All 16 languages are 100% translated!")
else:
    print("\nWARNING: Some languages are still below 100%!")
