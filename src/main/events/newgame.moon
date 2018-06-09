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
