import re

with open("Garten_Simulation/Models/AssessmentResult+Detailed.swift", "r") as f:
    content = f.read()

# 1. Remove the properties from DetailedAssessmentResult protocol
content = re.sub(r'\s*var [a-zA-Z]+DataSources:\s*\[AssessmentDataSource\]\s*\{.*?\}', '', content)

# 2. But the extensions still have them defined. Let's just find all var XXXDataSources: [AssessmentDataSource] { ... } and remove them.
# A regex is tricky to match nested brackets, so let's do a simple text replace where possible, or just parse the file line by line.

# Since we don't want to break the file with a bad regex, let's restore AssessmentDataSource in DetailedAssessmentAnalysisView.swift, but just make it empty and not used in the UI. 
# Yes, that's much safer than trying to delete half of AssessmentResult+Detailed.swift with a regex.
