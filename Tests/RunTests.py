import unittest, sys, os
CWD = os.getcwd()
HEAD, TAIL = os.path.split(CWD)
BACKEND_PATH = os.path.join(HEAD, "Lauhdutin", "@Resources", "Backend")
sys.path.append(BACKEND_PATH)
FRONTEND_PATH = os.path.join(HEAD, "Lauhdutin", "@Resources", "Frontend")
sys.path.append(FRONTEND_PATH)
from BannerDownloader import BannerDownloader
from GOGGalaxy import GOGGalaxy
from Steam import Steam
from WindowsShortcuts import WindowsShortcuts
import Utility
from Enums import GameKeys
from Enums import Platform


class WindowsShortcutsTests(unittest.TestCase):
    def create_class_instance(self):
        return WindowsShortcuts(os.path.join(CWD, "@Resources"))

    def test_constructor(self):
        ws = self.create_class_instance()
        self.assertEqual(ws.shortcuts_path,
                         os.path.join(CWD, "@Resources", "Shortcuts"))
        self.assertEqual(ws.shortcut_banners,
                         ["Office Suite 2015.gif", "Overwatch.png"])

    def test_get_games(self):
        ws = self.create_class_instance()
        self.assertEqual(ws.get_games(), {
            "Office Suite 2015": {
                GameKeys.NAME: "Office Suite 2015",
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2015.gif"
            },
            "Office Suite 2017": {
                GameKeys.NAME: "Office Suite 2017",
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
            },
            "Overwatch": {
                GameKeys.NAME: "Overwatch",
                GameKeys.PATH:
                "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Overwatch.png"
            }
        })

    def test_get_shortcuts(self):
        ws = self.create_class_instance()
        self.assertEqual(ws.get_shortcuts(
        ), ["Office Suite 2015.lnk", "Office Suite 2017.lnk", "Overwatch.lnk"])

    def test_process_shortcut(self):
        ws = self.create_class_instance()
        self.assertEqual(
            ws.process_shortcut("Office Suite 2015.lnk"),
            ("Office Suite 2015", {
                GameKeys.NAME: "Office Suite 2015",
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2015.gif"
            }))
        self.assertEqual(
            ws.process_shortcut("Office Suite 2017.lnk"),
            ("Office Suite 2017", {
                GameKeys.NAME: "Office Suite 2017",
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
            }))
        self.assertEqual(
            ws.process_shortcut("Overwatch.lnk"), ("Overwatch", {
                GameKeys.NAME: "Overwatch",
                GameKeys.PATH:
                "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Overwatch.png"
            }))
        self.assertEqual(
            ws.process_shortcut("ImaginaryGame47.lnk"), (None, None))

    def test_get_banner_path(self):
        ws = self.create_class_instance()
        self.assertEqual(
            ws.get_banner_path("Office Suite 2015"),
            "Shortcuts\\Office Suite 2015.gif")
        self.assertEqual(
            ws.get_banner_path("Office Suite 2017"),
            "Shortcuts\\Office Suite 2017.jpg")
        self.assertEqual(
            ws.get_banner_path("Overwatch"), "Shortcuts\\Overwatch.png")

    def test_read_shortcut(self):
        ws = self.create_class_instance()
        self.assertIsNotNone(ws.read_shortcut("Office Suite 2015.lnk"))
        self.assertIsNotNone(ws.read_shortcut("Office Suite 2017.lnk"))
        self.assertIsNotNone(ws.read_shortcut("Overwatch.lnk"))
        self.assertIsNone(ws.read_shortcut("ImaginaryGame47.lnk"))
        self.assertNotEqual("", ws.read_shortcut("Office Suite 2015.lnk"))
        self.assertNotEqual("", ws.read_shortcut("Office Suite 2017.lnk"))
        self.assertNotEqual("", ws.read_shortcut("Overwatch.lnk"))

    def test_get_shortcut_target_path(self):
        ws = self.create_class_instance()
        self.assertEqual(
            ws.get_shortcut_target_path(
                ws.read_shortcut("Office Suite 2015.lnk")),
            "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe")
        self.assertEqual(
            ws.get_shortcut_target_path(
                ws.read_shortcut("Office Suite 2017.lnk")),
            "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe")
        self.assertEqual(
            ws.get_shortcut_target_path(ws.read_shortcut("Overwatch.lnk")),
            "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe")


class UtilityTests(unittest.TestCase):
    def test_title_strip_unicode(self):
        self.assertEqual(
            Utility.title_strip_unicode("Sleeping Dogs™"), "Sleeping Dogs")

    def test_title_move_the(self):
        self.assertEqual(
            Utility.title_move_the("The Witcher 3 - Wild Hunt"),
            "Witcher 3 - Wild Hunt, The")


