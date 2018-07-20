export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil

export LOCALIZATION = nil

export STATE = {
	PATHS: {
		GAMES: 'games.json'
		BANGS: 'cache\\bangs.txt'
		NOTES: 'cache\\notes.txt'
	}
	SCROLLBAR: {
		START: nil
		MAX_HEIGHT: nil
		HEIGHT: nil
		STEP: nil
	}
	GAME: nil
	ALL_GAMES: nil
	GAMES_VERSION: nil
	ALL_TAGS: nil
	ALL_PLATFORMS: nil
	HIGHLIGHTED_SLOT_INDEX: 0
	CENTERED: false
	ACTIVE_INPUT: false
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
		@action = args.action
		@update = args.update

class Slot
	new: (index, maxValueStringLength) =>
		@index = index
		@maxValueStringLength = maxValueStringLength

	populate: (property) =>
		@property = property
		@update()

	update: () =>
		if @property ~= nil
			@property.value = @property\update() if @property.update ~= nil
			SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index,
				utility.replaceUnsupportedChars(@property.title)))
			value = utility.replaceUnsupportedChars(@property.value)
			SKIN\Bang(('[!SetOption "Slot%dValue" "Text" "%s"]')\format(@index, value))
			if value\len() > @maxValueStringLength
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipText" "%s"]')\format(@index, value))
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "0"]')\format(@index))
			else
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]')\format(@index))
			return
		SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]')\format(@index))

	hasAction: () => return @property ~= nil and @property.action ~= nil

	action: () =>
		return if @property == nil or @property.action == nil
		@property\action(@index)

Game = nil

export HideStatus = () -> COMPONENTS.STATUS\hide()

additionalEnums = () ->
	ENUMS.TAG_STATES = {
		DISABLED: 1
		ENABLED: 2
		ENABLED_PLATFORM: 3
		MAX: 4
	}

getGamesAndTags = () ->
	games = io.readJSON(STATE.PATHS.GAMES)
	STATE.GAMES_VERSION = games.version
	STATE.TAGS_DICTIONARY = games.tagsDictionary
	STATE.GAMES_UPDATED_TIMESTAMP = games.updated or os.date('*t')
	STATE.ALL_GAMES = [Game(args, STATE.TAGS_DICTIONARY) for args in *games.games]
	STATE.ALL_TAGS = {}
	for key, tag in pairs(STATE.TAGS_DICTIONARY)
		STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED

export Initialize = () ->
	SKIN\Bang('[!Hide]')
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(() ->
		require('shared.enums')
		additionalEnums()
		utility = require('shared.utility')
		utility.createJSONHelpers()
		COMPONENTS.SETTINGS = require('shared.settings')()
		export log = if COMPONENTS.SETTINGS\getLogging() == true then (...) -> print(...) else () -> return
		log('Initializing Game config')
		export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
		Game = require('main.game')
		STATE.ALL_PLATFORMS = [Platform(COMPONENTS.SETTINGS) for Platform in *require('main.platforms')]
		getGamesAndTags()
		STATE.NUM_SLOTS = 4
		STATE.SCROLL_INDEX = 1
		valueMeter = SKIN\GetMeter('Slot1Value')
		maxValueStringLength = math.round(valueMeter\GetW() / valueMeter\GetOption('FontSize'))
		COMPONENTS.SLOTS = [Slot(i, maxValueStringLength) for i = 1, STATE.NUM_SLOTS]
		scrollbar = SKIN\GetMeter('Scrollbar')
		STATE.SCROLLBAR.START = scrollbar\GetY()
		STATE.SCROLLBAR.MAX_HEIGHT = scrollbar\GetH()
		STATE.SUPPORTED_BANNER_EXTENSIONS = STATE.ALL_PLATFORMS[1]\getBannerExtensions()
		SKIN\Bang(('[!SetOption "SaveButton" "Text" "%s"]')\format(
			LOCALIZATION\get('button_label_save','Save')))
		SKIN\Bang(('[!SetOption "CancelButton" "Text" "%s"]')\format(
			LOCALIZATION\get('button_label_cancel', 'Cancel')))
		SKIN\Bang('[!CommandMeasure "Script" "HandshakeGame()" "#ROOTCONFIG#"]')
		COMPONENTS.STATUS\hide()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () -> return

updateTitle = (game, maxStringLength) ->
	title = utility.replaceUnsupportedChars(game\getTitle())
	SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(title))
	if title\len() > maxStringLength
		SKIN\Bang(('[!SetOption "PageTitle" "ToolTipText" "%s"]')\format(title))
		SKIN\Bang('[!SetOption "PageTitle" "ToolTipHidden" "0"]')
	else
		SKIN\Bang('[!SetOption "PageTitle" "ToolTipHidden" "1"]')

