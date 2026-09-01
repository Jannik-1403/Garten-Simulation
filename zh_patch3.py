import json

patch_data = {
  "Aber es gibt Momente im Leben, da musst du deine Energie komplett fokussieren, wenn du gewinnen willst.": "但是生活中有些时候，如果你想赢，你就必须完全集中精力。",
  "Alles ist an seinem Platz. Wenn du dir noch mehr Struktur wünschst, versuche, deine Gewohnheiten in Clustern (Habit Stacking) zu organisieren.": "一切都在其位。如果你想要更多的结构，试着将你的习惯分组（习惯叠加）。",
  "An diesen Tagen brennt das Feuer richtig. Analysiere, was an diesen Tagen anders ist, und versuche, diese Bedingungen öfter zu schaffen.": "在这些日子里，热情高涨。分析这些日子有什么不同，并尝试更多地创造这些条件。",
  "An jedem Tag etwas zu machen – selbst wenn es nur 5 Minuten sind – ist der Schlüssel. Lass die Kette nicht abreißen.": "每天做点什么——即使只有 5 分钟——是关键。不要让链条断裂。",
  "Ausgezeichnete Balance! Du bist auf dem Weg, ein echter Meister deiner Zeit zu werden.": "出色的平衡！你正在成为真正的时间大师的路上。",
  "Baue jeden Tag ein kleines Erfolgserlebnis ein. Das Momentum kommt von alleine, wenn du einfach anfängst.": "每天建立一个小小的成就感。只要你开始，动力就会随之而来。",
  "Bevor du deinen Tag planst, atme einmal tief durch. Überlege dir genau, welche 1-2 Aufgaben heute WIRKLICH wichtig sind.": "在计划你的一天之前，深呼吸。仔细考虑今天哪1-2个任务才是真正重要的。",
  "Behalte diesen Fokus bei und du wirst erstaunliche Ergebnisse erzielen.": "保持这种专注，你会取得惊人的成绩。",
  "Bleib dran und versuche, auch die anderen Gewohnheiten langsam wieder in deinen Alltag zu integrieren.": "坚持下去，尝试慢慢地将其他习惯重新融入你的日常生活。",
  "Bleib dran, der Weg ist das Ziel!": "坚持下去，旅程本身就是目的！",
  "Das ist der perfekte Weg, um langfristig erfolgreich zu sein.": "这是长期成功的完美方式。",
  "Das ist die wichtigste Regel für nachhaltigen Erfolg.": "这是持久成功的最重要规则。",
  "Das ist eine solide Leistung, auf der du aufbauen kannst.": "这是一个坚实的成绩，你可以在此基础上再接再厉。",
  "Das meiste Potenzial liegt in der Beständigkeit.": "最大的潜力在于持久性。",
  "Dein aktueller Spielstand wird vollständig überschrieben. Diese Aktion kann nicht rückgängig gemacht werden.": "您当前的保存进度将被完全覆盖。此操作无法撤消。",
  "Deine Bemühungen zahlen sich aus!": "你的努力正在得到回报！",
  "Dein Fokus auf die wichtigen Dinge ist beeindruckend.": "你对重要事情的专注令人印象深刻。",
  "Die Balance zwischen Anspannung und Entspannung ist entscheidend.": "紧张与放松之间的平衡至关重要。",
  "Die Richtung stimmt. Wenn du jetzt noch etwas mehr Konstanz reinbringst, bist du nicht mehr aufzuhalten.": "方向是对的。如果你现在能增加一些稳定性，你将势不可挡。",
  "Diese Disziplin ist bewundernswert.": "这种纪律令人钦佩。",
  "Diese Phase ist normal. Nutze sie, um Kraft zu tanken und dich neu auszurichten.": "这个阶段很正常。用它来恢复体力并重新调整自己。",
  "Diese Regelmäßigkeit ist das Fundament für alles Weitere.": "这种规律性是未来一切的基础。",
  "Diese Woche warst du sehr aktiv.": "你这周非常活跃。",
  "Diese Woche war von Höhen und Tiefen geprägt.": "本周充满了起伏。",
  "Du bist auf einem sehr guten Weg!": "你走在非常好的道路上！",
  "Du bist der Architekt deiner Realität.": "你是自己现实的建筑师。",
  "Du bist ein Vorbild an Konstanz.": "你是一致性的榜样。",
  "Du bringst eine fantastische Energie in deine Projekte.": "你为你的项目带来了极好的能量。",
  "Du denkst langfristig. Das ist der Schlüssel zum Erfolg.": "你在长远考虑。这是成功的关键。",
  "Du erforschst neue Möglichkeiten.": "你正在探索新的可能性。",
  "Du erreichst deine Ziele mit Leichtigkeit.": "你轻松实现目标。",
  "Du gehst systematisch vor.": "你系统地进行。",
  "Du hast bereits 2 Jahre und 10.000€ in ein Projekt gesteckt. Du erkennst heute glasklar: Es ist eine Sackgasse und macht dich unglücklich.": "你已经在一个项目上投入了2年时间和10,000欧元。今天你清楚地意识到：这是一个死胡同，让你感到不快乐。",
  "Du hast das Steuer fest in der Hand.": "你牢牢掌握着方向盘。",
  "Du hast den Rhythmus gefunden.": "你找到了节奏。",
  "Du hast diese Woche solide Ergebnisse geliefert.": "你这周交出了坚实的答卷。",
  "Du hast eine klare Vision.": "你有清晰的愿景。",
  "Du hast eine unglaubliche Dynamik entwickelt.": "你发展出了不可思议的动力。",
  "Du hast ein gutes Gleichgewicht gefunden.": "你找到了很好的平衡。",
  "Du hast Großes vor.": "你有宏伟的计划。",
  "Du hast in dieser Woche ein starkes Fundament gelegt.": "你这周打下了坚实的基础。",
  "Du hast viel Potenzial.": "你有很大潜力。",
  "Du investierst viel in dich selbst.": "你在自己身上投入了很多。",
  "Du kennst deine Prioritäten.": "你知道你的优先事项。",
  "Du lässt dich nicht aus der Ruhe bringen.": "你不轻易被扰乱。",
  "Du machst stetig Fortschritte.": "你在稳步取得进展。",
  "Du nutzt deine Zeit effizient.": "你有效利用时间。",
  "Du passt dich schnell an neue Situationen an.": "你能快速适应新情况。",
  "Du priorisierst geschickt.": "你巧妙地确定优先级。",
  "Du ruhst in dir selbst.": "你泰然自若。",
  "Du setzt deine Energie gezielt ein.": "你有针对性地使用精力。",
  "Du setzt klare Grenzen.": "你设定了明确的界限。",
  "Du spielst auf hohem Level. Die Marginal Gains für Eliten liegen in der Demut und dem Zurückgeben.": "你处于高水平。精英的边际收益在于谦逊和回馈。",
  "Du triffst klare Entscheidungen.": "你做出明确的决定。",
  "Du verfolgst deine Ziele mit Nachdruck.": "你坚定地追求目标。",
  "Du weißt, was zu tun ist.": "你知道该怎么做。",
  "Du zeigst eine hohe Resilienz.": "你展现出很高的韧性。",
  "Ein solider Start in die Woche.": "本周有一个坚实的开局。",
  "Es geht nicht darum, perfekt zu sein, sondern besser als gestern.": "这不在于完美，而在于比昨天更好。",
  "Es ist okay, auch mal einen schlechten Tag zu haben.": "偶尔有糟糕的一天也没关系。",
  "Finde heraus, was an den schwächeren Tagen los war, und lerne daraus.": "找出较弱的日子里发生了什么，并从中吸取教训。",
  "Fokus ist deine Superkraft.": "专注是你的超能力。",
  "Gönn dir eine Pause, du hast sie dir verdient.": "休息一下，这是你应得的。",
  "Jeder Schritt zählt, egal wie klein.": "每一步都很重要，无论多小。",
  "Kontinuität schlägt Intensität.": "持续性胜过强度。",
  "Lass dich nicht von Rückschlägen entmutigen.": "不要被挫折气馁。",
  "Mach weiter so!": "继续保持！",
  "Nimm dir Zeit für dich.": "花点时间给自己。",
  "Qualität vor Quantität.": "质量胜于数量。",
  "Schritt für Schritt kommst du ans Ziel.": "一步一步，你会达到目标。",
  "Setze dir kleine, erreichbare Ziele.": "设定小而可实现的目标。",
  "Vergleiche dich nicht mit anderen, sondern nur mit deinem gestrigen Ich.": "不要与别人比较，只与昨天的自己比较。",
  "Vertraue dem Prozess.": "相信这个过程。",
  "Wenn du so weitermachst, wirst du Großes erreichen.": "如果你继续这样下去，你将取得伟大的成就。",
  "Wirf einen Blick auf deine Gewohnheiten und schau, wo du optimieren kannst.": "看看你的习惯，看看哪里可以优化。",
  "Zeitmanagement ist der Schlüssel.": "时间管理是关键。",
  "Zieh dein Ding durch!": "坚持做你自己的事！"
}

with open("Garten_Simulation/Localizable.xcstrings", "r") as f:
    data = json.load(f)

count = 0
for key, zh_text in patch_data.items():
    if key in data["strings"]:
        if "localizations" not in data["strings"][key]:
            data["strings"][key]["localizations"] = {}
        data["strings"][key]["localizations"]["zh-Hans"] = {"stringUnit": {"state": "translated", "value": zh_text}}
        data["strings"][key]["localizations"]["zh-Hant"] = {"stringUnit": {"state": "translated", "value": zh_text}}
        count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Patched {count} keys for Chinese part 3.")
