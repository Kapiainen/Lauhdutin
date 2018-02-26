Platform = require('main.platforms.platform')
Game = require('main.game')

-- Dump a list of folders in one of the paths.
-- Parse the list of folders and see if any of the names match with one of the pre-defined sets of arguments.

class Battlenet extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.BATTLENET
		@platformProcess = 'Battle.net.exe'
		@name = 'Blizzard Battle.net'
		@cachePath = 'cache\\battlenet\\'
		@battlenetPaths = [path for path in *settings\getBattlenetPaths()] or {}
		@enabled = settings\getBattlenetEnabled()
		@games = {}

	hasUnprocessedPaths: () => return #@battlenetPaths > 0
	
	hasProcessedPath: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	identifyFolders: () =>
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\battlenet\\identifyFolders.bat" "%s"]')\format(@battlenetPaths[1]))
		return @getWaitCommand(), '', 'OnIdentifiedBattlenetFolders'

	generateGames: () =>
		games = {}
		output = io.readFile(io.joinPaths(@cachePath, 'output.txt'))
		basePath = table.remove(@battlenetPaths, 1)
		folders = output\lower()\splitIntoLines()
		bits = table.remove(folders, 1)
		bits = if (bits\find('64')) ~= nil then 64 else 32
		for folder in *folders
			args = nil
			switch folder
				when 'destiny 2'
					args = {
						title: 'Destiny 2'
						path: 'battlenet://DST2'
						process: 'destiny2.exe' -- No 32-bit executable
					}
				when 'diablo iii'
					args = {
						title: 'Diablo III'
						path: 'battlenet://D3'
						process: if bits == 64 then 'Diablo III64.exe' else 'Diablo III.exe'
					}
				when 'hearthstone'
					args = {
						title: 'Hearthstone'
						path: 'battlenet://WTCG'
						process: 'Hearthstone.exe' -- No 64-bit executable
					}
				when 'heroes of the storm'
					args = {
						title: 'Heroes of the Storm'
						path: 'battlenet://Hero'
						process: if bits == 64 then 'HeroesOfTheStorm_x64.exe' else 'HeroesOfTheStorm.exe'
					}
				when 'overwatch'
					args = {
						title: 'Overwatch'
						path: 'battlenet://Pro'
						process: 'Overwatch.exe' -- No 32-bit executable
					}
				when 'starcraft'
					args = {
						title: 'StarCraft'
						path: 'battlenet://S1'
						process: 'StarCraft.exe' -- No 64-bit executable
					}
				when 'starcraft ii'
					args = {
						title: 'StarCraft II'
						path: 'battlenet://S2'
						process: if bits == 64 then 'SC2_x64.exe' else 'SC2.exe'
					}
				when 'world of warcraft'
					args = {
						title: 'World of Warcraft'
						path: 'battlenet://WoW'
						process: if bits == 64 then 'Wow-64.exe' else 'Wow.exe'
					}
				else
					continue
			if args.title == nil
				log('Skipping Blizzard Battle.net game because the title is missing')
				continue
			elseif args.path == nil
				log('Skipping Blizzard Battle.net game because the path is missing')
				continue
			args.banner = @getBannerPath(args.title)
			unless args.banner
				args.expectedBanner = args.title
			args.platformID = @platformID
			table.insert(games, args)
		for args in *games
			table.insert(@games, Game(args))

return Battlenet
