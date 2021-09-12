utility = require('shared.utility')
bit = require('lib.bit.numberlua')
digest = require('lib.digest.crc32')
Platform = require('main.platforms.platform')

-- Regular Steam games
-- Optional: Parse the Steam community profile, which must be set to public, to get a list of all Steam games (AppIDs, titles, and hours played) associated with the chosen account.
-- Parse "Steam\steamapps\libraryfolders.vdf" to get any additional Steam libraries that may exist on other drives.
-- Parse "Steam\userdata\<accountID>\config\localconfig.vdf" to get the timestamp for when the game was last played.
-- Parse "Steam\userdata\<accountID>\7\remote\sharedconfig.vdf" to get the tags assigned to the game via Steam.
-- Dump lists of appmanifest_*.acf files that exist in each Steam library's "steamapps" folder.
-- Parse each .acf file to get the title of the game and the AppID.

-- Shortcuts to non-Steam games added to the Steam library
-- Parse "Steam\userdata\<accountID>\config\shortcuts.vdf" to get the path, title, and any tags assigned via Steam.

lookupTable = [('%.0f')\format(2^i) for i = 0, 56] -- 2^57 and greater start rounding the last (few) digits.
lookupTable[58] = '144115188075855872'
lookupTable[59] = '288230376151711744'
lookupTable[60] = '576460752303423488'
lookupTable[61] = '1152921504606846976'
lookupTable[62] = '2305843009213693952'
lookupTable[63] = '4611686018427387904'
lookupTable[64] = '9223372036854775808'
lookupTable = [ [tonumber(char) for char in value\reverse()\gmatch('.')] for value in *lookupTable ]

