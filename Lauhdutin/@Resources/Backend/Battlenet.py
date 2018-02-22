import os, urllib.request, string, re
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
        cache_path = os.path.join(a_resources_path, "Cache")
        if not os.path.isdir(cache_path):
            os.makedirs(cache_path)
        self.store_page_contents = None
        store_page_path = os.path.join(cache_path, "Battle.net store.html")
        if not os.path.isfile(store_page_path):
            store_page = urllib.request.urlopen(
                "https://eu.battle.net/shop/en/product/category/digital-games")
            if store_page:
                store_page_lines = []
                for line in store_page.readlines():
                    try:
                        store_page_lines.append(
                            line.decode("utf-8", errors="ignore").strip())
                    except:
                        pass
                output = []
                for line in store_page_lines:
                    temp = []
                    for char in line:
                        if char in string.printable:
                            temp.append(char)
                    output.append(temp)
                store_page_lines = []
                for line in output:
                    store_page_lines.append("".join(line))
                with open(store_page_path, "w") as f:
                    f.write("\n".join(store_page_lines))
                self.store_page_contents = store_page_lines
        else:
            with open(store_page_path, "r") as f:
                self.store_page_contents = f.readlines()
        self.supported_games = {
            "hearthstone": {
                "title": "Hearthstone",
                "path": "battlenet://WTCG",
                "process": "Hearthstone.exe"  # No 64-bit executable
            },
            "heroes of the storm": {
                "title": "Heroes of the Storm",
                "path": "battlenet://Hero",
                "process": "HeroesOfTheStorm_x64.exe",
                "process32": "HeroesOfTheStorm.exe"
            },
            "overwatch": {
                "title": "Overwatch",
                "path": "battlenet://Pro",
                "process": "Overwatch.exe"  # No 32-bit executable
            },
            "starcraft ii": {
                "title": "StarCraft II",
                "path": "battlenet://S2",
                "process": "SC2_x64.exe",
                "process32": "SC2.exe"
            },
            "diablo iii": {
                "title": "Diablo III",
                "path": "battlenet://D3",
                "process": "Diablo III64.exe",
                "process32": "Diablo III.exe"
            },
            "world of warcraft": {
                "title": "World of Warcraft",
                "path": "battlenet://WoW",
                "process": "Wow-64.exe",
                "process32": "Wow.exe"
            },
            "destiny 2": {
                "title": "Destiny 2",
                "path": "battlenet://DST2",
                "process": "destiny2.exe" # No 32-bit executable
            }
        }
        self.supported_classic_games = {}

    def get_games(self):
        result = {}
        for folder in self.games_folders:
            for root, dirs, files in os.walk(folder):
                for directory in dirs:
                    game_template = self.supported_games.get(directory.lower(),
                                                             None)
                    if game_template:
                        print("\tFound game '%s'" % game_template["title"])
                        banner_path = self.get_banner_path(
                            game_template["title"])
                        banner_url = None
                        if not banner_path:
                            regex = re.compile(r"<img src=\"(.+?)\" alt=\"" +
                                               game_template[
                                                   "title"] + r"\" />")
                            for line in reversed(self.store_page_contents):
                                match = regex.match(line)
                                if match:
                                    banner_url = "https:%s" % match.group(1)
                                    break
                            if not banner_url:
                                regex = re.compile(r"<img src=\"(.+?)\" alt=\""
                                                   + game_template["title"])
                                for line in reversed(self.store_page_contents):
                                    match = regex.match(line)
                                    if match:
                                        banner_url = "https:%s" % match.group(
                                            1)
                                        break
                            banner_path = "Battle.net\\%s.jpg" % game_template[
                                "title"]
                        game_dict = {
                            GameKeys.NAME: game_template["title"],
                            GameKeys.PATH: game_template["path"],
                            GameKeys.PROCESS: game_template["process"],
                            GameKeys.LASTPLAYED: 0,
                            GameKeys.PLATFORM: Platform.BATTLENET,
                            GameKeys.BANNER_PATH: banner_path,
                            GameKeys.HOURS_TOTAL: 0
                        }
                        if banner_url:
                            game_dict[GameKeys.BANNER_URL] = banner_url
                        if (Utility.get_os_bitness() == 32 and
                                game_template.get("process32", None)):
                            game_dict[GameKeys.PROCESS] = (
                                game_template["process32"])
                        result[game_template["title"]] = game_dict
        return result

    def get_banner_path(self, a_game_title):
        lower_case_title = a_game_title.lower()
        for banner in self.banners:
            if lower_case_title in banner.lower():
                return "Battle.net\\%s" % banner
        return None
