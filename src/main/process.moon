-- A process measure regularly sends update events.
-- If a specific process is being monitored, then that process' state is updated.
-- Else the statuses of the various supported platforms' client processes are updated.

class Process
	new: () =>
		@monitoring = false
		@currentGame = nil
		@startingTime = nil
		@duration = 0

	getGame: () => @currentGame

	registerPlatforms: (platforms) =>
		log('Registering platform processes')
		@platformProcesses = {}
		@platformStatuses = {}
		for platform in *platforms
			if platform\isEnabled()
				id = platform\getPlatformID()
				process = platform\getPlatformProcess()
				if process ~= nil
					@platformProcesses[id] = process
					@platformStatuses[id] = false
					log(('- %d = %s')\format(id, tostring(process)))

	update: (running) =>
		if @monitoring
			log('Updating game process status')
			if running and not @gameStatus
				@gameStatus = true
				@duration = 0
				@startingTime = os.time()
				log('Game started')
				return true
			elseif not running and @gameStatus
				@stopMonitoring()
			else
				log('Game is still running')
				return false
		callback = () -> COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_PLATFORM_RUNNING_STATUS, @updatePlatforms(COMPONENTS.COMMANDER\getOutput()))
		COMPONENTS.COMMANDER\run('tasklist /fo csv /nh', nil, callback, nil, nil, 'UTF8')
		return true

	updatePlatforms: (output) =>
		return {} if @platformProcesses == nil
		log('Updating platform client process statuses')
		for id, process in pairs(@platformProcesses)
			@platformStatuses[id] = if output\match(process) ~= nil then true else false
			log(('- %d = %s')\format(id, tostring(@platformStatuses[id])))
		return @platformStatuses

	monitor: (game) =>
		assert(type(game) == 'table', 'main.process.Process.monitor')
		@currentGame = game
		process = game\getProcess()
		log('Monitoring process', process)
		@duration = 0
		@startingTime = os.time()
		return if process == nil
		@gameStatus = false
		@monitoring = true
		assert(type(process) == 'string', 'main.process.Process.monitor')
		SKIN\Bang(('[!SetOption "Process" "ProcessName" "%s"]')\format(process))
		SKIN\Bang('[!SetOption "Process" "UpdateDivider" "63"]')

	stopMonitoring: () =>
		return if @currentGame == nil
		@gameStatus = false
		@monitoring = false
		@duration = os.time() - @startingTime
		@startingTime = nil
		COMPONENTS.SIGNAL\emit(SIGNALS.GAME_PROCESS_TERMINATED, @currentGame, @duration / 3600)
		@currentGame = nil
		SKIN\Bang('[!SetOption "Process" "UpdateDivider" "630"]')

export OnProcessUpdate = (running) ->
	return unless STATE.INITIALIZED
	success, err = pcall(() -> COMPONENTS.PROCESS\update(running == 1))
	COMPONENTS.STATUS\show(err, true) unless success

return Process