class Steam extends Platform
	new: (settings) =>
		super(settings)
		@name = "Steam"
		@platform = 'steam'
		@platformID = ENUMS.PLATFORM_IDS.STEAM
		@platformProcess = 'steam.exe'
		@cachePath = 'cache\\steam\\'
		@enabled = settings\getSteamEnabled()
		@steamPath = settings\getSteamPath()
		@accountID = settings\getSteamAccountID()
		@communityID = settings\getSteamCommunityID()
		@useCommunityProfile = settings\getSteamParseCommunityProfile()
		@games = {}
		@communityProfilePath = io.joinPaths(@cachePath, 'communityProfile.txt')
		@communityProfileGames = nil

	validate: () =>
		clientPath = io.joinPaths(@steamPath, 'steam.exe')
		assert(io.fileExists(clientPath, false), 'The Steam path is not valid.')
		assert(@accountID ~= nil, 'A Steam account has not been chosen.')
		assert(tonumber(@accountID) ~= nil, 'The Steam account is invalid.')
		if @useCommunityProfile
			assert(@communityID ~= nil, 'A Steam ID has not been provided for downloading the community profile.')
			assert(tonumber(@communityID) ~= nil, 'The Steam ID is invalid.')

	toBinaryString: (value) =>
		assert(type(value) == 'number')
		binary = {}
		for bit = 32, 1, -1
			binary[bit] = math.fmod(value, 2)
			value = math.floor((value - binary[bit]) / 2)
		return table.concat(binary)

	adjustBinaryStringHash: (binary) =>
		assert(type(binary) == 'string')
		return binary .. '00000010000000000000000000000000' -- Equivalent to '<< 32 | 0x02000000'

	toDecimalString: (binary) =>
		assert(type(binary) == 'string')
		bitValues = {}
		i = #binary
		for char in binary\gmatch('.')
			table.insert(bitValues, lookupTable[i]) if char == '1'
			i -= 1
		maxNumDigits = 24
		digits = [0 for i = 1, maxNumDigits]
		while #bitValues > 0
			i = 1
			carry = 0
			bitValue = table.remove(bitValues, 1)
			while i <= maxNumDigits
				temp = digits[i] + carry
				temp += bitValue[i] if bitValue[i] ~= nil
				if temp > 9
					temp = temp % 10
					carry = 1
				else
					carry = 0
				digits[i] = temp
				i += 1
		digits = [tostring(digit) for digit in *digits]
		decimalString = table.concat(digits)\reverse()
		return decimalString\sub((decimalString\find('[^0]')))

	-- Generating an AppID for a non-Steam game
	-- # Original approach
	--
	--   hash = crc32(path .. title)
	--   hash = hash | 0x80000000
	--   hash = hash << 32
	--   hash = hash | 0x02000000
	--
	-- # Issues
	-- Left-shifting by 32 is not feasible since it results in 0.
	-- This is presumably due to the type that is used in C to implement Lua's number type.
	-- Converting numbers larger than 2^56 into strings causes the number to be rounded.
	--
	-- # Workaround
	-- The workaround is to generate the CRC32 hash and bitwise OR the hash as usual.
	-- Then the hash is turned into a string containing the binary version of the hash.
	-- The binary hash is then left-shifted by appending 0x02000000 in binary as a string.
	-- The binary is then turned back into a string containing the decimal version of the hash.
	generateAppID: (title, path) =>
		value = path .. title
		hash = digest.crc32(value)
		hash = bit.bor(hash, 0x80000000)
		binaryHash = @toBinaryString(hash)
		binaryHash = @adjustBinaryStringHash(binaryHash)
		return @toDecimalString(binaryHash)

	downloadCommunityProfile: () =>
		return nil unless @useCommunityProfile
		SKIN\Bang('["#@#windowless.vbs" "#@#main\\platforms\\steam\\deleteCachedCommunityProfile.bat"]')
		assert(type(@communityID) == 'string', 'main.platforms.steam.init.downloadCommunityProfile')
		url = ('http://steamcommunity.com/profiles/%s/games/?tab=all&xml=1')\format(@communityID)
		return url, 'communityProfile.txt', 'OnCommunityProfileDownloaded', 'OnCommunityProfileDownloadFailed'

	getDownloadedCommunityProfilePath: () => return io.joinPaths(STATE.PATHS.DOWNLOADFILE, 'communityProfile.txt')

	getCachedCommunityProfilePath: () => return io.joinPaths(STATE.PATHS.RESOURCES, @cachePath, 'communityProfile.txt')

	parseCommunityProfile: (profile) =>
		games = {}
		num = 0
		for game in profile\gmatch('<game>(.-)</game>')
			appID = game\match('<appID>(%d+)</appID>')
			continue if games[appID] ~= nil
			title = game\match('<name><!%[CDATA%[(.-)%]%]></name>')
			if title == nil
				log('Skipping Steam game', appID, 'because a title could not be parsed from the community profile')
				continue
			games[appID] = {
				title: title\trim()
				hoursPlayed: tonumber(game\match('<hoursOnRecord>(%d+%.%d*)</hoursOnRecord>'))
			}
			num += 1
		log('Games found in the Steam community profile:', num)
		@communityProfileGames = games

	getLibraries: () =>
		log('Getting Steam libraries from libraryfolders.vdf')
		libraries = {io.joinPaths(@steamPath, 'steamapps\\')}
		libraryFoldersPath = io.joinPaths(@steamPath, 'steamapps\\libraryfolders.vdf')
		if io.fileExists(libraryFoldersPath, false)
			file = io.readFile(libraryFoldersPath, false)
			lines = file\splitIntoLines()
			vdf = utility.parseVDF(lines)
			if type(vdf.libraryfolders) == 'table'
				for key, value in pairs(vdf.libraryfolders)
					if tonumber(key) ~= nil
						if type(value) == 'table'
							if value.path
								value.path ..= '\\' if value.path\endsWith('\\')
								table.insert(libraries, io.joinPaths((value.path\gsub('\\\\', '\\')), 'steamapps\\'))
						else
							value ..= '\\' if value\endsWith('\\')
							table.insert(libraries, io.joinPaths((value\gsub('\\\\', '\\')), 'steamapps\\'))
			else
				log('\\Steam\\steamapps\\libraryfolders.vdf does not contain a table called "libraryfolders".')
		else
			log('Could not find "\\Steam\\steamapps\\libraryfolders.vdf"')
		@libraries = libraries

	hasLibrariesToParse: () => return #@libraries > 0

	hasGottenACFs: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	getACFs: () =>
		io.writeFile(io.joinPaths(@cachePath, 'output.txt'), '')
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\steam\\getACFs.bat" "%s"]')\format(@libraries[1]))
		return @getWaitCommand(), '', 'OnGotACFs'

	parseLocalConfig: () =>
		log('Parsing localconfig.vdf')
		file = io.readFile(io.joinPaths(@steamPath, 'userdata\\', @accountID, 'config\\localconfig.vdf'), false)
		lines = file\splitIntoLines()
		return utility.parseVDF(lines)

	parseSharedConfig: () =>
		log('Parsing sharedconfig.vdf')
		file = io.readFile(io.joinPaths(@steamPath, 'userdata\\', @accountID, '\\7\\remote\\sharedconfig.vdf'), false)
		lines = file\splitIntoLines()
		return utility.parseVDF(lines)

	getTags: (appID, sharedConfig) =>
		tags = nil
		config = sharedConfig.userroamingconfigstore
		config = sharedConfig.userlocalconfigstore if config == nil
		if config == nil
			log('Steam sharedConfig has an unsupported structure at the top-level')
			return tags
		if config.software == nil
			log('Steam sharedConfig.software is nil')
			return tags
		if config.software.valve == nil
			log('Steam sharedConfig.software.valve is nil')
			return tags
		if config.software.valve.steam == nil
			log('Steam sharedConfig.software.valve.steam is nil')
			return tags
		if config.software.valve.steam.apps == nil
			log('Steam sharedConfig.software.valve.steam.apps is nil')
			return tags
		app = config.software.valve.steam.apps[appID]
		if app == nil
			log('Could not find the Steam game', appID, 'in sharedConfig')
			return tags
		if app.tags == nil
			log('Failed to get tags for Steam game', appID)
			return tags
		return tags if type(app.tags) ~= 'table'
		tags = {}
		for index, tag in pairs(app.tags)
			table.insert(tags, tag)
		return if #tags > 0 then tags else nil

	getLastPlayed: (appID, localConfig) =>
		lastPlayed = nil
		config = localConfig.userroamingconfigstore
		config = localConfig.userlocalconfigstore if config == nil
		if config == nil
			log('Steam localConfig has an unsupported structure at the top-level')
			return lastPlayed
		if config.software == nil
			log('Steam localConfig.software is nil')
			return lastPlayed
		if config.software.valve == nil
			log('Steam localConfig.software.valve is nil')
			return lastPlayed
		if config.software.valve.steam == nil
			log('Steam localConfig.software.valve.steam is nil')
			return lastPlayed
		if config.software.valve.steam.apps == nil
			log('Steam localConfig.software.valve.steam.apps is nil')
			return lastPlayed
		app = config.software.valve.steam.apps[appID]
		if app == nil
			log('Could not find the Steam game', appID, 'in localConfig')
			return lastPlayed
		if app.lastplayed == nil
			log('Failed to get last played timestamp for Steam game', appID)
			return lastPlayed
		lastPlayed = tonumber(app.lastplayed)
		return lastPlayed

	generateBannerURL: (appID) =>
		return ('http://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg')\format(appID)

	getBanner: (appID) =>
		banner = @getBannerPath(appID)
		return banner, nil if banner -- Found an existing copy in the skin's cache
		for extension in *@bannerExtensions
			gridBannerPath = io.joinPaths(@steamPath, 'userdata\\', @accountID, 'config\\grid\\', appID .. extension)
			cacheBannerPath = io.joinPaths(@cachePath, appID .. extension)
			if io.fileExists(gridBannerPath, false) and not io.fileExists(cacheBannerPath)
				io.copyFile(gridBannerPath, cacheBannerPath, false)
				return cacheBannerPath, nil -- Found a custom banner that was assigned via Steam's grid view
		banner = io.joinPaths(@cachePath, appID .. '.jpg')
		bannerURL = @generateBannerURL(appID)
		return banner, bannerURL -- Download the game's banner

	getPath: (appID) => return ('steam://rungameid/%s')\format(appID)

	getProcess: () => return 'GameOverlayUI.exe'

	generateShortcuts: () =>
		games = {}
		shortcutsPath = io.joinPaths(@steamPath, 'userdata\\', @accountID, '\\config\\shortcuts.vdf')
		return nil unless io.fileExists(shortcutsPath, false)
		contents = io.readFile(shortcutsPath, false, 'rb')
		contents = contents\gsub('%c', '|')
		shortcutsBannerPath = 'cache\\steam_shortcuts'
		for game in contents\reverse()\gmatch('(.-)emaNppA')
			game = game\reverse()
			title = game\match('|(.-)|')
			if title == nil
				log('Skipping Steam shortcut because the title could not be parsed')
				continue
			path = ('"%s"')\format(game\match('"(.-)"'))
			if path == nil
				log('Skipping Steam shortcut because the path could not be parsed')
				continue
			appID = @generateAppID(title, path)
			if appID == nil
				log('Skipping Steam shortcut because the appID could not be generated')
				continue
			path = ('steam://rungameid/%s')\format(appID)
			banner = @getBannerPath(appID, shortcutsBannerPath)
			expectedBanner = nil
			unless banner
				for extension in *@bannerExtensions
					gridBannerPath = io.joinPaths(@steamPath, 'userdata\\', @accountID, 'config\\grid\\', appID .. extension)
					cacheBannerPath = io.joinPaths(shortcutsBannerPath, appID .. extension)
					if io.fileExists(gridBannerPath, false) and not io.fileExists(cacheBannerPath)
						io.copyFile(gridBannerPath, cacheBannerPath, false)
						break
				banner = @getBannerPath(appID)
			unless banner
				expectedBanner = appID
			process = if game\match('AllowOverlay') then 'GameOverlayUI.exe' else nil
			tags = {}
			tagsString = game\match('tags|(.+)')
			if tagsString
				for tag in tagsString\gmatch('|%d|([^|]+)|')
					table.insert(tags, tag)
			tags = nil if #tags == 0
			table.insert(games, {
				:title
				:path
				:process
				:banner
				:expectedBanner
				platformOverride: @name
				platformTags: tags
				platformID: @platformID
			})
		for args in *games
			table.insert(@games, args)

	generateGames: () =>
		@localConfig = @parseLocalConfig() if @localConfig == nil
		@sharedConfig = @parseSharedConfig() if @sharedConfig == nil
		libraryPath = table.remove(@libraries, 1)
		games = {}
		file = io.readFile(io.joinPaths(@cachePath, 'output.txt'))
		manifests = file\splitIntoLines()
		for manifest in *manifests
			log('Processing Steam game:', manifest)
			appID = manifest\match('appmanifest_(%d+)%.acf')
			if appID == nil
				log('Skipping Steam game because the appID could not be parsed')
				continue
			assert(type(appID) == 'string', 'main.platforms.steam.init.generateGames')
			if games[appID] ~= nil -- Disregard duplicates, if they appear for some reason.
				log('Skipping Steam game', appID, 'because it has already been processed')
				continue
			if @communityProfileGames ~= nil and @communityProfileGames[appID] == nil -- If the community profile has been parsed, then disregard games not found on the profile.
				log('Skipping Steam game', appID, 'because it does not appear in the community profile')
				continue
			file = io.readFile(io.joinPaths(libraryPath, manifest), false)
			lines = file\splitIntoLines()
			success, vdf = pcall(utility.parseVDF, lines)
			unless success
				log(('Failed to parse "%s": %s')\format(manifest, vdf))
				continue
			title = nil
			if vdf.appstate ~= nil
				title = vdf.appstate.name
			if title == nil and vdf.userconfig ~= nil
				title = vdf.userconfig.name
			if title == nil and @communityProfileGames ~= nil and @communityProfileGames[appID] ~= nil
				title = @communityProfileGames[appID].title
			if title == nil
				log('Skipping Steam game', appID, 'because title could not be found')
				continue
			banner, bannerURL = @getBanner(appID)
			expectedBanner = if banner ~= nil then nil else appID
			hoursPlayed = nil
			if @communityProfileGames ~= nil and @communityProfileGames[appID] ~= nil
				hoursPlayed = @communityProfileGames[appID].hoursPlayed
				@communityProfileGames[appID] = nil
			games[appID] = {
				:title
				path: @getPath(appID)
				platformID: @platformID
				:banner
				:bannerURL
				:expectedBanner
				:hoursPlayed
				lastPlayed: @getLastPlayed(appID, @localConfig)
				platformTags: @getTags(appID, @sharedConfig)
				process: @getProcess()
			}
		-- Wait until all detected Steam libraries have been processed before dealing with any remaining
		-- (i.e. not installed) games found in the community profile.
		if @communityProfileGames ~= nil and #@libraries == 0
			log('Processing remaining Steam games found in the community profile')
			for appID, game in pairs(@communityProfileGames)
				continue if games[appID] ~= nil -- The game has already been processed
				banner, bannerURL = @getBanner(appID)
				expectedBanner = if banner ~= nil then nil else appID
				games[appID] = {
					title: game.title
					path: ('steam://rungameid/%s')\format(appID)
					platformID: @platformID
					:banner
					:bannerURL
					:expectedBanner
					hoursPlayed: game.hoursPlayed
					lastPlayed: @getLastPlayed(appID, @localConfig)
					platformTags: @getTags(appID, @sharedConfig)
					process: @getProcess()
					uninstalled: true
				}
				@communityProfileGames[appID] = nil
		for appID, args in pairs(games)
			table.insert(@games, args)

	getStorePageURL: (game) =>
		assert(game ~= nil and game\getPlatformID() == @platformID, 'main.platforms.steam.init.getStorePageURL')
		if game\getPlatformOverride() == nil
			appID = game\getBanner()\reverse()\match('^[^%.]+%.([^\\]+)')\reverse()
			return ('https://store.steampowered.com/app/%s')\format(appID)
		return nil

	getBannerURL: (game) =>
		assert(game ~= nil and game\getPlatformID() == @platformID, 'main.platforms.steam.init.getBannerURL')
		if game\getPlatformOverride() == nil
			appID = game\getBanner()\reverse()\match('^[^%.]+%.([^\\]+)')\reverse()
			return @generateBannerURL(appID)
		return nil

