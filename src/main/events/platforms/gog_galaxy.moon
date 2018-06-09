export OnDownloadedGOGCommunityProfile = () ->
	success, err = pcall(
		() ->
			unless STATE.PLATFORM_QUEUE[1]\hasdownloadedCommunityProfile()
				return utility.runLastCommand()
			log('Downloaded GOG community profile')
			utility.runCommand(STATE.PLATFORM_QUEUE[1]\dumpDatabases())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnDumpedDBs = () ->
	success, err = pcall(
		() ->
			unless STATE.PLATFORM_QUEUE[1]\hasDumpedDatabases()
				return utility.runLastCommand()
			log('Dumped GOG Galaxy databases')
			cachePath = STATE.PLATFORM_QUEUE[1]\getCachePath()
			index = io.readFile(io.joinPaths(cachePath, 'index.txt'))
			galaxyPath = io.joinPaths(cachePath, 'galaxy.txt')
			galaxy = io.readFile(galaxyPath)
			newGalaxy = {}
			wholeLine = {}
			lines = galaxy\splitIntoLines()
			for line in *lines
				if line\match('^%d+|[^|]+|[^|]+|.+$')
					table.insert(newGalaxy, table.concat(wholeLine, ''))
					wholeLine = {}
				table.insert(wholeLine, line)
			if #wholeLine > 0
				table.insert(newGalaxy, table.concat(wholeLine, ''))
			galaxy = table.concat(newGalaxy, '\n')
			io.writeFile(galaxyPath, galaxy)
			profilePath = io.joinPaths(cachePath, 'profile.txt')
			profile = if io.fileExists(profilePath) then io.readFile(profilePath) else nil
			STATE.PLATFORM_QUEUE[1]\generateGames(index, galaxy, profile)
			OnFinishedDetectingPlatformGames()
	)
	COMPONENTS.STATUS\show(err, true) unless success
