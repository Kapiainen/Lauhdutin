import sys, os, subprocess, json
from Enums import GameKeys

try:
	RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
	ResourcePath = sys.argv[2][:-1]
	Config = sys.argv[3][:-1]

	# Parse 'games.json'
	game_path = os.path.join(ResourcePath, "Temp", "tags_temp.json")
	game_json = None
	with open(game_path, "r") as file:
		game_json = json.load(file)
	if game_json:
		# Prepare 'Notes.txt'
		tags_path = os.path.join(ResourcePath, "Temp", "tags.txt")
		with open(tags_path, "w") as file:
			tags = game_json.get(GameKeys.TAGS, None)
			if tags:
				sorted_tags = []
				for key, value in tags.items():
					sorted_tags.append(value)
				sorted_tags = sorted(sorted_tags)
				file.write("\n".join(sorted_tags))
		# Start Notepad and wait for it to finish
		subprocess.call(["notepad", tags_path])
		# Update the game's JSON
		tags_content = None
		with open(tags_path, "r") as file:
			tags_content = file.read().strip()
		if tags_content:
			tag_lines = tags_content.split("\n")
			tags = {}
			i = 0
			for tag in tag_lines:
				tag = tag.strip()
				if tag != "":
					tags[str(i)] = tag
					i += 1
			game_json[GameKeys.TAGS] = tags
		elif game_json.get(GameKeys.TAGS):
			del game_json[GameKeys.TAGS]
		with open(game_path, "w") as file:
			json.dump(game_json, file, indent=4)
		# Let the skin know that note editing has finished
		subprocess.call([RainmeterPath, "!CommandMeasure", "LauhdutinScript", "OnFinishedEditingTags()", Config], shell=False)
except:
	import traceback
	traceback.print_exc()
input()