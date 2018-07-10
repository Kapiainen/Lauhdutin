export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil
json = nil

export LOCALIZATION = nil

export STATE = {
	PATHS: {
		RESOURCES: nil
	}
	SCROLLBAR: {
		START: nil
		MAX_HEIGHT: nil
		HEIGHT: nil
		STEP: nil
	}
	NUM_SLOTS: 5
	LOGGING: false
	STACK: false
	SCROLL_INDEX: nil
	PROPERTIES: nil
	DEFAULT_PROPERTIES: nil
	INVERSE_PROPERTIES: nil
	FILTER_TYPE: nil
	ARGUMENTS: {}
	NUM_GAMES_PATTERN: ''
	BACK_BUTTON_TITLE: ''
}

COMPONENTS = {
	STATUS: nil
	SETTINGS: nil
	SLOTS: nil
}

class Property
	new: (args) =>
		@title = args.title
		@value = args.value
		@enum = args.enum
		@arguments = args.arguments
		@properties = args.properties
		@action = args.action
		@update = args.update

class Slot
	new: (index) =>
		@index = index

	populate: (property) =>
		@property = property
		@update()

	update: () =>
		if @property
			@property.value = @property\update() if @property.update ~= nil
			SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index,
				utility.replaceUnsupportedChars(@property.title)))
			SKIN\Bang(('[!SetOption "Slot%dValue" "Text" "%s"]')\format(@index,
				utility.replaceUnsupportedChars(@property.value)))
			return
		SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "Text" " "]')\format(@index))

	hasAction: () => return @property ~= nil

	action: () =>
		if @property.enum ~= nil
			STATE.FILTER_TYPE = @property.enum
		if @property.arguments ~= nil
			for key, value in pairs(@property.arguments)
				STATE.ARGUMENTS[key] = value
		if @property.properties ~= nil
			STATE.PROPERTIES = @property.properties
			return true
		if @property.action ~= nil
			@property\action()
			return true
		filter = STATE.FILTER_TYPE
		arguments = json.encode(STATE.ARGUMENTS)\gsub('"', '|')
		SKIN\Bang(('[!CommandMeasure "Script" "Filter(%d, %s, \'%s\')" "#ROOTCONFIG#"]')\format(filter,
			tostring(STATE.STACK), arguments))
		return false

Game = nil

export HideStatus = () -> COMPONENTS.STATUS\hide()

export Initialize = () ->
	SKIN\Bang('[!Hide]')
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.enums')
			utility = require('shared.utility')
			utility.createJSONHelpers()
			json = require('lib.json')
			COMPONENTS.SETTINGS = require('shared.settings')()
			export log = if COMPONENTS.SETTINGS\getLogging() == true then (...) -> print(...) else () -> return
			log('Initializing Filter config')
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			STATE.NUM_GAMES_PATTERN = LOCALIZATION\get('game_number_of_games', '%d games')
			STATE.BACK_BUTTON_TITLE = LOCALIZATION\get('filter_back_button_title', 'Back')
			Game = require('main.game')
			STATE.SCROLL_INDEX = 1
			COMPONENTS.SLOTS = [Slot(i) for i = 1, STATE.NUM_SLOTS]
			scrollbar = SKIN\GetMeter('Scrollbar')
			STATE.SCROLLBAR.START = scrollbar\GetY()
			STATE.SCROLLBAR.MAX_HEIGHT = scrollbar\GetH()
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeFilter()" "#ROOTCONFIG#"]')
			COMPONENTS.STATUS\hide()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () -> return

sortPropertiesByTitle = (a, b) -> return a.title\lower() < b.title\lower()

createHiddenProperties = (default, inverse, numGames, numHiddenGames) ->
	if numHiddenGames > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_is_hidden', 'Is hidden')
			value: STATE.NUM_GAMES_PATTERN\format(numHiddenGames)
			enum: ENUMS.FILTER_TYPES.HIDDEN
			arguments: {
				state: true
			}
		}))
	if numGames > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_is_hidden_inverse', 'Is not hidden')
			value: STATE.NUM_GAMES_PATTERN\format(numGames)
			enum: ENUMS.FILTER_TYPES.HIDDEN
			arguments: {
				state: true
				inverse: true
			}
		}))

