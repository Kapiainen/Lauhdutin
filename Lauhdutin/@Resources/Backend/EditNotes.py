import sys, os, subprocess, json
from Enums import GameKeys

try:
	RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
	ResourcePath = sys.argv[2][:-1]
	Config = sys.argv[3][:-1]

	# Parse 'games.json'
	game_path = os.path.join(ResourcePath, "Temp", "notes_temp.json")
	game_json = None
	with open(game_path, "r") as file:
		game_json = json.load(file)
	if game_json:
		# Prepare 'Notes.txt'
		notes_path = os.path.join(ResourcePath, "Temp", "notes.txt")
		with open(notes_path, "w") as file:
			file.write(game_json.get(GameKeys.NOTES, ""))
		# Start Notepad and wait for it to finish
		subprocess.call(["notepad", notes_path])
		# Update the game's JSON
		notes_content = None
		with open(notes_path, "r") as file:
			notes_content = file.read()
		if notes_content:
			game_json[GameKeys.NOTES] = notes_content
			with open(game_path, "w") as file:
				json.dump(game_json, file)
		# Let the skin know that note editing has finished
		subprocess.call([RainmeterPath, "!CommandMeasure", "LauhdutinScript", "OnFinishedEditingNotes()", Config], shell=False)
except:
	import traceback
	traceback.print_exc()
input()