local Config
do
  local _class_0
  local _base_0 = {
    isActive = function(self)
      return self.active == 1
    end,
    getX = function(self)
      return self.windowX
    end,
    getY = function(self)
      return self.windowY
    end,
    getZ = function(self)
      return self.alwaysOnTop
    end,
    isClickThrough = function(self)
      return self.clickThrough == 1
    end,
    isDraggable = function(self)
      return self.draggable == 1
    end,
    snapsToEdges = function(self)
      return self.snapEdges == 1
    end,
    isKeptOnScreen = function(self)
      return self.keepOnScreen == 1
    end,
    getLoadOrder = function(self)
      return self.loadOrder
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, str)
      assert(type(str) == 'string' and str ~= '', 'shared.config.Config')
      self.active = tonumber(str:match('Active=(%d+)')) or 0
      self.windowX = tonumber(str:match('WindowX=(%d+)')) or 0
      self.windowY = tonumber(str:match('WindowY=(%d+)')) or 0
      self.clickThrough = tonumber(str:match('ClickThrough=(%d+)')) or 0
      self.draggable = tonumber(str:match('Draggable=(%d+)')) or 0
      self.snapEdges = tonumber(str:match('SnapEdges=(%d+)')) or 0
      self.keepOnScreen = tonumber(str:match('KeepOnScreen=(%d+)')) or 0
      self.alwaysOnTop = tonumber(str:match('AlwaysOnTop=(%d+)')) or 0
      self.loadOrder = tonumber(str:match('LoadOrder=(%d+)')) or 0
    end,
    __base = _base_0,
    __name = "Config"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Config = _class_0
end
RAINMETER = { }
local rainmeterINIPath = io.joinPaths(SKIN:GetVariable('SETTINGSPATH'), 'Rainmeter.ini')
RAINMETER.GetConfig = function(self, name)
  assert(type(name) == 'string', 'shared.skin.GetConfig')
  local rainmeterINI = io.readFile(rainmeterINIPath, false)
  local pattern = '%[' .. name .. '%][^%[]+'
  local starts, ends = rainmeterINI:find(pattern)
  if starts == nil or ends == nil then
    return nil
  end
  return Config(rainmeterINI:sub(starts, ends))
end
RAINMETER.GetConfigs = function(self, names)
  local rainmeterINI = io.readFile(rainmeterINIPath, false)
  local configs = { }
  for _index_0 = 1, #names do
    local _continue_0 = false
    repeat
      local name = names[_index_0]
      local pattern = '%[' .. name .. '%][^%[]+'
      local starts, ends = rainmeterINI:find(pattern)
      if starts == nil or ends == nil then
        _continue_0 = true
        break
      end
      table.insert(configs, Config(rainmeterINI:sub(starts, ends)))
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return configs
end
RAINMETER.GetConfigMonitor = function(self, config)
  assert(config.__class == Config, 'shared.skin.GetConfigMonitor')
  local x = config:getX()
  local y = config:getY()
  for i = 1, 8 do
    local _continue_0 = false
    repeat
      do
        local monitorX = tonumber(SKIN:GetVariable(('SCREENAREAX@%d'):format(i)))
        local monitorY = tonumber(SKIN:GetVariable(('SCREENAREAY@%d'):format(i)))
        local monitorWidth = tonumber(SKIN:GetVariable(('SCREENAREAWIDTH@%d'):format(i)))
        local monitorHeight = tonumber(SKIN:GetVariable(('SCREENAREAHEIGHT@%d'):format(i)))
        if x < monitorX or x > (monitorX + monitorWidth - 1) then
          _continue_0 = true
          break
        end
        if y < monitorY or y > (monitorY + monitorHeight - 1) then
          _continue_0 = true
          break
        end
        return i
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return nil
end
RAINMETER.CenterOnMonitor = function(self, configWidth, configHeight, screen)
  if screen == nil then
    screen = 1
  end
  assert(type(configWidth) == 'number', 'shared.skin.CenterOnMonitor')
  assert(type(configHeight) == 'number', 'shared.skin.CenterOnMonitor')
  assert(type(screen) == 'number', 'shared.skin.CenterOnMonitor')
  local monitorX = tonumber(SKIN:GetVariable(('SCREENAREAX@%d'):format(screen)))
  local monitorY = tonumber(SKIN:GetVariable(('SCREENAREAY@%d'):format(screen)))
  local monitorWidth = tonumber(SKIN:GetVariable(('SCREENAREAWIDTH@%d'):format(screen)))
  local monitorHeight = tonumber(SKIN:GetVariable(('SCREENAREAHEIGHT@%d'):format(screen)))
  local x = math.round(monitorX + (monitorWidth - configWidth) / 2)
  local y = math.round(monitorY + (monitorHeight - configHeight) / 2)
  return SKIN:Bang(('[!Move "%d" "%d"]'):format(x, y))
end
