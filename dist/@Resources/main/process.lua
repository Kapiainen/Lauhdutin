local utility = require('shared.utility')
local Process
do
  local _class_0
  local _base_0 = {
    getGame = function(self)
      return self.currentGame
    end,
    registerPlatforms = function(self, platforms)
      log('Registering platform processes')
      self.platformProcesses = { }
      self.platformStatuses = { }
      for _index_0 = 1, #platforms do
        local platform = platforms[_index_0]
        if platform:isEnabled() then
          local id = platform:getPlatformID()
          local process = platform:getPlatformProcess()
          if process ~= nil then
            self.platformProcesses[id] = process
            self.platformStatuses[id] = false
            log(('- %d = %s'):format(id, tostring(process)))
          end
        end
      end
    end,
    update = function(self, running)
      if self.monitoring then
        log('Updating game process status')
        if running and not self.gameStatus then
          self.gameStatus = true
          self.duration = 0
          self.startingTime = os.time()
          GameProcessStarted(self.currentGame)
          return true
        elseif not running and self.gameStatus then
          self:stopMonitoring()
        else
          log('Game is still running')
          return false
        end
      end
      utility.runCommand('tasklist /fo csv /nh', '', 'UpdatePlatformProcesses', { }, 'Hide', 'UTF8')
      return true
    end,
    updatePlatforms = function(self)
      if self.platformProcesses == nil then
        return { }
      end
      log('Updating platform client process statuses')
      local output = self.commandMeasure:GetStringValue()
      for id, process in pairs(self.platformProcesses) do
        if output:match(process) ~= nil then
          self.platformStatuses[id] = true
        else
          self.platformStatuses[id] = false
        end
        log(('- %d = %s'):format(id, tostring(self.platformStatuses[id])))
      end
      return self.platformStatuses
    end,
    monitor = function(self, game)
      assert(type(game) == 'table', 'main.process.Process.monitor')
      self.currentGame = game
      local process = game:getProcess()
      log('Monitoring process', process)
      self.duration = 0
      self.startingTime = os.time()
      if process == nil then
        return 
      end
      self.gameStatus = false
      self.monitoring = true
      assert(type(process) == 'string', 'main.process.Process.monitor')
      SKIN:Bang(('[!SetOption "Process" "ProcessName" "%s"]'):format(process))
      return SKIN:Bang('[!SetOption "Process" "UpdateDivider" "63"]')
    end,
    stopMonitoring = function(self)
      if self.currentGame == nil then
        return 
      end
      self.gameStatus = false
      self.monitoring = false
      self.duration = os.time() - self.startingTime
      self.startingTime = nil
      GameProcessTerminated(self.currentGame)
      self.currentGame = nil
      return SKIN:Bang('[!SetOption "Process" "UpdateDivider" "630"]')
    end,
    getDuration = function(self)
      return self.duration
    end,
    isRunning = function(self)
      return self.gameStatus
    end,
    isPlatformRunning = function(self, platformID)
      if self.platformProcesses == nil then
        return false
      end
      return self.platformStatuses[platformID] == true
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.monitoring = false
      self.commandMeasure = SKIN:GetMeasure('Command')
      self.currentGame = nil
      self.startingTime = nil
      self.duration = 0
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