createUninstalledProperties = (default, inverse, numGames, numUninstalledGames) ->
	if numUninstalledGames > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_is_uninstalled', 'Is not installed')
			value: STATE.NUM_GAMES_PATTERN\format(numUninstalledGames)
			enum: ENUMS.FILTER_TYPES.UNINSTALLED
			arguments: {
				state: true
			}
		}))
	if numGames > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_is_uninstalled_inverse', 'Is installed')
			value: STATE.NUM_GAMES_PATTERN\format(numGames)
			enum: ENUMS.FILTER_TYPES.UNINSTALLED
			arguments: {
				state: true
				inverse: true
			}
		}))

createPlatformProperties = (default, inverse, numGames, platforms, platformGameCounts, backDefault,
	backInverse) ->
	platformsDefault = {}
	platformsInverse = {}
	platformNames = {platform\getPlatformID(), platform\getName() for platform in *platforms}
	for platform, i in pairs(platformGameCounts)
		continue if i <= 0
		if type(platform) == 'number'
			table.insert(platformsDefault, Property({
				title: platformNames[platform]
				value: STATE.NUM_GAMES_PATTERN\format(i)
				arguments: {
					platformID: platform
				}
			}))
			table.insert(platformsInverse, Property({
				title: platformNames[platform]
				value: STATE.NUM_GAMES_PATTERN\format(numGames - i)
				arguments: {
					platformID: platform
					inverse: true
				}
			}))
		else
			title = platform .. '*'
			table.insert(platformsDefault, Property({
				:title
				value: STATE.NUM_GAMES_PATTERN\format(i)
				arguments: {
					platformOverride: platform
				}
			}))
			table.insert(platformsInverse, Property({
				:title
				value: STATE.NUM_GAMES_PATTERN\format(numGames - i)
				arguments: {
					platformOverride: platform
					inverse: true
				}
			}))
	table.sort(platformsDefault, sortPropertiesByTitle)
	table.sort(platformsInverse, sortPropertiesByTitle)
	platformsDefault = if numGames < 1 then nil else Property({
		title: LOCALIZATION\get('filter_from_platform', 'Is on platform X')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.PLATFORM
		properties: platformsDefault
	})
	platformsInverse = if numGames < 1 then nil else Property({
		title: LOCALIZATION\get('filter_from_platform_inverse', 'Is not on platform X')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.PLATFORM
		properties: platformsInverse
	})
	if platformsDefault
		table.insert(platformsDefault.properties, 1, backDefault)
		table.insert(default, platformsDefault)
	if platformsInverse
		table.insert(platformsInverse.properties, 1, backInverse)
		table.insert(inverse, platformsInverse)

createTagProperties = (default, inverse, numGames, numGamesWithTags, tagsGameCounts, backDefault,
	backInverse) ->
	tagsDefault = {}
	tagsInverse = {}
	for tag, i in pairs(tagsGameCounts)
		if i > 0
			table.insert(tagsDefault, Property({
				title: tag
				value: STATE.NUM_GAMES_PATTERN\format(i)
				arguments: {
					:tag
				}
			}))
			table.insert(tagsInverse, Property({
				title: tag
				value: STATE.NUM_GAMES_PATTERN\format(numGames - i)
				arguments: {
					:tag
					inverse: true
				}
			}))
	table.sort(tagsDefault, sortPropertiesByTitle)
	table.sort(tagsInverse, sortPropertiesByTitle)
	tagsDefault = if #tagsDefault < 1 then nil else Property({
		title: LOCALIZATION\get('filter_has_tag', 'Has tag X')
		value: STATE.NUM_GAMES_PATTERN\format(numGamesWithTags)
		enum: ENUMS.FILTER_TYPES.TAG
		properties: tagsDefault
	})
	tagsInverse = if #tagsInverse < 1 then nil else Property({
		title: LOCALIZATION\get('filter_has_tag_inverse', 'Does not have tag X')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.TAG
		properties: tagsInverse
	})
	if tagsDefault
		table.insert(tagsDefault.properties, 1, backDefault)
		table.insert(default, tagsDefault)
	if tagsInverse
		table.insert(tagsInverse.properties, 1, backInverse)
		table.insert(inverse, tagsInverse)

