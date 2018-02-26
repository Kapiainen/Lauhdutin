utility = require('shared.utility')
bit = require('lib.bit.numberlua')
digest = require('lib.digest.crc32')
Platform = require('main.platforms.platform')
Game = require('main.game')

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

class Steam extends Platform
	new: (settings) =>
		super(settings)
		@name = "Steam"
		@platform = 'steam'
		@platformID = ENUMS.PLATFORM_IDS.STEAM
		@platformProcess = 'Steam.exe'
		@cachePath = 'cache\\steam\\'
		@enabled = settings\getSteamEnabled()
		@steamPath = settings\getSteamPath()
		@accountID = settings\getSteamAccountID()
		@communityID = settings\getSteamCommunityID()
		@useCommunityProfile = settings\getSteamParseCommunityProfile()
		if @enabled
			clientPath = io.joinPaths(@steamPath, 'steam.exe')
			assert(io.fileExists(clientPath, false), 'The Steam path is not valid.')
			assert(@accountID ~= nil, 'A Steam account has not been chosen.')
			assert(tonumber(@accountID) ~= nil, 'The Steam account is invalid.')
			if @useCommunityProfile
				assert(@communityID ~= nil, 'A Steam ID has not been provided for downloading the community profile.')
				assert(tonumber(@communityID) ~= nil, 'The Steam ID is invalid.')
		@games = {}
		@communityProfilePath = io.joinPaths(@cachePath, 'communityProfile.txt')
		@communityProfileGames = nil
		if @enabled
			SKIN\Bang('["#@#windowless.vbs" "#@#main\\platforms\\steam\\deleteCachedCommunityProfile.bat"]')

	toBinaryString: (value) =>
		binary = {}
		for bit = 32, 1, -1
			binary[bit] = math.fmod(value, 2)
			value = math.floor((value - binary[bit]) / 2)
		return table.concat(binary)

	adjustBinaryStringHash: (binary) =>
		return binary .. '00000010000000000000000000000000' -- Equivalent to '<< 32 | 0x02000000'

	toDecimalString: (binary) =>
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
		assert(type(@communityID) == 'string', 'main.platforms.steam.init.downloadCommunityProfile')
		url = ('http://steamcommunity.com/profiles/%s/games/?tab=all&xml=1')\format(@communityID)
		return url, 'communityProfile.txt', 'OnCommunityProfileDownloaded', 'OnCommunityProfileDownloadFailed'

	parseCommunityProfile: () =>
		downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, 'communityProfile.txt')
		cachedPath = io.joinPaths(STATE.PATHS.RESOURCES, @cachePath, 'communityProfile.txt')
		os.rename(downloadedPath, cachedPath)
		return unless io.readFile(@communityProfilePath)
		file = io.readFile(@communityProfilePath)
		games = {}
		num = 0
		for game in file\gmatch('<game>(.-)</game>')
			appID = game\match('<appID>(%d+)</appID>')
			continue if games[appID] ~= nil
			title = game\match('<name><!%[CDATA%[(.-)%]%]></name>')
			if title == nil
				log('Skipping Steam game', appID, 'because a title could not be parsed from the community profile')
				continue
			games[appID] = {
				:title
				hoursPlayed: tonumber(game\match('<hoursOnRecord>(%d+%.%d*)</hoursOnRecord>'))
			}
			num += 1
		log(num)
		@communityProfileGames = games

	getLibraries: () =>
		libraries = {io.joinPaths(@steamPath, 'steamapps\\')}
		file = io.readFile(io.joinPaths(@steamPath, 'steamapps\\libraryfolders.vdf'), false)
		lines = file\splitIntoLines()
		vdf = utility.parseVDF(lines)
		for key, value in pairs(vdf.libraryfolders)
			if tonumber(key) ~= nil
				value ..= '\\' if value\endsWith('\\')
				table.insert(libraries, io.joinPaths((value\gsub('\\\\', '\\')), 'steamapps\\'))
		@libraries = libraries

	hasLibrariesToParse: () => return #@libraries > 0

	hasGottenACFs: () => return io.fileExists(io.joinPaths(@cachePath, 'completed.txt'))

	getACFs: () =>
		io.writeFile(io.joinPaths(@cachePath, 'output.txt'), '')
		SKIN\Bang(('["#@#windowless.vbs" "#@#main\\platforms\\steam\\getACFs.bat" "%s"]')\format(@libraries[1]))
		return @getWaitCommand(), '', 'OnGotACFs'

	parseLocalConfig: () =>
		file = io.readFile(io.joinPaths(@steamPath, 'userdata\\', @accountID, 'config\\localconfig.vdf'), false)
		lines = file\splitIntoLines()
		return utility.parseVDF(lines)

	parseSharedConfig: () =>
		file = io.readFile(io.joinPaths(@steamPath, 'userdata\\', @accountID, '\\7\\remote\\sharedconfig.vdf'), false)
		lines = file\splitIntoLines()
		return utility.parseVDF(lines)

	getTags: (appID) =>
		tags = {}
		config = @sharedConfig.userroamingconfigstore
		config = @sharedConfig.userlocalconfigstore if config == nil
		return tags if config == nil
		app = config.software.valve.steam.apps[appID]
		return tags if app == nil
		return tags if app.tags == nil
		return tags if type(app.tags) ~= 'table'
		for index, tag in pairs(app.tags)
			table.insert(tags, tag)
		return if #tags > 0 then tags else nil

	getLastPlayed: (appID) =>
		lastPlayed = nil
		config = @localConfig.userroamingconfigstore
		config = @localConfig.userlocalconfigstore if config == nil
		return lastPlayed if config == nil
		app = config.software.valve.steam.apps[appID]
		return lastPlayed if app == nil
		return lastPlayed if app.lastplayed == nil
		lastPlayed = tonumber(app.lastplayed)
		return lastPlayed

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
		bannerURL = ('http://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg')\format(appID)
		return banner, bannerURL -- Download the game's banner

	getPath: (appID) => return ('steam://rungameid/%s')\format(appID)

	getProcess: () => return 'GameOverlayUI.exe'

	generateShortcuts: () =>
		games = {}
		lookupTable = [ [tonumber(char) for char in value\reverse()\gmatch('.')] for value in *lookupTable ]
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
			table.insert(@games, Game(args))

	generateGames: () =>
		@localConfig = @parseLocalConfig() if @localConfig == nil
		@sharedConfig = @parseSharedConfig() if @sharedConfig == nil
		libraryPath = table.remove(@libraries, 1)
		games = {}
		file = io.readFile(io.joinPaths(@cachePath, 'output.txt'))
		manifests = file\splitIntoLines()
		for manifest in *manifests
			appID = manifest\match('appmanifest_(%d+)%.acf')
			continue if appID == nil
			assert(type(appID) == 'string', 'main.platforms.steam.init.generateGames')
			-- Disregard duplicates, if they appear for some reason.
			continue if games[appID] ~= nil
			-- If the community profile has been parsed, then disregard games not found on the profile.
			continue if @communityProfileGames ~= nil and @communityProfileGames[appID] == nil
			file = io.readFile(io.joinPaths(libraryPath, manifest), false)
			lines = file\splitIntoLines()
			vdf = utility.parseVDF(lines)
			banner, bannerURL = @getBanner(appID)
			expectedBanner = if banner ~= nil then nil else appID
			hoursPlayed = nil
			if @communityProfileGames ~= nil and @communityProfileGames[appID] ~= nil
				hoursPlayed = @communityProfileGames[appID].hoursPlayed
				@communityProfileGames[appID] = nil
			games[appID] = {
				title: vdf.appstate.name or (vdf.userconfig and vdf.userconfig.name)
				path: @getPath(appID)
				platformID: @platformID
				:banner
				:bannerURL
				:expectedBanner
				:hoursPlayed
				lastPlayed: @getLastPlayed(appID)
				platformTags: @getTags(appID)
				process: @getProcess()
			}
		-- Wait until all detected Steam libraries have been processed before dealing with any remaining
		-- (i.e. not installed) games found in the community profile.
		if @communityProfileGames ~= nil and #@libraries == 0
			for appID, game in pairs(@communityProfileGames)
				continue if games[appID] ~= nil
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
					lastPlayed: @getLastPlayed(appID)
					platformTags: @getTags(appID)
					process: @getProcess()
					uninstalled: true
				}
				@communityProfileGames[appID] = nil
		for appID, args in pairs(games)
			table.insert(@games, Game(args))

return Steam
