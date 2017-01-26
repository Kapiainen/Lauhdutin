# Python environment
import os, string, zlib, re
# Back-end
import Utility
from Enums import GameKeys
from Enums import Platform

class VDFKeys():
	APPSTATE = "appstate"
	APPID = "appid"
	NAME = "name"
	USERCONFIG = "userconfig"
	USERLOCALCONFIGSTORE = "userlocalconfigstore"
	SOFTWARE = "software"
	VALVE = "valve"
	STEAM = "steam"
	APPS = "apps"
	LASTPLAYED = "lastplayed"
	APPNAME = "appname"

class VDF:
	def __init__(self):
		self.regex_dict_key = re.compile('^\s*"([^"]+)"\s*$')
		self.regex_dict_start = re.compile('^\s*{\s*$')
		self.regex_dict_end = re.compile('^\s*}\s*$')
		self.regex_key_value = re.compile('^\s*"([^"]+)"\s*"([^"]+)"\s*$')
		self.regex_comment = re.compile('^\s*//.*$')
		self.regex_base = re.compile('^\s*"#base"\s*"([^"]+)"\s*$')
		self.indentation = ""

	def open(self, a_path):
		if os.path.isfile(a_path):
			with open(a_path) as f:
				source = f.readlines()
				value, i = self.parse(source, 0)
				return value
		else:
			return None

	def parse(self, a_list_of_lines, a_start_index):
		result = {}
		key = ""
		value = ""
		i = a_start_index
		while i < len(a_list_of_lines):
			match = self.regex_dict_key.match(a_list_of_lines[i])
			if match:
				i += 1
				key = match.group(1)
				key = key.lower()
				if self.regex_dict_start.match(a_list_of_lines[i]):
					value, i = self.parse(a_list_of_lines, i + 1)
					if value == None and i == None:
						return None, None
					else:
						result[key] = value
				else:
					return None, None
			else:
				match = self.regex_key_value.match(a_list_of_lines[i])
				if match:
					key = match.group(1)
					key = key.lower()
					value = match.group(2)
					result[key] = value
				else:
					if self.regex_dict_end.match(a_list_of_lines[i]):
						return result, i
					elif self.regex_comment.match(a_list_of_lines[i]):
						pass
					else:
						match = self.regex_base.match(a_list_of_lines[i])
			i += 1
		return result, i

	def save(self, a_path, a_dict):
		if a_dict != None and bool(a_dict):
			folder_path = os.path.split(a_path)[0]
			if not os.path.isdir(folder_path):
				os.makedirs(folder_path)
			with open(a_path, "w") as f:
				f.writelines(self.serialize(a_dict))
			return True
		return False

	def serialize(self, a_dict):
		result = []
		for key, value in a_dict.items():
			if isinstance(value, dict):
				result.append(self.indentation + '"' + str(key) + '"\n')
				result.append(self.indentation + '{\n')
				self.indentation = self.indentation + "\t"
				temp = self.serialize(value)
				for line in temp:
					result.append(line)
				self.indentation = self.indentation[:-1]
				result.append(self.indentation + '}\n')
			elif isinstance(value, int) or isinstance(value, float) or isinstance(value, str):
				result.append(self.indentation + '"' + str(key) + '"\t\t"' + str(value) + '"\n')
		return result

