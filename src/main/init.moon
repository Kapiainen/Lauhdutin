export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

json = nil

Game = nil

export LOCALIZATION = nil

export STATE = {
	-- Always available
	INITIALIZED: false
	PATHS: {
		GAMES: 'games.json'
	}
	ROOT_CONFIG: nil
	SETTINGS: {}
	NUM_SLOTS: 0
	SCROLL_INDEX: 1
	SCROLL_STEP: 1
	SCROLL_INDEX_UPDATED: nil
	LEFT_CLICK_ACTION: 1
	PLATFORM_NAMES: {}
	GAMES: {}
	REVEALING_DELAY: 0
	SKIN_VISIBLE: true
	SKIN_ANIMATION_PLAYING: false
	-- Volatile
	PLATFORM_ENABLED_STATUS: nil
	PLATFORM_QUEUE: nil
	BANNER_QUEUE: nil
	GAME_BEING_MODIFIED: nil
}

export COMPONENTS = {
	ANIMATIONS: nil
	DOWNLOADER: nil
	COMMANDER: nil
	CONTEXT_MENU: nil
	LIBRARY: nil
	PROCESS: nil
	SETTINGS: nil
	SIGNAL: nil
	SLOTS: nil
	STATUS: nil
	TOOLBAR: nil
}

export SIGNALS = {
	DETECTED_SHORTCUT_GAMES: 'detected_shortcut_games'
	UPDATE_PLATFORM_RUNNING_STATUS: 'update_platform_running_status'
	UPDATE_SLOTS: 'update_slots'
}

export log = (...) -> print(...) if STATE.LOGGING == true

export HideStatus = () -> COMPONENTS.STATUS\hide()

export setUpdateDivider = (value) ->
	assert(type(value) == 'number' and value % 1 == 0 and value ~= 0, 'main.init.setUpdateDivider')
	SKIN\Bang(('[!SetOption "Script" "UpdateDivider" "%d"]')\format(value))
	SKIN\Bang('[!UpdateMeasure "Script"]')

startDetectingPlatformGames = () ->
	platform = STATE.PLATFORM_QUEUE[1]
	msg = LOCALIZATION\get('main_status_detecting_platform_games', 'Detecting %s games')
	COMPONENTS.STATUS\show(msg\format(platform\getName()))
	switch platform\getPlatformID()
		when ENUMS.PLATFORM_IDS.SHORTCUTS
			COMPONENTS.SIGNAL\register(SIGNALS.DETECTED_SHORTCUT_GAMES, platform\onParsedShortcuts())
			platform\parseShortcuts()
		when ENUMS.PLATFORM_IDS.STEAM
			url, folder, file = platform\downloadCommunityProfile()
			if url ~= nil
				log('Attempting to download and parse the Steam community profile')
				COMPONENTS.DOWNLOADER\push({
					:url
					outputFile: file
					outputFolder: folder
					finishCallback: (args) ->
						log('Successfully downloaded Steam community profile')
						cachedPath = io.joinPaths(args.folder, args.file)
						profile = ''
						if io.fileExists(cachedPath)
							profile = io.readFile(cachedPath)
						args.platform\parseCommunityProfile(profile)
						args.platform\getLibraries()
						if args.platform\hasLibrariesToParse()
							return args.platform\getACFs()
						OnFinishedDetectingPlatformGames()
					errorCallback: (args) ->
						log('Failed to download Steam community profile')
						args.platform\getLibraries()
						if args.platform\hasLibrariesToParse()
							return args.platform\getACFs()
						OnFinishedDetectingPlatformGames()
					callbackArgs: {
						:file
						:folder
						:platform
					}
				})
				COMPONENTS.DOWNLOADER\start()
			else
				log('Starting to detect Steam games')
				platform\getLibraries()
				if platform\hasLibrariesToParse()
					platform\getACFs()
				else
					OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS
			log('Starting to detect non-Steam game shortcuts added to Steam')
			games = platform\generateGames()
			OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.BATTLENET
			log('Starting to detect Blizzard Battle.net games')
			if platform\hasUnprocessedPaths()
				platform\identifyFolders()
			else
				OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.GOG_GALAXY
			log('Starting to detect GOG Galaxy games')
			unless platform\downloadCommunityProfile()
				platform\dumpDatabases()
		when ENUMS.PLATFORM_IDS.CUSTOM
			log('Starting to detect Custom games')
			platform\detectBanners(COMPONENTS.LIBRARY\getOldGames())
			OnFinishedDetectingPlatformGames()
		else
			assert(nil, 'main.init.startDetectingPlatformGames')

