import re

path = "Garten_Simulation/Models/PDFExportManager.swift"
with open(path, "r") as f:
    content = f.read()

content = content.replace(
    'let quizView = QuizScreenshotView(assessmentStore: assessmentStore)',
    'let quizView = QuizScreenshotView(assessmentStore: assessmentStore).environment(\\.locale, locale)'
)

with open(path, "w") as f:
    f.write(content)