class Steam():
	def __init__(self, a_path, a_userdataid):
		self.steam_path = a_path
		self.result = {}
		self.userdataid = a_userdataid

	def get_games(self):
		self.result = {}
		vdf = VDF()
		# Get libraries
		libraries = []
		libraries.append(self.steam_path)
		libraryFolders = vdf.open(os.path.join(self.steam_path, "SteamApps", "libraryfolders.vdf"))
		if libraryFolders:
			for key, path in libraryFolders.get("libraryfolders", {}).items():
				if self.is_int(key):
					libraries.append(path.replace("\\\\", "\\"))
		# Read appmanifests
		for basePath in libraries:
			path = os.path.join(basePath, "steamapps")
			if not os.path.isdir(path):
				continue
			appmanifests = [os.path.join(path, f)
				for f in os.listdir(path)
				if f.startswith( "appmanifest_") and f.endswith(".acf")]
			for appmanifest in appmanifests:
				manifest = vdf.open(appmanifest)
				if not manifest:
					continue
				manifest = manifest.get(VDFKeys.APPSTATE)
				if not manifest:
					continue
				if not manifest.get(VDFKeys.APPID):
					continue
				if (not manifest.get(VDFKeys.NAME)
					and not (manifest.get(VDFKeys.USERCONFIG)
							and manifest[VDFKeys.USERCONFIG].get(VDFKeys.NAME))):
					continue
				game = {}
				game[GameKeys.PLATFORM] = Platform.STEAM
				game[GameKeys.PATH] = "steam://rungameid/" + manifest[VDFKeys.APPID]
				if manifest.get(VDFKeys.NAME):
					game[GameKeys.NAME] = manifest[VDFKeys.NAME]
				elif manifest.get(VDFKeys.USERCONFIG):
					game[GameKeys.NAME] = manifest[VDFKeys.USERCONFIG][VDFKeys.NAME]
				game[GameKeys.NAME] = Utility.title_strip_unicode(game[GameKeys.NAME])
				game[GameKeys.NAME] = Utility.title_move_the(game[GameKeys.NAME])
				game[GameKeys.BANNER_PATH] = "Steam\\" + manifest[VDFKeys.APPID] + ".jpg"
				game[GameKeys.BANNER_URL] = ("http://cdn.akamai.steamstatic.com/steam/apps/"
												+ manifest[VDFKeys.APPID]
												+ "/header.jpg")
				game[GameKeys.LASTPLAYED] = 0
				self.result[manifest[VDFKeys.APPID]] = game

		# Read sharedconfig.vdf
		shared_config = vdf.open(os.path.join(self.steam_path, "userdata", self.userdataid, "7", "remote",
												"sharedconfig.vdf"))
		keys = [VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE, VDFKeys.STEAM, VDFKeys.APPS]
		while keys:
			if not shared_config:
				return
			shared_config = shared_config.get(keys[0])
			keys.pop(0)
		for appID, gameDict in shared_config.items():
			if gameDict.get(GameKeys.TAGS, None) != None:
				if self.result.get(appID, None) != None:
					self.result[appID]["tags"] = gameDict[GameKeys.TAGS]

		# Read localconfig.vdf
		local_config = vdf.open(os.path.join(self.steam_path, "userdata", self.userdataid, "config",
												"localconfig.vdf"))
		keys = [VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE, VDFKeys.STEAM, VDFKeys.APPS]
		while keys:
			if not local_config:
				return
			local_config = local_config.get(keys[0])
			keys.pop(0)
		for appID, gameDict in local_config.items():
			if gameDict.get(GameKeys.LASTPLAYED):
				if self.result.get(appID):
					self.result[appID]["lastplayed"] = gameDict[GameKeys.LASTPLAYED]
		return self.result

	def get_shortcuts(self):
		result = {}
		# Read shortcuts.vdf
		shortcuts = ""
		shortcuts_path = os.path.join(self.steam_path, "userdata", self.userdataid, "config", "shortcuts.vdf")
		if not os.path.isfile(shortcuts_path):
			return result
		with open(shortcuts_path, "rb") as f:
			byte = f.read(1)
			while byte != b"":
				shortcuts = shortcuts + byte.decode("utf-8", errors="ignore")
				byte = f.read(1)
		output = ""
		for char in shortcuts:
			if char in string.printable:
				output = output + char
			else:
				output = output + "|"
		shortcuts_dict = {}
		i = 0
		output_copy = output[9:]
		appnameIndex = output_copy.rfind("appname")
		while appnameIndex >= 0:
			shortcuts_dict[str(i)] = output_copy[appnameIndex - 1:]
			output_copy = output_copy[:appnameIndex - 1]
			appnameIndex = output_copy.rfind("appname")
			i += 1

		i = 0
		for key, shortcut in shortcuts_dict.items():
			game = {}
			game[GameKeys.PLATFORM] = Platform.STEAM_SHORTCUT
			game[GameKeys.LASTPLAYED] = 0
			# Title
			start = shortcut.find("|", 1) + 1
			end = shortcut.find("|", start)
			game[GameKeys.NAME] = shortcut[start:end]
			game[GameKeys.NAME] = Utility.title_strip_unicode(game[GameKeys.NAME])
			game[GameKeys.NAME] = Utility.title_move_the(game[GameKeys.NAME])
			game[GameKeys.BANNER_PATH] = "Steam shortcuts\\" + game[GameKeys.NAME] + ".jpg"
			shortcut = shortcut[end:]
			# Path
			start = shortcut.find('"') + 1
			end = shortcut.find('"', start)
			game[GameKeys.PATH] = shortcut[start:end]
			shortcut = shortcut[end:]
			#SteamID
			steamID = zlib.crc32(("\"" + game[GameKeys.PATH] + "\"" + game[GameKeys.NAME]).encode())
			steamID = steamID | 0x80000000
			steamID = steamID << 32 | 0x02000000
			game[GameKeys.PATH] = "steam://rungameid/" + str(steamID)
			# Tags
			start = shortcut.find("tags||") + 6
			end = shortcut.find("||||", start)
			shortcut = shortcut[start:end]
			tagsList = shortcut.split("||")
			if len(tagsList) > 0:
				tags = {}
				for tag in tagsList:
					pair = tag.split("|")
					if len(pair) > 1:
						tags[pair[0]] = pair[1]
				if bool(tags) != False:
					game[GameKeys.TAGS] = tags
			result[str(i)] = game
			i += 1
		return result

	def is_int(self, a_string):
		try:
			int(a_string)
			return True
		except ValueError:
			return False