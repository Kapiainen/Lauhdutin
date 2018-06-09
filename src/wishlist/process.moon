class Process
	new: () =>
		@commandMeasure = SKIN\GetMeasure('Command')

	getActiveProcesses: () =>
		utility.runCommand('tasklist /fo csv /nh', '', 'UpdatePlatformProcesses', {}, 'Hide', 'UTF8')

	isPlatformRunning: (platform) =>
		process = platform\getPlatformProcess()
		output = @commandMeasure\GetStringValue()
		return if output\match(process) ~= nil then true else false

return Process