detectPlatforms = () ->
	COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_detecting_platforms', 'Detecting platforms'))
	platforms = [Platform(COMPONENTS.SETTINGS) for Platform in *require('main.platforms')]
	log('Num platforms:', #platforms)
	COMPONENTS.PROCESS\registerPlatforms(platforms)
	STATE.PLATFORM_ENABLED_STATUS = {}
	STATE.PLATFORM_QUEUE = {}
	platformRunningStatus = {}
	for platform in *platforms
		enabled = platform\isEnabled()
		platform\validate() if enabled
		platformID = platform\getPlatformID()
		STATE.PLATFORM_NAMES[platformID] = platform\getName()
		STATE.PLATFORM_ENABLED_STATUS[platformID] = enabled
		platformRunningStatus[platformID] = false if platform\getPlatformProcess() ~= nil
		table.insert(STATE.PLATFORM_QUEUE, platform) if enabled
		log(' ' .. STATE.PLATFORM_NAMES[platformID] .. ' = ' .. tostring(enabled))
	COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_PLATFORM_RUNNING_STATUS, platformRunningStatus)
	assert(#STATE.PLATFORM_QUEUE > 0, 'There are no enabled platforms.')

detectGames = () ->
	COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_detecting_games', 'Detecting games'))
	STATE.BANNER_QUEUE = {}
	startDetectingPlatformGames()

updateSlots = () ->
	if STATE.SCROLL_INDEX < 1
		STATE.SCROLL_INDEX = 1
	elseif STATE.SCROLL_INDEX > #STATE.GAMES - STATE.NUM_SLOTS + 1
		if #STATE.GAMES > STATE.NUM_SLOTS
			STATE.SCROLL_INDEX = #STATE.GAMES - STATE.NUM_SLOTS + 1
		else
			STATE.SCROLL_INDEX = 1
	if COMPONENTS.SLOTS\populate(STATE.GAMES, STATE.SCROLL_INDEX)
		COMPONENTS.ANIMATIONS\resetSlots()
		COMPONENTS.SLOTS\update()
	else
		SKIN\Bang(('[!SetOption "Slot1Text" "Text" "%s"]')\format(LOCALIZATION\get('main_no_games', 'No games to show')))
		COMPONENTS.ANIMATIONS\resetSlots()
		COMPONENTS.SLOTS\update()

onInitialized = () ->
	COMPONENTS.STATUS\hide()
	COMPONENTS.LIBRARY\finalize(STATE.PLATFORM_ENABLED_STATUS)
	STATE.PLATFORM_ENABLED_STATUS = nil
	COMPONENTS.LIBRARY\save()
	COMPONENTS.LIBRARY\sort(COMPONENTS.SETTINGS\getSorting())
	STATE.GAMES = COMPONENTS.LIBRARY\get()
	updateSlots()
	STATE.INITIALIZED = true
	animationType = COMPONENTS.SETTINGS\getSkinSlideAnimation()
	if animationType ~= ENUMS.SKIN_ANIMATIONS.NONE
		COMPONENTS.ANIMATIONS\pushSkinSlide(animationType, false)
		setUpdateDivider(1)
	log('Skin initialized')

additionalEnums = () ->
	ENUMS.LEFT_CLICK_ACTIONS = {
		LAUNCH_GAME: 1
		HIDE_GAME: 2
		UNHIDE_GAME: 3
		REMOVE_GAME: 4
	}

export Initialize = () ->
	STATE.ROOT_CONFIG = SKIN\GetVariable('ROOTCONFIG')
	dofile(('%s%s')\format(SKIN\GetVariable('@'), 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.string')
			json = require('lib.json')
			require('shared.io')(json)
			require('shared.rainmeter')
			require('shared.enums')
			additionalEnums()
			Game = require('main.game')
			COMPONENTS.DOWNLOADER = require('shared.downloader')()
			COMPONENTS.COMMANDER = require('shared.commander')()
			COMPONENTS.SIGNAL = require('shared.signal')()
			COMPONENTS.SIGNAL\register(SIGNALS.UPDATE_SLOTS, updateSlots)
			COMPONENTS.CONTEXT_MENU = require('main.context_menu')
			COMPONENTS.SETTINGS = require('shared.settings')()
			STATE.LOGGING = COMPONENTS.SETTINGS\getLogging()
			STATE.SCROLL_STEP = COMPONENTS.SETTINGS\getScrollStep()
			log('Initializing skin')
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			COMPONENTS.STATUS\show(LOCALIZATION\get('status_initializing', 'Initializing'))
			SKIN\Bang(('[!SetVariable "ContextTitleSettings" "%s"]')\format(LOCALIZATION\get('main_context_title_settings', 'Settings')))
			SKIN\Bang(('[!SetVariable "ContextTitleOpenShortcutsFolder" "%s"]')\format(LOCALIZATION\get('main_context_title_open_shortcuts_folder', 'Open shortcuts folder')))
			SKIN\Bang(('[!SetVariable "ContextTitleExecuteStoppingBangs" "%s"]')\format(LOCALIZATION\get('main_context_title_execute_stopping_bangs', 'Execute stopping bangs')))
			SKIN\Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_hiding_games', 'Start hiding games')))
			SKIN\Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_unhiding_games', 'Start unhiding games')))
			SKIN\Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_removing_games', 'Start removing games')))
			SKIN\Bang(('[!SetVariable "ContextTitleDetectGames" "%s"]')\format(LOCALIZATION\get('main_context_title_detect_games', 'Detect games')))
			SKIN\Bang(('[!SetVariable "ContextTitleAddGame" "%s"]')\format(LOCALIZATION\get('main_context_title_add_game', 'Add a game')))
			COMPONENTS.TOOLBAR = require('main.toolbar')(COMPONENTS.SETTINGS)
			COMPONENTS.TOOLBAR\hide()
			COMPONENTS.ANIMATIONS = require('main.animations')()
			STATE.NUM_SLOTS = COMPONENTS.SETTINGS\getLayoutRows() * COMPONENTS.SETTINGS\getLayoutColumns()
			COMPONENTS.SLOTS = require('main.slots')(COMPONENTS.SETTINGS)
			COMPONENTS.PROCESS = require('main.process')()
			COMPONENTS.LIBRARY = require('shared.library')(COMPONENTS.SETTINGS)
			detectPlatforms()
			if COMPONENTS.LIBRARY\getDetectGames() == true
				detectGames()
			else
				onInitialized()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			if STATE.SKIN_ANIMATION_PLAYING
				COMPONENTS.ANIMATIONS\play()
			elseif STATE.REVEALING_DELAY >= 0 and not STATE.SKIN_VISIBLE
					STATE.REVEALING_DELAY -= 17
					if STATE.REVEALING_DELAY < 0
						COMPONENTS.ANIMATIONS\pushSkinSlide(COMPONENTS.SETTINGS\getSkinSlideAnimation(), true)
			else
				COMPONENTS.ANIMATIONS\play()
				if STATE.SCROLL_INDEX_UPDATED == false
					updateSlots()
					STATE.SCROLL_INDEX_UPDATED = true
	)
	unless success
		COMPONENTS.STATUS\show(err, true)
		setUpdateDivider(-1)

-- Process monitoring
export UpdateProcess = (running) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.PROCESS\update(running == 1)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export GameProcessTerminated = (game) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			duration = COMPONENTS.PROCESS\getDuration() / 3600
			log(game\getTitle(), 'was played for', duration, 'hours')
			game\incrementHoursPlayed(duration)
			COMPONENTS.LIBRARY\save()
			platformID = game\getPlatformID()
			if COMPONENTS.SETTINGS\getBangsEnabled()
				unless game\getIgnoresOtherBangs()
					SKIN\Bang(bang) for bang in *COMPONENTS.SETTINGS\getGlobalStoppingBangs()
					platformBangs = switch platformID
						when ENUMS.PLATFORM_IDS.SHORTCUTS
							COMPONENTS.SETTINGS\getShortcutsStoppingBangs()
						when ENUMS.PLATFORM_IDS.STEAM, ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS
							COMPONENTS.SETTINGS\getSteamStoppingBangs()
						when ENUMS.PLATFORM_IDS.BATTLENET
							COMPONENTS.SETTINGS\getBattlenetStoppingBangs()
						when ENUMS.PLATFORM_IDS.GOG_GALAXY
							COMPONENTS.SETTINGS\getGOGGalaxyStoppingBangs()
						when ENUMS.PLATFORM_IDS.CUSTOM
							COMPONENTS.SETTINGS\getCustomStoppingBangs()
						else
							assert(nil, 'Encountered an unsupported platform ID when executing platform-specific stopping bangs.')
					SKIN\Bang(bang) for bang in *platformBangs
				SKIN\Bang(bang) for bang in *game\getStoppingBangs()
			switch platformID
				when ENUMS.PLATFORM_IDS.GOG_GALAXY
					if COMPONENTS.SETTINGS\getGOGGalaxyIndirectLaunch()
						SKIN\Bang('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\closeClient.bat"]')
			if COMPONENTS.SETTINGS\getHideSkin()
				SKIN\Bang('[!ShowFade]')
			if COMPONENTS.SETTINGS\getShowSession()
				SKIN\Bang(('[!DeactivateConfig "%s"]')\format(('%s\\Session')\format(STATE.ROOT_CONFIG)))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ManuallyTerminateGameProcess = () ->
	success, err = pcall(
		() ->
			COMPONENTS.PROCESS\stopMonitoring()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Skin events
export Unload = () ->
	success, err = pcall(
		() ->
			log('Unloading skin')
			COMPONENTS.LIBRARY\save()
			COMPONENTS.SETTINGS\save()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMouseOver = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			setUpdateDivider(1)
	)
	COMPONENTS.STATUS\show(err, true) unless success

otherWindowsActive = () ->
	rootConfigName = STATE.ROOT_CONFIG
	configs = RAINMETER\GetConfigs([('%s\\%s')\format(rootConfigName, name) for name in *{'Search', 'Sort', 'Filter', 'Game'}])
	for config in *configs
		if config\isActive()
			return true
	return false

export OnMouseLeave = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.ANIMATIONS\resetSlots()
			animationType = COMPONENTS.SETTINGS\getSkinSlideAnimation()
			if STATE.SKIN_VISIBLE and animationType ~= ENUMS.SKIN_ANIMATIONS.NONE and not otherWindowsActive()
				if COMPONENTS.ANIMATIONS\pushSkinSlide(animationType, false)
					return
			setUpdateDivider(-1)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMouseLeaveEnabler = () ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_VISIBLE
	success, err = pcall(
		() ->
			STATE.REVEALING_DELAY = COMPONENTS.SETTINGS\getSkinRevealingDelay()
			setUpdateDivider(-1)
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Toolbar
export OnMouseOverToolbar = () ->
	return unless STATE.INITIALIZED
	return unless STATE.SKIN_VISIBLE
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			COMPONENTS.TOOLBAR\show()
			COMPONENTS.SLOTS\unfocus()
			COMPONENTS.SLOTS\leave()
			COMPONENTS.ANIMATIONS\resetSlots()
			COMPONENTS.ANIMATIONS\cancelAnimations()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMouseLeaveToolbar = () ->
	return unless STATE.INITIALIZED
	return unless STATE.SKIN_VISIBLE
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			COMPONENTS.TOOLBAR\hide()
			COMPONENTS.SLOTS\focus()
			COMPONENTS.SLOTS\hover()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Toolbar -> Searching
export OnToolbarSearch = (stack) ->
	return unless STATE.INITIALIZED
	STATE.STACK_NEXT_FILTER = stack
	log('OnToolbarSearch', stack)
	SKIN\Bang('[!ActivateConfig "#ROOTCONFIG#\\Search"]')

export HandshakeSearch = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%s)" "#ROOTCONFIG#\\Search"]')\format(tostring(STATE.STACK_NEXT_FILTER)))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Search = (str, stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Searching for:', str)
			games = if stack then STATE.GAMES else nil
			COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.TITLE, {input: str, :games, :stack})
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarResetGames = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Toolbar -> Sorting
export OnToolbarSort = (quick) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarSort')
			if quick
				sortingType = COMPONENTS.SETTINGS\getSorting() + 1
				sortingType = 1 if sortingType >= ENUMS.SORTING_TYPES.MAX
				return Sort(sortingType)
			configName = ('%s\\Sort')\format(STATE.ROOT_CONFIG)
			config = RAINMETER\GetConfig(configName)
			if config ~= nil and config\isActive()
				return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			SKIN\Bang(('[!ActivateConfig "%s"]')\format(configName))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarReverseOrder = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Reversing order of games')
			table.reverse(STATE.GAMES)
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export HandshakeSort = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Sort"]')\format(COMPONENTS.SETTINGS\getSorting()))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Sort = (sortingType) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.SETTINGS\setSorting(sortingType)
			COMPONENTS.LIBRARY\sort(sortingType, STATE.GAMES)
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Toolbar -> Filtering
export OnToolbarFilter = (stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			STATE.STACK_NEXT_FILTER = stack
			configName = ('%s\\Filter')\format(STATE.ROOT_CONFIG)
			config = RAINMETER\GetConfig(configName)
			if config ~= nil and config\isActive()
				return HandshakeFilter()
			SKIN\Bang(('[!ActivateConfig "%s"]')\format(configName))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export HandshakeFilter = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			stack = tostring(STATE.STACK_NEXT_FILTER)
			appliedFilters = '[]'
			if STATE.STACK_NEXT_FILTER
				appliedFilters = json.encode(COMPONENTS.LIBRARY\getFilterStack())\gsub('"', '|')
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%s, \'%s\')" "#ROOTCONFIG#\\Filter"]')\format(stack, appliedFilters))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Filter = (filterType, stack, arguments) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Filter', filterType, type(filterType), stack, type(stack), arguments)
			arguments = arguments\gsub('|', '"')
			arguments = json.decode(arguments)
			arguments.games = if stack then STATE.GAMES else nil
			arguments.stack = stack
			COMPONENTS.LIBRARY\filter(filterType, arguments)
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Slots
launchGame = (game) ->
	game\setLastPlayed(os.time())
	COMPONENTS.LIBRARY\sort(COMPONENTS.SETTINGS\getSorting())
	COMPONENTS.LIBRARY\save()
	STATE.GAMES = COMPONENTS.LIBRARY\get()
	STATE.SCROLL_INDEX = 1
	updateSlots()
	COMPONENTS.PROCESS\monitor(game)
	if COMPONENTS.SETTINGS\getBangsEnabled()
		unless game\getIgnoresOtherBangs()
			SKIN\Bang(bang) for bang in *COMPONENTS.SETTINGS\getGlobalStartingBangs()
			platformBangs = switch game\getPlatformID()
				when ENUMS.PLATFORM_IDS.SHORTCUTS
					COMPONENTS.SETTINGS\getShortcutsStartingBangs()
				when ENUMS.PLATFORM_IDS.STEAM, ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS
					COMPONENTS.SETTINGS\getSteamStartingBangs()
				when ENUMS.PLATFORM_IDS.BATTLENET
					COMPONENTS.SETTINGS\getBattlenetStartingBangs()
				when ENUMS.PLATFORM_IDS.GOG_GALAXY
					COMPONENTS.SETTINGS\getGOGGalaxyStartingBangs()
				when ENUMS.PLATFORM_IDS.CUSTOM
					COMPONENTS.SETTINGS\getCustomStartingBangs()
				else
					assert(nil, 'Encountered an unsupported platform ID when executing platform-specific starting bangs.')
			SKIN\Bang(bang) for bang in *platformBangs
		SKIN\Bang(bang) for bang in *game\getStartingBangs()
	SKIN\Bang(('[%s]')\format(game\getPath()))
	if COMPONENTS.SETTINGS\getHideSkin()
		SKIN\Bang('[!HideFade]')
	if COMPONENTS.SETTINGS\getShowSession()
		SKIN\Bang(('[!ActivateConfig "%s"]')\format(('%s\\Session')\format(STATE.ROOT_CONFIG)))

installGame = (game) ->
	game\setLastPlayed(os.time())
	game\setInstalled(true)
	COMPONENTS.LIBRARY\sort(COMPONENTS.SETTINGS\getSorting())
	COMPONENTS.LIBRARY\save()
	STATE.GAMES = COMPONENTS.LIBRARY\get()
	STATE.SCROLL_INDEX = 1
	updateSlots()
	SKIN\Bang(('[%s]')\format(game\getPath()))

hideGame = (game) ->
	return if game\isVisible() == false
	game\setVisible(false)
	COMPONENTS.LIBRARY\save()
	i = table.find(STATE.GAMES, game)
	table.remove(STATE.GAMES, i) if i ~= nil
	if #STATE.GAMES == 0
		COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.NONE)
		STATE.GAMES = COMPONENTS.LIBRARY\get()
		STATE.SCROLL_INDEX = 1
		ToggleHideGames()
	updateSlots()

