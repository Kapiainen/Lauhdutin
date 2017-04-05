import sys, os, subprocess, json
from Enums import SettingKeys

try:
    RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
    ResourcePath = sys.argv[2][:-1]
    IsStartingBang = sys.argv[3][:-1] == "true"
    CallbackFunction = sys.argv[4][:-1]
    Config = sys.argv[5][:-1]

    settings_path = os.path.join(ResourcePath, "settings.json")
    temp_path = os.path.join(ResourcePath, "Temp", "bangs_temp.txt")
    if os.path.isfile(settings_path):
        settings = None
        with open(settings_path, "r") as file:
            settings = json.load(file)
        if settings:
            bangs = settings.get(SettingKeys.BANGS_STARTING, "")
            if not IsStartingBang:
                bangs = settings.get(SettingKeys.BANGS_STOPPING, "")
            bangs = "]\n[".join(bangs.split("]["))
            with open(temp_path, "w") as file:
                file.write(bangs)
            subprocess.call(["notepad", temp_path])
            with open(temp_path, "r") as file:
                bangs = file.read()
            bangs = bangs.replace("]\n[", "][")
            bangs = bangs.replace("`", "\"")
            with open(temp_path, "w") as file:
                file.write(bangs)
            subprocess.call(
                [
                    RainmeterPath, "!CommandMeasure", "SettingsScript",
                    "%s()" % CallbackFunction, Config
                ],
                shell=False)
except:
    import traceback
    traceback.print_exc()
input()
