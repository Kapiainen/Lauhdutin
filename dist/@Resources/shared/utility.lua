return {
  runCommand = function(parameter, output, callback, callbackArgs, state, outputType)
    if callbackArgs == nil then
      callbackArgs = { }
    end
    if state == nil then
      state = 'Hide'
    end
    if outputType == nil then
      outputType = 'UTF16'
    end
    assert(type(parameter) == 'string', 'shared.utility.runCommand')
    assert(type(output) == 'string', 'shared.utility.runCommand')
    assert(type(callback) == 'string', 'shared.utility.runCommand')
    SKIN:Bang(('[!SetOption "Command" "Parameter" "%s"]'):format(parameter))
    SKIN:Bang(('[!SetOption "Command" "OutputFile" "%s"]'):format(output))
    SKIN:Bang(('[!SetOption "Command" "OutputType" "%s"]'):format(outputType))
    SKIN:Bang(('[!SetOption "Command" "State" "%s"]'):format(state))
    SKIN:Bang(('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script %s(%s)]"]'):format(callback, table.concat(callbackArgs, ', ')))
    SKIN:Bang('[!UpdateMeasure "Command"]')
    return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
  end,
  runLastCommand = function()
    return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
  end
}
