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
          log('Game started')
          return true
        elseif not running and self.gameStatus then
          self:stopMonitoring()
        else
          log('Game is still running')
          return false
        end
      end
      local callback
      callback = function()
        return COMPONENTS.SIGNAL:emit(SIGNALS.UPDATE_PLATFORM_RUNNING_STATUS, self:updatePlatforms(COMPONENTS.COMMANDER:getOutput()))
      end
      COMPONENTS.COMMANDER:run('tasklist /fo csv /nh', nil, callback, nil, nil, 'UTF8')
      return true
    end,
    updatePlatforms = function(self, output)
      if self.platformProcesses == nil then
        return { }
      end
      log('Updating platform client process statuses')
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
      COMPONENTS.SIGNAL:emit(SIGNALS.GAME_PROCESS_TERMINATED, self.currentGame, self.duration / 3600)
      self.currentGame = nil
      return SKIN:Bang('[!SetOption "Process" "UpdateDivider" "630"]')
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.monitoring = false
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
OnProcessUpdate = function(running)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.PROCESS:update(running == 1)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
return Process
