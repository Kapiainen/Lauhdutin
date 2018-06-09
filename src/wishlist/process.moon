class Process
	new: () =>
		@commandMeasure = SKIN\GetMeasure('Command')

	getActiveProcesses: (gameID) =>
		utility.runCommand('tasklist /fo csv /nh', '', 'UpdatePlatformProcesses', {tostring(gameID)}, 'Hide', 'UTF8')

	isPlatformRunning: (platform) =>
		process = platform\getPlatformProcess()
		output = @commandMeasure\GetStringValue()
		return if output\match(process) ~= nil then true else false

return Process