if RUN_TESTS
	assertionMessage = 'Steam test failed!'
	settings = {
		getSteamEnabled: () => return true
		getSteamPath: () => return 'Y:\\Program Files (32)\\Steam'
		getSteamAccountID: () => return '1234567890'
		getSteamCommunityID: () => return '987654321'
		getSteamParseCommunityProfile: () => return true
	}
	steam = Steam(settings)

	assert(steam\toBinaryString(136) == '00000000000000000000000010001000', assertionMessage)
	assert(steam\toBinaryString(5895412582) == '01011111011001001101101101100110', assertionMessage)

	assert(steam\adjustBinaryStringHash('') == '00000010000000000000000000000000', assertionMessage)
	assert(steam\adjustBinaryStringHash('0101') == '010100000010000000000000000000000000', assertionMessage)

	assert(steam\toDecimalString('1111') == '15', assertionMessage)
	assert(steam\toDecimalString('01001000100011100100111000010000') == '1217285648', assertionMessage)

	assert(steam\generateAppID('Whatevs', '"Y:\\Program Files (32)\\SomeGame\\game.exe"') == '17882896429207257088', assertionMessage)
	assert(steam\generateAppID('Spelunky Classic', '"D:\\Games\\GOG\\Spelunky Classic\\Spelunky.exe"') == '15292025676400427008', assertionMessage)

	profile = 'Some kind of header or other junk that we are not interested in...