unhideGame = (game) ->
	return if game\isVisible() == true
	game\setVisible(true)
	COMPONENTS.LIBRARY\save()
	i = table.find(STATE.GAMES, game)
	table.remove(STATE.GAMES, i) if i ~= nil
	if #STATE.GAMES == 0
		COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.NONE)
		STATE.GAMES = COMPONENTS.LIBRARY\get()
		STATE.SCROLL_INDEX = 1
		ToggleUnhideGames()
	updateSlots()

removeGame = (game) ->
	COMPONENTS.LIBRARY\remove(game)
	i = table.find(STATE.GAMES, game)
	table.remove(STATE.GAMES, i) if i ~= nil
	if #STATE.GAMES == 0
		COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.NONE)
		STATE.GAMES = COMPONENTS.LIBRARY\get()
		STATE.SCROLL_INDEX = 1
		ToggleRemoveGames()
	updateSlots()

export OnLeftClickSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			game = COMPONENTS.SLOTS\leftClick(index)
			return unless game
			action = switch STATE.LEFT_CLICK_ACTION
				when ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
					result = nil
					if game\isInstalled() == true
						result = launchGame
					else
						platformID = game\getPlatformID()
						if platformID == ENUMS.PLATFORM_IDS.STEAM and game\getPlatformOverride() == nil
							result = installGame
					result
				when ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME then hideGame
				when ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME then unhideGame
				when ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME then removeGame
				else
					assert(nil, 'main.init.OnLeftClickSlot')
			return unless action
			animationType = COMPONENTS.SETTINGS\getSlotsClickAnimation()
			unless COMPONENTS.ANIMATIONS\pushSlotClick(index, animationType, action, game)
				action(game)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMiddleClickSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			log('OnMiddleClickSlot', index)
			game = COMPONENTS.SLOTS\middleClick(index)
			return if game == nil
			configName = ('%s\\Game')\format(STATE.ROOT_CONFIG)
			config = RAINMETER\GetConfig(configName)
			if STATE.GAME_BEING_MODIFIED == game and config\isActive()
				STATE.GAME_BEING_MODIFIED = nil
				return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			STATE.GAME_BEING_MODIFIED = game
			if config == nil or not config\isActive()
				SKIN\Bang(('[!ActivateConfig "%s"]')\format(configName))
			else
				HandshakeGame()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export HandshakeGame = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('HandshakeGame')
			gameID = STATE.GAME_BEING_MODIFIED\getGameID()
			assert(gameID ~= nil, 'main.init.HandshakeGame')
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Game"]')\format(gameID))
	)
	COMPONENTS.STATUS\show(err, true) unless success

