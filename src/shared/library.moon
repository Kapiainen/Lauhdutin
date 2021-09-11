Game = require('main.game')
json = require('lib.json')

-- A migrator is a table with the following fields:
-- - "version":
--   The version number (an integer) of the file that stores games in JSON.
--   If the file being loaded has a version number lower than this field, then the games need to be updated.
-- - "func":
--   A function that takes the table of games and updates each game in-place as necessary.
migrators = {
	{
		version: 1 -- Version 2.7.1 -> 3.0.0
		func: (games) ->
			gamesToRemove = {}
			for i, game in ipairs(games)
				remove = false
				remove = true if type(game.title) ~= 'string' or game.title\trim() == ''
				remove = true if type(game.path) ~= 'string' or game.path\trim() == ''
				remove = true if type(game.platform) ~= 'number' or game.platform < 0 or game.platform > 5
				if remove
					table.insert(gamesToRemove, game)
				else
					game.platformID = switch game.platform
						when 0 then ENUMS.PLATFORM_IDS.STEAM -- Steam
						when 1 then ENUMS.PLATFORM_IDS.STEAM -- Steam shortcuts
						when 2 then ENUMS.PLATFORM_IDS.GOG_GALAXY
						when 3 then ENUMS.PLATFORM_IDS.SHORTCUTS -- Windows shortcuts (.lnk)
						when 4 then ENUMS.PLATFORM_IDS.SHORTCUTS -- Windows shortcuts (.url)
						when 5 then ENUMS.PLATFORM_IDS.BATTLENET
					game.platformOverride = game.platformoverride
					game.platformoverride = nil
					game.hoursPlayed = game.hourstotal
					game.hourstotal = nil
					game.lastPlayed = tonumber(game.lastplayed)
					game.lastplayed = nil
					game.uninstalled = game.notinstalled
					game.notinstalled = nil
					game.processOverride = game.processoverride
					game.processoverride = nil
					if game.tags ~= nil
						tags = {}
						for key, tag in pairs(game.tags)
							table.insert(tags, tag)
						game.tags = tags
					game.banner = nil
					game.bannererror = nil
					game.bannerurl = nil
					game.error = nil
					game.hourslast2weeks = nil
					game.ignoresbangs = nil
					game.invalidpatherror = nil
					-- Leave game.notes
					-- Leave game.hidden
					-- Leave game.process
			for game in *gamesToRemove
				i = table.find(games, game)
				table.remove(games, i)
	}
	{
		version: 2 -- Version 3.0.0 -> 3.1.0
		func: (games) ->
			-- Reduce the number of characters stored in 'games.json'.
			for i, game in ipairs(games)
				-- Remove empty tables.
				game.tags = nil if game.tags ~= nil and #game.tags == 0
				game.platformTags = nil if game.platformTags ~= nil and #game.platformTags == 0
				game.startingBangs = nil if game.startingBangs ~= nil and #game.startingBangs == 0
				game.stoppingBangs = nil if game.stoppingBangs ~= nil and #game.stoppingBangs == 0
				-- Switch over to using abbreviated properties.
				game.ba = game.banner
				game.baURL = game.bannerURL
				game.exBa = game.expectedBanner
				game.gaID = game.gameID
				game.hi = game.hidden
				game.hoPl = game.hoursPlayed
				game.igOtBa = game.ignoresOtherBangs
				game.laPl = game.lastPlayed
				game.no = game.notes
				game.pa = game.path
				game.plID = game.platformID
				game.plOv = game.platformOverride
				game.plTa = game.platformTags
				game.pr = game.process
				game.prOv = game.processOverride
				game.staBa = game.startingBangs
				game.stoBa = game.stoppingBangs
				game.ta = game.tags
				game.ti = game.title
				game.un = game.uninstalled
				-- Clean up by removing the old properties.
				game.banner = nil
				game.bannerURL = nil
				game.expectedBanner = nil
				game.gameID = nil
				game.hidden = nil
				game.hoursPlayed = nil
				game.ignoresOtherBangs = nil
				game.lastPlayed = nil
				game.notes = nil
				game.path = nil
				game.platformID = nil
				game.platformOverride = nil
				game.platformTags = nil
				game.process = nil
				game.processOverride = nil
				game.startingBangs = nil
				game.stoppingBangs = nil
				game.tags = nil
				game.title = nil
				game.uninstalled = nil
	}
}

