Platform = require('main.platforms.platform')
Game = require('main.game')
json = require('lib.json')

-- Dump "productId" and "localpath" columns from the "Products" table of "index.db":
-- - productId: Unique ID associated with a game.
-- - localpath: The absolute path to the folder containing the game.
--
-- Dump "productId", "title", and "images" columns from the "LimitedDetails" table of "galaxy.db"
-- - productId: Same as above.
-- - title: The name of the game.
-- - images: A JSON-string containing URLs to various images associated with the game (e.g. logo).
--
-- Parse each "goggame_<productID>.info" found in each games' folder.
-- - Each file contains a JSON-string with among other things the relative path to the game's executable.
--
-- Games can be launched via the GOG Galaxy client with:
-- 	"GALAXYPATH\GalaxyClient.exe" /command=runGame /gameId=IDNUMBER /path="GAMEPATH"

class GOGGalaxy extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
		@name = 'GOG Galaxy'
		@cachePath = 'cache\\gog_galaxy\\'
		@enabled = settings\getGOGGalaxyEnabled()
		@programDataPath = settings\getGOGGalaxyProgramDataPath()
		if @enabled
			assert(io.fileExists(io.joinPaths(@programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
			assert(io.fileExists(io.joinPaths(@programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
		@indirectLaunch = settings\getGOGGalaxyIndirectLaunch()
		@platformProcess = 'GalaxyClient.exe' if @indirectLaunch
		@clientPath = settings\getGOGGalaxyClientPath()
		if @clientPath ~= nil
			@clientPath = io.joinPaths(@clientPath, 'GalaxyClient.exe')
			if @indirectLaunch
				assert(io.fileExists(@clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
		elseif @indirectLaunch
			assert(@clientPath ~= nil, 'A path to the GOG Galaxy client has not been defined.')
		@games = {}

	hasDumpedDatabases: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	dumpDatabases: () =>
		assert(@programDataPath ~= nil, 'The path to GOG Galaxy\'s ProgramData path has not been defined.')
		indexDBPath = io.joinPaths(@programDataPath, 'storage\\index.db')
		galaxyDBPath = io.joinPaths(@programDataPath, 'storage\\galaxy.db')
		assert(io.fileExists(indexDBPath, false) == true, ('"%s" does not exist.')\format(indexDBPath))
		assert(io.fileExists(galaxyDBPath, false) == true, ('"%s" does not exist.')\format(galaxyDBPath))
		sqlitePath = io.joinPaths(STATE.PATHS.RESOURCES, 'sqlite3.exe')
		assert(io.fileExists(sqlitePath, false) == true, ('SQLite3 CLI tool is missing. Expected the path to be "%s".')\format(sqlitePath))
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\dumpDatabases.bat" "%s" "%s"]')\format(indexDBPath, galaxyDBPath))
		return @getWaitCommand(), '', 'OnDumpedDBs'

	parseIndexDB: () =>
		output = io.readFile(io.joinPaths(@cachePath, 'index.txt'))
		lines = output\splitIntoLines()
		productIDs = {}
		paths = {}
		for line in *lines
			productID, path = line\match('^(%d+)|(.+)$')
			productIDs[productID] = true
			paths[productID] = path
		return productIDs, paths

	parseGalaxyDB: (productIDs) =>
		output = io.readFile(io.joinPaths(@cachePath, 'galaxy.txt'))
		lines = output\splitIntoLines()
		titles = {}
		bannerURLs = {}
		for line in *lines
			productID, title, images = line\match('^(%d+)|([^|]+)|(.+)$')
			continue unless productIDs[productID] == true
			titles[productID] = title
			images = json.decode(images\lower())
			bannerURLs[productID] = images.logo\gsub('_glx_logo', '_392')
		return titles, bannerURLs

	generateGames: () =>
		games = {}
		productIDs, paths = @parseIndexDB()
		titles, bannerURLs = @parseGalaxyDB(productIDs)
		for productID, _ in pairs(productIDs)
			info = io.readFile(io.joinPaths(paths[productID], ('goggame-%s.info')\format(productID)), false)
			info = json.decode(info)
			exePath = (info.playTasks[1].path\gsub('//', '\\'))
			banner = @getBannerPath(productID)
			bannerURL = nil
			unless banner
				bannerURL = bannerURLs[productID]
				banner = io.joinPaths(@cachePath, productID .. bannerURL\reverse()\match('^([^%.]+%.)')\reverse())
			path = nil
			if @indirectLaunch
				path = ('"%s" "/command=runGame" "/gameId=%s"')\format(@clientPath, productID)
			else
				path = ('"%s"')\format(io.joinPaths(paths[productID], exePath))
			table.insert(games, {
				:banner
				:bannerURL
				title: titles[productID]
				:path
				platformID: @platformID
				process: exePath\reverse()\match('^([^\\]+)')\reverse()
			})
		@games = [Game(args) for args in *games]

return GOGGalaxy