getGameByID = (gameID) ->
	assert(type(gameID) == 'number' and gameID % 1 == 0, 'main.init.getGameByID')
	games = io.readJSON(STATE.PATHS.GAMES)
	games = games.games
	game = games[gameID] -- gameID should also be the index of the game since the games table in games.json should be sorted according to the gameIDs.
	if game == nil or game.gameID ~= gameID -- Backup approach in case we didn't find the right game.
		game = nil
		for args in *games
			if args.gameID == gameID
				game = args
				break
	if game == nil
		log('Failed to get game by gameID:', gameID)
		return nil
	return Game(game)

export UpdateGame = (gameID) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('UpdateGame', gameID)
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.UpdateGame')
			COMPONENTS.LIBRARY\update(game)
			STATE.SCROLL_INDEX_UPDATED = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnHoverSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			COMPONENTS.SLOTS\hover(index)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnLeaveSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			COMPONENTS.SLOTS\leave(index)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnScrollSlots = (direction) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			index = STATE.SCROLL_INDEX + direction * STATE.SCROLL_STEP
			if index < 1
				return
			elseif index > #STATE.GAMES - STATE.NUM_SLOTS + 1
				return
			STATE.SCROLL_INDEX = index
			log(('Scroll index is now %d')\format(STATE.SCROLL_INDEX))
			STATE.SCROLL_INDEX_UPDATED = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Game detection
