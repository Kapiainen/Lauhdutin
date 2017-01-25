# Python environment
import os, urllib.request, time
# Back-end
from Enums import GameKeys

class BannerDownloader:
	def __init__(self, a_path):
		self.banners_path = os.path.join(a_path, "Banners")
		subDirs = ["Steam", "GOG Galaxy", "Steam Shortcuts", "Shortcuts"]
		for subDir in subDirs:
			dirPath = os.path.join(self.banners_path, subDir)
			if not os.path.isdir(dirPath):
				os.makedirs(dirPath)

	def process(self, a_game_dicts):
		for game_dict in a_game_dicts:
			if game_dict.get(GameKeys.BANNER_URL, None) != None and game_dict.get(GameKeys.BANNER_PATH, None) != None:
				file_path = os.path.join(self.banners_path, game_dict[GameKeys.BANNER_PATH])
				if game_dict.get(GameKeys.BANNER_ERROR, False):
					print("\tBanner failed to download last time for '%s'" % game_dict[GameKeys.NAME])
				elif not os.path.isfile(file_path):
					time.sleep(0.5)
					try:
						urllib.request.urlretrieve(game_dict[GameKeys.BANNER_URL], file_path)
						print("\tDownloading banner for '%s'" % game_dict[GameKeys.NAME])
					except:
						print("\tFailed to download banner for '%s'" % game_dict[GameKeys.NAME])
						game_dict[GameKeys.BANNER_ERROR] = True
				else:
					print("\tBanner already downloaded for '%s'" % game_dict[GameKeys.NAME])
				del game_dict[GameKeys.BANNER_URL]
