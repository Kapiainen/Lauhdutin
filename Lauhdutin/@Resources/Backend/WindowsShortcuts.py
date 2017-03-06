# Python environment
import os, re, subprocess, shlex
# Back-end
from Enums import GameKeys
from Enums import Platform
import Utility


class WindowsShortcuts():
    def __init__(self, a_resource_path):
        self.shortcut_parser_script = os.path.join(a_resource_path, "Backend",
                                                   "ShortcutParser.vbs")
        path = os.path.join(a_resource_path, "Shortcuts")
        if not os.path.isdir(path):
            os.makedirs(path)
        self.shortcuts_path = path
        self.shortcut_banners = None
        for root, directories, files in os.walk(
                os.path.join(a_resource_path, "Banners", "Shortcuts")):
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
        return []

    def process_shortcut(self, a_shortcut):
        args = [
            "wscript", self.shortcut_parser_script,
            os.path.join(self.shortcuts_path, a_shortcut)
        ]
        output = subprocess.check_output(args)
        if output:
            output = output.decode()
            target_match = re.search("Target=([^\r]+)", output)
            if target_match:
                game_dict = {}
                name = a_shortcut[:-4]
                game_dict[GameKeys.NAME] = Utility.title_move_the(name)
                target_path = target_match.group(1)
                if not os.path.isfile(target_path) and not os.path.isdir(target_path):
                    game_dict[GameKeys.ERROR] = True
                    game_dict[GameKeys.INVALID_PATH] = True
                game_dict[GameKeys.PATH] = target_path
                game_dict[GameKeys.LASTPLAYED] = 0
                game_dict[GameKeys.PLATFORM] = Platform.WINDOWS_SHORTCUT
                game_dict[GameKeys.BANNER_PATH] = self.get_banner_path(name)
                arguments_match = re.search("Arguments=([^\r]+)", output)
                if arguments_match:
                    arguments_string = arguments_match.group(1)
                    if arguments_string:
                        arguments = shlex.split(arguments_string)
                        game_dict[GameKeys.ARGUMENTS] = arguments
                return (name, game_dict)
        return (None, None)

    def get_banner_path(self, a_name):
        if self.shortcut_banners:
            for banner in self.shortcut_banners:
                if banner.lower().startswith("%s." % a_name.lower()):
                    return "Shortcuts\\%s" % banner
        return "Shortcuts\\%s.jpg" % a_name

    def get_url_shortcuts(self):
        for root, directories, files in os.walk(self.shortcuts_path):
            return [f for f in files if f.endswith(".url")]
        return []

    def process_url_shortcut(self, a_shortcut):
        args = [
            "wscript", self.shortcut_parser_script,
            os.path.join(self.shortcuts_path, a_shortcut)
        ]
        output = subprocess.check_output(args)
        if output:
            output = output.decode()
            target_match = re.search("Target=([^\r]+)", output)
            if target_match:
                game_dict = {}
                name = a_shortcut[:-4]
                game_dict[GameKeys.NAME] = Utility.title_move_the(name)
                game_dict[GameKeys.PATH] = target_match.group(1)
                game_dict[GameKeys.LASTPLAYED] = 0
                game_dict[GameKeys.PLATFORM] = Platform.WINDOWS_URL_SHORTCUT
                game_dict[GameKeys.BANNER_PATH] = self.get_banner_path(name)
                return (name, game_dict)
        return (None, None)
