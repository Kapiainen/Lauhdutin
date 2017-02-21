import os
from Enums import GameKeys
from Enums import Platform
import Utility


class Battlenet():
    def __init__(self, a_games_path, a_resources_path):
        self.games_folders = a_games_path.split("|")
        self.banners = []
        banners_path = os.path.join(a_resources_path, "Banners", "Battle.net")
        if os.path.isdir(banners_path):
            for root, dirs, files in os.walk(banners_path):
                self.banners = files
                break
        self.supported_games = {
            "Hearthstone": {
                "path": "battlenet://WTCG",
                "process": "Hearthstone.exe"  # No 64-bit executable
            },
            "Heroes of the Storm": {
                "path": "battlenet://Hero",
                "process": "HeroesOfTheStorm_x64.exe",
                "process32": "HeroesOfTheStorm.exe"
            },
            "Overwatch": {
                "path": "battlenet://Pro",
                "process": "Overwatch.exe"  # No 32-bit executable
            },
            "StarCraft II": {
                "path": "battlenet://S2",
                "process": "SC2_x64.exe",
                "process32": "SC2.exe"
            },
            "Diablo III": {
                "path": "battlenet://D3",
                "process": "Diablo III64.exe",
                "process32": "Diablo III.exe"
            },
            "World of Warcraft": {
                "path": "battlenet://WoW",
                "process": "Wow-64.exe",
                "process32": "Wow.exe"
            }
        }

    def get_games(self):
        result = {}
        for folder in self.games_folders:
            for root, dirs, files in os.walk(folder):
                for directory in dirs:
                    game_template = self.supported_games.get(directory, None)
                    if game_template:
                        print("\tFound game '%s'" % directory)
                        game_dict = {
                            GameKeys.NAME: directory,
                            GameKeys.PATH: game_template["path"],
                            GameKeys.PROCESS: game_template["process"],
                            GameKeys.LASTPLAYED: 0,
                            GameKeys.PLATFORM: Platform.BATTLENET,
                            GameKeys.BANNER_PATH:
                            self.get_banner_path(directory),
                            GameKeys.HOURS_TOTAL: 0
                        }
                        if (Utility.get_os_bitness() == 32 and
                                game_template.get("process32", None)):
                            game_dict[GameKeys.PROCESS] = (
                                game_template["process32"])
                        result[directory] = game_dict
        return result

    def get_banner_path(self, a_game_title):
        lower_case_title = a_game_title.lower()
        for banner in self.banners:
            if lower_case_title in banner.lower():
                return "Battle.net\\%s" % banner
        return "Battle.net\\%s.jpg" % a_game_title
