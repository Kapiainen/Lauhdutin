return {
	runCommand: (parameter, output, callback, callbackArgs = {}, state = 'Hide', outputType = 'UTF16') ->
		assert(type(parameter) == 'string', 'shared.utility.runCommand')
		assert(type(output) == 'string', 'shared.utility.runCommand')
		assert(type(callback) == 'string', 'shared.utility.runCommand')
		SKIN\Bang(('[!SetOption "Command" "Parameter" "%s"]')\format(parameter))
		SKIN\Bang(('[!SetOption "Command" "OutputFile" "%s"]')\format(output))
		SKIN\Bang(('[!SetOption "Command" "OutputType" "%s"]')\format(outputType))
		SKIN\Bang(('[!SetOption "Command" "State" "%s"]')\format(state))
		SKIN\Bang(('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script %s(%s)]"]')\format(callback, table.concat(callbackArgs, ', ')))
		SKIN\Bang('[!UpdateMeasure "Command"]')
		SKIN\Bang('[!CommandMeasure "Command" "Run"]')

	runLastCommand: () -> SKIN\Bang('[!CommandMeasure "Command" "Run"]')
}