updateBanner = (game) ->
	path = game\getBanner()
	unless path
		SKIN\Bang('[!SetOption "Banner" "ImageName" "#@#game\\gfx\\blank.png"]')
		SKIN\Bang(('[!SetOption "BannerMissing" "Text" "%s"]')\format(LOCALIZATION\get('game_no_banner',
			'No banner')))
		expectedBanner = game\getExpectedBanner()
		if expectedBanner
			extensions = table.concat(STATE.SUPPORTED_BANNER_EXTENSIONS, '|')\gsub('%.', '')
			tooltip = switch game\getPlatformID()
				when ENUMS.PLATFORM_IDS.SHORTCUTS
					platformOverride = game\getPlatformOverride()
					if platformOverride ~= nil
						('\\@Resources\\Shortcuts\\%s\\%s.%s')\format(platformOverride, expectedBanner,
							extensions)
					else
						('\\@Resources\\Shortcuts\\%s.%s')\format(expectedBanner, extensions)
				when ENUMS.PLATFORM_IDS.STEAM
					if game\getPlatformOverride()
						('\\@Resources\\cache\\steam_shortcuts\\%s.%s')\format(expectedBanner, extensions)
					else
						('\\@Resources\\cache\\steam\\%s.%s')\format(expectedBanner, extensions)
				when ENUMS.PLATFORM_IDS.BATTLENET
					('\\@Resources\\cache\\battlenet\\%s.%s')\format(expectedBanner, extensions)
				when ENUMS.PLATFORM_IDS.GOG_GALAXY
					('\\@Resources\\cache\\gog_galaxy\\%s.%s')\format(expectedBanner, extensions)
				when ENUMS.PLATFORM_IDS.CUSTOM
					('\\@Resources\\cache\\custom\\%s.%s')\format(expectedBanner, extensions)
			SKIN\Bang(('[!SetOption "BannerMissing" "ToolTipText" "%s"]')\format(tooltip))
			SKIN\Bang('[!SetOption "BannerMissing" "ToolTipHidden" "0"]')
			return
	SKIN\Bang(('[!SetOption "Banner" "ImageName" "#@#%s"]')\format(path))
	SKIN\Bang('[!SetOption "BannerMissing" "Text" ""]')
	SKIN\Bang('[!SetOption "BannerMissing" "ToolTipHidden" "1"]')

