export OnIdentifiedBattlenetFolders = () ->
	success, err = pcall(
		() ->
			unless STATE.PLATFORM_QUEUE[1]\hasProcessedPath()
				return utility.runLastCommand()
			log('Dumped list of folders in a Blizzard Battle.net folder')
			STATE.PLATFORM_QUEUE[1]\generateGames(io.readFile(io.joinPaths(STATE.PLATFORM_QUEUE[1]\getCachePath(), 'output.txt')))
			if STATE.PLATFORM_QUEUE[1]\hasUnprocessedPaths()
				return utility.runCommand(STATE.PLATFORM_QUEUE[1]\identifyFolders())
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success
