local Process
do
  local _class_0
  local _base_0 = {
    getActiveProcesses = function(self, gameID)
      return utility.runCommand('tasklist /fo csv /nh', '', 'UpdatePlatformProcesses', {
        tostring(gameID)
      }, 'Hide', 'UTF8')
    end,
    isPlatformRunning = function(self, platform)
      local process = platform:getPlatformProcess()
      local output = self.commandMeasure:GetStringValue()
      if output:match(process) ~= nil then
        return true
      else
        return false
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.commandMeasure = SKIN:GetMeasure('Command')
    end,
    __base = _base_0,
    __name = "Process"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Process = _class_0
end
return Process