class SteamTests(unittest.TestCase):
    def create_class_instance(self):
        return Steam(
            os.path.join(CWD, "Steam"), "0123456789", "12498725934096846")

    def test_constructor(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.steam_path, os.path.join(CWD, "Steam"))
        self.assertEqual(steam.userdataid, "0123456789")
        self.assertEqual(steam.steamid64, "12498725934096846")
        self.assertEqual(steam.banner_url_prefix, "http://cdn.akamai.steamstatic.com/steam/apps/")
        self.assertEqual(steam.banner_url_suffix, "/header.jpg")

    def test_get_shortcuts(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.get_shortcuts(), {
            '0': {
                'platform': 1,
                'lastplayed': 0,
                'title': 'RealTemp',
                'banner': 'Steam shortcuts\\RealTemp.jpg',
                'path': 'steam://rungameid/17906321180839641088'
            },
            '1': {
                'platform': 1,
                'lastplayed': 0,
                'title': 'GPU-Z',
                'banner': 'Steam shortcuts\\GPU-Z.jpg',
                'path': 'steam://rungameid/11616125968489381888',
                'tags': {
                    '0': 'GPU',
                    '1': 'Utility'
                }
            },
            '2': {
                'platform': 1,
                'lastplayed': 0,
                'title': 'CPU-Z',
                'banner': 'Steam shortcuts\\CPU-Z.jpg',
                'path': 'steam://rungameid/13161530333453090816',
                'tags': {
                    '0': 'CPU',
                    '1': 'Utility'
                }
            }
        })

    def test_read_shortcuts_file(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.read_shortcuts_file(),
            '|shortcuts||0||AppName|CPU-Z||exe|"D:\\Programs\\CPU-Z\\cpuz_x64.exe"||StartDir|"D:\\Programs\\CPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|CPU||1|Utility||||1||AppName|GPU-Z||exe|"D:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe"||StartDir|"D:\\Programs\\GPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|GPU||1|Utility||||2||AppName|RealTemp||exe|"D:\\Programs\\RealTemp\\RealTemp.exe"||StartDir|"D:\\Programs\\RealTemp\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags|||||'
        )

    def test_parse_shortcuts_string(self):
        steam = self.create_class_instance()
        output = steam.read_shortcuts_file()
        self.assertEqual(
            steam.parse_shortcuts_string(output), {
                '0':
                '|AppName|RealTemp||exe|"D:\\Programs\\RealTemp\\RealTemp.exe"||StartDir|"D:\\Programs\\RealTemp\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags|||||',
                '1':
                '|AppName|GPU-Z||exe|"D:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe"||StartDir|"D:\\Programs\\GPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|GPU||1|Utility||||2|',
                '2':
                '|AppName|CPU-Z||exe|"D:\\Programs\\CPU-Z\\cpuz_x64.exe"||StartDir|"D:\\Programs\\CPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|CPU||1|Utility||||1|'
            })

    def test_parse_shortcut_title(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(steam.read_shortcuts_file())
        name, _ = steam.parse_shortcut_title(shortcuts["0"])
        self.assertEqual(name, "RealTemp")
        name, _ = steam.parse_shortcut_title(shortcuts["1"])
        self.assertEqual(name, "GPU-Z")
        name, _ = steam.parse_shortcut_title(shortcuts["2"])
        self.assertEqual(name, "CPU-Z")

    def test_parse_shortcut_path(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(steam.read_shortcuts_file())
        name, shortcut = steam.parse_shortcut_title(shortcuts["0"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "D:\\Programs\\RealTemp\\RealTemp.exe")
        name, shortcut = steam.parse_shortcut_title(shortcuts["1"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "D:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe")
        name, shortcut = steam.parse_shortcut_title(shortcuts["2"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "D:\\Programs\\CPU-Z\\cpuz_x64.exe")

    def test_parse_shortcut_app_id(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(steam.read_shortcuts_file())
        name, shortcut = steam.parse_shortcut_title(shortcuts["0"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 17906321180839641088)
        name, shortcut = steam.parse_shortcut_title(shortcuts["1"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 11616125968489381888)
        name, shortcut = steam.parse_shortcut_title(shortcuts["2"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 13161530333453090816)

    def test_parse_shortcut_tags(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(steam.read_shortcuts_file())
        name, shortcut = steam.parse_shortcut_title(shortcuts["0"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        self.assertEqual(steam.parse_shortcut_tags(shortcut), None)
        name, shortcut = steam.parse_shortcut_title(shortcuts["1"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        self.assertEqual(
            steam.parse_shortcut_tags(shortcut), {"0": "GPU",
                                                  "1": "Utility"})
        name, shortcut = steam.parse_shortcut_title(shortcuts["2"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        self.assertEqual(
            steam.parse_shortcut_tags(shortcut), {"0": "CPU",
                                                  "1": "Utility"})

    def test_is_int(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.is_int("0123456789"), True)
        self.assertEqual(steam.is_int("This is not a number"), False)


if __name__ == '__main__':
    unittest.main()
