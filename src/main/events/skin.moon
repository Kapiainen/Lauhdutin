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
	configs = utility.getConfigs([('%s\\%s')\format(rootConfigName, name) for name in *{'Search', 'Sort', 'Filter', 'Game'}])
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
			if STATE.VARIANT == 'Main' and STATE.SKIN_VISIBLE and animationType ~= ENUMS.SKIN_ANIMATIONS.NONE and not otherWindowsActive()
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

export TriggerGameDetection = () ->
	success, err = pcall(
		() ->
			games = io.readJSON(STATE.PATHS.GAMES)
			games.updated = nil
			io.writeJSON(STATE.PATHS.GAMES, games)
			SKIN\Bang("[!Refresh]")
	)
	COMPONENTS.STATUS\show(err, true) unless success

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

export OnBannerDownloadFinished = () ->
	success, err = pcall(
		() ->
			log('Successfully downloaded a banner')
			downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, SKIN\GetMeasure('Downloader')\GetOption('DownloadFile'))
			game = table.remove(STATE.BANNER_QUEUE, 1)
			bannerPath = io.joinPaths(STATE.PATHS.RESOURCES, game\getBanner())
			os.rename(downloadedPath, bannerPath)
			game\setBannerURL(nil)
			game\setExpectedBanner(nil)
			startDownloadingBanner()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnBannerDownloadError = () ->
	success, err = pcall(
		() ->
			log('Failed to download a banner')
			game = table.remove(STATE.BANNER_QUEUE, 1)
			io.writeFile(game\getBanner()\gsub('%..+', '%.failedToDownload'), '')
			game\setBanner(nil)
			game\setBannerURL(nil)
			startDownloadingBanner()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnFinishedDownloadingBanners = () ->
	success, err = pcall(
		() ->
			log('Finished downloading banners')
			utility.stopDownloader()
			onInitialized()
	)
	COMPONENTS.STATUS\show(err, true) unless success
