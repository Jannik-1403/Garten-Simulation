import json

patch_data = {
  "assessment.source.fin.q12": "问题12：贪婪陷阱（高风险投资）",
  "assessment.source.fin.q14": "问题14：处理小额支出（微小漏洞）",
  "assessment.source.fin.risk": "风险对冲：",
  "assessment.source.fit.cons": "一致性：",
  "assessment.source.fit.int": "强度：",
  "assessment.source.fit.q_cons": "一致性问题：训练频率和规律性",
  "assessment.source.fit.q_int": "强度问题：您的锻炼强度",
  "assessment.source.fit.q_resp": "责任问题：对健身的个人责任",
  "assessment.source.fit.resp": "个人责任：",
  "assessment.source.gro.disc": "纪律：",
  "assessment.source.gro.eff": "效率：",
  "assessment.source.gro.exec": "执行力：",
  "assessment.source.gro.q_disc": "纪律问题：一致性，即使没有动力",
  "assessment.source.gro.q_eff": "效率问题：时间利用和优先级",
  "assessment.source.gro.q_exec": "执行问题：计划与实际行动",
  "assessment.source.hea.nutri": "燃料（营养）：",
  "assessment.source.hea.prev": "预防：",
  "assessment.source.hea.q_nutri": "营养问题：膳食计划和糖分",
  "assessment.source.hea.q_regen": "恢复问题：休息，伸展，预防",
  "assessment.source.hea.q_sleep": "睡眠问题：睡眠时长和质量",
  "assessment.source.hea.sleep": "恢复（睡眠）：",
  "assessment.source.lif.env": "环境：",
  "assessment.source.lif.inf": "影响范围：",
  "assessment.source.lif.q_env": "环境问题：你周围是谁，他们有什么影响？",
  "assessment.source.lif.q_inf": "影响问题：你是控制局面还是任其发生？",
  "assessment.source.lif.q_std": "标准问题：你设定的标准有多高？",
  "assessment.source.lif.std": "标准：",
  "assessment.source.max_possible": "可能的最大值：",
  "assessment.source.men.ego": "自我/心态：",
  "assessment.source.men.focus": "专注：",
  "assessment.source.men.q_ego": "自我问题：自我反思和心态",
  "assessment.source.men.q_focus": "专注问题：分心和深度工作",
  "assessment.source.men.q_resil": "韧性问题：对挫折和压力的反应",
  "assessment.source.men.resil": "韧性：",
  "assessment.source.min_possible": "可能的最小值：",
  "assessment.source.points": "分数",
  "assessment.source.questions": "评估中的问题",
  "assessment.source.raw_scores": "您的原始分数",
  "assessment.source.strongest_param": "你最强的参数=你的优势",
  "assessment.source.sum_3_scores": "所有3个原始分数之和：",
  "assessment.source.weakest_1": "你最低的原始分数决定了弱点。",
  "assessment.source.weakest_2": "比较所有三个参数。",
  "assessment.source.weakest_3": "最低值=最大的改进潜力。",
  "assessment.source.weakest_area": "你最弱的领域",
  "body.measure.info.brust": "在胸部最宽处测量。",
  "body.measure.info.oberschenkel": "在大腿最粗处测量。",
  "body.measure.info.taille": "在腹部最窄处测量，通常在肚脐上方。",
  "body.measure.info.unterarm": "在前臂最粗处测量。",
  "body.measure.info.waden": "在小腿最粗处测量。",
  "body.tracking.action.build": "增肌",
  "body.tracking.action.gain": "增重",
  "body.tracking.action.lose": "减肥",
  "body.tracking.action.reduce": "减少",
  "body.tracking.button.target": "目标",
  "body.tracking.change_rate_desc": "为了达到您的目标，您必须每周大约 %@ %.2f %@。这是一个健康的速度。",
  "body.tracking.easy_desc": "为了达到您的目标，您必须每周大约 %@ %.2f %@。这是一个非常轻松的节奏，如果您需要，也可以更有野心一点。",
  "body.tracking.easy_desc_adaptive": "为了达到您的目标，您需要每周 %3$@ 大约 %1$.2f %2$@。这非常轻松，理论上您也可以在 %4$d 周内完成。",
  "body.tracking.easy_goal": "非常轻松的节奏",
  "body.tracking.need_more_data": "我们需要更多数据。请定期输入您的体重，以便在此处查看您符合生物学的每周趋势（平均至平均）。",
  "body.tracking.no_manual_entries": "没有手动条目",
  "body.tracking.no_target_measurement": "未设定目标值",
  "body.tracking.no_target_weight": "未设定目标体重",
  "body.tracking.progress.on_track": "在正轨上！(%1$.2f %2$@/周)",
  "body.tracking.progress.tip_on_track": "完美！继续保持。",
  "body.tracking.progress.tip_too_fast": "提示：速成节食或减重过快是不健康的。放慢一点。",
  "body.tracking.progress.tip_too_slow": "提示：为了在选定的时间范围内实现目标，您需要挑战自己一点。",
  "body.tracking.progress.tip_wrong_gain": "提示：检查您每天的卡路里摄入量并稍微增加。",
  "body.tracking.progress.tip_wrong_lose": "提示：注意您的卡路里缺口和饮食。",
  "body.tracking.progress.too_fast": "太快：您正在以 %1$.2f %2$@/周的速度变化（计划：%3$.2f）。",
  "body.tracking.progress.too_slow": "有点太慢：只有 %1$.2f %2$@/周（计划：%3$.2f）。",
  "body.tracking.progress.wrong_way_gain": "方向错误：您减轻了 %1$.2f %2$@，而不是增加了 %3$.2f %2$@。",
  "body.tracking.progress.wrong_way_lose": "方向错误：您增加了 %1$.2f %2$@，而不是减轻了 %3$.2f %2$@。",
  "body.tracking.realistic_goal": "现实的目标",
  "body.tracking.since_2days": "从前天起",
  "body.tracking.since_date": "自 %@ 起",
  "body.tracking.since_yesterday": "从昨天起",
  "body.tracking.status.bulking.deficit.desc": "你燃烧的卡路里比你吃的多。立即增加300千卡。",
  "body.tracking.status.bulking.deficit.title": "🔴 赤字警告",
  "body.tracking.status.bulking.fat.desc": "体重增加过于猛烈。你积累了不必要的脂肪。减少200千卡。",
  "body.tracking.status.bulking.fat.title": "🔴 脂肪警告",
  "body.tracking.status.bulking.perfect.desc": "增肌进展顺利。保持宏观营养。在健身房稳步增加训练强度。",
  "body.tracking.status.bulking.perfect.title": "🟢 完美的节奏",
  "body.tracking.status.bulking.stagnation.desc": "燃料太少。从明天开始，每天增加200千卡卡路里。",
  "body.tracking.status.bulking.stagnation.title": "🟡 停滞期",
  "body.tracking.status.cutting.gain.desc": "你体重增加了而不是减轻了。每天减少300千卡。",
  "body.tracking.status.cutting.gain.title": "🔴 增加警告",
  "body.tracking.status.cutting.muscleloss.desc": "减重过于猛烈。你燃烧了宝贵的肌肉。每天增加200千卡。",
  "body.tracking.status.cutting.muscleloss.title": "🟠 肌肉流失警告",
  "body.tracking.status.cutting.perfect.desc": "脂肪燃烧进展顺利。保持宏观营养。继续进行高强度训练。",
  "body.tracking.status.cutting.perfect.title": "🟢 完美的节奏",
  "body.tracking.status.cutting.stagnation.desc": "您的减重停滞了。减少 200 千卡或增加有氧运动。",
  "body.tracking.status.cutting.stagnation.title": "🟡 停滞期",
  "body.timerange.j": "年",
  "body.timerange.m": "月",
  "body.timerange.sixm": "6个月",
  "body.timerange.t": "天",
  "body.timerange.w": "周",
  "body.tracking.unit.cm": "厘米",
  "body.tracking.unit.kg": "千克"
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
    else:
        # If the key doesn't even exist yet, create it.
        data["strings"][key] = {
            "localizations": {
                "zh-Hans": {"stringUnit": {"state": "translated", "value": zh_text}},
                "zh-Hant": {"stringUnit": {"state": "translated", "value": zh_text}}
            }
        }
        count += 1

with open("Garten_Simulation/Localizable.xcstrings", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Patched {count} keys for Chinese part 4.")
