import re

file_path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"

with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

new_string = """        "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!": ["de": "Du warst %lld Minuten lang extrem fokussiert. Die XP werden auf alle deine Pflanzen aufgeteilt!", "en": "You were extremely focused for %lld minutes. The XP will be distributed among all your plants!", "es": "Estuviste extremadamente enfocado durante %lld minutos. ¡La experiencia se repartirá entre todas tus plantas!", "fr": "Tu as été extrêmement concentré pendant %lld minutes. L'XP sera répartie entre toutes tes plantes !", "it": "Sei stato estremamente concentrato per %lld minuti. I punti XP saranno divisi tra tutte le tue piante!", "pt": "Ficaste extremamente focado durante %lld minutos. O XP será distribuído por todas as tuas plantas!", "ja": "あなたは %lld 分間、非常に集中していました。XPはすべての植物に分配されます！", "ko": "당신은 %lld분 동안 극도로 집중했습니다. XP는 모든 식물에게 분배됩니다!", "pl": "Byłeś ekstremalnie skupiony przez %lld minut. Punkty doświadczenia zostaną rozdzielone na wszystkie twoje rośliny!", "nl": "Je was %lld minuten lang extreem gefocust. De XP wordt over al je planten verdeeld!", "tr": "%lld dakika boyunca son derece odaklanmıştınız. XP tüm bitkilerinize dağıtılacak!"],"""

# Find the end of the dictionary
end_idx = content.rfind("]")
end_idx = content.rfind("}", 0, end_idx) # Find the end of the dictionary
if end_idx != -1:
    last_comma_idx = content.rfind(",", 0, end_idx)
    # Just append before the last closing brace
    content = content[:end_idx] + "\n" + new_string + "\n" + content[end_idx:]

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Injected string successfully.")
else:
    print("Could not find dictionary end.")

