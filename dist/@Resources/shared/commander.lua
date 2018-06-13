local measure = nil
local parameter = nil
local output = nil
local callback = nil
local callbackArgs = nil
local Commander
do
  local _class_0
  local _base_0 = {
    run = function(self, param, out, cb, cbArgs, state, outputType)
      if out == nil then
        out = ''
      end
      if cb == nil then
        cb = nil
      end
      if cbArgs == nil then
        cbArgs = nil
      end
      if state == nil then
        state = 'Hide'
      end
      if outputType == nil then
        outputType = 'UTF16'
      end
      assert(type(param) == 'string', 'shared.commander.Commander.run')
      assert(type(out) == 'string', 'shared.commander.Commander.run')
      parameter = param
      output = out
      callback = cb
      callbackArgs = cbArgs
      SKIN:Bang(('[!SetOption "Command" "Parameter" "%s"]'):format(param))
      SKIN:Bang(('[!SetOption "Command" "OutputFile" "%s"]'):format(out))
      SKIN:Bang(('[!SetOption "Command" "OutputType" "%s"]'):format(outputType))
      SKIN:Bang(('[!SetOption "Command" "State" "%s"]'):format(state))
      SKIN:Bang('[!SetOption "Command" "FinishAction" "[!CommandMeasure Script OnCommanderFinished()]"]')
      SKIN:Bang('[!UpdateMeasure "Command"]')
      return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
    end,
    ["repeat"] = function(self)
      if parameter == nil then
        return 
      end
      return SKIN:Bang('[!CommandMeasure "Command" "Run"]')
    end,
    getOutput = function(self)
      return measure:GetStringValue() or ''
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      measure = SKIN:GetMeasure('Command')
      return assert(measure ~= nil, 'shared.commander.Commander.new')
    end,
    __base = _base_0,
    __name = "Commander"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Commander = _class_0
end
OnCommanderFinished = function()
  log('Commander finished running', parameter)
  if callback ~= nil then
    return callback(callbackArgs)
  end
end
return Commander
