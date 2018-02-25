local Platform = require('main.platforms.platform')
local Game = require('main.game')
local Shortcuts
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    parseShortcuts = function(self)
      if io.fileExists(self.outputPath) then
        io.writeFile(self.outputPath, '')
      end
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\shortcuts\\parseShortcuts.bat" "%s"]'):format(self.shortcutsPath))
      return self:getWaitCommand(), '', 'OnParsedShortcuts'
    end,
    hasParsedShortcuts = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    generateGames = function(self)
      if not (io.fileExists(self.outputPath)) then
        self.games = { }
        return 
      end
      local games = { }
      local output = io.readFile(self.outputPath)
      local lines = output:splitIntoLines()
      while #lines > 0 and #lines % 3 == 0 do
        local absoluteFilePath = table.remove(lines, 1)
        local _, diverges = absoluteFilePath:find(self.shortcutsPath)
        local relativeFilePath = absoluteFilePath:sub(diverges + 1)
        local parts = relativeFilePath:split('\\')
        local title
        local _exp_0 = #parts
        if 1 == _exp_0 then
          title = parts[1]
        elseif 2 == _exp_0 then
          title = parts[2]
        else
          title = assert(nil, 'Unexpected path structure when processing Windows shortcuts.')
        end
        title = title:match('^([^%.]+)')
        local platformOverride
        local _exp_1 = #parts
        if 2 == _exp_1 then
          platformOverride = parts[1]
        else
          platformOverride = nil
        end
        local banner = nil
        local expectedBanner = nil
        if platformOverride ~= nil then
          banner = self:getBannerPath(title, ('Shortcuts\\%s'):format(platformOverride))
        else
          banner = self:getBannerPath(title, 'Shortcuts')
        end
        if not (banner) then
          expectedBanner = title
        end
        local path = ('"%s"'):format(table.remove(lines, 1):match('^	Target=(.-)$'))
        local arguments = table.remove(lines, 1)
        if arguments then
          arguments = arguments:match('^	Arguments=(.-)$')
        end
        if arguments ~= nil and arguments ~= '' then
          arguments = arguments:split('"%s"')
          if #arguments > 0 then
            path = ('%s "%s"'):format(path, table.concat(arguments, '" "'))
          end
        end
        table.insert(games, {
          title = title,
          banner = banner,
          expectedBanner = expectedBanner,
          path = path,
          platformOverride = platformOverride,
          platformID = self.platformID
        })
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #games do
          local args = games[_index_0]
          _accum_0[_len_0] = Game(args)
          _len_0 = _len_0 + 1
        end
        self.games = _accum_0
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      _class_0.__parent.__init(self, settings)
      self.platformID = ENUMS.PLATFORM_IDS.SHORTCUTS
      self.name = LOCALIZATION:get('platform_name_windows_shortcut', 'Windows shortcut')
      self.cachePath = 'cache\\shortcuts\\'
      self.shortcutsPath = io.joinPaths(STATE.PATHS.RESOURCES, 'Shortcuts\\')
      self.outputPath = io.joinPaths(self.cachePath, 'output.txt')
      self.enabled = settings:getShortcutsEnabled()
    end,
    __base = _base_0,
    __name = "Shortcuts",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Shortcuts = _class_0
end
return Shortcuts
