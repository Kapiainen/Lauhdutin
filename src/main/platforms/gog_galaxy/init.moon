Platform = require('main.platforms.platform')
json = require('lib.json')

-- New version
--   Dump "productId" and "installationPath" columns from the "InstalledBaseProducts" table of "galaxy.db":
--   - productId: Unique ID associated with a game.
--   - installationPath: The absolute path to the folder containing the game.
-- Old version
--   Dump "productId" and "localpath" columns from the "Products" table of "index.db":
--   - productId: Unique ID associated with a game.
--   - localpath: The absolute path to the folder containing the game.
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
--  The game can also be brought up in GOG Galaxy client if the game is not currently installed.

class GOGGalaxy extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
		@name = 'GOG Galaxy'
		@cachePath = 'cache\\gog_galaxy\\'
		@enabled = settings\getGOGGalaxyEnabled()
		@programDataPath = settings\getGOGGalaxyProgramDataPath()
		@indirectLaunch = settings\getGOGGalaxyIndirectLaunch()
		@platformProcess = 'GalaxyClient.exe' if @indirectLaunch
		@clientPath = settings\getGOGGalaxyClientPath()
		@useCommunityProfile = settings\getGOGGalaxyParseCommunityProfile()
		@communityProfileName = settings\getGOGGalaxyProfileName()
		@communityProfileJavaScriptPath = io.joinPaths('main','platforms', 'gog_galaxy', 'profile.js')
		@phantomjsPath = io.joinPaths(STATE.PATHS.RESOURCES, 'phantomjs.exe')
		@games = {}

	validate: () =>
		assert(io.fileExists(io.joinPaths(@programDataPath, 'storage\\galaxy.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
		sqlitePath = io.joinPaths(STATE.PATHS.RESOURCES, 'sqlite3.exe')
		assert(io.fileExists(sqlitePath, false) == true, ('SQLite3 CLI tool is missing. Expected the path to be "%s".')\format(sqlitePath))
		if @clientPath ~= nil
			@clientPath = io.joinPaths(@clientPath, 'GalaxyClient.exe')
			if @indirectLaunch
				assert(io.fileExists(@clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
		elseif @indirectLaunch
			assert(@clientPath ~= nil, 'A path to the GOG Galaxy client has not been defined.')
		if @useCommunityProfile == true
			assert(type(@communityProfileName) == 'string' and #@communityProfileName > 0, 'A GOG profile name has not been defined.')
			assert(io.fileExists(@phantomjsPath, false) == true, ('PhantomJS is missing. Expected the path to be "%s".')\format(@phantomjsPath))
			assert(io.fileExists(@communityProfileJavaScriptPath) == true, ('The JavaScript file for downloading and parsing the GOG community profile is missing. Expected the path to be "%s".')\format(@communityProfileJavaScriptPath))

	downloadCommunityProfile: () =>
		return nil unless @useCommunityProfile
		parameter = ('""%s" "\\%s""')\format(@phantomjsPath, @communityProfileJavaScriptPath)
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\downloadProfile.bat" "%s"]')\format(@communityProfileName))
		return @getWaitCommand(), '', 'OnDownloadedGOGCommunityProfile'

	hasdownloadedCommunityProfile: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	hasDumpedDatabases: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	dumpDatabases: () =>
		assert(@programDataPath ~= nil, 'The path to GOG Galaxy\'s ProgramData path has not been defined.')
		indexDBPath = io.joinPaths(@programDataPath, 'storage\\index.db')
		galaxyDBPath = io.joinPaths(@programDataPath, 'storage\\galaxy.db')
		assert(io.fileExists(galaxyDBPath, false) == true, ('"%s" does not exist.')\format(galaxyDBPath))
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\dumpDatabases.bat" "%s" "%s"]')\format(indexDBPath, galaxyDBPath))
		return @getWaitCommand(), '', 'OnDumpedDBs'

	parseIndexDB: (output) =>
		assert(type(output) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseIndexDB')
		lines = output\splitIntoLines()
		productIDs = {}
		paths = {}
		for line in *lines
			productID, path = line\match('^(%d+)|(.+)$')
			productIDs[productID] = true
			paths[productID] = path
		return productIDs, paths

	parseProfile: (output, productIDs) =>
		hoursPlayed = {}
		return hoursPlayed if output == nil
		for id, hours in output\gmatch('(%d+)|([%d%.]+)')
			if productIDs[id] == nil
				productIDs[id] = false
			hoursPlayed[id] = tonumber(hours)
		return hoursPlayed

	parseGalaxyDB: (productIDs, output) =>
		assert(type(productIDs) == 'table', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseGalaxyDB')
		assert(type(output) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseGalaxyDB')
		lines = output\splitIntoLines()
		titles = {}
		bannerURLs = {}
		for line in *lines
			productID, title, images = line\match('^(%d+)|([^|]+)|([^|]+)|.+$')
			continue if productIDs[productID] == nil
			titles[productID] = title
			images = json.decode(images\lower())
			bannerURLs[productID] = images.logo\gsub('_glx_logo', '_392')
		return titles, bannerURLs

	parseInfo: (dirPath, productID) =>
		assert(type(dirPath) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseInfo')
		assert(type(productID) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseInfo')
		path = io.joinPaths(dirPath, ('goggame-%s.info')\format(productID))
		unless io.fileExists(path, false)
			log('Skipping GOG Galaxy game', productID, 'because the .info file could not be found')
			return nil
		file = io.readFile(path, false)
		if file == '' or file\trim() == ''
			log('Skipping GOG Galaxy game', productID, 'because the .info file is empty')
			return nil
		return json.decode(file)

	getBanner: (productID, bannerURLs) =>
		assert(type(productID) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
		banner = @getBannerPath(productID)
		unless banner
			bannerURL = bannerURLs[productID]
			if bannerURL
				banner = io.joinPaths(@cachePath, productID .. bannerURL\reverse()\match('^([^%.]+%.)')\reverse())
				expectedBanner = productID
				return banner, bannerURL, expectedBanner
		return banner, nil, nil

	getExePath: (info) =>
		assert(type(info) == 'table', 'main.platforms.gog_galaxy.init.GOGGalaxy.getExePath')
		return nil, nil if type(info.playTasks) ~= 'table'
		task = nil
		for t in *info.playTasks
			if t.isPrimary == true
				task = t
				break
		if task == nil
			return nil, nil if type(info.playTasks[1]) ~= 'table'
			return nil, nil if type(info.playTasks[1].path) ~= 'string'
			task = info.playTasks[1]
		path = (task.path\gsub('//', '\\'))
		if task.arguments ~= nil
			return path, task.arguments
		return path, nil

	-- TODO: Refactor to allow for tests
	generateGames: (indexOutput, galaxyOutput, profileOutput) =>
		assert(type(indexOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
		assert(type(galaxyOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
		games = {}
		productIDs, paths = @parseIndexDB(indexOutput)
		hoursPlayed = @parseProfile(profileOutput, productIDs)
		titles, bannerURLs = @parseGalaxyDB(productIDs, galaxyOutput)
		for productID, installed in pairs(productIDs)
			banner, bannerURL, expectedBanner = @getBanner(productID, bannerURLs)
			path = ('"%s" "/command=runGame" "/gameId=%s"')\format(@clientPath, productID)
			process = nil
			if installed
				info = @parseInfo(paths[productID], productID)
				if type(info) ~= 'table'
					log('Skipping GOG Galaxy game', productID, 'because the info file could not be found')
					continue
				exePath, arguments = @getExePath(info)
				if type(exePath) ~= 'string'
					log('Skipping GOG Galaxy game', productID, 'because the path to the executable could not be found')
					continue
				process = exePath\reverse()\match('^([^\\]+)')\reverse()
				unless @indirectLaunch
					fullPath = io.joinPaths(paths[productID], exePath)
					unless io.fileExists(fullPath, false)
						path = nil
					else
						if arguments == nil
							path = ('"%s"')\format(fullPath)
						else
							path = ('"%s" "%s"')\format(fullPath, arguments)
			title = titles[productID]
			if title == nil
				log('Skipping GOG Galaxy game', productID, 'because title could not be found')
				continue
			elseif path == nil
				log('Skipping GOG Galaxy game', productID, 'because path could not be found')
				continue
			table.insert(games, {
				:banner
				:bannerURL
				:expectedBanner
				:title
				:path
				uninstalled: not installed
				platformID: @platformID
				:process
				hoursPlayed: hoursPlayed[productID]
			})
		@games = games

	getStorePageURL: (game) =>
		assert(game ~= nil and game\getPlatformID() == @platformID, 'main.platforms.gog_galaxy.init.getStorePageURL')
		productID = game\getBanner()\reverse()\match('^[^%.]+%.([^\\]+)')\reverse()
		galaxy = io.readFile(io.joinPaths(@cachePath, 'galaxy.txt'))
		url = nil
		for line in *galaxy\splitIntoLines()
			if line\startsWith(productID)
				urls = line\match('^%d+|[^|]+|[^|]+|(.+)$')
				if urls ~= nil
					urls = json.decode(urls\lower())
					if url == nil and urls.store ~= nil
						if type(urls.store.href) == 'string'
							url = urls.store.href
						elseif type(urls.store) == 'string'
							url = urls.store
					if url == nil and urls.product_card ~= nil
						if type(urls.product_card.href) == 'string'
							url = urls.product_card.href
						elseif type(urls.product_card) == 'string'
							url = urls.product_card
					if url == nil and urls.forum ~= nil
						if type(urls.forum.href) == 'string'
							url = urls.forum.href\gsub('forum', 'game')
						elseif type(urls.forum) == 'string'
							url = urls.forum\gsub('forum', 'game')
				break
		return url

	getBannerURL: (game) =>
		assert(game ~= nil and game\getPlatformID() == @platformID, 'main.platforms.gog_galaxy.init.getBannerURL')
		productID = game\getBanner()\reverse()\match('^[^%.]+%.([^\\]+)')\reverse()
		galaxy = io.readFile(io.joinPaths(@cachePath, 'galaxy.txt'))
		productIDs = {}
		productIDs[productID] = true
		titles, bannerURLs = @parseGalaxyDB(productIDs, galaxy)
		return bannerURLs[productID]

if RUN_TESTS
	assertionMessage = 'GOG Galaxy test failed!'
	settings = {
		getGOGGalaxyEnabled: () => return true
		getGOGGalaxyProgramDataPath: () => return ''
		getGOGGalaxyIndirectLaunch: () => return true
		getGOGGalaxyClientPath: () => return ''
		getGOGGalaxyParseCommunityProfile: () => return false
		getGOGGalaxyProfileName: () => return ''
	}
	galaxy = GOGGalaxy(settings)
	
	indexOutput = '1207660094|D:\\Games\\GOG Galaxy\\Dust - An Elysian Tail
1207659069|D:\\Games\\GOG Galaxy\\Torchlight
1495134320|D:\\Games\\GOG Galaxy\\The Witcher 3 Wild Hunt GOTY
1207660413|D:\\Games\\GOG Galaxy\\Shadowrun Returns
1207658807|D:\\Games\\GOG Galaxy\\Psychonauts
1207666193|D:\\Games\\GOG Galaxy\\Legend of Grimrock II'
	productIDs, paths = galaxy\parseIndexDB(indexOutput)
	assert(type(productIDs) == 'table', assertionMessage)
	assert(type(paths) == 'table', assertionMessage)
	assert(productIDs['1207660094'] == true, assertionMessage)
	assert(productIDs['1207659069'] == true, assertionMessage)
	assert(productIDs['1495134320'] == true, assertionMessage)
	assert(productIDs['1207660413'] == true, assertionMessage)
	assert(productIDs['1207658807'] == true, assertionMessage)
	assert(productIDs['1207666193'] == true, assertionMessage)
	assert(paths['1207660094'] == 'D:\\Games\\GOG Galaxy\\Dust - An Elysian Tail', assertionMessage)
	assert(paths['1207659069'] == 'D:\\Games\\GOG Galaxy\\Torchlight', assertionMessage)
	assert(paths['1495134320'] == 'D:\\Games\\GOG Galaxy\\The Witcher 3 Wild Hunt GOTY', assertionMessage)
	assert(paths['1207660413'] == 'D:\\Games\\GOG Galaxy\\Shadowrun Returns', assertionMessage)
	assert(paths['1207658807'] == 'D:\\Games\\GOG Galaxy\\Psychonauts', assertionMessage)
	assert(paths['1207666193'] == 'D:\\Games\\GOG Galaxy\\Legend of Grimrock II', assertionMessage)
	galaxyOutput = '1495134320|The Witcher 3: Wild Hunt - Game of the Year Edition|{"background":"https://images-2.gog.com/d942735a04269e01ab4799e55f5cd158c2c78e4265240b940b622578a002b08b.jpg","icon":"https://images-2.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1.png","logo":"https://images-3.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo.jpg","logo2x":"https://images-2.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo_2x.jpg","menuNotificationAv":"https://images-4.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av.png","menuNotificationAv2":"https://images-1.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av2.png","sidebarIcon":"https://images-1.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon.png","sidebarIcon2x":"https://images-4.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon_2x.png"}|{  "forum" : "http://www.gog.com/forum/the_witcher_3_wild_hunt",  "product_card" : "http://www.gog.com/game/the_witcher_3_wild_hunt_game_of_the_year_edition_game",  "purchase_link" : "https://www.gog.com/checkout/manual/1495134320",  "support" : "https://www.gog.com/support/the_witcher_3_wild_hunt_game_of_the_year_edition_game"}
1207659069|Torchlight|{"background":"https://images.gog.com/51a5d1be8c50b36655a0f057b12a0e13c9412de0c921a3b3f4aa753198bbd364.jpg","icon":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381.png","logo":"https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo.png","logo2x":"https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon.png","sidebarIcon2x":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/51a5d1be8c50b36655a0f057b12a0e13c9412de0c921a3b3f4aa753198bbd364.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/torchlight_series"  },  "icon" : {    "href" : "https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207659069?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/torchlight"  },  "support" : {    "href" : "https://www.gog.com/support/torchlight"  }}
1207660413|Shadowrun Returns|{"background":"https://images.gog.com/a6ee88aed8f046df9993b96a6aec9d1d48e9bbada856c994700a8a4f28172e60.jpg","icon":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81.png","logo":"https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo.png","logo2x":"https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon.png","sidebarIcon2x":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/a6ee88aed8f046df9993b96a6aec9d1d48e9bbada856c994700a8a4f28172e60.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/shadowrun_series"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/c72867f15555a110b320a75fdf2db7d54c1d7fae8bc96f7db65a4accca710541.jpg"  },  "icon" : {    "href" : "https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81.png"  },  "isIncludedInGames" : [    {      "href" : "http://api.gog.com/v1/games/1791521599?locale=en-US"    },    {      "href" : "http://api.gog.com/v1/games/1983446193?locale=en-US"    }  ],  "isRequiredByGames" : [    {      "href" : "http://api.gog.com/v1/games/1207660843?locale=en-US"    }  ],  "self" : {    "href" : "http://api.gog.com/v1/games/1207660413?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/shadowrun_returns"  },  "support" : {    "href" : "https://www.gog.com/support/shadowrun_returns"  }}
1207660094|Dust: An Elysian Tail|{"background":"https://images.gog.com/62b91190a44a7d38334b50e23ed5b1999e78a31122e6f4515b53aee2df1e360e.jpg","icon":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5.png","logo":"https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo.png","logo2x":"https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon.png","sidebarIcon2x":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/62b91190a44a7d38334b50e23ed5b1999e78a31122e6f4515b53aee2df1e360e.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/dust_an_elysian_tail"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/bd21391960c6087c8a760f5d858fc75d78654f065df45ccb08d66a149fd68634.jpg"  },  "icon" : {    "href" : "https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207660094?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/dust_an_elysian_tail"  },  "support" : {    "href" : "https://www.gog.com/support/dust_an_elysian_tail"  }}
1207658807|Psychonauts|{"background":"https://images.gog.com/db4d0a4594d8d070ffb13d1feb1882f1a3fa6ab5325323e2b86cbd69a160c797.jpg","icon":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f.png","logo":"https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo.png","logo2x":"https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon.png","sidebarIcon2x":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/db4d0a4594d8d070ffb13d1feb1882f1a3fa6ab5325323e2b86cbd69a160c797.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/psychonauts"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/09856119fff2f98b29b8b3f91edf0ea5bd12af19e9c95b1f33ea60b8f431912c.jpg"  },  "icon" : {    "href" : "https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207658807?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/psychonauts"  },  "support" : {    "href" : "https://www.gog.com/support/psychonauts"  }}'
	titles, bannerURLs = galaxy\parseGalaxyDB(productIDs, galaxyOutput)
	assert(type(titles) == 'table', assertionMessage)
	assert(type(bannerURLs) == 'table', assertionMessage)
	assert(titles['1495134320'] == 'The Witcher 3: Wild Hunt - Game of the Year Edition', assertionMessage)
	assert(titles['1207659069'] == 'Torchlight', assertionMessage)
	assert(titles['1207660413'] == 'Shadowrun Returns', assertionMessage)
	assert(titles['1207660094'] == 'Dust: An Elysian Tail', assertionMessage)
	assert(titles['1207658807'] == 'Psychonauts', assertionMessage)
	assert(bannerURLs['1495134320'] == 'https://images-3.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_392.jpg', assertionMessage)
	assert(bannerURLs['1207659069'] == 'https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_392.png', assertionMessage)
	assert(bannerURLs['1207660413'] == 'https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_392.png', assertionMessage)
	assert(bannerURLs['1207660094'] == 'https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_392.png', assertionMessage)
	assert(bannerURLs['1207658807'] == 'https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_392.png', assertionMessage)

	infos = {
		'1207660094': {
			playTasks: {
				{
					path: 'bin//a.exe'
				}
			}
		}
		'1495134320': {
			playTasks: {
				{
					path: 'bin//x64//witcher3.exe'
				}
			}
		}
	}
	assert(galaxy\getExePath(infos['1207660094']) == 'bin\\a.exe', assertionMessage)
	assert(galaxy\getExePath(infos['1495134320']) == 'bin\\x64\\witcher3.exe', assertionMessage)

	--galaxy\parseInfo()
	--galaxy\getBanner()
	--galaxy\generateGames()

return GOGGalaxy
