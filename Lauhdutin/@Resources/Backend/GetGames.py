# Python environment
import sys, os, subprocess, json, time

print("Running on Python %d.%d.%d" %
      (sys.version_info.major, sys.version_info.minor, sys.version_info.micro))

RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
ResourcePath = sys.argv[2][:-1]
Config = sys.argv[3][:-1]


def set_skin_status(a_message=""):
    subprocess.call(
        [
            RainmeterPath, "!CommandMeasure", "LauhdutinScript",
            "OnShowStatus('%s')" % a_message, Config
        ],
        shell=False)

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
        exception_type, exception_message, stack_trace = sys.exc_info()
        set_skin_status("Exception raised in the backend: %s" % str(exception_message).replace("'", "`"))
        input()
        sys.exit()

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
        set_skin_status("Processing Windows shortcuts...")
        windows_shortcuts = WindowsShortcuts(ResourcePath)
        windows_shortcuts_games = windows_shortcuts.get_games()

        # Battle.net games (classic games are not supported at the moment)
        if settings.get("battlenet_path", None):
            print("Processing Battle.net games...")
            set_skin_status("Processing Battle.net games...")
            battlenet = Battlenet(settings["battlenet_path"], ResourcePath)
            battlenet_games = battlenet.get_games()
        else:
            battlenet_games = {}

        # Steam games
        if settings.get("steam_path", None):
            print("Processing Steam games...")
            set_skin_status("Processing Steam games...")
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
            set_skin_status("Processing GOG Galaxy games...")
            galaxy = GOGGalaxy(settings["galaxy_path"])
            galaxy_games = galaxy.get_games()
        else:
            galaxy_games = {}

        # Merge game dictionaries into one list
        print("Generating master list of games...")
        set_skin_status("Generating master list of games...")
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
        set_skin_status("Comparing new and old master lists...")
        all_games_old = read_json(os.path.join(ResourcePath, "games.json"))
        if all_games_old:
            for game_new in all_games:
                i = 0
                while i < len(all_games_old):
                    game_old = all_games_old[i]
                    if (game_new.get(GameKeys.NAME, "new") == game_old.get(
                            GameKeys.NAME, "old") and game_new.get(
                                GameKeys.PLATFORM, -1) == game_old.get(
                                    GameKeys.PLATFORM, -2)):
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
                        if game_old.get(GameKeys.NOTES, None):
                            game_new[GameKeys.NOTES] = game_old[GameKeys.NOTES]
                        if game_old.get(GameKeys.TAGS, None):
                            sorted_unique_tags = []
                            sorted_unique_tags.extend([
                                value
                                for key, value in game_old.get(GameKeys.TAGS,
                                                               {}).items()
                            ])
                            sorted_unique_tags.extend([
                                value
                                for key, value in game_new.get(GameKeys.TAGS,
                                                               {}).items()
                            ])
                            if sorted_unique_tags:
                                sorted_unique_tags = sorted(
                                    set(sorted_unique_tags))
                                combined_tags = {}
                                j = 0
                                for tag in sorted_unique_tags:
                                    combined_tags[str(j)] = tag
                                    j += 1
                                game_new[GameKeys.TAGS] = combined_tags
                        if game_old.get(GameKeys.IGNORES_BANGS, None) != None:
                            game_new[GameKeys.IGNORES_BANGS] = game_old[
                                GameKeys.IGNORES_BANGS]
                        else:
                            if settings.get("execute_bangs_by_default", True):
                                game_new[GameKeys.IGNORES_BANGS] = False
                            else:
                                game_new[GameKeys.IGNORES_BANGS] = True
                        if game_old.get(GameKeys.PROCESS_OVERRIDE, None):
                            game_new[GameKeys.PROCESS_OVERRIDE] = game_old[
                                GameKeys.PROCESS_OVERRIDE]
                        del all_games_old[i]
                        break
                    i += 1
            for game_old in all_games_old:
                game_old[GameKeys.NOT_INSTALLED] = True
                all_games.append(game_old)
        for game_new in all_games:
            if not game_new.get(GameKeys.HOURS_TOTAL, None):
                game_new[GameKeys.HOURS_TOTAL] = 0.0

        set_skin_status("Downloading banners...")
        print("Downloading banners for %d games from supported platforms..." %
              (len(steam_games) + len(galaxy_games) + len(battlenet_games)))
        banner_downloader = BannerDownloader(ResourcePath)
        for status in banner_downloader.process(all_games):
            set_skin_status("Downloading banners...#CRLF#%d%%" % status)

        # Daily backups - Adjust the list immediately below to keep more or fewer daily backups.
        backup_paths = [
            os.path.join(ResourcePath, "games_daily_backup_01.json"),
            os.path.join(ResourcePath, "games_daily_backup_02.json"),
            os.path.join(ResourcePath, "games_daily_backup_03.json"),
            os.path.join(ResourcePath, "games_daily_backup_04.json"),
            os.path.join(ResourcePath, "games_daily_backup_05.json")
        ]
        if not os.path.exists(backup_paths[0]):
            games_path = os.path.join(ResourcePath, "games.json")
            if os.path.exists(games_path):
                previous_games_master_list = read_json(games_path)
                if previous_games_master_list:
                    print("Making a new daily backup...")
                    set_skin_status("Making a new daily backup...")
                    write_json(backup_paths[0], previous_games_master_list)
        else:
            current_date = time.strftime('%Y-%m-%d', time.localtime(time.time()))
            latest_backup_date = time.strftime('%Y-%m-%d', time.localtime(os.path.getmtime(backup_paths[0])))
            if current_date != latest_backup_date:
                print("Making a new daily backup...")
                set_skin_status("Making a new daily backup...")
                backup_count = 0
                for backup_path in backup_paths:
                    if os.path.exists(backup_path):
                        backup_count += 1
                    else:
                        break
                if backup_count >= len(backup_paths):
                    os.remove(backup_paths[-1])
                    backup_count = len(backup_paths) - 1
                while backup_count > 0:
                    os.rename(backup_paths[backup_count - 1], backup_paths[backup_count])
                    backup_count -= 1
                write_json(backup_paths[0], all_games)
            else:
                print("A daily backup has already been made today (%s)..." % latest_backup_date)

        print("Writing master list of %d games to disk..." % len(all_games))
        set_skin_status("Writing master list of %d games to disk..." % len(all_games))
        write_json(os.path.join(ResourcePath, "games.json"), all_games)

        temp_dir_path = os.path.join(ResourcePath, "Temp")
        if not os.path.isdir(temp_dir_path):
            os.makedirs(temp_dir_path)

        print("Initializing frontend...")
        subprocess.call(
            [
                RainmeterPath, "!CommandMeasure", "LauhdutinScript",
                "OnInitialized()", Config
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
    set_skin_status("Exception raised in the backend: %s" % str(exception_message).replace("'", "`"))
input()
