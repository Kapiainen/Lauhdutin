getGameByID = (gameID) ->
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

getPlatformByGame = (game) ->
	platforms = [Platform(COMPONENTS.SETTINGS) for Platform in *require('wishlist.platforms')]
	platformID = game\getPlatformID()
	for platform in *platforms
		if platform\getPlatformID() == platformID
			return platform
	log("Failed to get platform based on the game", platformID)
	return nil

export UpdatePlatformProcesses = (gameID) ->
	success, err = pcall(
		() ->
			game = getGameByID(tonumber(gameID))
			return if game == nil
			platform = getPlatformByGame(game)
			if platform ~= nil and COMPONENTS.PROCESS\isPlatformRunning(platform)
				return SKIN\Bang(game\getClientCommand())
			SKIN\Bang(game\getURL())
	)
	COMPONENTS.STATUS\show(err, true) unless success
