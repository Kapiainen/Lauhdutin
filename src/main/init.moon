export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

export utility = nil
export json = nil

export Game = nil

export LOCALIZATION = nil

export STATE = {
	-- Always available
	INITIALIZED: false
	PATHS: {
		RESOURCES: nil
		DOWNLOADFILE: nil
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
	PLATFORM_RUNNING_STATUS: {}
	GAMES: {}
	REVEALING_DELAY: 0
	SKIN_VISIBLE: true
	SKIN_ANIMATION_PLAYING: false
	VARIANT: 'Main'
	-- Volatile
	PLATFORM_ENABLED_STATUS: nil
	PLATFORM_QUEUE: nil
	BANNER_QUEUE: nil
	GAME_BEING_MODIFIED: nil
}

export COMPONENTS = {
	STATUS: nil
	SETTINGS: nil
	LIBRARY: nil
}

export startDetectingPlatformGames = () ->
	COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_detecting_platform_games', 'Detecting %s games')\format(STATE.PLATFORM_QUEUE[1]\getName()))
	switch STATE.PLATFORM_QUEUE[1]\getPlatformID()
		when ENUMS.PLATFORM_IDS.SHORTCUTS
			log('Starting to detect Windows shortcuts')
			utility.runCommand(STATE.PLATFORM_QUEUE[1]\parseShortcuts())
		when ENUMS.PLATFORM_IDS.STEAM
			url, path, finishCallback, errorCallback = STATE.PLATFORM_QUEUE[1]\downloadCommunityProfile()
			if url ~= nil
				log('Attempting to download and parse the Steam community profile')
				utility.downloadFile(url, path, finishCallback, errorCallback)
			else
				log('Starting to detect Steam games')
				STATE.PLATFORM_QUEUE[1]\getLibraries()
				if STATE.PLATFORM_QUEUE[1]\hasLibrariesToParse()
					utility.runCommand(STATE.PLATFORM_QUEUE[1]\getACFs())
				else
					OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS
			log('Starting to detect non-Steam game shortcuts added to Steam')
			games = STATE.PLATFORM_QUEUE[1]\generateGames()
			OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.BATTLENET
			log('Starting to detect Blizzard Battle.net games')
			if STATE.PLATFORM_QUEUE[1]\hasUnprocessedPaths()
				utility.runCommand(STATE.PLATFORM_QUEUE[1]\identifyFolders())
			else
				OnFinishedDetectingPlatformGames()
		when ENUMS.PLATFORM_IDS.GOG_GALAXY
			log('Starting to detect GOG Galaxy games')
			parameter, output, callback = STATE.PLATFORM_QUEUE[1]\downloadCommunityProfile()
			if parameter ~= nil
				utility.runCommand(parameter, output, callback)
			else
				utility.runCommand(STATE.PLATFORM_QUEUE[1]\dumpDatabases())
		when ENUMS.PLATFORM_IDS.CUSTOM
			log('Starting to detect Custom games')
			STATE.PLATFORM_QUEUE[1]\detectBanners(COMPONENTS.LIBRARY\getOldGames())
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
	for platform in *platforms
		enabled = platform\isEnabled()
		platform\validate() if enabled
		platformID = platform\getPlatformID()
		STATE.PLATFORM_NAMES[platformID] = platform\getName()
		STATE.PLATFORM_ENABLED_STATUS[platformID] = enabled
		STATE.PLATFORM_RUNNING_STATUS[platformID] = false if platform\getPlatformProcess() ~= nil
		table.insert(STATE.PLATFORM_QUEUE, platform) if enabled
		log(' ' .. STATE.PLATFORM_NAMES[platformID] .. ' = ' .. tostring(enabled))
	assert(#STATE.PLATFORM_QUEUE > 0, 'There are no enabled platforms.')

detectGames = () ->
	COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_detecting_games', 'Detecting games'))
	STATE.BANNER_QUEUE = {}
	startDetectingPlatformGames()

export startDownloadingBanner = () ->
	while #STATE.BANNER_QUEUE > 0 -- Remove games, which have previously failed to have their banners downloaded
		if io.fileExists((STATE.BANNER_QUEUE[1]\getBanner()\gsub('%..+', '%.failedToDownload')))
			table.remove(STATE.BANNER_QUEUE, 1)
			continue
		break
	if #STATE.BANNER_QUEUE > 0
		log('Starting to download a banner')
		COMPONENTS.STATUS\show(LOCALIZATION\get('main_status_n_banners_to_download', '%d banners left to download')\format(#STATE.BANNER_QUEUE))
		utility.downloadBanner(STATE.BANNER_QUEUE[1])
	else
		STATE.BANNER_QUEUE = nil
		OnFinishedDownloadingBanners()

export onInitialized = () ->
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

updateContextTitles = () ->
	SKIN\Bang(('[!SetVariable "ContextTitleSettings" "%s"]')\format(LOCALIZATION\get('main_context_title_settings', 'Settings')))
	SKIN\Bang(('[!SetVariable "ContextTitleOpenShortcutsFolder" "%s"]')\format(LOCALIZATION\get('main_context_title_open_shortcuts_folder', 'Open shortcuts folder')))
	SKIN\Bang(('[!SetVariable "ContextTitleExecuteStoppingBangs" "%s"]')\format(LOCALIZATION\get('main_context_title_execute_stopping_bangs', 'Execute stopping bangs')))
	SKIN\Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_hiding_games', 'Start hiding games')))
	SKIN\Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_unhiding_games', 'Start unhiding games')))
	SKIN\Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_start_removing_games', 'Start removing games')))
	SKIN\Bang(('[!SetVariable "ContextTitleDetectGames" "%s"]')\format(LOCALIZATION\get('main_context_title_detect_games', 'Detect games')))
	SKIN\Bang(('[!SetVariable "ContextTitleAddGame" "%s"]')\format(LOCALIZATION\get('main_context_title_add_game', 'Add a game')))

export Initialize = () ->
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	STATE.PATHS.DOWNLOADFILE = SKIN\GetVariable('CURRENTPATH') .. 'DownloadFile\\'
	STATE.ROOT_CONFIG = SKIN\GetVariable('ROOTCONFIG')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.enums')
			require('main.events')
			additionalEnums()
			Game = require('main.game')
			utility = require('shared.utility')
			utility.createJSONHelpers()
			json = require('lib.json')
			COMPONENTS.SETTINGS = require('shared.settings')()
			STATE.LOGGING = COMPONENTS.SETTINGS\getLogging()
			STATE.SCROLL_STEP = COMPONENTS.SETTINGS\getScrollStep()
			log('Initializing skin')
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			updateContextTitles()
			COMPONENTS.STATUS\show(LOCALIZATION\get('status_initializing', 'Initializing'))
			COMPONENTS.TOOLBAR = require('main.toolbar')(COMPONENTS.SETTINGS)
			COMPONENTS.TOOLBAR\hide()
			COMPONENTS.ANIMATIONS = require('main.animations')()
			STATE.NUM_SLOTS = COMPONENTS.SETTINGS\getLayoutRows() * COMPONENTS.SETTINGS\getLayoutColumns()
			COMPONENTS.SLOTS = require('main.slots')(COMPONENTS.SETTINGS, require('main.slots.slot'), require('main.slots.overlay_slot'))
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

export log = (...) -> print(...) if STATE.LOGGING == true

export HideStatus = () -> COMPONENTS.STATUS\hide()

export setUpdateDivider = (value) ->
	assert(type(value) == 'number' and value % 1 == 0 and value ~= 0, 'main.init.setUpdateDivider')
	SKIN\Bang(('[!SetOption "Script" "UpdateDivider" "%d"]')\format(value))
	SKIN\Bang('[!UpdateMeasure "Script"]')

export updateSlots = () ->
	success, err = pcall(
		() ->
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
	)
	COMPONENTS.STATUS\show(err, true) unless success

export getGameByID = (gameID) ->
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

export getPlatformByGame = (game) ->
	platforms = [Platform(COMPONENTS.SETTINGS) for Platform in *require('main.platforms')]
	platformID = game\getPlatformID()
	for platform in *platforms
		if platform\getPlatformID() == platformID
			return platform
	log("Failed to get platform based on the game", platformID)
	return nil
