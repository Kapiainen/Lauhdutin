require('main.events.skin')
export Unload = nil
export TriggerGameDetection = nil
export ToggleHideGames = nil
export ToggleUnhideGames = nil
export ToggleRemoveGames = nil
export Refresh = () ->
	success, err = pcall(
		() ->
			games = io.readJSON(STATE.PATHS.GAMES)
			games.updated = nil
			io.writeJSON(STATE.PATHS.GAMES, games)
			SKIN\Bang("[!Refresh]")
	)
	COMPONENTS.STATUS\show(err, true) unless success