<game>
	<appID>40400</appID>
	<name><![CDATA[ AI War: Fleet Command ]]></name>
	<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/40400/91c4cd7c72ae83b354e9380f9e69849c34e163c3.jpg]]></logo>
	<storeLink><![CDATA[ http://steamcommunity.com/app/40400 ]]></storeLink>
	<hoursOnRecord>73.0</hoursOnRecord>
	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AIWar/achievements/]]></globalStatsLink>
</game>
<game>
	<appID>108710</appID>
	<name><![CDATA[ Alan Wake ]]></name>
	<logo>
	<![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/108710/0f9b6613ac50bf42639ed6a2e16e9b78e846ef0a.jpg]]></logo>
	<storeLink><![CDATA[ http://steamcommunity.com/app/108710 ]]></storeLink>
	<hoursOnRecord>26.7</hoursOnRecord>
	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AlanWake/achievements/]]></globalStatsLink>
</game>
<game>
	<appID>630</appID>
	<name><![CDATA[ Alien Swarm ]]></name>
	<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/630/de3320a2c29b55b6f21d142dee26d9b044a29e97.jpg]]></logo>
	<storeLink><![CDATA[ http://steamcommunity.com/app/630 ]]></storeLink>
	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AlienSwarm/achievements/]]></globalStatsLink>
