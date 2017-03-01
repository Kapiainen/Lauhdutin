# If GameKeys values are changed, then the changes have to be copied over to the 'GAME_KEYS' table in GUI.lua.
class GameKeys():
    ARGUMENTS = "arguments"
    BANNER_ERROR = "bannererror"
    BANNER_PATH = "banner"
    BANNER_URL = "bannerurl"
    ERROR = "error"
    HIDDEN = "hidden"
    HOURS_LAST_TWO_WEEKS = "hourslast2weeks"
    HOURS_TOTAL = "hourstotal"
    INVALID_PATH = "invalidpatherror"
    LASTPLAYED = "lastplayed"
    NAME = "title"
    NOT_INSTALLED = "notinstalled"
    PATH = "path"
    PLATFORM = "platform"
    PROCESS = "process"
    TAGS = "tags"


# If Platform values are changed, then the changes have to be copied over to the 'PLATFORM' table in GUI.lua.
class Platform():
    STEAM = 0
    STEAM_SHORTCUT = 1
    GOG_GALAXY = 2
    WINDOWS_SHORTCUT = 3
    WINDOWS_URL_SHORTCUT = 4
    BATTLENET = 5
