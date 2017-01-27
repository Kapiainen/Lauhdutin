# Python environment
import sys, os, subprocess, json

RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
ResourcePath = sys.argv[2][:-1]
Config = sys.argv[3][:-1]

try:
	# Back-end
	from WindowsShortcuts import WindowsShortcuts
	from Steam import Steam
	from GOGGalaxy import GOGGalaxy
	from BannerDownloader import BannerDownloader
	from Enums import GameKeys
except ImportError:
	try:
		sys.path.append(os.path.join(ResourcePath, "Backend"))
		from WindowsShortcuts import WindowsShortcuts
		from Steam import Steam
		from GOGGalaxy import GOGGalaxy
		from BannerDownloader import BannerDownloader
		from Enums import GameKeys
	except ImportError:
		import traceback
		traceback.print_exc()
		input()

try:
	####
	import time
	startTime = time.time()
	####

	def read_json(a_path):
		if os.path.isfile(a_path):
			with open(a_path, encoding="utf-8") as f:
				return json.load(f)
		return None

	def write_json(a_path, a_json):
		with open(a_path, "w") as f:
			json.dump(a_json, f, indent=2)

	settings = read_json(os.path.join(ResourcePath, "settings.json"))
	if settings:
		# Windows shortcuts (.lnk) in @Resources\Shortcuts
		print("Processing Windows shortcuts...")
		windows_shortcuts = WindowsShortcuts(os.path.join(ResourcePath))
		windows_shortcuts_games = windows_shortcuts.get_games()

		# Steam games
		if settings.get("steam_path", None):
			print("Processing Steam games...")
			steam = Steam(settings["steam_path"], settings.get("steam_userdataid", ""))
			steam_games = steam.get_games()
			# Non-steam games added to Steam as shortcuts
			print("Processing Steam shortcuts...")
			steam_shortcuts = steam.get_shortcuts()
		else:
			steam_games = None
			steam_shortcuts = None

		if settings.get("galaxy_path", None):
			# GOG Galaxy games
			print("Processing GOG Galaxy games...")
			galaxy = GOGGalaxy(settings["galaxy_path"])
			galaxy_games = galaxy.get_games()
		else:
			galaxy_games = None

		# Merge game dictionaries into one list
		print("Generating master list of games...")
		all_games = []
		if windows_shortcuts_games:
			for game_key, game_dict in windows_shortcuts_games.items():
				all_games.append(game_dict)

		if steam_games:
			for game_key, game_dict in steam_games.items():
				all_games.append(game_dict)

		if steam_shortcuts:
			for game_key, game_dict in steam_shortcuts.items():
				all_games.append(game_dict)

		if galaxy_games:
			for game_key, game_dict in galaxy_games.items():
				all_games.append(game_dict)

		print("Comparing new master list of games with old master list of games...")
		all_games_old = read_json(os.path.join(ResourcePath, "games.json"))
		if all_games_old:
			for game_new in all_games:
				for game_old in all_games_old:
					if game_new[GameKeys.NAME] == game_old[GameKeys.NAME]:
						if game_new.get(GameKeys.LASTPLAYED, None) != None and game_old.get(GameKeys.LASTPLAYED, None) != None:
							if int(game_old[GameKeys.LASTPLAYED]) > int(game_new[GameKeys.LASTPLAYED]):
								game_new[GameKeys.LASTPLAYED] = game_old[GameKeys.LASTPLAYED]
						if game_old.get(GameKeys.HIDDEN, None) != None:
							game_new[GameKeys.HIDDEN] = game_old[GameKeys.HIDDEN]
						if game_old.get(GameKeys.BANNER_ERROR, False):
							game_new[GameKeys.BANNER_ERROR] = True
						break

		print("Downloading banners for games from supported platforms...")
		banner_downloader = BannerDownloader(ResourcePath)
		banner_downloader.process(all_games)

		print("Writing master list of games to disk...")
		write_json(os.path.join(ResourcePath, "games.json"), all_games)

		print("Initializing frontend...")
		subprocess.call([RainmeterPath, "!CommandMeasure", "LauhdutinScript", "Init()", Config], shell=True)

	####
	endTime = time.time()
	seconds = float(endTime - startTime)
	minutes = int(seconds / 60)
	seconds = float(seconds - minutes * 60.0)
	print("Execution time: %s minutes %.2f seconds" % (minutes, seconds))
	####
except:
	import traceback
	traceback.print_exc()
	subprocess.call([RainmeterPath, "!SetOption", "StatusMessage", "Text", "Exception raised in the backend!", Config], shell=True)
	subprocess.call([RainmeterPath, "!ShowMeterGroup", "Status", Config], shell=True)
	subprocess.call([RainmeterPath, "!Redraw", Config], shell=True)
	input()
