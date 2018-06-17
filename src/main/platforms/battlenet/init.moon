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

	validate: () => return

	hasUnprocessedPaths: () => return #@battlenetPaths > 0
	
	hasProcessedPath: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	getCachePath: () => return @cachePath

	identifyFolders: () =>
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\battlenet\\identifyFolders.bat" "%s"]')\format(@battlenetPaths[1]))
		return @getWaitCommand(), '', 'OnIdentifiedBattlenetFolders'

	getBanner: (title, bannerURL) =>
		banner = @getBannerPath(title)
		unless banner
			if bannerURL
				banner = io.joinPaths(@cachePath, title .. bannerURL\reverse()\match('^([^%.]+%.)')\reverse())
		return banner

	generateGames: (output) =>
		assert(type(output) == 'string')
		table.remove(@battlenetPaths, 1)
		games = {}
		folders = output\lower()\splitIntoLines()
		assert(folders[1]\startsWith('bits:'))
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
						bannerURL: 'https://images.launchbox-app.com/34b4f780-34a2-42f0-a4ea-fa78933dd5e8.jpg'
					}
				when 'diablo iii'
					args = {
						title: 'Diablo III'
						path: 'battlenet://D3'
						process: if bits == 64 then 'Diablo III64.exe' else 'Diablo III.exe'
						bannerURL: 'https://images.launchbox-app.com/9c1d2d30-8845-4b8a-89e6-632abab530c5.png'
					}
				when 'hearthstone'
					args = {
						title: 'Hearthstone'
						path: 'battlenet://WTCG'
						process: 'Hearthstone.exe' -- No 64-bit executable
						bannerURL: 'https://images.launchbox-app.com/5aa3fd48-4edd-4d8a-a302-9eed46f3e471.png'
					}
				when 'heroes of the storm'
					args = {
						title: 'Heroes of the Storm'
						path: 'battlenet://Hero'
						process: if bits == 64 then 'HeroesOfTheStorm_x64.exe' else 'HeroesOfTheStorm.exe'
						bannerURL: 'https://images.launchbox-app.com/cb0aba61-915e-40e3-b2e1-187158819711.jpg'
					}
				when 'overwatch'
					args = {
						title: 'Overwatch'
						path: 'battlenet://Pro'
						process: 'Overwatch.exe' -- No 32-bit executable
						bannerURL: 'https://images.launchbox-app.com/09b1d6e3-316d-44d8-beca-90b87eb18c35.jpg'
					}
				when 'starcraft'
					args = {
						title: 'StarCraft'
						path: 'battlenet://S1'
						process: 'StarCraft.exe' -- No 64-bit executable
						--bannerURL: ''
					}
				when 'starcraft ii'
					args = {
						title: 'StarCraft II'
						path: 'battlenet://S2'
						process: if bits == 64 then 'SC2_x64.exe' else 'SC2.exe'
						--bannerURL: ''
					}
				when 'world of warcraft'
					args = {
						title: 'World of Warcraft'
						path: 'battlenet://WoW'
						process: if bits == 64 then 'Wow-64.exe' else 'Wow.exe'
						bannerURL: 'https://images.launchbox-app.com/09a032b5-b86e-435a-b75a-264fcaa8a05d.png'
					}
				else
					continue
			if args.title == nil
				log('Skipping Blizzard Battle.net game because the title is missing')
				continue
			elseif args.path == nil
				log('Skipping Blizzard Battle.net game because the path is missing')
				continue
			args.banner = @getBanner(args.title, args.bannerURL)
			unless args.banner
				args.expectedBanner = args.title
			args.platformID = @platformID
			table.insert(games, args)
		for args in *games
			table.insert(@games, Game(args))

if RUN_TESTS
	assertionMessage = 'Blizzard Battle.net test failed!'
	settings = {
		getBattlenetPaths: () => return {
			'Y:\\Blizzard games'
			'Z:\\Games\\Battle.net'
		}
		getBattlenetEnabled: () => return true
	}
	battlenet = Battlenet(settings)

	output = 'BITS:AMD64
Diablo III
StarCraft
Overwatch
Some random game
Hearthstone
'
	battlenet\generateGames(output)
	games = battlenet.games
	assert(#games == 4, assertionMessage)

	output = 'BITS:x86
Heroes of the Storm
StarCraft II
StarCraft
Another random game
World of Warcraft
Destiny 2
'
	battlenet\generateGames(output)
	games = battlenet.games
	assert(#games == 9, assertionMessage)
	expectedGames = {
		-- First library (64-bits)
		{
			title: 'Diablo III'
			path: 'battlenet://D3'
			process: 'Diablo III64.exe'
		}
		{
			title: 'StarCraft'
			path: 'battlenet://S1'
			process: 'StarCraft.exe'
		}
		{
			title: 'Overwatch'
			path: 'battlenet://Pro'
			process: 'Overwatch.exe'
		}
		{
			title: 'Hearthstone'
			path: 'battlenet://WTCG'
			process: 'Hearthstone.exe'
		}
		-- Second library (32-bits)
		{
			title: 'Heroes of the Storm'
			path: 'battlenet://Hero'
			process: 'HeroesOfTheStorm.exe'
		}
		{
			title: 'StarCraft II'
			path: 'battlenet://S2'
			process: 'SC2.exe'
		}
		{
			title: 'StarCraft'
			path: 'battlenet://S1'
			process: 'StarCraft.exe'
		}
		{
			title: 'World of Warcraft'
			path: 'battlenet://WoW'
			process: 'Wow.exe'
		}
		{
			title: 'Destiny 2'
			path: 'battlenet://DST2'
			process: 'destiny2.exe'
		}
	}
	for i, game in ipairs(games)
		assert(game\getTitle() == expectedGames[i].title, assertionMessage)
		assert(game\getPath() == expectedGames[i].path, assertionMessage)
		assert(game\getProcess() == expectedGames[i].process, assertionMessage)

return Battlenet