updateScrollbar = () ->
	STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
	div = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
	div = 1 if div < 1
	STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / div)
	div = (#STATE.PROPERTIES - STATE.NUM_SLOTS)
	div = 1 if div < 1
	STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / div
	SKIN\Bang(('[!SetOption "Scrollbar" "H" "%d"]')\format(STATE.SCROLLBAR.HEIGHT))
	y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
	SKIN\Bang(('[!SetOption "Scrollbar" "Y" "%d"]')\format(math.round(y)))

updateSlots = () ->
	for i, slot in ipairs(COMPONENTS.SLOTS)
		slot\populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
		if i == STATE.HIGHLIGHTED_SLOT_INDEX
			if slot\hasAction()
				MouseOver(i)
			else
				MouseLeave(i)

sortPropertiesByTitle = (a, b) -> return a.title\lower() < b.title\lower()

createTagProperty = (tag, state) ->
	f = () ->
		switch STATE.GAME_TAGS[tag]
			when ENUMS.TAG_STATES.DISABLED
				return LOCALIZATION\get('button_label_disabled', 'Disabled')
			when ENUMS.TAG_STATES.ENABLED
				return LOCALIZATION\get('button_label_enabled', 'Enabled')
			when ENUMS.TAG_STATES.ENABLED_PLATFORM
				return LOCALIZATION\get('button_label_enabled', 'Enabled') .. '*'
	if state == ENUMS.TAG_STATES.ENABLED_PLATFORM
		return Property({
					title: tag
					value: f()
					update: f
				})
	else
		return Property({
					title: tag
					value: f()
					action: (index) =>
						old = STATE.GAME_TAGS[tag]
						STATE.GAME_TAGS[tag] = switch STATE.GAME_TAGS[tag]
							when ENUMS.TAG_STATES.DISABLED then ENUMS.TAG_STATES.ENABLED
							when ENUMS.TAG_STATES.ENABLED then ENUMS.TAG_STATES.DISABLED
							else STATE.GAME_TAGS[tag]
					update: f
				})

createTagProperties = () ->
	properties = {}
	for tag, state in pairs(STATE.GAME_TAGS)
		table.insert(properties, createTagProperty(tag, state))
	table.sort(properties, sortPropertiesByTitle)
	table.insert(properties, 1,
		Property({
			title: LOCALIZATION\get('game_tag_create', 'Create a new tag')
			value: ''
			action: (index) => StartCreatingTag(index)
		})
	)
	return properties

createPlatformProperty = (game, platform) ->	
	get = () ->
		platformOverride = game\getPlatformOverride()
		return if platformOverride ~= nil then platformOverride .. '*' else platform\getName()
	action = switch platform\getPlatformID()
		when ENUMS.PLATFORM_IDS.CUSTOM then (index) => StartEditingPlatformOverride(index)
		else nil
	return Property({
		title: LOCALIZATION\get('game_platform', 'Platform')
		value: get()
		update: get
		:action
	})

createHoursPlayedProperty = (game) ->
	f = () => return ('%.0f')\format(game\getHoursPlayed())
	return Property({
		title: LOCALIZATION\get('button_label_hours_played', 'Hours played')
		value: f()
		action: (index) => StartEditingHoursPlayed(index)
		update: f
	})

createLastPlayedProperty = (game) ->
	f = () =>
		lastPlayed = game\getLastPlayed()
		if lastPlayed > 315532800
			date = os.date('*t', lastPlayed)
			return ('%04.f-%02.f-%02.f %02.f:%02.f:%02.f')\format(
				date.year, date.month, date.day,
				date.hour, date.min, date.sec
			)
		return LOCALIZATION\get('game_last_played_never', 'Never')
	return Property({
		title: LOCALIZATION\get('game_last_played', 'Last played')
		value: f()
	})

createInstalledProperty = (game) ->
	-- Installed
	f = () =>
		if game\isInstalled()
			return LOCALIZATION\get('button_label_yes', 'Yes')
		return LOCALIZATION\get('button_label_no', 'No')
	action = if game\getPlatformID() ~= ENUMS.PLATFORM_IDS.CUSTOM then nil else () =>
		game\setInstalled(not game\isInstalled())
	return Property({
		title: LOCALIZATION\get('game_installed', 'Installed')
		value: f()
		update: f
		:action
	})

createVisibleProperty = (game) ->
	f = () =>
		if game\isVisible()
			return LOCALIZATION\get('button_label_yes', 'Yes')
		return LOCALIZATION\get('button_label_no', 'No')
	return Property({
		title: LOCALIZATION\get('game_visible', 'Visible')
		value: f()
		action: (index) =>
			STATE.GAME\toggleVisibility()
		update: f
	})

createPathProperty = (game) ->
	action = nil
	if game\getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM
		action = (index) => StartEditingPath(index)
	else
		path = game\getPath()\match('"(.-)"')
		if path ~= nil and io.fileExists(path, false)
			head, tail = io.splitPath(path)
			if head ~= nil
				action = (index) => SKIN\Bang(('["%s"]')\format(head))
	get = () => ('""%s""')\format(game\getPath())
	return Property({
		title: LOCALIZATION\get('game_path', 'Path')
		value: get()
		update: get
		:action
	})

createProcessProperty = (game) ->
	f = () =>
		processOverride = game\getProcessOverride()
		if processOverride ~= nil and processOverride ~= ''
			return processOverride .. '*'
		process = game\getProcess(true)
		if process ~= nil and process ~= ''
			return process 
		return LOCALIZATION\get('game_process_none', 'None')
	return Property({
		title: LOCALIZATION\get('game_process', 'Process')
		value: f()
		action: (index) =>
			StartEditingProcessOverride(index)
		update: f
	})

createNotesProperty = (game) ->
	f = () =>
		notes = game\getNotes()
		if notes ~= nil and notes\len() > 0
			lines = notes\splitIntoLines()
			line = lines[1]
			line ..= '...' if #lines > 1
			return line
		return LOCALIZATION\get('game_notes_none', 'None')
	return Property({
		title: LOCALIZATION\get('game_notes', 'Notes')
		value: f()
		action: (index) =>
			StartEditingNotes()
		update: f
	})

createTagsProperty = (game) ->
	sourcePlatform = ENUMS.TAG_SOURCES.PLATFORM
	f = () =>
		gameTags, n = game\getTags()
		if n > 0
			tags = [{tag: tag, fromPlatform: source == sourcePlatform} for tag, source in pairs(gameTags)]
			table.sort(tags, (a, b) -> return a.tag < b.tag)
			str = ''
			for entry in *tags
				str ..= ' | ' .. entry.tag
				str ..= '*' if entry.fromPlatform
			return str\sub(4) if str ~= ''
		return LOCALIZATION\get('game_tags_none', 'None')
	sourceSkin = ENUMS.TAG_SOURCES.SKIN
	enabledSkin = ENUMS.TAG_STATES.ENABLED
	enabledPlatform = ENUMS.TAG_STATES.ENABLED_PLATFORM
	return Property({
		title: LOCALIZATION\get('game_tags', 'Tags')
		value: f()
		action: (index) =>
			gameTags, n = game\getTags()
			STATE.GAME_TAGS = {tag, state for tag, state in pairs(STATE.ALL_TAGS)}
			currentGameTags = STATE.GAME_TAGS
			for tag, source in pairs(gameTags)
				currentGameTags[tag] = if source == sourceSkin then enabledSkin else enabledPlatform
			SKIN\Bang(('[!SetOption "SaveButton" "Text" "%s"]')\format(
				LOCALIZATION\get('button_label_accept', 'Accept')))
			STATE.TAG_PROPERTIES = createTagProperties()
			STATE.PROPERTIES = STATE.TAG_PROPERTIES
			STATE.PREVIOUS_SCROLL_INDEX = STATE.SCROLL_INDEX
			STATE.SCROLL_INDEX = 1
			updateScrollbar()
			updateSlots()
		update: f
	})

createIgnoresOtherBangsProperty = (game) ->
	f = () =>
		if game\getIgnoresOtherBangs()
			return LOCALIZATION\get('button_label_yes', 'Yes')
		return LOCALIZATION\get('button_label_no', 'No')
	return Property({
		title: LOCALIZATION\get('game_ignores_other_bangs', 'Ignores other bangs')
		value: f()
		action: (index) =>
			STATE.GAME\toggleIgnoresOtherBangs()
		update: f
	})

createStartingBangsProperty = (game) ->
	f = () =>
		bangs = game\getStartingBangs()
		if bangs and #bangs > 0
			bangs = table.concat(bangs, ' | ')
			if bangs ~= ''
				return (bangs\gsub('\"', '\'\''))
		return LOCALIZATION\get('button_label_bangs_none', 'None')
	return Property({
		title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
		value: f()
		action: (index) =>
			StartEditingStartingBangs()
		update: f
	})

createStoppingBangsProperty = (game) ->
	f = () =>
		bangs = game\getStoppingBangs()
		if bangs and #bangs > 0
			bangs = table.concat(bangs, ' | ')
			if bangs ~= ''
				return (bangs\gsub('\"', '\'\''))
		return LOCALIZATION\get('button_label_bangs_none', 'None')
	return Property({
		title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
		value: f()
		action: (index) =>
			StartEditingStoppingBangs()
		update: f
	})

createBannerReacquisitionProperty = (game, platform) ->
	title = LOCALIZATION\get('button_label_update_banner', 'Update banner')
	value = LOCALIZATION\get('button_label_detect_download', 'Detect/download')
	action = () =>
		path = game\getBanner()
		exists = if path == nil then false else io.fileExists(path)
		unless path ~= nil and exists
			if path == nil
				expectedBanner = game\getExpectedBanner()
				if expectedBanner == nil
					return
				path = switch game\getPlatformID()
					when ENUMS.PLATFORM_IDS.SHORTCUTS
						platformOverride = game\getPlatformOverride()
						if platformOverride ~= nil
							('Shortcuts\\%s\\%s')\format(platformOverride, expectedBanner)
						else
							('Shortcuts\\%s')\format(expectedBanner)
					when ENUMS.PLATFORM_IDS.STEAM
						if game\getPlatformOverride()
							('cache\\steam_shortcuts\\%s')\format(expectedBanner)
				path = io.joinPaths(platform\getCachePath(), expectedBanner) if path == nil
			else
				path = path\reverse()\match('^[^%.]+%.(.-)')\reverse()
			for extension in *STATE.SUPPORTED_BANNER_EXTENSIONS
				newPath = ('%s%s')\format(path, extension)
				if io.fileExists(newPath)
					game\setBanner(newPath)
					updateBanner(game)
					return
		switch game\getPlatformID()
			when ENUMS.PLATFORM_IDS.STEAM, ENUMS.PLATFORM_IDS.GOG_GALAXY
				if game\getPlatformOverride() == nil
					SKIN\Bang(('[!CommandMeasure "Script" "ReacquireBanner(%d)" "#ROOTCONFIG#"]')\format(
						game\getGameID()))
					return
		unless exists
			game\setBanner(nil)
			updateBanner(game)
	return Property({
		:title
		:value
		:action
	})

createOpenStorePageProperty = (game) ->
	value = LOCALIZATION\get('button_label_platform_not_supported', 'Platform not supported')
	action = nil
	switch game\getPlatformID()
		when ENUMS.PLATFORM_IDS.STEAM, ENUMS.PLATFORM_IDS.GOG_GALAXY
			if game\getPlatformOverride() == nil
				value = LOCALIZATION\get('button_label_platform_supported', 'Platform supported')
				action = () ->
					SKIN\Bang(('[!CommandMeasure "Script" "OpenStorePage(%d)" "#ROOTCONFIG#"]')\format(
						game\getGameID()))
					SKIN\Bang('[!DeactivateConfig]')
	return Property({
		title: LOCALIZATION\get('button_label_open_store_page', 'Open store page')
		:value
		:action
		update: nil
	})

createProperties = (game, platform) ->
	return {
		createPlatformProperty(game, platform)
		createHoursPlayedProperty(game)
		createLastPlayedProperty(game)
		createInstalledProperty(game)
		createVisibleProperty(game)
		createPathProperty(game)
		createProcessProperty(game)
		createNotesProperty(game)
		createTagsProperty(game)
		createIgnoresOtherBangsProperty(game)
		createStartingBangsProperty(game)
		createStoppingBangsProperty(game)
		createBannerReacquisitionProperty(game, platform)
		createOpenStorePageProperty(game)
	}

centerConfig = () ->
	return if STATE.CENTERED == true
	STATE.CENTERED = true
	return if not COMPONENTS.SETTINGS\getCenterOnMonitor()
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

getPlatform = (game) ->
	platformID = game\getPlatformID()
	for p in *STATE.ALL_PLATFORMS
		if p\getPlatformID() == platformID
			return p
	return nil

getGame = (gameID) ->
	game = STATE.ALL_GAMES[gameID]
	if game == nil or game\getGameID() ~= gameID
		for game in *STATE.ALL_GAMES
			if game\getGameID() == gameID
				return game
	return game

export Handshake = (gameID) ->
	success, err = pcall(
		() ->
			log('Accepting Game handshake', gameID)
			game = getGame(gameID)
			assert(game ~= nil, ('Could not find a game with the gameID: %d')\format(gameID))
			STATE.GAME = game
			valueMeter = SKIN\GetMeter('PageTitle')
			maxStringLength = math.round(valueMeter\GetW() / valueMeter\GetOption('FontSize'))
			updateTitle(game, maxStringLength)
			updateBanner(game)
			platform = getPlatform(game)
			assert(platform ~= nil, 'Could not find the game\'s platform.')
			STATE.DEFAULT_PROPERTIES = createProperties(game, platform)
			STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
			updateScrollbar()
			updateSlots()
			centerConfig()
			SKIN\Bang('[!ZPos 1][!Show]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Scroll = (direction) ->
	return unless COMPONENTS.SLOTS ~= nil
	index = STATE.SCROLL_INDEX + direction
	if index < 1
		return
	elseif index > STATE.MAX_SCROLL_INDEX
		return
	STATE.SCROLL_INDEX = index
	updateScrollbar()
	updateSlots()

export MouseOver = (index) ->
	return unless COMPONENTS.SLOTS ~= nil
	STATE.HIGHLIGHTED_SLOT_INDEX = index
	return unless COMPONENTS.SLOTS[index] ~= nil and COMPONENTS.SLOTS[index]\hasAction()
	SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))

export MouseLeave = (index) ->
	return unless COMPONENTS.SLOTS ~= nil
	if index == 0
		STATE.HIGHLIGHTED_SLOT_INDEX = 0
		for i = index, STATE.NUM_SLOTS
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(i))
	else
		SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(index))

