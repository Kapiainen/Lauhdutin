# Python environment
import sys, os, subprocess, json

print("Running on Python %d.%d.%d" %
      (sys.version_info.major, sys.version_info.minor, sys.version_info.micro))

RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
ResourcePath = sys.argv[2][:-1]
Config = sys.argv[3][:-1]


def set_skin_status(a_message=""):
    subprocess.call(
        [
            RainmeterPath, "!SetOption", "StatusMessage", "Text", a_message,
            Config
        ],
        shell=False)
    subprocess.call(
        [RainmeterPath, "!UpdateMeterGroup", "Status", Config], shell=False)
    subprocess.call(
        [RainmeterPath, "!ShowMeterGroup", "Status", Config], shell=False)
    subprocess.call([RainmeterPath, "!Redraw", Config], shell=False)


minimum_major_version = 3
minimum_minor_version = 5
if not (sys.version_info.major >= minimum_major_version and
        sys.version_info.minor >= minimum_minor_version):
    set_skin_status(
        "Unsupported Python version: %s.%s. Expected %d.%d or later." %
        (sys.version_info.major, sys.version_info.minor, minimum_major_version,
         minimum_minor_version))
    exit()

try:
    # Back-end
    from WindowsShortcuts import WindowsShortcuts
    from Steam import Steam
    from GOGGalaxy import GOGGalaxy
    from BannerDownloader import BannerDownloader
    from Enums import GameKeys
    from Battlenet import Battlenet
except ImportError:
    try:
        sys.path.append(os.path.join(ResourcePath, "Backend"))
        from WindowsShortcuts import WindowsShortcuts
        from Steam import Steam
        from GOGGalaxy import GOGGalaxy
        from BannerDownloader import BannerDownloader
        from Enums import GameKeys
        from Battlenet import Battlenet
    except ImportError:
        import traceback
        traceback.print_exc()
        input()

try:
    ####
    import time
    startTime = time.time()

    ####


    def read_json(a_path):
        if os.path.isfile(a_path):
            with open(a_path, encoding="utf-8") as f:
                return json.load(f)
        return None

    def write_json(a_path, a_json):
        with open(a_path, "w") as f:
            json.dump(a_json, f, indent=2)

    settings = read_json(os.path.join(ResourcePath, "settings.json"))
    if settings:
        set_skin_status("Processing...")
        # Windows shortcuts (.lnk) in @Resources\Shortcuts
        print("Processing Windows shortcuts...")
        windows_shortcuts = WindowsShortcuts(ResourcePath)
        windows_shortcuts_games = windows_shortcuts.get_games()

        # Battle.net games (classic games are not supported at the moment)
        if settings.get("battlenet_path", None):
            print("Processing Battle.net games...")
            battlenet = Battlenet(settings["battlenet_path"], ResourcePath)
            battlenet_games = battlenet.get_games()
        else:
            battlenet_games = {}

        # Steam games
        if settings.get("steam_path", None):
            print("Processing Steam games...")
            steamID64 = ""
            if settings.get("parse_steam_community_profile", True):
                steamID64 = settings.get("steam_id64", "")
            steam = Steam(settings["steam_path"],
                          settings.get("steam_userdataid", ""),
                          steamID64)
            steam_games = steam.get_games()
            # Non-steam games added to Steam as shortcuts
            print("Processing Steam shortcuts...")
            steam_shortcuts = steam.get_shortcuts()
        else:
            steam_games = {}
            steam_shortcuts = {}

        if settings.get("galaxy_path", None):
            # GOG Galaxy games
            print("Processing GOG Galaxy games...")
            galaxy = GOGGalaxy(settings["galaxy_path"])
            galaxy_games = galaxy.get_games()
        else:
            galaxy_games = {}

        # Merge game dictionaries into one list
        print("Generating master list of games...")
        all_games = []
        if windows_shortcuts_games:
            for game_key, game_dict in windows_shortcuts_games.items():
                all_games.append(game_dict)

        if battlenet_games:
            for game_key, game_dict in battlenet_games.items():
                all_games.append(game_dict)

        if steam_games:
            for game_key, game_dict in steam_games.items():
                all_games.append(game_dict)

        if steam_shortcuts:
            for game_key, game_dict in steam_shortcuts.items():
                all_games.append(game_dict)

        if galaxy_games:
            for game_key, game_dict in galaxy_games.items():
                all_games.append(game_dict)

        print("Found %d games..." % len(all_games))
        print(
            "Comparing new master list of games with old master list of games..."
        )
        all_games_old = read_json(os.path.join(ResourcePath, "games.json"))
        if all_games_old:
            for game_new in all_games:
                i = 0
                while i < len(all_games_old):
                    game_old = all_games_old[i]
                    if (game_new[GameKeys.NAME] == game_old[GameKeys.NAME] and
                            game_new[GameKeys.PLATFORM] == game_old[
                                GameKeys.PLATFORM]):
                        if (game_new.get(GameKeys.LASTPLAYED, None) != None and
                                game_old.get(GameKeys.LASTPLAYED,
                                             None) != None):
                            if int(game_old[GameKeys.LASTPLAYED]) > int(
                                    game_new[GameKeys.LASTPLAYED]):
                                game_new[GameKeys.LASTPLAYED] = game_old[
                                    GameKeys.LASTPLAYED]
                        if game_old.get(GameKeys.HIDDEN, None) != None:
                            game_new[GameKeys.HIDDEN] = game_old[
                                GameKeys.HIDDEN]
                        if game_old.get(GameKeys.BANNER_ERROR, False):
                            game_new[GameKeys.BANNER_ERROR] = True
                        if (game_old.get(GameKeys.HOURS_TOTAL, None) and
                                not game_new.get(GameKeys.HOURS_TOTAL, None)):
                            game_new[GameKeys.HOURS_TOTAL] = game_old[
                                GameKeys.HOURS_TOTAL]
                        del all_games_old[i]
                        break
                    i += 1
            for game_old in all_games_old:
                game_old[GameKeys.NOT_INSTALLED] = True
                all_games.append(game_old)
        for game_new in all_games:
            if not game_new.get(GameKeys.HOURS_TOTAL, None):
                game_new[GameKeys.HOURS_TOTAL] = 0.0

        set_skin_status("Downloading...")
        print("Downloading banners for %d games from supported platforms..." %
              (len(steam_games) + len(galaxy_games)))
        banner_downloader = BannerDownloader(ResourcePath)
        banner_downloader.process(all_games)

        print("Writing master list of %d games to disk..." % len(all_games))
        write_json(os.path.join(ResourcePath, "games.json"), all_games)

        print("Initializing frontend...")
        subprocess.call(
            [
                RainmeterPath, "!CommandMeasure", "LauhdutinScript", "Init()",
                Config
            ],
            shell=False)

    ####
    endTime = time.time()
    seconds = float(endTime - startTime)
    minutes = int(seconds / 60)
    seconds = float(seconds - minutes * 60.0)
    print("Execution time: %s minutes %.2f seconds" % (minutes, seconds))
    ####
except:
    import traceback
    traceback.print_exc()
    exception_type, exception_message, stack_trace = sys.exc_info()
    set_skin_status("Exception raised in the backend: %s" % exception_message)
input()
