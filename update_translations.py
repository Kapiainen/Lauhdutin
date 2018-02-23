import os
import re

version = "version 1"
pattern = re.compile(r"LOCALIZATION\\get\('(.+?)',\s*['\"](.+?)['\"]\)")

print("\nUpdating translation file...")
cwd = os.getcwd()
translations = {}
for root, dirs, files in os.walk(os.path.join(cwd, "src")):
	for file in files:
		if file.endswith(".moon"):
			path = os.path.join(root, file)
			with open(path, encoding="utf8") as f:
				contents = f.read()
				for match in pattern.finditer(contents):
					key = match.group(1)
					value = match.group(2)
					translations[key] = value
lines = []
for key, value in translations.items():
	lines.append(key + "\t" + value)
lines.sort()
lines.insert(0, version)
with open(os.path.join(cwd, "translations", "English.txt"), "w", encoding="utf8") as f:
	f.write("\n".join(lines) + "\n")
print("Successfully updated the translation file!")
