# Python environment
import os, re
# Back-end
from Enums import GameKeys
from Enums import Platform

class WindowsShortcuts():
	def __init__(self, a_path):
		path = os.path.join(a_path, "Shortcuts")
		if not os.path.isdir(path):
			os.makedirs(path)
		self.shortcuts_path = path
		self.path_regex = re.compile(r"(\w:[\\\w\s]+\.exe)")
		self.shortcut_banners = None
		for root, directories, files in os.walk(os.path.join(a_path, "Banners", "Shortcuts")):
			self.shortcut_banners = files
			break

	def get_games(self):
		shortcuts = None
		for root, directories, files in os.walk(self.shortcuts_path):
			shortcuts = [f for f in files if f.endswith(".lnk")]
			break
		if shortcuts:
			result = {}
			for shortcut in shortcuts:
				game_key, game_dict = self.read_shortcut(shortcut[:-4],
															os.path.join(self.shortcuts_path, shortcut))
				if game_key and game_dict:
					result[game_key] = game_dict
			return result
		return None

	def read_shortcut(self, a_name, a_path):
		# Quick and dirty. Should be replaced at some point with a better method.
		game_dict = {}
		shortcut_contents = ""
		with open(a_path, "rb") as f:
			byte = f.read(1)
			while byte != b"":
				shortcut_contents = shortcut_contents + byte.decode("utf-8", errors="ignore")
				byte = f.read(1)
		path = None
		for match in self.path_regex.finditer(shortcut_contents):
			if os.path.isfile(match.group(1)):
				path = match.group(1)
				game_dict[GameKeys.PATH] = path
				game_dict[GameKeys.NAME] = a_name
				game_dict[GameKeys.LASTPLAYED] = 0
				game_dict[GameKeys.PLATFORM] = Platform.WINDOWS_SHORTCUT
				if self.shortcut_banners:
					for banner in self.shortcut_banners:
						if banner.lower().startswith(a_name.lower()):
							game_dict[GameKeys.BANNER_PATH] = "Shortcuts\\" + banner
							break
				if not game_dict.get(GameKeys.BANNER_PATH):
					game_dict[GameKeys.BANNER_PATH] = "Shortcuts\\%s.jpg" % a_name
				return (a_name, game_dict,)
		return (None, None,)
