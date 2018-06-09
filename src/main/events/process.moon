export UpdateProcess = (running) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.PROCESS\update(running == 1)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export UpdatePlatformProcesses = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			STATE.PLATFORM_RUNNING_STATUS = COMPONENTS.PROCESS\updatePlatforms()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export GameProcessStarted = (game) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Game started')
			return
	)
	COMPONENTS.STATUS\show(err, true) unless success

export GameProcessTerminated = (game) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			duration = COMPONENTS.PROCESS\getDuration() / 3600
			log(game\getTitle(), 'was played for', duration, 'hours')
			game\incrementHoursPlayed(duration)
			COMPONENTS.LIBRARY\save()
			platformID = game\getPlatformID()
			if COMPONENTS.SETTINGS\getBangsEnabled()
				unless game\getIgnoresOtherBangs()
					SKIN\Bang(bang) for bang in *COMPONENTS.SETTINGS\getGlobalStoppingBangs()
					platformBangs = switch platformID
						when ENUMS.PLATFORM_IDS.SHORTCUTS
							COMPONENTS.SETTINGS\getShortcutsStoppingBangs()
						when ENUMS.PLATFORM_IDS.STEAM, ENUMS.PLATFORM_IDS.STEAM_SHORTCUTS
							COMPONENTS.SETTINGS\getSteamStoppingBangs()
						when ENUMS.PLATFORM_IDS.BATTLENET
							COMPONENTS.SETTINGS\getBattlenetStoppingBangs()
						when ENUMS.PLATFORM_IDS.GOG_GALAXY
							COMPONENTS.SETTINGS\getGOGGalaxyStoppingBangs()
						when ENUMS.PLATFORM_IDS.CUSTOM
							COMPONENTS.SETTINGS\getCustomStoppingBangs()
						else
							assert(nil, 'Encountered an unsupported platform ID when executing platform-specific stopping bangs.')
					SKIN\Bang(bang) for bang in *platformBangs
				SKIN\Bang(bang) for bang in *game\getStoppingBangs()
			switch platformID
				when ENUMS.PLATFORM_IDS.GOG_GALAXY
					if COMPONENTS.SETTINGS\getGOGGalaxyIndirectLaunch()
						SKIN\Bang('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\closeClient.bat"]')
			if COMPONENTS.SETTINGS\getHideSkin()
				SKIN\Bang('[!ShowFade]')
			if COMPONENTS.SETTINGS\getShowSession()
				SKIN\Bang(('[!DeactivateConfig "%s"]')\format(('%s\\Session')\format(STATE.ROOT_CONFIG)))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ManuallyTerminateGameProcess = () ->
	success, err = pcall(
		() ->
			COMPONENTS.PROCESS\stopMonitoring()
	)
	COMPONENTS.STATUS\show(err, true) unless success
