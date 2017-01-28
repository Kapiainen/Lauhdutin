# Python environment
import os, string, zlib, re, urllib.request
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
	TAGS = "tags"

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
			with open(a_path, encoding="utf-8") as f:
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
	def __init__(self, a_path, a_userdataid, a_steamid64):
		self.steam_path = a_path
		self.steamid64 = a_steamid64
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
		# Read sharedconfig.vdf to get tags assigned in Steam.
		shared_config = vdf.open(os.path.join(self.steam_path, "userdata", self.userdataid, "7", "remote",
												"sharedconfig.vdf"))
		keys = [VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE, VDFKeys.STEAM, VDFKeys.APPS]
		while keys:
			if not shared_config:
				print("\t\tFailed to process 'sharedconfig.vdf'")
				return self.result
			shared_config = shared_config.get(keys[0])
			keys.pop(0)

		# Read localconfig.vdf to get the timestamp for when the game was last played.
		local_config = vdf.open(os.path.join(self.steam_path, "userdata", self.userdataid, "config",
												"localconfig.vdf"))
		keys = [VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE, VDFKeys.STEAM, VDFKeys.APPS]
		while keys:
			if not local_config:
				print("\t\tFailed to process 'localconfig.vdf'")
				return self.result
			local_config = local_config.get(keys[0])
			keys.pop(0)

		game_definitions = {}
		if self.steamid64 and self.steamid64 != "":
			try:
				print("\tAttempting to access commmunity profile...")
				community_profile_page = urllib.request.urlopen("http://steamcommunity.com/profiles/%s/games/?tab=all&xml=1" % self.steamid64)
				community_profile = community_profile_page.readlines()
				decoded_lines = []
				for line in community_profile:
					try:
						decoded_lines.append(line.decode("utf-8", errors="ignore").strip().lower())
					except:
						pass
				i = 0
				while i < len(decoded_lines):
					if decoded_lines[i] == "<game>":
						game_def = {}
						while decoded_lines[i] != "</game>" and i < len(decoded_lines):
							if decoded_lines[i].startswith("<appid>"):
								game_def[VDFKeys.APPID] = decoded_lines[i][7:decoded_lines[i].find("</")]
							#elif decoded_lines[i].startswith("<name>"):
							#	game_def[GameKeys.NAME] = decoded_lines[i][6+9:decoded_lines[i].find("]]></")]
							elif decoded_lines[i].startswith("<hourslast2weeks>"):
								game_def[GameKeys.HOURS_LAST_TWO_WEEKS] = float(decoded_lines[i][17:decoded_lines[i].find("</")])
							elif decoded_lines[i].startswith("<hoursonrecord>"):
								game_def[GameKeys.HOURS_TOTAL] = float(decoded_lines[i][15:decoded_lines[i].find("</")])
							i += 1
							if len(game_def) > 1 and game_def.get(VDFKeys.APPID, None):
								game_definitions[game_def[VDFKeys.APPID]] = game_def
					i += 1
				if len(game_definitions) > 0:
					print("\tSuccessfully parsed community profile...")
				else:
					print("\tCommunity profile might be set to private...")
			except: # Possibly no internet connection or server issues
				print("\tFailed to access commmunity profile...")

		# Read appmanifests
		for basePath in libraries:
			print("\tFound library '%s'" % basePath)
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
				app_id = manifest[VDFKeys.APPID]
				game[GameKeys.PLATFORM] = Platform.STEAM
				game[GameKeys.PATH] = "steam://rungameid/" + app_id
				if manifest.get(VDFKeys.NAME):
					game[GameKeys.NAME] = manifest[VDFKeys.NAME]
				elif manifest.get(VDFKeys.USERCONFIG):
					game[GameKeys.NAME] = manifest[VDFKeys.USERCONFIG][VDFKeys.NAME]
				game[GameKeys.NAME] = Utility.title_move_the(Utility.title_strip_unicode(game[GameKeys.NAME]))
				print("\t\tFound game '%s'" % game[GameKeys.NAME])
				game[GameKeys.BANNER_PATH] = "Steam\\" + manifest[VDFKeys.APPID] + ".jpg"
				game[GameKeys.BANNER_URL] = ("http://cdn.akamai.steamstatic.com/steam/apps/"
												+ app_id
												+ "/header.jpg")
				game[GameKeys.LASTPLAYED] = 0
				if local_config.get(app_id, None):
					if local_config[app_id].get(VDFKeys.LASTPLAYED, None):
						game[GameKeys.LASTPLAYED] = local_config[app_id][VDFKeys.LASTPLAYED]
				if shared_config.get(app_id, None):
					if shared_config[app_id].get(VDFKeys.TAGS, None):
						game[GameKeys.TAGS] = shared_config[app_id][VDFKeys.TAGS]
				if game_definitions.get(app_id, None):
					game_def = game_definitions[app_id]
					if game_def.get(GameKeys.HOURS_LAST_TWO_WEEKS, None):
						game[GameKeys.HOURS_LAST_TWO_WEEKS] = game_def[GameKeys.HOURS_LAST_TWO_WEEKS]
					if game_def.get(GameKeys.HOURS_TOTAL, None):
						game[GameKeys.HOURS_TOTAL] = game_def[GameKeys.HOURS_TOTAL]
				self.result[app_id] = game
		
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
			game[GameKeys.NAME] = Utility.title_move_the(Utility.title_strip_unicode(shortcut[start:end]))
			print("\tFound game '%s'" % game[GameKeys.NAME])
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