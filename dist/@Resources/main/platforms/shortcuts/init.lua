local Platform = require('main.platforms.platform')
local Shortcuts
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self) end,
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
    getOutputPath = function(self)
      return self.outputPath
    end,
    generateGames = function(self, output)
      assert(type(output) == 'string')
      if output == '' then
        self.games = { }
        return 
      end
      local games = { }
      local lines = output:splitIntoLines()
      while #lines > 0 and #lines % 3 == 0 do
        local _continue_0 = false
        repeat
          local absoluteFilePath = table.remove(lines, 1)
          local relativeFilePath = absoluteFilePath:sub(#self.shortcutsPath + 1)
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
          local path = table.remove(lines, 1):match('^	Target=(.-)$')
          local uninstalled = nil
          if not (io.fileExists(path, false)) then
            uninstalled = true
          end
          path = ('"%s"'):format(path)
          local arguments = table.remove(lines, 1)
          if arguments then
            arguments = arguments:match('^	Arguments=(.-)$')
          end
          if arguments then
            arguments = arguments:trim()
          end
          if arguments ~= nil and arguments ~= '' then
            local args = { }
            local attempts = 20
            while #arguments > 0 and attempts > 0 do
              local arg = nil
              if arguments:match('^"') then
                local starts, ends = arguments:find('"(.-)"')
                arg = arguments:sub(starts + 1, ends - 1)
                arguments = arguments:sub(ends + 1):trim()
              else
                local starts, ends = arguments:find('([^%s]+)')
                arg = arguments:sub(starts, ends)
                arguments = arguments:sub(ends + 1):trim()
              end
              if arg == nil then
                attempts = attempts - 1
              else
                table.insert(args, arg)
              end
            end
            arguments = args
            if #arguments > 0 then
              path = ('%s "%s"'):format(path, table.concat(arguments, '" "'))
            end
          end
          if title == nil then
            log('Skipping Windows shortcut', absoluteFilePath, 'because title could not be found')
            _continue_0 = true
            break
          elseif path == nil then
            log('Skipping Windows shortcut', absoluteFilePath, 'because path could not be found')
            _continue_0 = true
            break
          end
          table.insert(games, {
            title = title,
            banner = banner,
            expectedBanner = expectedBanner,
            path = path,
            platformOverride = platformOverride,
            uninstalled = uninstalled,
            platformID = self.platformID
          })
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      self.games = games
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
if RUN_TESTS then
  local assertionMessage = 'Windows shortcuts test failed!'
  local settings = {
    getShortcutsEnabled = function(self)
      return true
    end
  }
  local shortcuts = Shortcuts(settings)
  local output = 'D:\\Programs\\Rainmeter\\Skins\\Lauhdutin\\@Resources\\Shortcuts\\Some game.lnk\n	Target=Y:\\Games\\Some game\\game.exe\n	Arguments=\nD:\\Programs\\Rainmeter\\Skins\\Lauhdutin\\@Resources\\Shortcuts\\Some platform\\Some other game.lnk\n	Target=Y:\\Games\\Some other game\\othergame.exe\n	Arguments=--console'
  shortcuts:generateGames(output)
  local games = shortcuts.games
  assert(#games == 2)
  assert(games[1]:getTitle() == 'Some game', assertionMessage)
  assert(games[1]:getPath() == '"Y:\\Games\\Some game\\game.exe"', assertionMessage)
  assert(games[1]:getPlatformID() == ENUMS.PLATFORM_IDS.SHORTCUTS, assertionMessage)
  assert(games[1]:getProcess() == 'game.exe', assertionMessage)
  assert(games[1]:isInstalled() == false, assertionMessage)
  assert(games[1]:getExpectedBanner() == 'Some game', assertionMessage)
  assert(games[2]:getTitle() == 'Some other game', assertionMessage)
  assert(games[2]:getPath() == '"Y:\\Games\\Some other game\\othergame.exe" "--console"', assertionMessage)
  assert(games[2]:getPlatformID() == ENUMS.PLATFORM_IDS.SHORTCUTS, assertionMessage)
  assert(games[2]:getPlatformOverride() == 'Some platform', assertionMessage)
  assert(games[2]:getProcess() == 'othergame.exe', assertionMessage)
  assert(games[2]:isInstalled() == false, assertionMessage)
  assert(games[2]:getExpectedBanner() == 'Some other game', assertionMessage)
end
return Shortcuts