export MouseLeftPress = (index) ->
	slots = COMPONENTS.SLOTS
	return unless slots ~= nil and slots[index] ~= nil and slots[index]\hasAction()
	SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]')\format(index))

export ButtonAction = (index) ->
	slots = COMPONENTS.SLOTS
	return unless slots ~= nil and slots[index] ~= nil and slots[index]\hasAction()
	SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))
	slots[index]\action()
	updateSlots()

showDefaultProperties = () ->
	bangs = ('[!SetOption "SaveButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_save', 'Save'))
	bangs ..= ('[!SetOption "CancelButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_cancel',
		'Cancel'))
	SKIN\Bang(bangs)
	STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
	STATE.SCROLL_INDEX = STATE.PREVIOUS_SCROLL_INDEX
	STATE.PREVIOUS_SCROLL_INDEX = 1
	updateScrollbar()
	updateSlots()

export Save = () ->
	success, err = pcall(() ->
		return if STATE.ACTIVE_INPUT == true
		switch STATE.PROPERTIES
			when STATE.DEFAULT_PROPERTIES
				io.writeJSON(STATE.PATHS.GAMES, {
					version: STATE.GAMES_VERSION
					tagsDictionary: STATE.TAGS_DICTIONARY
					games: STATE.ALL_GAMES
					updated: STATE.GAMES_UPDATED_TIMESTAMP
				})
				gameID = STATE.GAME\getGameID()
				bangs = ('[!CommandMeasure "Script" "UpdateGame(%d)" "#ROOTCONFIG#"]')\format(gameID)
				bangs ..= '[!DeactivateConfig]'
				SKIN\Bang(bangs)
			when STATE.TAG_PROPERTIES
				tags = {}
				sourceSkin = ENUMS.TAG_SOURCES.SKIN
				sourcePlatform = ENUMS.TAG_SOURCES.PLATFORM
				enabledSkin = ENUMS.TAG_STATES.ENABLED
				enabledPlatform = ENUMS.TAG_STATES.ENABLED_PLATFORM
				for tag, state in pairs(STATE.GAME_TAGS)
					if state == enabledSkin
						tags[tag] = sourceSkin
					elseif state == enabledPlatform
						tags[tag] = sourcePlatform
				STATE.GAME\setTags(tags)
				showDefaultProperties()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Cancel = () ->
	success, err = pcall(
		() ->
			return if STATE.ACTIVE_INPUT == true
			switch STATE.PROPERTIES
				when STATE.DEFAULT_PROPERTIES
					SKIN\Bang('[!DeactivateConfig]')
				when STATE.TAG_PROPERTIES
					showDefaultProperties()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OpenBanner = () ->
	success, err = pcall(
		() ->
			path = SKIN\GetMeter('Banner')\GetOption('ImageName')
			if path ~= nil and path ~= '' and path\match('@Resources\\game\\gfx\\') == nil
				SKIN\Bang(('"%s"')\format(path))
			else
				game = STATE.GAME
				path = switch game\getPlatformID()
					when ENUMS.PLATFORM_IDS.SHORTCUTS
						platformOverride = game\getPlatformOverride()
						if platformOverride ~= nil
							('Shortcuts\\%s\\')\format(platformOverride)
						else
							'Shortcuts\\'
					when ENUMS.PLATFORM_IDS.STEAM
						if game\getPlatformOverride()
							'cache\\steam_shortcuts\\'
						else
							'cache\\steam\\'
					when ENUMS.PLATFORM_IDS.BATTLENET
						'cache\\battlenet\\'
					when ENUMS.PLATFORM_IDS.GOG_GALAXY
						'cache\\gog_galaxy\\'
					when ENUMS.PLATFORM_IDS.CUSTOM
						'cache\\custom\\'
				SKIN\Bang(('"#@#%s"')\format(path))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnDismissedInput = () ->
	success, err = pcall(
		() ->
			STATE.ACTIVE_INPUT = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

startEditing = (slotIndex, batchIndex, defaultValue) ->
	meter = SKIN\GetMeter(('Slot%dValue')\format(slotIndex))
	SKIN\Bang(('[!SetOption "Input" "X" "%d"]')\format(meter\GetX() - 1))
	SKIN\Bang(('[!SetOption "Input" "Y" "%d"]')\format(meter\GetY() - 1))
	SKIN\Bang(('[!SetOption "Input" "W" "%d"]')\format(meter\GetW()))
	SKIN\Bang(('[!SetOption "Input" "H" "%d"]')\format(20))
	defaultValue = '' if defaultValue == nil
	SKIN\Bang(('[!SetOption "Input" "DefaultValue" "%s"]')\format(defaultValue))
	SKIN\Bang(('[!CommandMeasure "Input" "ExecuteBatch %d"]')\format(batchIndex))
	STATE.ACTIVE_INPUT = true

-- Platform override
export StartEditingPlatformOverride = (index) ->
	success, err = pcall(
		() ->
			startEditing(index, 4, STATE.GAME\getPlatformOverride())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedPlatformOverride = (platform) ->
	success, err = pcall(
		() ->
			STATE.GAME\setPlatformOverride(platform\sub(1, -2))
			updateSlots()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Path
export StartEditingPath = (index) ->
	success, err = pcall(
		() ->
			startEditing(index, 5, STATE.GAME\getPath())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedPath = (path) ->
	success, err = pcall(
		() ->
			STATE.GAME\setPath(path\sub(1, -2))
			updateSlots()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Process override
export StartEditingProcessOverride = (index) ->
	success, err = pcall(
		() ->
			startEditing(index, 1, STATE.GAME\getProcessOverride())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedProcessOverride = (process) ->
	success, err = pcall(
		() ->
			STATE.GAME\setProcessOverride(process\sub(1, -2))
			updateSlots()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Hours played
export StartEditingHoursPlayed = (index) ->
	success, err = pcall(
		() ->
			startEditing(index, 3, STATE.GAME\getHoursPlayed())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedHoursPlayed = (hoursPlayed) ->
	success, err = pcall(
		() ->
			STATE.GAME\setHoursPlayed(tonumber((hoursPlayed\sub(1, -2)\gsub(',', '.'))))
			updateSlots()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Tags
export StartCreatingTag = (index) ->
	success, err = pcall(() -> startEditing(index, 2))
	COMPONENTS.STATUS\show(err, true) unless success

export OnCreatedTag = (tag) ->
	success, err = pcall(
		() ->
			OnDismissedInput()
			tag = tag\sub(1, -2)
			return if STATE.ALL_TAGS[tag] ~= nil
			STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
			STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
			createProperty = table.remove(STATE.TAG_PROPERTIES, 1)
			table.insert(STATE.TAG_PROPERTIES, createTagProperty(tag, STATE.GAME_TAGS[tag]))
			table.sort(STATE.TAG_PROPERTIES, sortPropertiesByTitle)
			table.insert(STATE.TAG_PROPERTIES, 1, createProperty)
			updateScrollbar()
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Starting bangs
export StartEditingStartingBangs = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!ZPos 0]')
			bangs = STATE.GAME\getStartingBangs()
			io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
			utility.runCommand(('""..\\@Resources\\%s""')\format(STATE.PATHS.BANGS), '',
				'OnEditedStartingBangs')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedStartingBangs = () ->
	success, err = pcall(
		() ->
			bangs = io.readFile(STATE.PATHS.BANGS)
			STATE.GAME\setStartingBangs(bangs\splitIntoLines())
			updateSlots()
			SKIN\Bang('[!ZPos 1]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Stopping bangs
export StartEditingStoppingBangs = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!ZPos 0]')
			bangs = STATE.GAME\getStoppingBangs()
			io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
			utility.runCommand(('""..\\@Resources\\%s""')\format(STATE.PATHS.BANGS), '',
				'OnEditedStoppingBangs')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedStoppingBangs = () ->
	success, err = pcall(
		() ->
			bangs = io.readFile(STATE.PATHS.BANGS)
			STATE.GAME\setStoppingBangs(bangs\splitIntoLines())
			updateSlots()
			SKIN\Bang('[!ZPos 1]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ToggleIgnoresOtherBangs = () ->
	success, err = pcall(
		() ->
			STATE.GAME\toggleIgnoresOtherBangs()
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export StartEditingNotes = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!ZPos 0]')
			notes = STATE.GAME\getNotes()
			notes = '' if notes == nil
			io.writeFile(STATE.PATHS.NOTES, notes)
			utility.runCommand(('""..\\@Resources\\%s""')\format(STATE.PATHS.NOTES), '', 'OnEditedNotes')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedNotes = () ->
	success, err = pcall(
		() ->
			notes = io.readFile(STATE.PATHS.NOTES)
			STATE.GAME\setNotes(notes)
			updateSlots()
			SKIN\Bang('[!ZPos 1]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnReacquiredBanner = () ->
	success, err = pcall(
		() ->
			updateBanner(STATE.GAME)
	)
	COMPONENTS.STATUS\show(err, true) unless success
