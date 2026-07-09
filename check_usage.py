import os
import re

keys = [
    "%lldh %lldm",
    "bad_habit.screen_time.desc",
    "bad_habit.screen_time.name",
    "common.hours",
    "common.hours.short",
    "common.minutes",
    "common.minutes.short",
    "habit.screen_time.desc",
    "habit.screen_time.name",
    "note.auto.screentime_success",
    "screentime.preprompt.button",
    "screentime.preprompt.desc",
    "screentime.preprompt.subtitle",
    "screentime.preprompt.title",
    "screenTime.reason.exceeded",
    "screenTime.target.label",
    "settings.screenTime.instruction"
]

for key in keys:
    found = False
    for root, dirs, files in os.walk("Garten_Simulation"):
        for file in files:
            if file.endswith(".swift"):
                with open(os.path.join(root, file), "r", encoding="utf-8") as f:
                    if key in f.read():
                        found = True
                        break
        if found:
            break
    print(f"{key}: {'USED' if found else 'UNUSED'}")
