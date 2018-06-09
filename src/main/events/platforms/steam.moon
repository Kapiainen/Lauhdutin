export OnCommunityProfileDownloaded = () ->
	success, err = pcall(
		() ->
			log('Successfully downloaded Steam community profile')
			utility.stopDownloader()
			downloadedPath = STATE.PLATFORM_QUEUE[1]\getDownloadedCommunityProfilePath()
			cachedPath = STATE.PLATFORM_QUEUE[1]\getCachedCommunityProfilePath()
			os.rename(downloadedPath, cachedPath)
			profile = ''
			if io.fileExists(cachedPath, false)
				profile = io.readFile(cachedPath, false)
			STATE.PLATFORM_QUEUE[1]\parseCommunityProfile(profile)
			STATE.PLATFORM_QUEUE[1]\getLibraries()
			if STATE.PLATFORM_QUEUE[1]\hasLibrariesToParse()
				return utility.runCommand(STATE.PLATFORM_QUEUE[1]\getACFs())
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnCommunityProfileDownloadFailed = () ->
	success, err = pcall(
		() ->
			log('Failed to download Steam community profile')
			utility.stopDownloader()
			STATE.PLATFORM_QUEUE[1]\getLibraries()
			if STATE.PLATFORM_QUEUE[1]\hasLibrariesToParse()
				return utility.runCommand(STATE.PLATFORM_QUEUE[1]\getACFs())
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnGotACFs = () ->
	success, err = pcall(
		() ->
			unless STATE.PLATFORM_QUEUE[1]\hasGottenACFs()
				return utility.runLastCommand()
			log('Dumped list of Steam appmanifests')
			STATE.PLATFORM_QUEUE[1]\generateGames()
			if STATE.PLATFORM_QUEUE[1]\hasLibrariesToParse()
				return utility.runCommand(STATE.PLATFORM_QUEUE[1]\getACFs())
			STATE.PLATFORM_QUEUE[1]\generateShortcuts()
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success
