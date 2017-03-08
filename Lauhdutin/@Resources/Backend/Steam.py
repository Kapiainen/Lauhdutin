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
                    if (value == None and i == None):
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
        if (a_dict != None and bool(a_dict)):
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
            elif (isinstance(value, int) or isinstance(value, float) or
                  isinstance(value, str)):
                result.append(self.indentation + '"' + str(key) + '"\t\t"' +
                              str(value) + '"\n')
        return result


class Steam():
    def __init__(self, a_path, a_userdataid, a_steamid64):
        self.steam_path = a_path
        self.steamid64 = a_steamid64
        self.userdataid = a_userdataid
        self.vdf = VDF()
        self.banner_url_prefix = "http://cdn.akamai.steamstatic.com/steam/apps/"
        self.banner_url_suffix = "/header.jpg"

    def get_games(self):
        result = {}
        vdf = VDF()
        libraries = self.get_libraries(self.steam_path)
        shared_config = self.get_shared_config(self.steam_path,
                                               self.userdataid)
        local_config = self.get_local_config(self.steam_path, self.userdataid)
        # Steam community profile
        game_definitions = None
        if (self.steamid64 and self.steamid64 != ""):
            try:
                print("\tAttempting to access commmunity profile...")
                encoded_lines = self.get_community_profile(self.steamid64)
                decoded_lines = self.decode_community_profile(encoded_lines)
                game_definitions = self.parse_community_profile(decoded_lines)
                if len(game_definitions) > 0:
                    print("\tSuccessfully parsed community profile...")
                else:
                    print("\tCommunity profile might be set to private...")
                    game_definitions = None
            except:  # Possibly no internet connection or server issues
                print("\tFailed to either access or parse commmunity profile...")
                import traceback
                traceback.print_exc()
                game_definitions = None
        for basePath in libraries:
            print("\tFound library '%s'" % basePath)
            appmanifest_paths = self.get_appmanifest_paths(basePath)
            if not appmanifest_paths:
                continue
            for appmanifest_path in appmanifest_paths:
                appmanifest = self.get_appmanifest(appmanifest_path)
                if not appmanifest:
                    continue
                game = self.get_installed_game(appmanifest, local_config,
                                               shared_config, game_definitions)
                if game:
                    result[appmanifest[VDFKeys.APPID]] = game
        print("\tFound %d games that are installed" % len(result))
        if game_definitions:
            print("\tChecking for games that are not installed...")
            not_installed_count = 0
            for app_id, game_def in game_definitions.items():
                if not result.get(app_id, None):
                    not_installed_count += 1
                    result[app_id] = self.get_not_installed_game(
                        app_id, game_def, local_config, shared_config)
            print("\tFound %s games that are not installed" %
                  not_installed_count)
        return result

    def get_libraries(self, a_path):
        # Get all of the libraries that games may be installed to.
        libraries = []
        libraries.append(a_path)
        libraryFolders = self.vdf.open(
            os.path.join(a_path, "SteamApps", "libraryfolders.vdf"))
        if libraryFolders:
            for key, path in libraryFolders.get("libraryfolders", {}).items():
                if self.is_int(key):
                    libraries.append(path.replace("\\\\", "\\"))
        return libraries

    def get_shared_config(self, a_path, a_userdataid):
        # Read sharedconfig.vdf to get tags assigned in Steam.
        shared_config = self.vdf.open(
            os.path.join(a_path, "userdata", a_userdataid, "7", "remote",
                         "sharedconfig.vdf"))
        keys = [
            VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE,
            VDFKeys.STEAM, VDFKeys.APPS
        ]
        while keys:
            if not shared_config:
                print("\t\tFailed to process 'sharedconfig.vdf'")
                shared_config = None
                break
            shared_config = shared_config.get(keys[0])
            keys.pop(0)
        return shared_config

    def get_local_config(self, a_path, a_userdataid):
        # Read localconfig.vdf to get the timestamp for when the game was last played.
        local_config = self.vdf.open(
            os.path.join(a_path, "userdata", a_userdataid, "config",
                         "localconfig.vdf"))
        keys = [
            VDFKeys.USERLOCALCONFIGSTORE, VDFKeys.SOFTWARE, VDFKeys.VALVE,
            VDFKeys.STEAM, VDFKeys.APPS
        ]
        while keys:
            if not local_config:
                print("\t\tFailed to process 'localconfig.vdf'")
                local_config = None
                break
            local_config = local_config.get(keys[0])
            keys.pop(0)
        return local_config

    def get_community_profile(self, a_steamid64):
        community_profile_page = urllib.request.urlopen(
            "http://steamcommunity.com/profiles/%s/games/?tab=all&xml=1" %
            a_steamid64)
        return community_profile_page.readlines()

    def decode_community_profile(self, a_encoded_lines):
        decoded_lines = []
        for line in a_encoded_lines:
            try:
                decoded_lines.append(
                    line.decode("utf-8", errors="ignore").strip())
            except:
                pass
        return decoded_lines

    def parse_community_profile(self, a_decoded_lines):
        game_definitions = {}
        i = 0
        while i < len(a_decoded_lines):
            if a_decoded_lines[i] == "<game>":
                game_def = {}
                while (a_decoded_lines[i].lower() != "</game>" and
                       i < len(a_decoded_lines)):
                    line = a_decoded_lines[i].lower()
                    if line.startswith("<appid>"):
                        game_def[VDFKeys.APPID] = a_decoded_lines[i][
                            7:a_decoded_lines[i].find("</")]
                    elif line.startswith("<name>"):
                        game_def[GameKeys.NAME] = Utility.title_move_the(
                            Utility.title_strip_unicode(a_decoded_lines[i][
                                6 + 9:a_decoded_lines[i].find("]]></")]))
                    elif line.startswith("<hourslast2weeks>"):
                        game_def[GameKeys.HOURS_LAST_TWO_WEEKS] = float(
                            a_decoded_lines[i][17:a_decoded_lines[i]
                                               .find("</")])
                    elif line.startswith("<hoursonrecord>"):
                        hours_total_string = a_decoded_lines[i][15:a_decoded_lines[i].find("</")]
                        if "," in hours_total_string:
                            hours_total_string = hours_total_string.replace(",", "")
                        game_def[GameKeys.HOURS_TOTAL] = float(hours_total_string)
                    i += 1
                    if (len(game_def) >= 1 and
                            game_def.get(VDFKeys.APPID, None)):
                        game_definitions[game_def[VDFKeys.APPID]] = game_def
            i += 1
        return game_definitions

    def get_appmanifest_paths(self, a_path):
        path = os.path.join(a_path, "steamapps")
        if not os.path.isdir(path):
            return None
        return [
            os.path.join(path, f) for f in os.listdir(path)
            if (f.startswith("appmanifest_") and f.endswith(".acf"))
        ]

    def get_appmanifest(self, a_path):
        appmanifest = self.vdf.open(a_path)
        if not appmanifest:
            return None
        appmanifest = appmanifest.get(VDFKeys.APPSTATE)
        if not appmanifest:
            return None
        if not appmanifest.get(VDFKeys.APPID):
            return None
        if (not appmanifest.get(VDFKeys.NAME) and
                not (appmanifest.get(VDFKeys.USERCONFIG) and
                     appmanifest[VDFKeys.USERCONFIG].get(VDFKeys.NAME))):
            return None
        return appmanifest

    def get_installed_game(self, a_appmanifest, a_local_config,
                           a_shared_config, a_game_definitions):
        game = {}
        app_id = a_appmanifest[VDFKeys.APPID]
        game[GameKeys.PLATFORM] = Platform.STEAM
        game[GameKeys.PATH] = "steam://rungameid/" + app_id
        game[GameKeys.NAME] = self.get_game_name(a_appmanifest)
        print("\t\tFound game '%s'" % game[GameKeys.NAME])
        game[GameKeys.BANNER_PATH] = (
            "Steam\\" + a_appmanifest[VDFKeys.APPID] + ".jpg")
        game[GameKeys.BANNER_URL] = (
            self.banner_url_prefix + app_id + self.banner_url_suffix)
        game[GameKeys.LASTPLAYED] = self.get_last_played_stamp(app_id,
                                                               a_local_config)
        tags = self.get_tags(app_id, a_shared_config)
        if tags:
            game[GameKeys.TAGS] = tags
        if a_game_definitions:
            game_def = a_game_definitions.get(app_id, None)
            if game_def:
                game[GameKeys.HOURS_LAST_TWO_WEEKS] = game_def.get(
                    GameKeys.HOURS_LAST_TWO_WEEKS, 0)
                game[GameKeys.HOURS_TOTAL] = game_def.get(GameKeys.HOURS_TOTAL,
                                                          0)
            else:
                print("\t\t\tAccount does not have '%s'" % game[GameKeys.NAME])
                return None
        return game

    def get_game_name(self, a_appmanifest):
        if a_appmanifest.get(VDFKeys.NAME):
            name = a_appmanifest[VDFKeys.NAME]
        elif a_appmanifest.get(VDFKeys.USERCONFIG):
            name = a_appmanifest[VDFKeys.USERCONFIG][VDFKeys.NAME]
        return Utility.title_move_the(Utility.title_strip_unicode(name))

    def get_last_played_stamp(self, a_app_id, a_local_config):
        lastplayed = 0
        if (a_local_config and a_local_config.get(a_app_id, None)):
            if a_local_config[a_app_id].get(VDFKeys.LASTPLAYED, None):
                lastplayed = (a_local_config[a_app_id][VDFKeys.LASTPLAYED])
        return lastplayed

    def get_tags(self, a_app_id, a_shared_config):
        if (a_shared_config and a_shared_config.get(a_app_id, None)):
            if a_shared_config[a_app_id].get(VDFKeys.TAGS, None):
                return (a_shared_config[a_app_id][VDFKeys.TAGS])
        return None

    def get_not_installed_game(self, a_app_id, a_game_def, a_local_config,
                               a_shared_config):
        game = {}
        game[GameKeys.PLATFORM] = Platform.STEAM
        game[GameKeys.NOT_INSTALLED] = True
        game[GameKeys.NAME] = a_game_def.get(GameKeys.NAME, a_app_id)
        game[GameKeys.BANNER_URL] = (
            self.banner_url_prefix + a_app_id + self.banner_url_suffix)
        game[GameKeys.BANNER_PATH] = "Steam\\" + a_app_id + ".jpg"
        game[GameKeys.LASTPLAYED] = 0
        game[GameKeys.PATH] = "steam://rungameid/" + a_app_id
        game[GameKeys.HOURS_LAST_TWO_WEEKS] = a_game_def.get(
            GameKeys.HOURS_LAST_TWO_WEEKS, 0)
        game[GameKeys.HOURS_TOTAL] = a_game_def.get(GameKeys.HOURS_TOTAL, 0)
        game[GameKeys.LASTPLAYED] = self.get_last_played_stamp(a_app_id,
                                                               a_local_config)
        tags = self.get_tags(a_app_id, a_shared_config)
        if tags:
            game[GameKeys.TAGS] = tags
        return game

    def get_shortcuts(self):
        result = {}
        output = self.read_shortcuts_file(self.steam_path, self.userdataid)
        if output:
            shortcuts_dict = self.parse_shortcuts_string(output)
            i = 0
            for key, shortcut in shortcuts_dict.items():
                game = {}
                game[GameKeys.PLATFORM] = Platform.STEAM_SHORTCUT
                game[GameKeys.LASTPLAYED] = 0
                game[GameKeys.NAME], shortcut = self.parse_shortcut_title(
                    shortcut)
                print("\tFound game '%s'" % game[GameKeys.NAME])
                game[GameKeys.BANNER_PATH] = "Steam shortcuts\\%s.jpg" % (
                    game[GameKeys.NAME])
                path, arguments, shortcut = self.parse_shortcut_path(shortcut)
                if not os.path.isfile(path):
                    game[GameKeys.ERROR] = True
                    game[GameKeys.INVALID_PATH] = True
                game[GameKeys.PATH] = "steam://rungameid/%s" % (
                    self.parse_shortcut_app_id('"%s"%s' % (path, arguments),
                                               game[GameKeys.NAME]))
                game[GameKeys.NAME] = Utility.title_move_the(
                    Utility.title_strip_unicode(game[GameKeys.NAME]))
                tags = self.parse_shortcut_tags(shortcut)
                if tags:
                    game[GameKeys.TAGS] = tags
                result[str(i)] = game
                i += 1
        return result

    def read_shortcuts_file(self, a_path, a_userdataid):
        shortcuts_path = os.path.join(a_path, "userdata", a_userdataid,
                                      "config", "shortcuts.vdf")
        if not os.path.isfile(shortcuts_path):
            return None
        shortcuts = ""
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
        return output

    def parse_shortcuts_string(self, a_string):
        shortcuts_dict = {}
        i = 0
        a_string = a_string[9:]
        appnameIndex = a_string.lower().rfind("appname")
        while appnameIndex >= 0:
            shortcuts_dict[str(i)] = a_string[appnameIndex - 1:]
            a_string = a_string[:appnameIndex - 1]
            appnameIndex = a_string.lower().rfind("appname")
            i += 1
        return shortcuts_dict

    def parse_shortcut_title(self, a_string):
        start = a_string.find("|", 1) + 1
        end = a_string.find("|", start)
        name = a_string[start:end]
        return (name, a_string[end:])

    def parse_shortcut_path(self, a_string):
        start = a_string.find('"') + 1
        end = a_string.find('"', start)
        path = a_string[start:end]
        start = end + 1
        end = a_string.find('|', start)
        arguments = a_string[start:end]
        return (path, arguments, a_string[end:])

    def parse_shortcut_app_id(self, a_path, a_name):
        app_id = zlib.crc32((a_path + a_name).encode())
        app_id = app_id | 0x80000000
        app_id = app_id << 32 | 0x02000000
        return app_id

    def parse_shortcut_tags(self, a_string):
        start = a_string.find("tags||") + 6
        end = a_string.find("||||", start)
        a_string = a_string[start:end]
        tagsList = a_string.split("||")
        if len(tagsList) > 0:
            tags = {}
            for tag in tagsList:
                pair = tag.split("|")
                if len(pair) > 1:
                    tags[pair[0]] = pair[1]
            if bool(tags) != False:
                return tags

    def is_int(self, a_string):
        try:
            int(a_string)
            return True
        except ValueError:
            return False