export OnFinishedDetectingPlatformGames = () ->
	success, err = pcall(
		() ->
			log('Finished detecting platform\'s games')
			platform = table.remove(STATE.PLATFORM_QUEUE, 1)
			games = platform\getGames()
			log(('Found %d %s games')\format(#games, platform\getName()))
			COMPONENTS.LIBRARY\extend(games)
			for game in *games
				if game\getBannerURL() ~= nil
					path = game\getBanner()
					if path == nil
						game\setBannerURL(nil)
					elseif not io.fileExists((path\gsub('%..+', '%.failedToDownload')))
						table.insert(STATE.BANNER_QUEUE, game)
			if #STATE.PLATFORM_QUEUE > 0
				return startDetectingPlatformGames()
			STATE.PLATFORM_QUEUE = nil
			log(('%d banners to download')\format(#STATE.BANNER_QUEUE))
			if #STATE.BANNER_QUEUE > 0
				finishCallback = (args) ->
					COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_n_banners_to_download', '%d banners left to download')\format(args.bannersLeft))
					args.game\setBannerURL(nil)
					args.game\setExpectedBanner(nil)
				finalFinishCallback = (args) ->
					finishCallback(args)
					onInitialized() -- TODO: Emit
				errorCallback = (args) ->
					file = args.file\reverse()\match('^[^%.]+%.([^\\]+)')\reverse()
					io.writeFile(io.joinPaths(args.folder, file .. '.failedToDownload'), '')
					args.game\setBanner(nil)
					args.game\setBannerURL(nil)
				for i, game in ipairs(STATE.BANNER_QUEUE)
					folder, file = io.splitPath(game\getBanner())
					COMPONENTS.DOWNLOADER\push({
						url: game\getBannerURL()
						outputFile: file
						outputFolder: folder
						finishCallback: if i > 1 then finishCallback else finalFinishCallback
						:errorCallback
						callbackArgs: {
							:file
							:folder
							:game
							bannersLeft: i
						}
					})
				return if COMPONENTS.DOWNLOADER\start()
			onInitialized()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Game detection -> Steam
export OnGotACFs = () ->
	success, err = pcall(
		() ->
			log('Dumped list of Steam appmanifests')
			STATE.PLATFORM_QUEUE[1]\generateGames()
			if STATE.PLATFORM_QUEUE[1]\hasLibrariesToParse()
				return STATE.PLATFORM_QUEUE[1]\getACFs()
			STATE.PLATFORM_QUEUE[1]\generateShortcuts()
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Game detection -> Blizzard Battle.Net
export OnIdentifiedBattlenetFolders = () ->
	success, err = pcall(
		() ->
			log('Dumped list of folders in a Blizzard Battle.net folder')
			STATE.PLATFORM_QUEUE[1]\generateGames(io.readFile(io.joinPaths(STATE.PLATFORM_QUEUE[1]\getCachePath(), 'output.txt')))
			if STATE.PLATFORM_QUEUE[1]\hasUnprocessedPaths()
				return STATE.PLATFORM_QUEUE[1]\identifyFolders()
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Game detection -> GOG Galaxy
export OnDownloadedGOGCommunityProfile = () ->
	success, err = pcall(
		() ->
			log('Downloaded GOG community profile')
			STATE.PLATFORM_QUEUE[1]\dumpDatabases()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnDumpedDBs = () ->
	success, err = pcall(
		() ->
			log('Dumped GOG Galaxy databases')
			cachePath = STATE.PLATFORM_QUEUE[1]\getCachePath()
			index = io.readFile(io.joinPaths(cachePath, 'index.txt'))
			galaxyPath = io.joinPaths(cachePath, 'galaxy.txt')
			galaxy = io.readFile(galaxyPath)
			newGalaxy = {}
			wholeLine = {}
			lines = galaxy\splitIntoLines()
			for line in *lines
				if line\match('^%d+|[^|]+|[^|]+|.+$')
					table.insert(newGalaxy, table.concat(wholeLine, ''))
					wholeLine = {}
				table.insert(wholeLine, line)
			if #wholeLine > 0
				table.insert(newGalaxy, table.concat(wholeLine, ''))
			galaxy = table.concat(newGalaxy, '\n')
			io.writeFile(galaxyPath, galaxy)
			profilePath = io.joinPaths(cachePath, 'profile.txt')
			profile = if io.fileExists(profilePath) then io.readFile(profilePath) else nil
			STATE.PLATFORM_QUEUE[1]\generateGames(index, galaxy, profile)
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success

getPlatformByGame = (game) ->
	platforms = [Platform(COMPONENTS.SETTINGS) for Platform in *require('main.platforms')]
	platformID = game\getPlatformID()
	for platform in *platforms
		if platform\getPlatformID() == platformID
			return platform
	log("Failed to get platform based on the game", platformID)
	return nil

export ReacquireBanner = (gameID) ->
	success, err = pcall(
		() ->
			log('ReacquireBanner', gameID)
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.OnReacquireBanner')
			log('Reacquiring a banner for', game\getTitle())
			platform = getPlatformByGame(game)
			assert(platform ~= nil, 'main.init.ReacquireBanner')
			url = platform\getBannerURL(game)
			if url == nil
				log("Failed to get URL for banner reacquisition", gameID)
				return
			path = game\getBanner()
			if io.fileExists(path)
				os.remove(io.absolutePath(path))
			folder, file = io.splitPath(path)
			COMPONENTS.DOWNLOADER\push({
				:url
				outputFile: file
				outputFolder: folder
				finishCallback: () ->
					log('Successfully reacquired a banner')
					STATE.SCROLL_INDEX_UPDATED = false
					SKIN\Bang('[!UpdateMeasure "Script"]')
					SKIN\Bang('[!CommandMeasure "Script" "OnReacquiredBanner()" "#ROOTCONFIG#\\Game"]')
				errorCallback: () -> log('Failed to reacquire a banner')
			})
			COMPONENTS.DOWNLOADER\start()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Context title action
export ToggleHideGames = () ->
	success, err = pcall(
		() ->
			if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
				SKIN\Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_hiding_games', 'Start hiding games')))
				STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
				return
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
				ToggleUnhideGames()
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
				ToggleRemoveGames()
			COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.HIDDEN, {state: false, stack: true, games: STATE.GAMES})
			games = COMPONENTS.LIBRARY\get()
			if #games == 0
				COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.HIDDEN, {state: false})
				games = COMPONENTS.LIBRARY\get()
				if #games == 0
					return
				else
					STATE.GAMES = games
					STATE.SCROLL_INDEX = 1
					updateSlots()
			else
				STATE.GAMES = games
				updateSlots()
			SKIN\Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_hiding_games', 'Stop hiding games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ToggleUnhideGames = () ->
	success, err = pcall(
		() ->
			if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
				SKIN\Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_unhiding_games', 'Start unhiding games')))
				STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
				return
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
				ToggleHideGames()
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
				ToggleRemoveGames()
			COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.HIDDEN, {state: true, stack: true, games: STATE.GAMES})
			games = COMPONENTS.LIBRARY\get()
			if #games == 0
				COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.HIDDEN, {state: true})
				games = COMPONENTS.LIBRARY\get()
				if #games == 0
					return
				else
					STATE.GAMES = games
					STATE.SCROLL_INDEX = 1
					updateSlots()
			else
				STATE.GAMES = games
				updateSlots()
			SKIN\Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_unhiding_games', 'Stop unhiding games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ToggleRemoveGames = () ->
	success, err = pcall(
		() ->
			if STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
				SKIN\Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_removing_games', 'Start removing games')))
				STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
				return
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
				ToggleHideGames()
			elseif STATE.LEFT_CLICK_ACTION == ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
				ToggleUnhideGames()
			if #STATE.GAMES == 0
				COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.NONE)
				STATE.GAMES = COMPONENTS.LIBRARY\get()
				STATE.SCROLL_INDEX = 1
				updateSlots()
			return if #STATE.GAMES == 0
			SKIN\Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_removing_games', 'Stop removing games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export TriggerGameDetection = () ->
	success, err = pcall(
		() ->
			games = io.readJSON(STATE.PATHS.GAMES)
			games.updated = nil
			io.writeJSON(STATE.PATHS.GAMES, games)
			SKIN\Bang("[!Refresh]")
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OpenStorePage = (gameID) ->
	success, err = pcall(
		() ->
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.OpenStorePage')
			platform = getPlatformByGame(game)
			assert(platform ~= nil, 'main.init.OpenStorePage')
			url = platform\getStorePageURL(game)
			if url == nil
				log("Failed to get URL for opening the store page", gameID)
				return
			SKIN\Bang(('[%s]')\format(url))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export StartAddingGame = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!ActivateConfig "#ROOTCONFIG#\\NewGame"]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export HandshakeNewGame = () ->
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\NewGame"]')\format(COMPONENTS.LIBRARY\getNextAvailableGameID()))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnAddGame = (gameID) ->
	success, err = pcall(
		() ->
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.OnAddGame')
			COMPONENTS.LIBRARY\insert(game)
	)
	COMPONENTS.STATUS\show(err, true) unless success
