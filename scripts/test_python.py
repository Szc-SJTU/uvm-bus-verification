from pathlib import Path
import sys

print("Python OK")
print("Executable:", sys.executable)
print("IC root:", Path(__file__).resolve().parents[1])