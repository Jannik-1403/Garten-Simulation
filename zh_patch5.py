import json

patch_data = {
  "assessment.finance.worst.entscheidung": "你在推迟财务决定。拖延不仅浪费时间，还浪费金钱。",
  "assessment.finance.worst.kontrolle": "你经常对自己的财务状况缺乏了解。这会导致盲目消费和自我破坏。是时候接受现实了。",
  "assessment.finance.worst.risiko": "你冲动行事，承担无法估量的风险。短期的多巴胺会破坏你长期的财富积累。",
  "assessment.fitness.worst.intensitaet": "你并没有真正挑战自己。如果你总是呆在舒适区，你的身体就会停滞不前。",
  "assessment.fitness.worst.konsistenz": "你训练不规律。健身不是短跑，而是马拉松。你缺乏持久性。",
  "assessment.fitness.worst.verantwortung": "你在找借口。你必须对自己的身体状况负全部责任。",
  "assessment.growth.worst.disziplin": "你依赖动力而不是纪律。没有一致性就不会有成长。",
  "assessment.growth.worst.effizienz": "你工作很努力，但不够聪明。你把精力浪费在错误的事情上。",
  "assessment.growth.worst.umsetzung": "你计划很多，但没有付诸实践。没有执行力，想法毫无价值。",
  "assessment.health.worst.kraftstoff": "你饮食不佳或喝水太少。你没有给身体提供它需要的能量。",
  "assessment.health.worst.praevention": "你忽视了身体发出的警报信号，直到为时已晚。预防胜于治疗。",
  "assessment.health.worst.regeneration": "你牺牲了睡眠和休息。没有恢复，你的身体就会崩溃。你在透支自己。",
  "assessment.lifestyle.worst.einfluss": "你太受外部因素的控制。掌控你的时间和精力。",
  "assessment.lifestyle.worst.standards": "你太容易满足。提高你的标准，过更好的生活。",
  "assessment.lifestyle.worst.umfeld": "你的环境拖累了你。你是与你相处时间最长的5个人的平均值。",
  "assessment.mental.worst.ego": "你把自我价值太依赖于别人的意见。这让你变得容易被控制。",
  "assessment.mental.worst.fokus": "你很容易分心，偏离目标。你目前的注意力太被动了。",
  "assessment.mental.worst.resilienz": "遇到挫折时你很快就会崩溃。当风暴来临时，你必须学会保持情绪稳定。",
  "assessment.roadmap.add_habit": "接受挑战",
  "assessment.roadmap.habit_added": "已添加！",
  "assessment.roadmap.phase1.title": "第一阶段：意识",
  "assessment.roadmap.phase2.title": "第二阶段：行动",
  "assessment.roadmap.phase3.title": "第三阶段：系统",
  "assessment.roadmap.reality_check": "现实检查",
  "assessment.roadmap.tough_love": "残酷的真相",
  "assessment.source.calculation": "计算",
  "assessment.source.cat.avg": "平均：得分在 0 到 -10 之间",
  "assessment.source.cat.below_avg": "低于平均水平：得分低于 -10",
  "assessment.source.cat.top10": "前 10％：得分超过 +15",
  "assessment.source.cat.top30": "前 30％：得分超过 0",
  "assessment.source.categories": "类别",
  "assessment.source.fin.control": "财务控制：",
  "assessment.source.fin.decision": "决定：",
  "assessment.source.fin.percentile": "你的百分位数 = (得分 + 41) / 82",
  "assessment.source.fin.q1": "问题 1：对意外还款的反应",
  "assessment.source.fin.q2": "问题 2：投资应用行为",
  "assessment.source.fin.q3": "问题 3：不看余额的账户余额（财务控制）",
  "assessment.source.fin.q4": "问题 4：对不必要的订阅的反应（预算决定）",
  "assessment.source.fin.q6": "问题 6：生活方式膨胀行为（风险对冲）",
  "assessment.source.fin.q7": "问题 7：地位 vs. 合理支出"
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

print(f"Patched {count} keys for Chinese part 5.")
