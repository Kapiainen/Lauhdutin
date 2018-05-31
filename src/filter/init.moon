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
			SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index, utility.replaceUnsupportedChars(@property.title)))
			SKIN\Bang(('[!SetOption "Slot%dValue" "Text" "%s"]')\format(@index, utility.replaceUnsupportedChars(@property.value)))
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
		SKIN\Bang(('[!CommandMeasure "Script" "Filter(%d, %s, \'%s\')" "#ROOTCONFIG#"]')\format(filter, tostring(STATE.STACK), arguments))
		return false

Game = nil

export log = (...) -> print(...) if STATE.LOGGING == true

export Initialize = () ->
	SKIN\Bang('[!Hide]')
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			log('Initializing Filter config')
			require('shared.enums')
			utility = require('shared.utility')
			utility.createJSONHelpers()
			json = require('lib.json')
			COMPONENTS.SETTINGS = require('shared.settings')()
			STATE.LOGGING = COMPONENTS.SETTINGS\getLogging()
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			STATE.NUM_GAMES_PATTERN = LOCALIZATION\get('game_number_of_games', '%d games')
			STATE.BACK_BUTTON_TITLE = LOCALIZATION\get('filter_back_button_title', 'Back')
			Game = require('main.game')
			STATE.SCROLL_INDEX = 1
			COMPONENTS.SLOTS = [Slot(i) for i = 1, STATE.NUM_SLOTS]
			scrollbar = SKIN\GetMeter('Scrollbar')
			STATE.SCROLLBAR.START = scrollbar\GetY()
			STATE.SCROLLBAR.MAX_HEIGHT = scrollbar\GetH()
			SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(LOCALIZATION\get('filter_window_all_title', 'Filter')))
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeFilter()" "#ROOTCONFIG#"]')
			COMPONENTS.STATUS\hide()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () ->
	return

sortPropertiesByTitle = (a, b) ->
	return true if a.title\lower() < b.title\lower()
	return false

createPlatformProperties = (games, platforms, inverse) ->
	platformProperties = {}
	for platform in *platforms
		platformGames = 0
		platformID = platform\getPlatformID()
		for game in *games
			if game\getPlatformID() == platformID and game\getPlatformOverride() == nil
				platformGames += 1
		if platformGames > 0
			table.insert(platformProperties, Property({
				title: platform\getName()
				value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(#games - platformGames) else STATE.NUM_GAMES_PATTERN\format(platformGames)
				arguments: {
					platformID: platformID
					:inverse
				}
			}))
	platformOverrides = {}
	for game in *games
		platformOverride = game\getPlatformOverride()
		if platformOverride ~= nil
			if platformOverrides[platformOverride] == nil
				platformOverrides[platformOverride] = {platformID: game\getPlatformID(), numGames: 1}
			else
				platformOverrides[platformOverride].numGames += 1
	for platformOverride, params in pairs(platformOverrides)
		if params.numGames > 0
			table.insert(platformProperties, Property({
				title: platformOverride .. '*'
				value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(#games - params.numGames) else STATE.NUM_GAMES_PATTERN\format(params.numGames)
				arguments: {
					platformID: params.platformID
					platformOverride: platformOverride
					:inverse
				}
			}))
	table.sort(platformProperties, sortPropertiesByTitle)
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_from_platform_inverse', 'Is not on platform X') else LOCALIZATION\get('filter_from_platform', 'Is on platform X')
		value: STATE.NUM_GAMES_PATTERN\format(#games)
		enum: ENUMS.FILTER_TYPES.PLATFORM
		properties: platformProperties
	})

createTagProperties = (games, filterStack, inverse) ->
	tags = {}
	gamesWithTags = 0
	for game in *games
		skinTags = game\getTags()
		platformTags = game\getPlatformTags()
		gamesWithTags += 1 if (#skinTags > 0 or #platformTags > 0)
		combinedTags = {}
		for tag in *skinTags
			combinedTags[tag] = true
		for tag in *platformTags
			combinedTags[tag] = true
		for tag, _ in pairs(combinedTags)
			skip = false
			for f in *filterStack
				if f.filter == ENUMS.FILTER_TYPES.TAG and f.args.tag == tag
					skip = true
					break
			continue if skip
			if tags[tag] == nil
				tags[tag] = 0
			tags[tag] += 1
	return nil, gamesWithTags if gamesWithTags < 1
	tagProperties = {}
	for tag, numGames in pairs(tags)
		if numGames > 0
			table.insert(tagProperties, Property({
				title: tag
				value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(#games - numGames) else STATE.NUM_GAMES_PATTERN\format(numGames)
				arguments: {
					tag: tag
					:inverse
				}
			}))
	return nil, gamesWithTags if #tagProperties < 1
	table.sort(tagProperties, sortPropertiesByTitle)
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_has_tag_inverse', 'Does not have tag X') else LOCALIZATION\get('filter_has_tag', 'Has tag X')
		value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(#games) else STATE.NUM_GAMES_PATTERN\format(gamesWithTags)
		enum: ENUMS.FILTER_TYPES.TAG
		properties: tagProperties
	}), gamesWithTags

createHasNoTagsProperty = (numGamesWithoutTags, numGamesWithTags, inverse) ->
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_has_no_tags_inverse', 'Has one or more tags') else LOCALIZATION\get('filter_has_no_tags', 'Has no tags')
		value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(numGamesWithTags) else STATE.NUM_GAMES_PATTERN\format(numGamesWithoutTags)
		enum: ENUMS.FILTER_TYPES.NO_TAGS
		arguments: {
			state: true
			:inverse
		}
	})

