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
			config = utility.getConfig(configName)
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