createNoTagProperties = (default, inverse, numGames, numGamesWithTags) ->
	if (numGames - numGamesWithTags) > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_has_no_tags', 'Has no tags')
			value: STATE.NUM_GAMES_PATTERN\format(numGames - numGamesWithTags)
			enum: ENUMS.FILTER_TYPES.NO_TAGS
			arguments: {
				state: true
			}
		}))
	if numGamesWithTags > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_has_no_tags_inverse', 'Has one or more tags')
			value: STATE.NUM_GAMES_PATTERN\format(numGamesWithTags)
			enum: ENUMS.FILTER_TYPES.NO_TAGS
			arguments: {
				state: true
				inverse: true
			}
		}))

createRandomProperties = (default, inverse, numGames) ->
	if numGames > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_random', 'Pick a random game')
			value: STATE.NUM_GAMES_PATTERN\format(numGames)
			enum: ENUMS.FILTER_TYPES.RANDOM_GAME
			arguments: {
				state: true
			}
		}))
	if numGames > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_random_inverse', 'Remove a random game')
			value: STATE.NUM_GAMES_PATTERN\format(numGames)
			enum: ENUMS.FILTER_TYPES.RANDOM_GAME
			arguments: {
				state: true
				inverse: true
			}
		}))

createNeverPlayerProperties = (default, inverse, numGames, numGamesNeverPlayed) ->
	if numGamesNeverPlayed > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_never_played', 'Has never been played')
			value: STATE.NUM_GAMES_PATTERN\format(numGamesNeverPlayed)
			enum: ENUMS.FILTER_TYPES.NEVER_PLAYED
			arguments: {
				state: true
			}
		}))
	if (numGames - numGamesNeverPlayed) > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_never_played_inverse', 'Has been played')
			value: STATE.NUM_GAMES_PATTERN\format(numGames - numGamesNeverPlayed)
			enum: ENUMS.FILTER_TYPES.NEVER_PLAYED
			arguments: {
				state: true
				inverse: true
			}
		}))

createNotesProperties = (default, inverse, numGames, numGamesWithNotes) ->
	if numGamesWithNotes > 0
		table.insert(default, Property({
			title: LOCALIZATION\get('filter_has_notes', 'Has notes')
			value: STATE.NUM_GAMES_PATTERN\format(numGamesWithNotes)
			enum: ENUMS.FILTER_TYPES.HAS_NOTES
			arguments: {
				state: true
			}
		}))
	if (numGames - numGamesWithNotes) > 0
		table.insert(inverse, Property({
			title: LOCALIZATION\get('filter_has_notes_inverse', 'Does not have notes')
			value: STATE.NUM_GAMES_PATTERN\format(numGames - numGamesWithNotes)
			enum: ENUMS.FILTER_TYPES.HAS_NOTES
			arguments: {
				state: true
				inverse: true
			}
		}))

createInvertProperties = (default, inverse) ->
	invertFilters = Property({
		title: LOCALIZATION\get('filter_invert_filters', 'Invert filters')
		value: ' '
		action: () =>
			if STATE.PROPERTIES == STATE.DEFAULT_PROPERTIES
				STATE.PROPERTIES = STATE.INVERSE_PROPERTIES
			else
				STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
	})
	table.insert(default, 1, invertFilters)
	table.insert(inverse, 1, invertFilters)

createClearProperties = (default, inverse) ->
	clear = Property({
		title: LOCALIZATION\get('filter_clear_filters', 'Clear filters')
		value: ' '
		enum: ENUMS.FILTER_TYPES.NONE
	})
	table.insert(default, clear)
	table.insert(inverse, clear)

createCancelProperties = (default, inverse) ->
	cancel = Property({
		title: LOCALIZATION\get('button_label_cancel', 'Cancel')
		value: ' '
		action: () => SKIN\Bang('[!DeactivateConfig]')
	})
	table.insert(default, cancel)
	table.insert(inverse, cancel)

