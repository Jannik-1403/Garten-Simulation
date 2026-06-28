import re
import glob

files = glob.glob('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/*AssessmentModel.swift')
files.append('/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Models/AssessmentModel.swift')
files = list(set(files))

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    # Find enum ...ScoringEngine and replace it completely until its closing brace
    # A safe way is to find "enum XXXScoringEngine {" and then count braces
    def fix_engines(text):
        pattern = re.compile(r'enum (\w+)ScoringEngine \{')
        while True:
            match = pattern.search(text)
            if not match:
                break
            
            start_idx = match.end() - 1
            brace_count = 0
            end_idx = -1
            for i in range(start_idx, len(text)):
                if text[i] == '{':
                    brace_count += 1
                elif text[i] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        end_idx = i
                        break
            
            if end_idx != -1:
                prefix = match.group(1)
                new_engine = f"""enum {prefix}ScoringEngine {{
    static func computeProfile(from score: Int) -> {prefix}Profile {{
        switch score {{
        case ..<(-9): return .level1
        case (-9)...5: return .level2
        case 6...20: return .level3
        default: return .level4
        }}
    }}
}}"""
                text = text[:match.start()] + new_engine + text[end_idx+1:]
            else:
                break
        return text

    # Also clean up ScoreDeltas declaration that might have been left empty or something
    # But earlier I used `re.sub(r'struct \w*ScoreDeltas.*?\{.*?\}', '', new_content, flags=re.DOTALL)`
    # Which probably removed the struct but maybe not the comments. That's fine.
    
    # We also need to fix AssessmentResult which might have leftover fields
    # Let's check AssessmentResult:
    def fix_results(text):
        pattern = re.compile(r'struct (\w+AssessmentResult|AssessmentResult): Codable \{')
        while True:
            match = pattern.search(text)
            if not match:
                break
            
            start_idx = match.end() - 1
            brace_count = 0
            end_idx = -1
            for i in range(start_idx, len(text)):
                if text[i] == '{':
                    brace_count += 1
                elif text[i] == '}':
                    brace_count -= 1
                    if brace_count == 0:
                        end_idx = i
                        break
                        
            if end_idx != -1:
                name = match.group(1)
                if name == 'AssessmentResult':
                    prefix = 'Finance'
                else:
                    prefix = name.replace('AssessmentResult', '')
                    
                new_result = f"""struct {name}: Codable {{
    let profile: {prefix}Profile
    let score: Int
    let date: Date
}}"""
                text = text[:match.start()] + new_result + text[end_idx+1:]
            else:
                break
        return text
        
    content = fix_engines(content)
    content = fix_results(content)
    
    with open(filepath, 'w') as f:
        f.write(content)
        
