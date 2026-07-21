import re
import json

def process_file():
    with open("Garten_Simulation/Models/HabitProgressionStrategy.swift", "r") as f:
        content = f.read()

    # We need to replace string literals with String(localized:, defaultValue:)
    # Because of the complexity of Swift interpolation, we'll use a regex that matches
    # title = "...", desc = "...", and todos = ["..."]
    
    strings_to_translate = {}
    
    # We will just find all literal strings that look like German text
    # e.g., things containing spaces and letters, not just variable names
    
    # This is a bit too complex for simple regex. Let's write a python AST or just
    # carefully replace known patterns.
    pass

