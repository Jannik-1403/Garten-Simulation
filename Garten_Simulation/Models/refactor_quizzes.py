import re
import glob
import os

files = glob.glob('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/*AssessmentModel.swift')
files.append('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/AssessmentModel.swift')
files = list(set(files))

def refactor_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Replace all custom Answer types with AssessmentAnswer
    content = re.sub(r'(Mental|Health|Fitness|Growth|Lifestyle)Answer', 'AssessmentAnswer', content)
    # 2. Replace all custom Question types with AssessmentQuestion
    content = re.sub(r'(Mental|Health|Fitness|Growth|Lifestyle)Question', 'AssessmentQuestion', content)
    
    # 3. Replace all Deltas objects in answers with calculated single score delta
    # Old format: delta: ScoreDeltas(kontrolle: -2, entscheidung: -1, risiko: 0)
    # We want to just find the answers and assign +2, +1, -1, -2 based on their sum of values
    def answer_replacer(match):
        full_match = match.group(0)
        # Find all numbers in the delta
        nums = [int(n) for n in re.findall(r'-?\d+', match.group(1))]
        return full_match, sum(nums)

    # We need to process question by question
    # A question block looks like: AssessmentQuestion(..., answers: [ ... ])
    questions = re.finditer(r'AssessmentQuestion\(.*?answers:\s*\[(.*?)\]\s*\)', content, re.DOTALL)
    
    new_content = content
    for q_match in questions:
        q_text = q_match.group(0)
        answers_text = q_match.group(1)
        
        # Find all answers in this question
        # AssessmentAnswer(id: 0, textKey: "...", delta: ...)
        answer_matches = list(re.finditer(r'AssessmentAnswer\s*\(\s*id:\s*\d+,\s*textKey:\s*".*?",\s*delta:\s*[a-zA-Z]+\s*\((.*?)\)\s*\)', answers_text, re.DOTALL))
        
        if len(answer_matches) != 4:
            continue
            
        # Calculate sums
        sums = []
        for a_m in answer_matches:
            nums = [int(n) for n in re.findall(r'-?\d+', a_m.group(1))]
            sums.append((a_m, sum(nums)))
            
        # Sort by sum descending
        sorted_sums = sorted(sums, key=lambda x: x[1], reverse=True)
        # Assign points: +2, +1, -1, -2
        points = [2, 1, -1, -2]
        
        new_answers_text = answers_text
        for i, (a_m, _) in enumerate(sorted_sums):
            old_delta = a_m.group(0)
            # Find the delta part and replace it
            delta_part = re.search(r'delta:\s*[a-zA-Z]+\s*\(.*?\)', old_delta, re.DOTALL).group(0)
            new_delta = f'delta: {points[i]}'
            new_answer_str = old_delta.replace(delta_part, new_delta)
            
            # Since the original text might have identical formatting for different answers, we must be careful with replace
            # We will just replace it in a dictionary mapped by id
            pass
            
        # Let's do it safer by rebuilding the question string
        new_answers_list = []
        # We need to keep the original order (by id)
        # Create mapping of id to assigned points
        id_to_points = {}
        for i, (a_m, _) in enumerate(sorted_sums):
            id_match = re.search(r'id:\s*(\d+)', a_m.group(0))
            ans_id = int(id_match.group(1))
            id_to_points[ans_id] = points[i]
            
        for a_m in answer_matches:
            id_match = re.search(r'id:\s*(\d+)', a_m.group(0))
            ans_id = int(id_match.group(1))
            
            old_delta_full = re.search(r'delta:\s*[a-zA-Z]+\s*\(.*?\)', a_m.group(0), re.DOTALL).group(0)
            new_answer_str = a_m.group(0).replace(old_delta_full, f'delta: {id_to_points[ans_id]}')
            new_answers_text = new_answers_text.replace(a_m.group(0), new_answer_str)
            
        new_q_text = q_text.replace(answers_text, new_answers_text)
        new_content = new_content.replace(q_text, new_q_text)

    # 4. Remove all *ScoreDeltas structs
    new_content = re.sub(r'struct \w*ScoreDeltas.*?\{.*?\}', '', new_content, flags=re.DOTALL)
    
    # 5. Remove all *RawScore structs
    new_content = re.sub(r'struct \w*RawScore.*?\{.*?\}', '', new_content, flags=re.DOTALL)
    
    # 6. Replace Profiles
    def profile_replacer(match):
        prefix = match.group(1) # e.g. Finance, Mental
        lower_prefix = prefix.lower()
        return f"""enum {prefix}Profile: String, Codable, CaseIterable {{
    case level1
    case level2
    case level3
    case level4

    var titleKey: String {{ "assessment.{lower_prefix}.profile.\\(rawValue).title" }}
    var descKey:  String {{ "assessment.{lower_prefix}.profile.\\(rawValue).desc" }}
    var actionKey: String {{ "assessment.{lower_prefix}.profile.\\(rawValue).action" }}
    var buildHabitsKey: String {{ "assessment.{lower_prefix}.profile.\\(rawValue).build" }}
    var breakHabitsKey: String {{ "assessment.{lower_prefix}.profile.\\(rawValue).break" }}

    var icon: String {{
        switch self {{
        case .level1: return "exclamationmark.triangle.fill"
        case .level2: return "arrow.up.right.circle.fill"
        case .level3: return "star.fill"
        case .level4: return "crown.fill"
        }}
    }}

    var color: String {{
        switch self {{
        case .level1: return "#FF6B6B"
        case .level2: return "#FFB347"
        case .level3: return "#4FC3F7"
        case .level4: return "#4CAF50"
        }}
    }}
}}"""
    
    new_content = re.sub(r'enum (\w+)Profile: String, Codable, CaseIterable \{.*?(?=\n// MARK|\nstruct|\nenum \w+ScoringEngine|\n$)', profile_replacer, new_content, flags=re.DOTALL)

    # 7. Replace AssessmentResult types
    def result_replacer(match):
        prefix = match.group(1)
        name = match.group(2)
        return f"""struct {name}: Codable {{
    let profile: {prefix}Profile
    let score: Int
    let date: Date
}}"""
    new_content = re.sub(r'struct (([a-zA-Z]+)AssessmentResult|AssessmentResult): Codable \{.*?\}', lambda m: result_replacer(m) if m.group(2) else f"""struct AssessmentResult: Codable {{
    let profile: FinanceProfile
    let score: Int
    let date: Date
}}""", new_content, flags=re.DOTALL)

    # 8. Replace ScoringEngines
    def engine_replacer(match):
        prefix = match.group(1)
        return f"""enum {prefix}ScoringEngine {{
    static func computeProfile(from score: Int) -> {prefix}Profile {{
        switch score {{
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }}
    }}
}}"""
    new_content = re.sub(r'enum (\w+)ScoringEngine \{.*?\}', engine_replacer, new_content, flags=re.DOTALL)

    with open(filepath, 'w') as f:
        f.write(new_content)

for f in files:
    print(f"Refactoring {f}")
    refactor_file(f)

