titles = {
	settings: 'ContextTitleSettings'
	openShortcutsFolder: 'ContextTitleOpenShortcutsFolder'
	executeStoppingBangs: 'ContextTitleExecuteStoppingBangs'
	hideGamesStatus: 'ContextTitleHideGamesStatus'
	unhideGameStatus: 'ContextTitleUnhideGameStatus'
	removeGamesStatus: 'ContextTitleRemoveGamesStatus'
	detectGames: 'ContextTitleDetectGames'
	addGame: 'ContextTitleAddGame'
}

set = (title, key, default) -> SKIN\Bang(('[!SetVariable "%s" "%s"]')\format(title, LOCALIZATION\get(key, default)))
setStartHidingGames = () -> set(titles.hideGamesStatus, 'main_context_title_start_hiding_games', 'Start hiding games')
setStopHidingGames = () -> set(titles.hideGamesStatus, 'main_context_title_stop_hiding_games', 'Stop hiding games')
setStartUnhidingGames = () -> set(titles.unhideGameStatus, 'main_context_title_start_unhiding_games', 'Start unhiding games')
setStopUnhidingGames = () -> set(titles.unhideGameStatus, 'main_context_title_stop_unhiding_games', 'Stop unhiding games')
setStartRemovingGames = () -> set(titles.removeGamesStatus, 'main_context_title_start_removing_games', 'Start removing games')
setStopRemovingGames = () -> set(titles.removeGamesStatus, 'main_context_title_stop_removing_games', 'Stop removing games')

class ContextMenu
	new: () =>
		set(titles.settings, 'main_context_title_settings', 'Settings')
		set(titles.openShortcutsFolder, 'main_context_title_open_shortcuts_folder', 'Open shortcuts folder')
		set(titles.executeStoppingBangs, 'main_context_title_execute_stopping_bangs', 'Execute stopping bangs')
		setStartHidingGames()
		setStartUnhidingGames()
		setStartRemovingGames()
		set(titles.detectGames, 'main_context_title_detect_games', 'Detect games')
		set(titles.addGame, 'main_context_title_add_game', 'Add a game')
		COMPONENTS.SIGNAL\register(SIGNALS.START_HIDING_GAMES, () ->
				setStopHidingGames()
				setStartUnhidingGames()
				setStartRemovingGames()
		)
		COMPONENTS.SIGNAL\register(SIGNALS.STOP_HIDING_GAMES, () -> setStartHidingGames())
		COMPONENTS.SIGNAL\register(SIGNALS.START_UNHIDING_GAMES, () ->
				setStartHidingGames()
				setStopUnhidingGames()
				setStartRemovingGames()
		)
		COMPONENTS.SIGNAL\register(SIGNALS.STOP_UNHIDING_GAMES, () -> setStartUnhidingGames())
		COMPONENTS.SIGNAL\register(SIGNALS.START_REMOVING_GAMES, () ->
				setStartHidingGames()
				setStartUnhidingGames()
				setStopRemovingGames()
		)
		COMPONENTS.SIGNAL\register(SIGNALS.STOP_REMOVING_GAMES, () -> setStartRemovingGames())

export OnContextExecuteStoppingBangs = () ->
	success, err = pcall(() -> COMPONENTS.PROCESS\stopMonitoring())
	COMPONENTS.STATUS\show(err, true) unless success

export OnContextToggleHideGames = () ->
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
					COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_SLOTS)
			else
				STATE.GAMES = games
				COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_SLOTS)
			SKIN\Bang(('[!SetVariable "ContextTitleHideGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_hiding_games', 'Stop hiding games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnContextToggleUnhideGames = () ->
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
					COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_SLOTS)
			else
				STATE.GAMES = games
				COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_SLOTS)
			SKIN\Bang(('[!SetVariable "ContextTitleUnhideGameStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_unhiding_games', 'Stop unhiding games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnContextToggleRemoveGames = () ->
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
				COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_SLOTS)
			return if #STATE.GAMES == 0
			SKIN\Bang(('[!SetVariable "ContextTitleRemoveGamesStatus" "%s"]')\format(LOCALIZATION\get('main_context_title_stop_removing_games', 'Stop removing games')))
			STATE.LEFT_CLICK_ACTION = ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnContextTriggerGameDetection = () ->
	success, err = pcall(
		() ->
			games = io.readJSON(STATE.PATHS.GAMES)
			games.updated = nil
			io.writeJSON(STATE.PATHS.GAMES, games)
			SKIN\Bang("[!Refresh]")
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnContextAddGame = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!ActivateConfig "#ROOTCONFIG#\\NewGame"]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

return ContextMenu
