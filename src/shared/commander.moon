measure = nil
parameter = nil
output = nil
callback = nil
callbackArgs = nil

class Commander
	new: () =>
		measure = SKIN\GetMeasure('Command')
		assert(measure ~= nil, 'shared.commander.Commander.new')

	run: (param, out = '', cb = nil, cbArgs = nil, state = 'Hide', outputType = 'UTF16') =>
		assert(type(param) == 'string', 'shared.commander.Commander.run')
		assert(type(out) == 'string', 'shared.commander.Commander.run')
		parameter = param
		output = out
		callback = cb
		callbackArgs = cbArgs
		SKIN\Bang(('[!SetOption "Command" "Parameter" "%s"]')\format(param))
		SKIN\Bang(('[!SetOption "Command" "OutputFile" "%s"]')\format(out))
		SKIN\Bang(('[!SetOption "Command" "OutputType" "%s"]')\format(outputType))
		SKIN\Bang(('[!SetOption "Command" "State" "%s"]')\format(state))
		SKIN\Bang('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script OnCommanderFinished()]"]')
		SKIN\Bang('[!UpdateMeasure "Command"]')
		SKIN\Bang('[!CommandMeasure "Command" "Run"]')

	repeat: () =>
		return if parameter == nil
		SKIN\Bang('[!CommandMeasure "Command" "Run"]')

	getOutput: () => return measure\GetStringValue() or ''

export OnCommanderFinished = () ->
	log('Commander finished running', parameter)
	callback(callbackArgs) if callback ~= nil

return Commander
