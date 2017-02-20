# Python environment
import os, re
# Back-end
from Enums import GameKeys
from Enums import Platform
import Utility


class WindowsShortcuts():
    def __init__(self, a_path):
        path = os.path.join(a_path, "Shortcuts")
        if not os.path.isdir(path):
            os.makedirs(path)
        self.shortcuts_path = path
        self.path_regex = re.compile(
            r"(\w:(?:\\[^\\\/:\*\?\<\>\|]+(?=\\))*\\[^\\\/:\*\?\<\>\|]+\.exe)")
        self.shortcut_banners = None
        for root, directories, files in os.walk(
                os.path.join(a_path, "Banners", "Shortcuts")):
            self.shortcut_banners = files
            break

    def get_games(self):
        result = {}
        shortcuts = self.get_shortcuts()
        if shortcuts:
            for shortcut in shortcuts:
                print("\tFound shortcut '%s'" % shortcut)
                game_key, game_dict = self.process_shortcut(shortcut)
                if (game_key and game_dict):
                    result[game_key] = game_dict
        url_shortcuts = self.get_url_shortcuts()
        if url_shortcuts:
            for shortcut in url_shortcuts:
                print("\tFound shortcut '%s'" % shortcut)
                game_key, game_dict = self.process_url_shortcut(shortcut)
                print(game_dict)
                if (game_key and game_dict):
                    result[game_key] = game_dict
        return result

    def get_shortcuts(self):
        for root, directories, files in os.walk(self.shortcuts_path):
            return [f for f in files if f.endswith(".lnk")]
        return None

    def process_shortcut(self, a_shortcut):
        # Quick and dirty. Should be replaced at some point with a better method.
        name = a_shortcut[:-4] # Remove '.lnk' extension
        shortcut_contents = self.read_shortcut(a_shortcut)
        if not shortcut_contents:
            return (None, None)
        target_path = self.get_shortcut_target_path(shortcut_contents)
        if not target_path:
            return (None, None)
        game_dict = {}
        game_dict[GameKeys.NAME] = Utility.title_move_the(name)
        if not os.path.isfile(target_path):
            game_dict[GameKeys.ERROR] = True
            game_dict[GameKeys.INVALID_PATH] = True
        game_dict[GameKeys.PATH] = target_path
        game_dict[GameKeys.LASTPLAYED] = 0
        game_dict[GameKeys.PLATFORM] = Platform.WINDOWS_SHORTCUT
        game_dict[GameKeys.BANNER_PATH] = self.get_banner_path(name)
        return (name, game_dict)

    def get_banner_path(self, a_name):
        if self.shortcut_banners:
            for banner in self.shortcut_banners:
                if banner.lower().startswith("%s." % a_name.lower()):
                    return "Shortcuts\\%s" % banner
        return "Shortcuts\\%s.jpg" % a_name

    def read_shortcut(self, a_shortcut):
        shortcut_path = os.path.join(self.shortcuts_path, a_shortcut)
        if not os.path.isfile(shortcut_path):
            return None
        shortcut_contents = ""
        with open(shortcut_path, "rb") as f:
            byte = f.read(1)
            while byte != b"":
                shortcut_contents = shortcut_contents + byte.decode(
                    "utf-8", errors="ignore")
                byte = f.read(1)
        return shortcut_contents

    def get_shortcut_target_path(self, a_string):
        for match in self.path_regex.finditer(a_string):
            return match.group(1)
        return None

    def get_url_shortcuts(self):
        for root, directories, files in os.walk(self.shortcuts_path):
            return [f for f in files if f.endswith(".url")]
        return None

    def process_url_shortcut(self, a_shortcut):
        name = a_shortcut[:-4] # Remove '.url' extension
        with open(os.path.join(self.shortcuts_path, a_shortcut)) as f:
            contents = f.read()
            match = re.search("URL=(.*)", contents)
            if match:
                game_dict = {}
            game_dict[GameKeys.NAME] = Utility.title_move_the(name)
            game_dict[GameKeys.PATH] = match.group(1)
            game_dict[GameKeys.LASTPLAYED] = 0
            game_dict[GameKeys.PLATFORM] = Platform.WINDOWS_URL_SHORTCUT
            game_dict[GameKeys.BANNER_PATH] = self.get_banner_path(name)
            return (name, game_dict)
        return (None, None)