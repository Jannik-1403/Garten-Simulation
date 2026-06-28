import re
import json

with open("Localization/AppStrings.swift", "r") as f:
    lines = f.readlines()

for idx, line in enumerate(lines):
    if '": ["de":' in line and '"it":' not in line:
        print(f"Missing IT on line {idx+1}: {line.strip()}")
