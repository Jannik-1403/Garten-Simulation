import time
import subprocess
import sys

while True:
    try:
        output = subprocess.check_output("ps aux | grep translate_robust.py | grep -v grep", shell=True)
        if b"translate_robust.py" in output:
            time.sleep(60)
        else:
            break
    except subprocess.CalledProcessError:
        break

print("Translation process finished!")
