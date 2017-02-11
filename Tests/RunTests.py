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
STEAM_PATH = os.path.join(CWD, "Steam")
STEAM_LIBRARY_PATH = os.path.join(CWD, "SteamLibrary")
STEAM_USERDATAID = "0123456789"
STEAM_STEAMID64 = "12498725934096846"
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
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2015.gif"
            },
            "Office Suite 2017": {
                GameKeys.NAME: "Office Suite 2017",
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
            },
            "Overwatch": {
                GameKeys.NAME: "Overwatch",
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
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
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
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
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
                GameKeys.PATH:
                "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
                GameKeys.LASTPLAYED: 0,
                GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
                GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
            }))
        self.assertEqual(
            ws.process_shortcut("Overwatch.lnk"), ("Overwatch", {
                GameKeys.NAME: "Overwatch",
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
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
        return Steam(STEAM_PATH, "0123456789", "12498725934096846")

    def test_constructor(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.steam_path, STEAM_PATH)
        self.assertEqual(steam.userdataid, "0123456789")
        self.assertEqual(steam.steamid64, "12498725934096846")
        self.assertEqual(steam.banner_url_prefix,
                         "http://cdn.akamai.steamstatic.com/steam/apps/")
        self.assertEqual(steam.banner_url_suffix, "/header.jpg")

    def test_get_games(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.get_games(), {
            '206190': {
                'platform': 0,
                'path': 'steam://rungameid/206190',
                'title': 'Gunpoint',
                'banner': 'Steam\\206190.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/206190/header.jpg',
                'lastplayed': '1483391006'
            },
            '212680': {
                'platform': 0,
                'path': 'steam://rungameid/212680',
                'title': 'FTL: Faster Than Light',
                'banner': 'Steam\\212680.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/212680/header.jpg',
                'lastplayed': '1485649993',
                'tags': {
                    '0': 'Not completed'
                }
            },
            '40700': {
                'platform': 0,
                'path': 'steam://rungameid/40700',
                'title': 'Machinarium',
                'banner': 'Steam\\40700.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/40700/header.jpg',
                'lastplayed': '1351494000',
                'tags': {
                    '0': 'Not completed'
                }
            },
            '26800': {
                'platform': 0,
                'path': 'steam://rungameid/26800',
                'title': 'Braid',
                'banner': 'Steam\\26800.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/26800/header.jpg',
                'lastplayed': 0
            }
        })

    def test_get_libraries(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.get_libraries(STEAM_PATH), [STEAM_PATH, 'G:\\SteamLibrary'])

    def test_get_shared_config(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.get_shared_config(STEAM_PATH, STEAM_USERDATAID), {
                '40700': {
                    'lastplayed': '1365538122',
                    'tags': {
                        '0': 'Not completed'
                    }
                },
                '206190': {},
                '212680': {
                    'lastplayed': '1364562857',
                    'cloudenabled': '0',
                    'tags': {
                        '0': 'Not completed'
                    }
                },
                '219150': {
                    'lastplayed': '1360500953'
                },
                '250900': {
                    'tags': {
                        '0': 'Not completed'
                    }
                },
                '9985': {
                    'lastplayed': '1291895311'
                },
                '13140': {
                    'lastplayed': '1267043680',
                    'cloudenabled': '1'
                },
                '15700': {
                    'tags': {
                        '0': 'Not completed'
                    }
                },
                '17450': {
                    'lastplayed': '1351361838'
                },
                '17460': {
                    'lastplayed': '1285609024'
                },
                '17500': {
                    'lastplayed': '1271009838'
                },
                '18110': {
                    'preloadsell': '1',
                    'lastplayed': '1275666608'
                },
                '20500': {
                    'lastplayed': '1306685354',
                    'tags': {
                        '0': 'Not completed'
                    },
                    'hidden': '0'
                }
            })

    def test_get_local_config(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.get_local_config(STEAM_PATH, STEAM_USERDATAID), {
                '40700': {
                    'lastplayed': '1351494000'
                },
                '206190': {
                    'lastplayed': '1483391006'
                },
                '212680': {
                    'lastplayed': '1485649993'
                },
                '219150': {
                    'lastplayed': '1483391126'
                },
                '250900': {
                    'lastplayed': '1483487840'
                },
                '9890': {
                    'lastplayed': '86400'
                },
                '9985': {
                    'lastplayed': '86400'
                },
                '13140': {
                    'lastplayed': '86400'
                },
                '15700': {
                    'lastplayed': '1462968923'
                },
                '17080': {
                    'lastplayed': '1378381708'
                },
                '17450': {
                    'lastplayed': '1417274465'
                },
                '17460': {
                    'lastplayed': '1375801947'
                },
                '17500': {
                    'lastplayed': '1271009838'
                },
                '17520': {
                    'lastplayed': '1432370270'
                },
                '18110': {
                    'lastplayed': '86400'
                },
                '20500': {
                    'lastplayed': '1428684708'
                }
            })

    def test_get_community_profile(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.get_community_profile(0), [
                b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><response><error><![CDATA[The specified profile could not be found.]]></error></response>'
            ])

    def test_decode_community_profile(self):
        steam = self.create_class_instance()
        with open(os.path.join(CWD, "SteamCommunityProfile.xml"), "r") as f:
            encoded_lines = [line.encode() for line in f.readlines()]
            self.assertEqual(
                steam.decode_community_profile(encoded_lines), [
                    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><gamesList>',
                    '<steamID64>12498725934096846</steamID64>',
                    '<steamID><![CDATA[TestPersona]]></steamID>', '<games>',
                    '<game>', '<appID>40700</appID>',
                    '<name><![CDATA[Machinarium]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/40700/5101b896d69a6eafc32667689a7f5d8756a4ac87.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/40700]]></storeLink>',
                    '<hoursOnRecord>2.5</hoursOnRecord>', '</game>', '<game>',
                    '<appID>206190</appID>',
                    '<name><![CDATA[Gunpoint]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/206190/f82deeb9e1b01b8d8247d7824a7ce2f9ca8133f7.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/206190]]></storeLink>',
                    '<hoursOnRecord>2.0</hoursOnRecord>',
                    '<statsLink><![CDATA[http://steamcommunity.com/profiles/12498725934096846/stats/206190]]></statsLink>',
                    '<globalStatsLink><![CDATA[http://steamcommunity.com/stats/206190/achievements/]]></globalStatsLink>',
                    '</game>', '<game>', '<appID>212680</appID>',
                    '<name><![CDATA[FTL: Faster Than Light]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/212680/975193db5ca8cc2a4c969cea8f80d93157264ec1.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/212680]]></storeLink>',
                    '<hoursOnRecord>14.4</hoursOnRecord>', '</game>', '<game>',
                    '<appID>219150</appID>',
                    '<name><![CDATA[Hotline Miami]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/219150/540a1457099f072ced7153239861e42f14febd56.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/219150]]></storeLink>',
                    '<hoursOnRecord>4.6</hoursOnRecord>',
                    '<statsLink><![CDATA[http://steamcommunity.com/profiles/12498725934096846/stats/HotlineMiami]]></statsLink>',
                    '<globalStatsLink><![CDATA[http://steamcommunity.com/stats/HotlineMiami/achievements/]]></globalStatsLink>',
                    '</game>', '<game>', '<appID>250900</appID>',
                    '<name><![CDATA[The Binding of Isaac: Rebirth]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/250900/c7a76988c53e7f3a3aa1cf224aaf4dbd067ebbf9.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/250900]]></storeLink>',
                    '<hoursOnRecord>528.2</hoursOnRecord>',
                    '<statsLink><![CDATA[http://steamcommunity.com/profiles/12498725934096846/stats/250900]]></statsLink>',
                    '<globalStatsLink><![CDATA[http://steamcommunity.com/stats/250900/achievements/]]></globalStatsLink>',
                    '</game>', '<game>', '<appID>15700</appID>',
                    "<name><![CDATA[Oddworld: Abe's Oddysee]]></name>",
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/15700/b36c09cedd607be8661c6ae9dea7966158281c3f.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/15700]]></storeLink>',
                    '</game>', '<game>', '<appID>17450</appID>',
                    '<name><![CDATA[Dragon Age: Origins]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/17450/c313ab7941ba8375dd17a0531b724ef94ca54dea.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/17450]]></storeLink>',
                    '<hoursOnRecord>124.4</hoursOnRecord>', '</game>',
                    '<game>', '<appID>17500</appID>',
                    '<name><![CDATA[Zombie Panic! Source]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/17500/696ce5ae0fc0f454da3518097d263c7cab48a017.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/17500]]></storeLink>',
                    '<hoursOnRecord>0.2</hoursOnRecord>',
                    '<statsLink><![CDATA[http://steamcommunity.com/profiles/12498725934096846/stats/17500]]></statsLink>',
                    '<globalStatsLink><![CDATA[http://steamcommunity.com/stats/17500/achievements/]]></globalStatsLink>',
                    '</game>', '<game>', '<appID>20500</appID>',
                    '<name><![CDATA[Red Faction: Guerrilla Steam Edition]]></name>',
                    '<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/20500/27632013243c01b01cbbc7a34184d93b08bd5f9f.jpg]]></logo>',
                    '<storeLink><![CDATA[http://steamcommunity.com/app/20500]]></storeLink>',
                    '<hoursOnRecord>2.6</hoursOnRecord>',
                    '<statsLink><![CDATA[http://steamcommunity.com/profiles/12498725934096846/stats/20500]]></statsLink>',
                    '<globalStatsLink><![CDATA[http://steamcommunity.com/stats/20500/achievements/]]></globalStatsLink>',
                    '</game>', '</games>', '</gamesList>'
                ])

    def test_parse_community_profile(self):
        steam = self.create_class_instance()
        with open(os.path.join(CWD, "SteamCommunityProfile.xml"), "r") as f:
            encoded_lines = [line.encode() for line in f.readlines()]
            decoded_lines = steam.decode_community_profile(encoded_lines)
            self.assertEqual(
                steam.parse_community_profile(decoded_lines), {
                    '40700': {
                        'appid': '40700',
                        'title': 'Machinarium',
                        'hourstotal': 2.5
                    },
                    '206190': {
                        'appid': '206190',
                        'title': 'Gunpoint',
                        'hourstotal': 2.0
                    },
                    '212680': {
                        'appid': '212680',
                        'title': 'FTL: Faster Than Light',
                        'hourstotal': 14.4
                    },
                    '219150': {
                        'appid': '219150',
                        'title': 'Hotline Miami',
                        'hourstotal': 4.6
                    },
                    '250900': {
                        'appid': '250900',
                        'title': 'Binding of Isaac: Rebirth, The',
                        'hourstotal': 528.2
                    },
                    '15700': {
                        'appid': '15700',
                        'title': "Oddworld: Abe's Oddysee"
                    },
                    '17450': {
                        'appid': '17450',
                        'title': 'Dragon Age: Origins',
                        'hourstotal': 124.4
                    },
                    '17500': {
                        'appid': '17500',
                        'title': 'Zombie Panic! Source',
                        'hourstotal': 0.2
                    },
                    '20500': {
                        'appid': '20500',
                        'title': 'Red Faction: Guerrilla Steam Edition',
                        'hourstotal': 2.6
                    }
                })

    def test_get_appmanifest_paths(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.get_appmanifest_paths(STEAM_PATH), [
                os.path.join(STEAM_PATH, "steamapps", appmanifest)
                for appmanifest in [
                    'appmanifest_206190.acf', 'appmanifest_212680.acf',
                    'appmanifest_40700.acf'
                ]
            ])
        self.assertEqual(
            steam.get_appmanifest_paths(STEAM_LIBRARY_PATH), [
                os.path.join(STEAM_LIBRARY_PATH, "steamapps", appmanifest)
                for appmanifest in [
                    'appmanifest_219150.acf', 'appmanifest_250900.acf',
                    'appmanifest_274170.acf'
                ]
            ])

    def test_get_appmanifest(self):
        steam = self.create_class_instance()
        appmanifest_paths = steam.get_appmanifest_paths(STEAM_PATH)
        appmanifest_paths.extend(
            steam.get_appmanifest_paths(STEAM_LIBRARY_PATH))
        expected_results = [{
            'appid': '206190',
            'name': 'Gunpoint',
            'userconfig': {
                'language': 'english'
            }
        }, {
            'appid': '212680',
            'name': 'FTL: Faster Than Light',
            'userconfig': {
                'language': 'english'
            }
        }, {
            'appid': '40700',
            'name': 'Machinarium',
            'userconfig': {
                'language': 'english'
            }
        }, {
            'appid': '219150',
            'name': 'Hotline Miami',
            'userconfig': {
                'language': 'english'
            }
        }, {
            'appid': '250900',
            'name': 'The Binding of Isaac: Rebirth',
            'userconfig': {
                'language': 'english'
            }
        }, {
            'appid': '274170',
            'name': 'Hotline Miami 2: Wrong Number',
            'userconfig': {
                'language': 'english'
            }
        }]
        self.assertEqual(len(appmanifest_paths), len(expected_results))
        i = 0
        while i < len(appmanifest_paths):
            self.assertEqual(
                steam.get_appmanifest(appmanifest_paths[i]),
                expected_results[i])
            i += 1

    def test_get_installed_game(self):
        steam = self.create_class_instance()
        with open(os.path.join(CWD, "SteamCommunityProfile.xml"), "r") as f:
            encoded_lines = [line.encode() for line in f.readlines()]
            decoded_lines = steam.decode_community_profile(encoded_lines)
            game_definitions = steam.parse_community_profile(decoded_lines)
            local_config = steam.get_local_config(STEAM_PATH, STEAM_USERDATAID)
            shared_config = steam.get_shared_config(STEAM_PATH,
                                                    STEAM_USERDATAID)
            appmanifest_paths = steam.get_appmanifest_paths(STEAM_PATH)
            appmanifest_paths.extend(
                steam.get_appmanifest_paths(STEAM_LIBRARY_PATH))
            expected_results = [{
                'platform': 0,
                'path': 'steam://rungameid/206190',
                'title': 'Gunpoint',
                'banner': 'Steam\\206190.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/206190/header.jpg',
                'lastplayed': '1483391006',
                'hourslast2weeks': 0,
                'hourstotal': 2.0
            }, {
                'platform': 0,
                'path': 'steam://rungameid/212680',
                'title': 'FTL: Faster Than Light',
                'banner': 'Steam\\212680.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/212680/header.jpg',
                'lastplayed': '1485649993',
                'tags': {
                    '0': 'Not completed'
                },
                'hourslast2weeks': 0,
                'hourstotal': 14.4
            }, {
                'platform': 0,
                'path': 'steam://rungameid/40700',
                'title': 'Machinarium',
                'banner': 'Steam\\40700.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/40700/header.jpg',
                'lastplayed': '1351494000',
                'tags': {
                    '0': 'Not completed'
                },
                'hourslast2weeks': 0,
                'hourstotal': 2.5
            }, {
                'platform': 0,
                'path': 'steam://rungameid/219150',
                'title': 'Hotline Miami',
                'banner': 'Steam\\219150.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/219150/header.jpg',
                'lastplayed': '1483391126',
                'hourslast2weeks': 0,
                'hourstotal': 4.6
            }, {
                'platform': 0,
                'path': 'steam://rungameid/250900',
                'title': 'Binding of Isaac: Rebirth, The',
                'banner': 'Steam\\250900.jpg',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/250900/header.jpg',
                'lastplayed': '1483487840',
                'tags': {
                    '0': 'Not completed'
                },
                'hourslast2weeks': 0,
                'hourstotal': 528.2
            }, None]
            appmanifests = [
                steam.get_appmanifest(appmanifest_path)
                for appmanifest_path in appmanifest_paths
            ]
            self.assertEqual(len(appmanifests), len(expected_results))
            i = 0
            while i < len(appmanifests):
                self.assertEqual(
                    steam.get_installed_game(appmanifests[i], local_config,
                                             shared_config, game_definitions),
                    expected_results[i])
                i += 1

    def test_get_game_name(self):
        steam = self.create_class_instance()
        appmanifest_paths = steam.get_appmanifest_paths(STEAM_PATH)
        appmanifest_paths.extend(
            steam.get_appmanifest_paths(STEAM_LIBRARY_PATH))
        expected_results = [
            'Gunpoint', 'FTL: Faster Than Light', 'Machinarium',
            'Hotline Miami', 'Binding of Isaac: Rebirth, The',
            'Hotline Miami 2: Wrong Number'
        ]
        self.assertEqual(len(appmanifest_paths), len(expected_results))
        i = 0
        while i < len(appmanifest_paths):
            appmanifest = steam.get_appmanifest(appmanifest_paths[i])
            self.assertEqual(
                steam.get_game_name(appmanifest), expected_results[i])
            i += 1

    def test_get_last_played_stamp(self):
        steam = self.create_class_instance()
        local_config = steam.get_local_config(STEAM_PATH, STEAM_USERDATAID)
        app_ids = [
            '40700', '206190', '212680', '219150', '250900', '9890', '9985',
            '13140', '15700', '17080', '17450', '17460', '17500', '17520',
            '18110', '20500'
        ]
        expected_results = [
            '1351494000', '1483391006', '1485649993', '1483391126',
            '1483487840', '86400', '86400', '86400', '1462968923',
            '1378381708', '1417274465', '1375801947', '1271009838',
            '1432370270', '86400', '1428684708'
        ]
        self.assertEqual(len(app_ids), len(expected_results))
        i = 0
        while i < len(app_ids):
            self.assertEqual(
                steam.get_last_played_stamp(app_ids[i], local_config),
                expected_results[i])
            i += 1

    def test_get_tags(self):
        steam = self.create_class_instance()
        shared_config = steam.get_shared_config(STEAM_PATH, STEAM_USERDATAID)
        app_ids = [
            "40700", "206190", "212680", "219150", "250900", "9985", "13140",
            "15700", "17450", "17460", "17500", "18110", "20500"
        ]
        expected_results = [{
            "0": "Not completed"
        }, None, {
            "0": "Not completed"
        }, None, {
            "0": "Not completed"
        }, None, None, {
            "0": "Not completed"
        }, None, None, None, None, {
            "0": "Not completed"
        }]
        self.assertEqual(len(app_ids), len(expected_results))
        i = 0
        while i < len(app_ids):
            self.assertEqual(
                steam.get_tags(app_ids[i], shared_config), expected_results[i])
            i += 1

    def test_get_not_installed_game(self):
        steam = self.create_class_instance()
        local_config = steam.get_local_config(STEAM_PATH, STEAM_USERDATAID)
        shared_config = steam.get_shared_config(STEAM_PATH, STEAM_USERDATAID)
        with open(os.path.join(CWD, "SteamCommunityProfile.xml"), "r") as f:
            encoded_lines = [line.encode() for line in f.readlines()]
            decoded_lines = steam.decode_community_profile(encoded_lines)
            game_definitions = steam.parse_community_profile(decoded_lines)
            app_ids = [app_id for app_id in game_definitions]
            expected_results = [{
                'platform': 0,
                'notinstalled': True,
                'title': 'Machinarium',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/40700/header.jpg',
                'banner': 'Steam\\40700.jpg',
                'lastplayed': '1351494000',
                'path': 'steam://rungameid/40700',
                'hourslast2weeks': 0,
                'hourstotal': 2.5,
                'tags': {
                    '0': 'Not completed'
                }
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Gunpoint',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/206190/header.jpg',
                'banner': 'Steam\\206190.jpg',
                'lastplayed': '1483391006',
                'path': 'steam://rungameid/206190',
                'hourslast2weeks': 0,
                'hourstotal': 2.0
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'FTL: Faster Than Light',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/212680/header.jpg',
                'banner': 'Steam\\212680.jpg',
                'lastplayed': '1485649993',
                'path': 'steam://rungameid/212680',
                'hourslast2weeks': 0,
                'hourstotal': 14.4,
                'tags': {
                    '0': 'Not completed'
                }
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Hotline Miami',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/219150/header.jpg',
                'banner': 'Steam\\219150.jpg',
                'lastplayed': '1483391126',
                'path': 'steam://rungameid/219150',
                'hourslast2weeks': 0,
                'hourstotal': 4.6
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Binding of Isaac: Rebirth, The',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/250900/header.jpg',
                'banner': 'Steam\\250900.jpg',
                'lastplayed': '1483487840',
                'path': 'steam://rungameid/250900',
                'hourslast2weeks': 0,
                'hourstotal': 528.2,
                'tags': {
                    '0': 'Not completed'
                }
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': "Oddworld: Abe's Oddysee",
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/15700/header.jpg',
                'banner': 'Steam\\15700.jpg',
                'lastplayed': '1462968923',
                'path': 'steam://rungameid/15700',
                'hourslast2weeks': 0,
                'hourstotal': 0,
                'tags': {
                    '0': 'Not completed'
                }
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Dragon Age: Origins',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/17450/header.jpg',
                'banner': 'Steam\\17450.jpg',
                'lastplayed': '1417274465',
                'path': 'steam://rungameid/17450',
                'hourslast2weeks': 0,
                'hourstotal': 124.4
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Zombie Panic! Source',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/17500/header.jpg',
                'banner': 'Steam\\17500.jpg',
                'lastplayed': '1271009838',
                'path': 'steam://rungameid/17500',
                'hourslast2weeks': 0,
                'hourstotal': 0.2
            }, {
                'platform': 0,
                'notinstalled': True,
                'title': 'Red Faction: Guerrilla Steam Edition',
                'bannerurl':
                'http://cdn.akamai.steamstatic.com/steam/apps/20500/header.jpg',
                'banner': 'Steam\\20500.jpg',
                'lastplayed': '1428684708',
                'path': 'steam://rungameid/20500',
                'hourslast2weeks': 0,
                'hourstotal': 2.6,
                'tags': {
                    '0': 'Not completed'
                }
            }]
            self.assertEqual(len(app_ids), len(expected_results))
            i = 0
            while i < len(app_ids):
                self.assertEqual(
                    steam.get_not_installed_game(
                        app_ids[i], game_definitions[app_ids[i]], local_config,
                        shared_config), expected_results[i])
                i += 1

    def test_get_shortcuts(self):
        steam = self.create_class_instance()
        self.assertEqual(steam.get_shortcuts(), {
            '0': {
                'platform': 1,
                'lastplayed': 0,
                'title': 'RealTemp',
                'banner': 'Steam shortcuts\\RealTemp.jpg',
                'path': 'steam://rungameid/10040859602154684416',
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True
            },
            '1': {
                'platform': 1,
                'lastplayed': 0,
                'title': 'GPU-Z',
                'banner': 'Steam shortcuts\\GPU-Z.jpg',
                'path': 'steam://rungameid/18383980479696076800',
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
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
                'path': 'steam://rungameid/11463541207985029120',
                GameKeys.ERROR: True,
                GameKeys.INVALID_PATH: True,
                'tags': {
                    '0': 'CPU',
                    '1': 'Utility'
                }
            }
        })

    def test_read_shortcuts_file(self):
        steam = self.create_class_instance()
        self.assertEqual(
            steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID),
            '|shortcuts||0||AppName|CPU-Z||exe|"X:\\Programs\\CPU-Z\\cpuz_x64.exe"||StartDir|"X:\\Programs\\CPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|CPU||1|Utility||||1||AppName|GPU-Z||exe|"X:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe"||StartDir|"X:\\Programs\\GPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|GPU||1|Utility||||2||AppName|RealTemp||exe|"X:\\Programs\\RealTemp\\RealTemp.exe"||StartDir|"X:\\Programs\\RealTemp\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags|||||'
        )

    def test_parse_shortcuts_string(self):
        steam = self.create_class_instance()
        output = steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID)
        self.assertEqual(
            steam.parse_shortcuts_string(output), {
                '0':
                '|AppName|RealTemp||exe|"X:\\Programs\\RealTemp\\RealTemp.exe"||StartDir|"X:\\Programs\\RealTemp\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags|||||',
                '1':
                '|AppName|GPU-Z||exe|"X:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe"||StartDir|"X:\\Programs\\GPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|GPU||1|Utility||||2|',
                '2':
                '|AppName|CPU-Z||exe|"X:\\Programs\\CPU-Z\\cpuz_x64.exe"||StartDir|"X:\\Programs\\CPU-Z\\"||icon|||ShortcutPath|||IsHidden||||||AllowDesktopConfig||||||OpenVR||||||tags||0|CPU||1|Utility||||1|'
            })

    def test_parse_shortcut_title(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(
            steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID))
        name, _ = steam.parse_shortcut_title(shortcuts["0"])
        self.assertEqual(name, "RealTemp")
        name, _ = steam.parse_shortcut_title(shortcuts["1"])
        self.assertEqual(name, "GPU-Z")
        name, _ = steam.parse_shortcut_title(shortcuts["2"])
        self.assertEqual(name, "CPU-Z")

    def test_parse_shortcut_path(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(
            steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID))
        name, shortcut = steam.parse_shortcut_title(shortcuts["0"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "X:\\Programs\\RealTemp\\RealTemp.exe")
        name, shortcut = steam.parse_shortcut_title(shortcuts["1"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "X:\\Programs\\GPU-Z\\GPU-Z.1.17.0.exe")
        name, shortcut = steam.parse_shortcut_title(shortcuts["2"])
        path, _ = steam.parse_shortcut_path(shortcut)
        self.assertEqual(path, "X:\\Programs\\CPU-Z\\cpuz_x64.exe")

    def test_parse_shortcut_app_id(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(
            steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID))
        name, shortcut = steam.parse_shortcut_title(shortcuts["0"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 10040859602154684416)
        name, shortcut = steam.parse_shortcut_title(shortcuts["1"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 18383980479696076800)
        name, shortcut = steam.parse_shortcut_title(shortcuts["2"])
        path, shortcut = steam.parse_shortcut_path(shortcut)
        app_id = steam.parse_shortcut_app_id(path, name)
        self.assertEqual(app_id, 11463541207985029120)

    def test_parse_shortcut_tags(self):
        steam = self.create_class_instance()
        shortcuts = steam.parse_shortcuts_string(
            steam.read_shortcuts_file(STEAM_PATH, STEAM_USERDATAID))
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


# TODO: Write tests for GOGGalaxy.py and create mock data to use when testing.
# TODO: Write tests for BannerDownloader.py.
# TODO: Write tests for GetGames.py.

if __name__ == '__main__':
    unittest.main()
