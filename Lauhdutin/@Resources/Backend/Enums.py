# If GameKeys values are changed, then the changes have to be copied over to the 'GAME_KEYS' table in GUI.lua.
class GameKeys():
	BANNER_ERROR = "bannererror"
	BANNER_PATH = "banner"
	BANNER_URL = "bannerurl"
	HIDDEN = "hidden"
	LASTPLAYED = "lastplayed"
	NAME = "title"
	PATH = "path"
	PLATFORM = "platform"
	TAGS = "tags"

# If Platform values are changed, then the changes have to be copied over to the 'PLATFORM' table in GUI.lua.
class Platform():
	STEAM = 0
	STEAM_SHORTCUT = 1
	GOG_GALAXY = 2
	WINDOWS_SHORTCUT = 3