createHiddenProperty = (numHiddenGames, numVisibleGames, inverse) ->
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_is_hidden_inverse', 'Is not hidden') else LOCALIZATION\get('filter_is_hidden', 'Is hidden')
		value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(numVisibleGames) else STATE.NUM_GAMES_PATTERN\format(numHiddenGames)
		enum: ENUMS.FILTER_TYPES.HIDDEN
		arguments: {
			state: true
			:inverse
		}
	})

createRandomProperty = (numGames, inverse) ->
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_random_inverse', 'Remove a random game') else LOCALIZATION\get('filter_random', 'Pick a random game')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.RANDOM_GAME
		arguments: {
			state: true
			:inverse
		}
	})

createNeverPlayedProperty = (games, inverse) ->
	numGames = 0
	for game in *games
		numGames += 1 if game\getHoursPlayed() == 0
	if inverse == true
		numGames = #games - numGames
	return nil if numGames < 1
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_never_played_inverse', 'Has been played') else LOCALIZATION\get('filter_never_played', 'Has never been played')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.NEVER_PLAYED
		arguments: {
			state: true
			:inverse
		}
	})

createHasNotesProperty = (games, inverse) ->
	numGames = 0
	for game in *games
		numGames += 1 if game\getNotes() ~= nil
	if inverse == true
		numGames = #games - numGames
	return nil if numGames < 1
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_has_notes_inverse', 'Does not have notes') else LOCALIZATION\get('filter_has_notes', 'Has notes')
		value: STATE.NUM_GAMES_PATTERN\format(numGames)
		enum: ENUMS.FILTER_TYPES.HAS_NOTES
		arguments: {
			state: true
			:inverse
		}
	})

createUninstalledProperty = (numUninstalledGames, numInstalledGames, inverse) ->
	return Property({
		title: if inverse == true then LOCALIZATION\get('filter_is_uninstalled_inverse', 'Is installed') else LOCALIZATION\get('filter_is_uninstalled', 'Is not installed')
		value: if inverse == true then STATE.NUM_GAMES_PATTERN\format(numInstalledGames) else STATE.NUM_GAMES_PATTERN\format(numUninstalledGames)
		enum: ENUMS.FILTER_TYPES.UNINSTALLED
		arguments: {
			state: true
			:inverse
		}
	})

