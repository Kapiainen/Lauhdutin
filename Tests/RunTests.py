import unittest, sys, os
CWD = os.getcwd()
HEAD, TAIL = os.path.split(CWD)
RESOURCES_PATH = os.path.join(CWD, "@Resources")
BACKEND_PATH = os.path.join(HEAD, "Lauhdutin", "@Resources", "Backend")
sys.path.append(BACKEND_PATH)
FRONTEND_PATH = os.path.join(HEAD, "Lauhdutin", "@Resources", "Frontend")
sys.path.append(FRONTEND_PATH)
from BannerDownloader import BannerDownloader
from GOGGalaxy import GOGGalaxy
from Steam import Steam
from WindowsShortcuts import WindowsShortcuts
from Enums import GameKeys
from Enums import Platform

class WindowsShortcutsTests(unittest.TestCase):
	def create_class_instance(self):
		return WindowsShortcuts(RESOURCES_PATH)

	def test_it_constructs(self):
		ws = self.create_class_instance()
		self.assertEqual(ws.shortcuts_path, os.path.join(RESOURCES_PATH, "Shortcuts"))
		self.assertEqual(ws.shortcut_banners, ["Office Suite 2015.gif", "Overwatch.png"])

	def test_it_gets_shortcuts(self):
		ws = self.create_class_instance()
		self.assertEqual(ws.get_shortcuts(), ["Office Suite 2015.lnk", "Office Suite 2017.lnk", "Overwatch.lnk"])

	def test_it_reads_a_shortcut(self):
		ws = self.create_class_instance()
		self.assertIsNotNone(ws.read_shortcut("Office Suite 2015.lnk"))
		self.assertIsNotNone(ws.read_shortcut("Office Suite 2017.lnk"))
		self.assertIsNotNone(ws.read_shortcut("Overwatch.lnk"))
		self.assertIsNone(ws.read_shortcut("ImaginaryGame47.lnk"))
		self.assertNotEqual("", ws.read_shortcut("Office Suite 2015.lnk"))
		self.assertNotEqual("", ws.read_shortcut("Office Suite 2017.lnk"))
		self.assertNotEqual("", ws.read_shortcut("Overwatch.lnk"))

	def test_it_gets_shortcut_target_path(self):
		ws = self.create_class_instance()
		self.assertEqual(ws.get_shortcut_target_path(ws.read_shortcut("Office Suite 2015.lnk")), "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe")
		self.assertEqual(ws.get_shortcut_target_path(ws.read_shortcut("Office Suite 2017.lnk")), "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe")
		self.assertEqual(ws.get_shortcut_target_path(ws.read_shortcut("Overwatch.lnk")), "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe")

	def test_it_processes_shortcuts(self):
		ws = self.create_class_instance()
		self.assertEqual(ws.process_shortcut("Office Suite 2015.lnk"),
			("Office Suite 2015", 
			{
				GameKeys.NAME: "Office Suite 2015",
				GameKeys.PATH: "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe",
				GameKeys.LASTPLAYED: 0,
				GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
				GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2015.gif"
			}))
		self.assertEqual(ws.process_shortcut("Office Suite 2017.lnk"),
			("Office Suite 2017", 
			{
				GameKeys.NAME: "Office Suite 2017",
				GameKeys.PATH: "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
				GameKeys.LASTPLAYED: 0,
				GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
				GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
			}))
		self.assertEqual(ws.process_shortcut("Overwatch.lnk"),
			("Overwatch", 
			{
				GameKeys.NAME: "Overwatch",
				GameKeys.PATH: "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe",
				GameKeys.LASTPLAYED: 0,
				GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
				GameKeys.BANNER_PATH: "Shortcuts\\Overwatch.png"
			}))
		self.assertEqual(ws.process_shortcut("ImaginaryGame47.lnk"), (None, None))

	def test_it_gets_games(self):
		ws = self.create_class_instance()
		self.assertEqual(ws.get_games(),
			{
				"Office Suite 2015": {
					GameKeys.NAME: "Office Suite 2015",
					GameKeys.PATH: "D:\\Program Files (x86)\\Office Suite 2015\\vERsion_1_52_8.exe",
					GameKeys.LASTPLAYED: 0,
					GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
					GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2015.gif"
				},
				"Office Suite 2017": {
					GameKeys.NAME: "Office Suite 2017",
					GameKeys.PATH: "D:\\Program Files (x86)\\Office Suite 2017\\version 2.4.53.exe",
					GameKeys.LASTPLAYED: 0,
					GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
					GameKeys.BANNER_PATH: "Shortcuts\\Office Suite 2017.jpg"
				},
				"Overwatch": {
					GameKeys.NAME: "Overwatch",
					GameKeys.PATH: "D:\\Program Files\\Battle.net Games\\Overwatch\\Overwatch.exe",
					GameKeys.LASTPLAYED: 0,
					GameKeys.PLATFORM: Platform.WINDOWS_SHORTCUT,
					GameKeys.BANNER_PATH: "Shortcuts\\Overwatch.png"
				}
			})		

if __name__ == '__main__':
	unittest.main()