createProperties = (games, hiddenGames, uninstalledGames, platforms, stack, filterStack) ->
	defaultProperties = {}
	inverseProperties = {}
	numGames = #games
	numHiddenGames = #hiddenGames
	createHiddenProperties(defaultProperties, inverseProperties, numGames, numHiddenGames)
	numUninstalledGames = #uninstalledGames
	createUninstalledProperties(defaultProperties, inverseProperties, numGames, numUninstalledGames)
	if numGames > 0
		skipPlatforms = false
		skipTags = false
		skipNoTags = false
		skipRandom = false
		skipNeverPlayed = false
		skipHasNotes = false
		for f in *filterStack
			switch f.filter
				when ENUMS.FILTER_TYPES.PLATFORM
					skipPlatforms = true
				when ENUMS.FILTER_TYPES.NO_TAGS
					skipTags = true
				when ENUMS.FILTER_TYPES.TAG
					skipNoTags = true
				when ENUMS.FILTER_TYPES.RANDOM_GAME
					skipRandom = true if numGames < 2
				when ENUMS.FILTER_TYPES.NEVER_PLAYED
					skipNeverPlayed = true
				when ENUMS.FILTER_TYPES.HAS_NOTES
					skipHasNotes = true
		backDefault = Property({
			title: STATE.BACK_BUTTON_TITLE
			value: ' '
			properties: defaultProperties
		})
		backInverse = Property({
			title: STATE.BACK_BUTTON_TITLE
			value: ' '
			properties: inverseProperties
		})
		-- Do once before processing games
		platformGameCounts = {}
		tagsGameCounts = {}
		numGamesWithTags = 0
		numGamesNeverPlayed = 0
		numGamesWithNotes = 0
		unless skipPlatforms
			for platform in *platforms
				platformGames = 0
				platformID = platform\getPlatformID()
				platformGameCounts[platformID] = 0
		-- Do once per game
		for game in *games
			unless skipPlatforms
				platformID = game\getPlatformID()
				platformOverride = game\getPlatformOverride()
				if platformOverride == nil
					platformGameCounts[platformID] += 1
				else
					if platformGameCounts[platformOverride] == nil
						platformGameCounts[platformOverride] = 0
					platformGameCounts[platformOverride] += 1
			unless skipTags
				gameTags, n = game\getTags()
				if n > 0
					for tag, source in pairs(gameTags)
						skip = false
						for f in *filterStack
							if f.filter == ENUMS.FILTER_TYPES.TAG and f.args.tag == tag
								skip = true
								break
						continue if skip
						if tagsGameCounts[tag] == nil
							tagsGameCounts[tag] = 0
						tagsGameCounts[tag] += 1
					numGamesWithTags += 1
			unless skipNeverPlayed
				numGamesNeverPlayed += 1 if game\getHoursPlayed() == 0
			unless skipHasNotes
				numGamesWithNotes += 1 if game\getNotes() ~= nil
		-- Do once after processing games
		unless skipPlatforms
			createPlatformProperties(defaultProperties, inverseProperties, numGames, platforms,
				platformGameCounts, backDefault, backInverse)
		unless skipTags
			createTagProperties(defaultProperties, inverseProperties, numGames, numGamesWithTags,
				tagsGameCounts, backDefault, backInverse)
		unless skipNoTags
			createNoTagProperties(defaultProperties, inverseProperties, numGames, numGamesWithTags)
		if not skipRandom and numGames > 1
			createRandomProperties(defaultProperties, inverseProperties, numGames)
		unless skipNeverPlayed
			createNeverPlayerProperties(defaultProperties, inverseProperties, numGames, numGamesNeverPlayed)
		unless skipHasNotes
			createNotesProperties(defaultProperties, inverseProperties, numGames, numGamesWithNotes)
	table.sort(defaultProperties, sortPropertiesByTitle)
	table.sort(inverseProperties, sortPropertiesByTitle)
	createInvertProperties(defaultProperties, inverseProperties)
	unless stack
		createClearProperties(defaultProperties, inverseProperties)
	createCancelProperties(defaultProperties, inverseProperties)
	return defaultProperties, inverseProperties