</game>
More games, etc.'
	steam\parseCommunityProfile(profile)
	numGames = 0
	games = steam.communityProfileGames
	for appID, info in pairs(steam.communityProfileGames)
		switch appID
			when '40400'
				assert(info.title == 'AI War: Fleet Command', assertionMessage)
				assert(info.hoursPlayed == 73.0, assertionMessage)
			when '108710'
				assert(info.title == 'Alan Wake', assertionMessage)
				assert(info.hoursPlayed == 26.7, assertionMessage)
			when '630'
				assert(info.title == 'Alien Swarm', assertionMessage)
				assert(info.hoursPlayed == nil, assertionMessage)
			else
				assert(nil, assertionMessage)
		numGames += 1
	assert(numGames == 3, assertionMessage)

	sharedConfig = {
		userroamingconfigstore: {software: {valve: {steam: {apps: {
			'654035': {
				tags: {
					'FPS'
					'Multiplayer'
				}
			}
		}}}}}}
	assert(steam\getTags('654020', sharedConfig) == nil, assertionMessage)
	assert(#steam\getTags('654035', sharedConfig) == 2, assertionMessage)

	localConfig = {
		userlocalconfigstore: {software: {valve: {steam: {apps: {
			'654020': {
				lastplayed: '123456789'
			}
		}}}}}}
	assert(steam\getLastPlayed('654020', localConfig) == 123456789, assertionMessage)
	assert(steam\getLastPlayed('654035', localConfig) == nil, assertionMessage)
	assert(steam\getPath('84065421351') == 'steam://rungameid/84065421351', assertionMessage)

	--steam\downloadCommunityProfile()
	--steam\getLibraries()
	--steam\hasLibrariesToParse()
	--steam\hasGottenACFs()
	--steam\getACFs()
	--steam\parseLocalConfig()
	--steam\parseSharedConfig()
	--steam\getBanner()
	--steam\generateShortcuts()
	--steam\generateGames()

return Steam