class Library
	new: (settings, regularMode = true) =>
	-- regularMode is true, if the instance of Library is being created for the main config
	-- regularMode should be false in all other cases (e.g. in the filter config)
		assert(type(settings) == 'table', 'shared.library.Library')
		assert(type(regularMode) == 'boolean', 'shared.library.Library')
		@version = 2
		@path = 'games.json'
		games = if io.fileExists(@path) then io.readJSON(@path) else {}
		@currentGameID = 1
		@numBackups = settings\getNumberOfBackups()
		@backupFilePattern = 'games_backup_%d.json'
		@searchUninstalledGames = settings\getSearchUninstalledGamesEnabled()
		@searchHiddenGames = settings\getSearchHiddenGamesEnabled()
		@filterStack = {}
		@processedGames = nil
		@gamesSortedByGameID = {}
		@detectGames = false
		@updatedTimestamp = if regularMode == true then os.date('*t') else games.updated
		@tagsDictionary = {}
		if regularMode
			@detectGames = switch settings\getGameDetectionFrequency()
				when ENUMS.GAME_DETECTION_FREQUENCY.ALWAYS
					true
				when ENUMS.GAME_DETECTION_FREQUENCY.ONCE_PER_DAY
					@updatedTimestamp = os.date('*t')
					updated = games.updated or {}
					if updated.year == @updatedTimestamp.year and updated.month == @updatedTimestamp.month and updated.day == @updatedTimestamp.day
						false
					else
						true
				when ENUMS.GAME_DETECTION_FREQUENCY.NEVER
					if games.updated == nil
						true
					else
						false
				else false
			if @detectGames == true
				@games = {}
				@oldGames = @load()
			else
				for key, tag in pairs(games.tagsDictionary or {})
					@tagsDictionary[key] = tag
				@games = [Game(args, @tagsDictionary) for args in *games.games]
				@oldGames = {}
		else
			for key, tag in pairs(games.tagsDictionary or {})
				@tagsDictionary[key] = tag
			@games = [Game(args, @tagsDictionary) for args in *games.games]
			@oldGames = {}

	getDetectGames: () => return @detectGames

	getNextAvailableGameID: () => return @currentGameID

	getOldGames: () => return @oldGames

	createBackup: (path) =>
		games = io.readJSON(path)
		date = os.date('*t')
		games.backup = {year: date.year, month: date.month, day: date.day}
		latestBackupPath = @backupFilePattern\format(1)
		if io.fileExists(latestBackupPath)
			latestBackup = io.readJSON(latestBackupPath)
			return if latestBackup.backup.year == date.year and latestBackup.backup.month == date.month and latestBackup.backup.day == date.day
			for i = @numBackups, 1, -1
				backupPath = @backupFilePattern\format(i)
				if io.fileExists(backupPath)
					if i == @numBackups
						os.remove(io.absolutePath(backupPath))
					else
						backupPath = io.absolutePath(backupPath)
						target = io.absolutePath(@backupFilePattern\format(i + 1))
						os.rename(backupPath, target)
		io.writeJSON(latestBackupPath, games)

	load: () =>
		paths = [@backupFilePattern\format(i) for i = 1, @numBackups]
		table.insert(paths, 1, @path)
		for path in *paths
			if io.fileExists(path)
				@createBackup(path)
				games = io.readJSON(path)
				version = games.version or 0
				for key, tag in pairs(games.tagsDictionary or {})
					@tagsDictionary[key] = tag
				games = games.games if version > 0
				games = {} if type(games) ~= 'table'
				migrated = @migrate(games, version)
				games = [Game(args, @tagsDictionary) for args in *games]
				if migrated
					@save(games)
				return games
		return {}

	cleanUp: () =>
		tagReferenceCounts = {key, 0 for key, tag in pairs(@tagsDictionary)}
		for game in *@gamesSortedByGameID
			continue unless game\hasTags()
			for key, tag in pairs(@tagsDictionary)
				if game\hasTag(key) ~= nil
					tagReferenceCounts[key] += 1
		for key, refCount in pairs(tagReferenceCounts)
			if refCount == 0
				@tagsDictionary[key] = nil

	save: (games = @gamesSortedByGameID) =>
		out = json.encode({
			version: @version
			tagsDictionary: @tagsDictionary
			games: games
			updated: @updatedTimestamp
		})
		out = out\gsub('"[^"]+":', {
			['"banner":']: '"ba":'
			['"bannerURL":']: '"baURL":'
			['"expectedBanner":']: '"exBa":'
			['"gameID":']: '"gaID":'
			['"hidden":']: '"hi":'
			['"hoursPlayed":']: '"hoPl":'
			['"ignoresOtherBangs":']: '"igOtBa":'
			['"lastPlayed":']: '"laPl":'
			['"notes":']: '"no":'
			['"path":']: '"pa":'
			['"platformID":']: '"plID":'
			['"platformOverride":']: '"plOv":'
			['"platformTags":']: '"plTa":'
			['"process":']: '"pr":'
			['"processOverride":']: '"prOv":'
			['"startingBangs":']: '"stBa":'
			['"stoppingBangs":']: '"stBa":'
			['"tags":']: '"ta":'
			['"title":']: '"ti":'
			['"uninstalled":']: '"un":'
		})
		io.writeFile(@path, out)

	migrate: (games, version) =>
		assert(type(version) == 'number' and version % 1 == 0,
			'Expected the games version number to be an integer.')
		assert(version <= @version,
			('Unsupported games version. Expected version %d or earlier.')\format(@version))
		return false if version == @version
		for migrator in *migrators
			if version < migrator.version
				log("Migrating games.json from version #{version} to #{migrator.version}.")
				migrator.func(games, @tagsDictionary)
		return true

	extend: (games) =>
		return {} if games == nil
		assert(type(games) == 'table', 'shared.library.Library.extend')
		return {} if #games == 0
		games = [Game(args, @tagsDictionary) for args in *games]
		for game in *games
			for i, oldGame in ipairs(@oldGames)
				if game\getPlatformID() == oldGame\getPlatformID() and game\getTitle() == oldGame\getTitle()
					game\merge(oldGame)
					table.remove(@oldGames, i)
					break
			game\setGameID(@currentGameID)
			@currentGameID += 1
			table.insert(@games, game)
			table.insert(@gamesSortedByGameID, game)
		return games

	updateSortedList: () => table.sort(@gamesSortedByGameID, (a, b) -> return a.gameID < b.gameID)

	insert: (game) =>
		assert(game.__class == Game, 'shared.library.Library.insert')
		title = game\getTitle()
		platformID = game\getPlatformID()
		for oldGame in *@games
			if oldGame\getPlatformID() == platformID and oldGame\getTitle() == title
				return
		game\setGameID(@currentGameID)
		@currentGameID += 1
		table.insert(@games, game)
		table.insert(@gamesSortedByGameID, game)
		@updateSortedList()
		@save()

	finalize: (platformEnabledStatus) =>
		assert(type(platformEnabledStatus) == 'table', 'shared.library.Library.finalize')
		@platformEnabledStatus = platformEnabledStatus
		for game in *@oldGames
			game\setInstalled(false) if game\getPlatformID() ~= ENUMS.PLATFORM_IDS.CUSTOM
			game\setGameID(@currentGameID)
			@currentGameID += 1
			table.insert(@games, game)
			table.insert(@gamesSortedByGameID, game)
		@oldGames = nil
		if #@gamesSortedByGameID ~= #@games
			@gamesSortedByGameID = table.shallowCopy(@games)
		@updateSortedList()
		if #@gamesSortedByGameID > 0
			@currentGameID = @gamesSortedByGameID[#@gamesSortedByGameID]\getGameID() + 1

	add: (gameID) =>
		assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID >= @currentGameID,
			'shared.library.Library.add')
		games = io.readJSON(@path)
		args = games.games[gameID]
		newGame = if args ~= nil then Game(args, @tagsDictionary) else nil
		if newGame == nil or newGame\getGameID() ~= gameID
			newGame = nil
			for args in *games.games
				game = Game(args, @tagsDictionary)
				if game\getGameID() == gameID
					newGame = game
					break
		if newGame == nil
			log('Failed to add game!')
			return false
		@insert(newGame)
		return true

	update: (gameID) =>
		assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID < @currentGameID,
			'shared.library.Library.update')
		games = io.readJSON(@path)
		tagsDictionary = games.tagsDictionary
		for key, tag in pairs(tagsDictionary)
			if @tagsDictionary[key] == nil
				@tagsDictionary[key] = tag
		args = games.games[gameID]
		updatedGame = if args ~= nil then Game(args, @tagsDictionary) else nil
		if updatedGame == nil or updatedGame\getGameID() ~= gameID
			updatedGame = nil
			for args in *games.games
				game = Game(args, @tagsDictionary)
				if game\getGameID() == gameID
					updatedGame = game
					break
		if updatedGame == nil
			log('Failed to find the updated game!')
			return false
		gameToUpdate = @gamesSortedByGameID[gameID]
		if gameToUpdate == nil or gameToUpdate\getGameID() ~= gameID
			gameToUpdate = nil
			for game in *@gamesSortedByGameID
				if game\getGameID() == gameID
					gameToUpdate = game
					break
		if gameToUpdate == nil
			log('Failed to update the game!')
			return false
		log('Updating game')
		gameToUpdate\merge(updatedGame, true)
		@save()
		return true

	sort: (sorting, games = @games) =>
		assert(type(sorting) == 'number' and sorting % 1 == 0, 'shared.library.Library.sort')
		comp = nil
		switch sorting
			when ENUMS.SORTING_TYPES.ALPHABETICALLY
				comp = (a, b) -> return a\getTitle()\lower() < b\getTitle()\lower()
			when ENUMS.SORTING_TYPES.LAST_PLAYED
				comp = (a, b) -> return a\getLastPlayed() > b\getLastPlayed()
			when ENUMS.SORTING_TYPES.HOURS_PLAYED
				comp = (a, b) -> return a\getHoursPlayed() > b\getHoursPlayed()
			else
				assert(nil, 'Unknown sorting type.')
		assert(type(comp) == 'function', 'shared.library.Library.sort')
		table.sort(games, comp)
		if games ~= @games
			table.sort(@games, comp)

	fuzzySearch: (str, pattern) =>
		assert(type(str) == 'string', 'shared.library.Library.fuzzySearch')
		assert(type(pattern) == 'string', 'shared.library.Library.fuzzySearch')
		-- Case-insensitive fuzzy match that returns a score
		score = 0
		return score if str == '' or pattern == ''
		-- Bonuses
		bonusPerfectMatch = 50
		bonusFirstMatch = 25
		bonusMatch = 10
		bonusMatchDistance = 10
		bonusConsecutiveMatches = 10
		bonusFirstWordMatch = 20
		-- Penalties
		penaltyNotMatch = -5

		pattern = pattern\lower()
		str = str\lower()
		-- Pattern matches perfectly
		score += bonusPerfectMatch if str == pattern
		patternChars = pattern\splitIntoChars()
		strWords = str\splitIntoWords()

		matchString = (_str, _patternChars) ->
			matchIndex = _str\find(_patternChars[1])
			if matchIndex ~= nil
				-- Distance of first match from start of a string
				score += bonusFirstMatch / matchIndex
				-- Number of matches in order
				-- Number of consecutive matches
				-- Distance between matches
				matchIndices = {}
				table.insert(matchIndices, matchIndex)
				consecutiveMatches = 0
				for i, char in ipairs(_patternChars)
					if i > 1 and matchIndices[i - 1] ~= nil
						matchIndex = _str\find(char, matchIndices[i - 1] + 1)
						if matchIndex ~= nil
							table.insert(matchIndices, matchIndex)
							score += bonusMatch
							distance = matchIndex - matchIndices[i - 1]
							if distance == 1
								consecutiveMatches += 1
							else
								score += consecutiveMatches * bonusConsecutiveMatches
								consecutiveMatches = 0
							score += bonusMatchDistance / distance
						else
							score += consecutiveMatches * bonusConsecutiveMatches
							score += penaltyNotMatch
							consecutiveMatches = 0
				if consecutiveMatches > 0
					score += consecutiveMatches * bonusConsecutiveMatches
				return true
			return false

		-- Matches in entire string
		unless matchString(str, patternChars)
			min = 1
			while not matchString(str, table.slice(patternChars, min)) and min < #patternChars
				min += 1
		if #strWords > 0
			-- Matches at beginning of words
			j = 1
			for i, char in ipairs(patternChars)
				if j <= #strWords and strWords[j]\find(char) == 1
					score += bonusFirstWordMatch
					j += 1
			-- Matches in words
			for word in *strWords
				matchString(word, patternChars)
		return if score >= 0 then score else 0

	filterGames: (games, condition) =>
		result = {}
		i = 1
		while i <= #games
			if condition(games[i]) == true
				table.insert(result, table.remove(games, i))
			else
				i += 1
		return result

	filter: (filter, args = {}) =>
		assert(type(filter) == 'number' and filter % 1 == 0, 'shared.library.Library.filter')
		gamesToProcess = nil
		if args ~= nil and args.stack == true
			assert(type(args.games) == 'table', 'shared.library.Library.filter')
			gamesToProcess = args.games
			args.games = nil
			table.insert(@filterStack, {
				:filter
				:args
			})
		else
			gamesToProcess = {}
			for game in *@games
				continue unless @platformEnabledStatus[game\getPlatformID()] == true
				if not game\isVisible()
					if not game\isInstalled() and @searchHiddenGames == true
						continue unless @searchUninstalledGames == true
					continue unless filter == ENUMS.FILTER_TYPES.HIDDEN or filter == ENUMS.FILTER_TYPES.TITLE and @searchHiddenGames == true
				elseif not game\isInstalled()
					continue unless filter == ENUMS.FILTER_TYPES.UNINSTALLED or filter == ENUMS.FILTER_TYPES.TITLE and @searchUninstalledGames == true
				table.insert(gamesToProcess, game)
			if filter == ENUMS.FILTER_TYPES.NONE
				@filterStack = {}
			else
				@filterStack = {{
					:filter
					:args
				}}
		games = nil
		switch filter
			when ENUMS.FILTER_TYPES.NONE
				games = gamesToProcess
				@filterStack = {}
			when ENUMS.FILTER_TYPES.TITLE
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.input) == 'string', 'shared.library.Library.filter')
				if args.input == ''
					games = gamesToProcess
				else
				-- Fuzzy search
				-- This filter does its own sorting
					temp = {}
					for game in *gamesToProcess
						table.insert(temp, {
							game: game
							score: @fuzzySearch(game\getTitle(), args.input)
						})
					table.sort(temp, (a, b) -> return a.score > b.score)
					games = [entry.game for entry in *temp]
			when ENUMS.FILTER_TYPES.PLATFORM
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert((type(args.platformID) == 'number' and args.platformID % 1 == 0) or
					type(args.platformOverride) == 'string', 'shared.library.Library.filter')
				platformID = args.platformID
				platformOverride = args.platformOverride
				games = @filterGames(gamesToProcess, (game) -> 
					if platformOverride == nil
						return platformID == game\getPlatformID() and game\getPlatformOverride() == nil
					return platformOverride == game\getPlatformOverride()
				)
			when ENUMS.FILTER_TYPES.TAG
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.tag) == 'string', 'shared.library.Library.filter')
				tag = args.tag
				key = table.find(@tagsDictionary, tag)
				games = @filterGames(gamesToProcess, (game) -> return game\hasTag(key) ~= nil)
			when ENUMS.FILTER_TYPES.HIDDEN
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				state = args.state
				games = @filterGames(gamesToProcess, (game) -> return game\isVisible() ~= state)
			when ENUMS.FILTER_TYPES.UNINSTALLED
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				state = args.state
				games = @filterGames(gamesToProcess, (game) -> return game\isInstalled() ~= state)
			when ENUMS.FILTER_TYPES.NO_TAGS
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				if args.state
					games = @filterGames(gamesToProcess, (game) -> return game\hasTags() == false)
				else
					games = @filterGames(gamesToProcess, (game) -> return game\hasTags() == true)
			when ENUMS.FILTER_TYPES.RANDOM_GAME
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = {table.remove(gamesToProcess, math.random(1, #gamesToProcess))}
			when ENUMS.FILTER_TYPES.NEVER_PLAYED
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = @filterGames(gamesToProcess, (game) -> return game\getHoursPlayed() == 0)
			when ENUMS.FILTER_TYPES.HAS_NOTES
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = @filterGames(gamesToProcess, (game) -> return game\getNotes() ~= nil)
			else
				assert(nil, 'shared.library.Library.filter')
		games = gamesToProcess if args.inverse == true
		assert(type(games) == 'table', 'shared.library.Library.filter')
		@processedGames = games

	getFilterStack: () => return @filterStack

	get: () =>
		@filter(ENUMS.FILTER_TYPES.NONE, nil) if @processedGames == nil
		games = @processedGames
		@processedGames = nil
		return games

	getGameByID: (gameID) =>
		assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID < @currentGameID,
			'shared.library.Library.getGameByGameID')
		game = @gamesSortedByGameID[gameID]
		if game == nil or game\getGameID() ~= gameID -- Backup approach in case we didn't find the right game.
			for game in *@gamesSortedByGameID
				if game\getGameID() == gameID
					return game
			log('Failed to get game by gameID:', gameID)
			return nil
		return game



	replace: (old, new) =>
		assert(old ~= nil and old.__class == Game, 'shared.library.Library.replace')
		assert(new ~= nil and new.__class == Game, 'shared.library.Library.replace')
		return table.replace(@games, old, new)

	remove: (game) =>
		i = table.find(@games, game)
		table.remove(@games, i)
		i = table.find(@gamesSortedByGameID, game)
		table.remove(@gamesSortedByGameID, i)
		@save()

return Library