updateScrollbar = () ->
	STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
	if #STATE.PROPERTIES > STATE.NUM_SLOTS
		div = (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1)
		div = 1 if div < 1
		STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / div)
		div = (#STATE.PROPERTIES - STATE.NUM_SLOTS)
		div = 1 if div < 1
		STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / div
	else
		STATE.SCROLLBAR.HEIGHT = STATE.SCROLLBAR.MAX_HEIGHT
		STATE.SCROLLBAR.STEP = 0
	SKIN\Bang(('[!SetOption "Scrollbar" "H" "%d"]')\format(STATE.SCROLLBAR.HEIGHT))
	y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
	SKIN\Bang(('[!SetOption "Scrollbar" "Y" "%d"]')\format(math.round(y)))

updateSlots = () ->
	for i, slot in ipairs(COMPONENTS.SLOTS)
		slot\populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
		if i == STATE.HIGHLIGHTED_SLOT_INDEX
			MouseOver(i)

export Handshake = (stack, appliedFilters) ->
	success, err = pcall(
		() ->
			log('Accepting Filter handshake', stack)
			STATE.SCROLL_INDEX = 1
			STATE.STACK = stack
			platforms = [Platform(COMPONENTS.SETTINGS) for Platform in *require('main.platforms')]
			games = nil
			hiddenGames = {}
			uninstalledGames = {}
			appliedFilters = appliedFilters\gsub('|', '"')
			filterStack = json.decode(appliedFilters)
			if stack
				SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(
					LOCALIZATION\get('filter_window_current_title', 'Filter (current games)')))
				library = require('shared.library')(COMPONENTS.SETTINGS, false)
				platformsEnabledStatus = {}
				temp = {}
				for platform in *platforms
					enabled = platform\isEnabled()
					platformsEnabledStatus[platform\getPlatformID()] = enabled
					table.insert(temp, platform) if enabled
				platforms = temp
				temp = nil
				library\finalize(platformsEnabledStatus)
				games = library\get()
				showHiddenGames = false
				showUninstalledGames = false
				for f in *filterStack
					if f.filter == ENUMS.FILTER_TYPES.HIDDEN and f.args.state == true
						showHiddenGames = true
					elseif f.filter == ENUMS.FILTER_TYPES.UNINSTALLED and f.args.state == true
						showUninstalledGames = true
					f.args.games = games
					library\filter(f.filter, f.args)
					games = library\get()
				for i = #games, 1, -1
					if not games[i]\isVisible() and not showHiddenGames
						table.insert(hiddenGames, table.remove(games, i))
					elseif not games[i]\isInstalled() and not (showUninstalledGames or showHiddenGames)
						table.insert(uninstalledGames, table.remove(games, i))
			else
				SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(
					LOCALIZATION\get('filter_window_all_title', 'Filter')))
				platforms = [platform for platform in *platforms when platform\isEnabled()]
				games = io.readJSON('games.json')
				games = [Game(args, games.tagsDictionary) for args in *games.games]
				for i = #games, 1, -1
					if not games[i]\isVisible()
						table.insert(hiddenGames, table.remove(games, i))
					elseif not games[i]\isInstalled()
						table.insert(uninstalledGames, table.remove(games, i))
			STATE.DEFAULT_PROPERTIES, STATE.INVERSE_PROPERTIES = createProperties(games, hiddenGames,
				uninstalledGames, platforms, stack, filterStack)
			STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
			updateScrollbar()
			updateSlots()
			if COMPONENTS.SETTINGS\getCenterOnMonitor()
				meter = SKIN\GetMeter('WindowShadow')
				skinWidth = meter\GetW()
				skinHeight = meter\GetH()
				mainConfig = utility.getConfig(SKIN\GetVariable('ROOTCONFIG'))
				monitorIndex = nil
				if mainConfig ~= nil
					monitorIndex = utility.getConfigMonitor(mainConfig) or 1
				else
					monitorIndex = 1
				x, y = utility.centerOnMonitor(skinWidth, skinHeight, monitorIndex)
				SKIN\Bang(('[!Move "%d" "%d"]')\format(x, y))
			SKIN\Bang('[!ZPos 1][!Show]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Scroll = (direction) ->
	success, err = pcall(
		() ->
			return unless COMPONENTS.SLOTS
			index = STATE.SCROLL_INDEX + direction
			if index < 1
				return
			elseif index > STATE.MAX_SCROLL_INDEX
				return
			STATE.SCROLL_INDEX = index
			updateScrollbar()
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseOver = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			STATE.HIGHLIGHTED_SLOT_INDEX = index
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseLeave = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			if index == 0
				STATE.HIGHLIGHTED_SLOT_INDEX = 0
				for i = index, STATE.NUM_SLOTS
					SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(i))
			else
				SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseLeftPress = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ButtonAction = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))
			if COMPONENTS.SLOTS[index]\action()
				STATE.SCROLL_INDEX = 1
				updateScrollbar()
				updateSlots()
			else
				SKIN\Bang('[!DeactivateConfig]')
	)
	COMPONENTS.STATUS\show(err, true) unless success
