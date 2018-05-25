Game = require('main.game')

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
}

class Library
	new: (settings, regularMode = true) =>
	-- regularMode is true, if the instance of Library is being created for the main config
	-- regularMode should be false in all other cases (e.g. in the filter config)
		assert(type(settings) == 'table', 'shared.library.Library')
		assert(type(regularMode) == 'boolean', 'shared.library.Library')
		@version = 1
		@path = 'games.json'
		if regularMode
			@numBackups = settings\getNumberOfBackups()
			@backupFilePattern = 'games_backup_%d.json'
			@games = {}
			@oldGames = @load()
			@currentGameID = 1
		else
			games = io.readJSON(@path)
			@games = [Game(args) for args in *games.games]
			@oldGames = {}
		@filterStack = {}
		@processedGames = nil
		@gamesSortedByGameID = nil

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
				games = games.games if version > 0
				games = {} if type(games) ~= 'table'
				migrated = @migrate(games, version)
				games = [Game(args) for args in *games]
				if migrated
					@save(games)
				return games
		return {}

	save: (games = @gamesSortedByGameID) =>
		io.writeJSON(@path, {
			version: @version
			games: games
		})

	migrate: (games, version) =>
		assert(type(version) == 'number' and version % 1 == 0, 'Expected the games version number to be an integer.')
		assert(version <= @version, ('Unsupported games version. Expected version %d or earlier.')\format(@version))
		return false if version == @version
		for migrator in *migrators
			if version < migrator.version
				log("Migrating games.json from version #{version} to #{migrator.version}.")
				migrator.func(games)
		return true

	add: (games) =>
		return false if games == nil
		assert(type(games) == 'table', 'shared.library.Library.add')
		return false if #games == 0
		for game in *games
			assert(game.__class == Game, 'shared.library.Library.add')
			for i, oldGame in ipairs(@oldGames)
				if game\getPlatformID() == oldGame\getPlatformID() and game\getTitle() == oldGame\getTitle()
					game\merge(oldGame)
					table.remove(@oldGames, i)
					break
			game\setGameID(@currentGameID)
			@currentGameID += 1
			table.insert(@games, game)
		return true

	finalize: (platformEnabledStatus) =>
		assert(type(platformEnabledStatus) == 'table', 'shared.library.Library.finalize')
		@platformEnabledStatus = platformEnabledStatus
		for game in *@oldGames
			game\setInstalled(false)
			game\setGameID(@currentGameID)
			@currentGameID += 1
			table.insert(@games, game)
		@oldGames = nil
		@gamesSortedByGameID = table.shallowCopy(@games)
		table.sort(@gamesSortedByGameID, (a, b) -> return a.gameID < b.gameID)

	update: (updatedGame) =>
		gameID = updatedGame\getGameID()
		for game in *@games
			if game\getGameID() == gameID
				game\merge(updatedGame)
				return true
		return false

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

	filter: (filter, args) =>
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
					continue unless filter == ENUMS.FILTER_TYPES.HIDDEN
				elseif not game\isInstalled()
					continue unless filter == ENUMS.FILTER_TYPES.UNINSTALLED
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
				assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, 'shared.library.Library.filter')
				platformID = args.platformID
				platformOverride = args.platformOverride
				if platformOverride ~= nil
					games = [game for game in *gamesToProcess when game\getPlatformID() == platformID and game\getPlatformOverride() == platformOverride]
				else
					games = [game for game in *gamesToProcess when game\getPlatformID() == platformID and game\getPlatformOverride() == nil]
			when ENUMS.FILTER_TYPES.TAG
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.tag) == 'string', 'shared.library.Library.filter')
				tag = args.tag
				games = [game for game in *gamesToProcess when game\hasTag(tag) == true]
			when ENUMS.FILTER_TYPES.HIDDEN
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				state = args.state
				games = [game for game in *gamesToProcess when game\isVisible() ~= state]
			when ENUMS.FILTER_TYPES.UNINSTALLED
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				state = args.state
				games = [game for game in *gamesToProcess when game\isInstalled() ~= state]
			when ENUMS.FILTER_TYPES.NO_TAGS
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				if args.state
					games = [game for game in *gamesToProcess when #game\getTags() == 0 and #game\getPlatformTags() == 0]
				else
					games = [game for game in *gamesToProcess when #game\getTags() > 0 or #game\getPlatformTags() > 0]
			when ENUMS.FILTER_TYPES.RANDOM_GAME
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = {gamesToProcess[math.random(1, #gamesToProcess)]}
			when ENUMS.FILTER_TYPES.NEVER_PLAYED
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = [game for game in *gamesToProcess when game\getHoursPlayed() == 0]
			when ENUMS.FILTER_TYPES.HAS_NOTES
				assert(type(args) == 'table', 'shared.library.Library.filter')
				assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
				games = [game for game in *gamesToProcess when game\getNotes() ~= nil]
			else
				assert(nil, 'shared.library.Library.filter')
		assert(type(games) == 'table', 'shared.library.Library.filter')
		@processedGames = games

	getFilterStack: () => return @filterStack

	get: () =>
		@filter(ENUMS.FILTER_TYPES.NONE, nil) if @processedGames == nil
		games = @processedGames
		@processedGames = nil
		return games

	replace: (old, new) =>
		assert(old ~= nil and old.__class == Game, 'shared.library.Library.replace')
		assert(new ~= nil and new.__class == Game, 'shared.library.Library.replace')
		return table.replace(@games, old, new)

	remove: (game) =>
		i = table.find(@games, game)
		table.remove(@games, i)
		@save()

return Library
