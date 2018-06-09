export OnParsedShortcuts = () ->
	success, err = pcall(
		() ->
			unless STATE.PLATFORM_QUEUE[1]\hasParsedShortcuts()
				return utility.runLastCommand()
			log('Parsed Windows shortcuts')
			output = ''
			path = STATE.PLATFORM_QUEUE[1]\getOutputPath()
			if io.fileExists(path)
				output = io.readFile(path)
			STATE.PLATFORM_QUEUE[1]\generateGames(output)
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success