createClearProperty = () ->
	return Property({
		title: LOCALIZATION\get('filter_clear_filters', 'Clear filters')
		value: ' '
		enum: ENUMS.FILTER_TYPES.NONE
	})

createCancelProperty = () ->
	return Property({
		title: LOCALIZATION\get('button_label_cancel', 'Cancel')
		value: ' '
		action: () =>
			SKIN\Bang('[!DeactivateConfig]')
	})

createProperties = (games, hiddenGames, uninstalledGames, platforms, stack, filterStack, inverse) ->
	properties = {}
	if #hiddenGames > 0
		table.insert(properties, createHiddenProperty(#hiddenGames, #games, inverse))
	if #uninstalledGames > 0
		table.insert(properties, createUninstalledProperty(#uninstalledGames, #games, inverse))
	if #games > 0
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
					skipRandom = true if #games < 2
				when ENUMS.FILTER_TYPES.NEVER_PLAYED
					skipNeverPlayed = true
				when ENUMS.FILTER_TYPES.HAS_NOTES
					skipHasNotes = true
		unless skipPlatforms
			platformsProperty = createPlatformProperties(games, platforms, inverse)
			if platformsProperty
				table.insert(platformsProperty.properties, Property({
					title: STATE.BACK_BUTTON_TITLE
					value: ' '
					properties: properties
				}))
				table.insert(properties, platformsProperty)
		gamesWithTags = 0
		unless skipTags
			tagsProperty, gamesWithTags = createTagProperties(games, filterStack, inverse)
			if tagsProperty
				table.insert(tagsProperty.properties, Property({
					title: STATE.BACK_BUTTON_TITLE
					value: ' '
					properties: properties
				}))
				table.insert(properties, tagsProperty)
		unless skipNoTags
			numGamesWithoutTags = #games - gamesWithTags
			if numGamesWithoutTags > 0
				table.insert(properties, createHasNoTagsProperty(numGamesWithoutTags, gamesWithTags, inverse))
		if not skipRandom and #games > 1
			table.insert(properties, createRandomProperty(#games, inverse))
		unless skipNeverPlayed
			neverPlayedProperty = createNeverPlayedProperty(games, inverse)
			if neverPlayedProperty
				table.insert(properties, neverPlayedProperty)
		unless skipHasNotes
			hasNotesProperty = createHasNotesProperty(games, inverse)
			if hasNotesProperty
				table.insert(properties, hasNotesProperty)
	table.sort(properties, sortPropertiesByTitle)
	table.insert(properties, 1, Property({
		title: LOCALIZATION\get('filter_window_invert_filters', 'Invert filters')
		value: ' '
		action: () =>
			if STATE.PROPERTIES == STATE.DEFAULT_PROPERTIES
				STATE.PROPERTIES = STATE.INVERSE_PROPERTIES
			else
				STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
	}))
	unless stack
		table.insert(properties, createClearProperty())
	table.insert(properties, createCancelProperty())
	return properties

updateScrollbar = () ->
	STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
	if #STATE.PROPERTIES > STATE.NUM_SLOTS
		STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1))
		STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / (#STATE.PROPERTIES - STATE.NUM_SLOTS)
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
				SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(LOCALIZATION\get('filter_window_current_title', 'Filter (current games)')))
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
				platforms = [platform for platform in *platforms when platform\isEnabled()]
				games = io.readJSON('games.json')
				games = [Game(args) for args in *games.games]
				for i = #games, 1, -1
					if not games[i]\isVisible()
						table.insert(hiddenGames, table.remove(games, i))
					elseif not games[i]\isInstalled()
						table.insert(uninstalledGames, table.remove(games, i))
			STATE.DEFAULT_PROPERTIES = createProperties(games, hiddenGames, uninstalledGames, platforms, stack, filterStack, false)
			STATE.INVERSE_PROPERTIES = createProperties(games, hiddenGames, uninstalledGames, platforms, stack, filterStack, true)
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
			SKIN\Bang('[!Show]')
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
