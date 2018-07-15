local utility = require('shared.utility')
local Game
do
  local _class_0
  local _base_0 = {
    merge = function(self, other, newer)
      if newer == nil then
        newer = false
      end
      assert(other.__class == Game, 'main.game.Game.merge')
      log('Merging: ' .. other.title)
      self.processOverride = other.processOverride
      self.hidden = other.hidden
      if self.lastPlayed ~= nil then
        if other.lastPlayed ~= nil and other.lastPlayed > self.lastPlayed then
          self.lastPlayed = other.lastPlayed
        end
      else
        self.lastPlayed = other.lastPlayed
      end
      if self.hoursPlayed ~= nil then
        if other.hoursPlayed ~= nil and other.hoursPlayed > self.hoursPlayed then
          self.hoursPlayed = other.hoursPlayed
        end
      else
        self.hoursPlayed = other.hoursPlayed
      end
      self.startingBangs = other.startingBangs
      self.stoppingBangs = other.stoppingBangs
      self.ignoresOtherBangs = other.ignoresOtherBangs
      self.notes = other.notes
      if newer == true then
        self.uninstalled = other.uninstalled
        self.path = other.path
        self.platformOverride = other.platformOverride
        self.banner = other.banner
        self.bannerURL = other.bannerURL
        self.expectedBanner = other.expectedBanner
        self.tags = other.tags
      else
        if other.tags ~= nil then
          if self.tags == nil then
            self.tags = { }
          end
          for key, oldSource in pairs(other.tags) do
            local newSource = self.tags[key]
            if newSource == nil and oldSource == ENUMS.TAG_SOURCES.SKIN then
              self.tags[key] = oldSource
            end
          end
        end
      end
    end,
    _moveThe = function(self, title)
      if title:lower():startsWith('the ') then
        title = ('%s, %s'):format(title:sub(5), title:sub(1, 3))
      end
      return title
    end,
    _parseProcess = function(self, path)
      path = path:gsub("\\", "/"):gsub("//", "/"):reverse()
      local process = path:match("(exe%p[^\\/:%*?<>|]+)/")
      if process ~= nil then
        return process:reverse()
      end
      return nil
    end,
    getGameID = function(self)
      return self.gameID
    end,
    setGameID = function(self, value)
      assert(type(value) == 'number' and value % 1 == 0, 'main.game.Game.setGameID')
      self.gameID = value
    end,
    getTitle = function(self)
      return self.title
    end,
    getPlatformID = function(self)
      return self.platformID
    end,
    getPlatformOverride = function(self)
      return self.platformOverride
    end,
    setPlatformOverride = function(self, platform)
      if not (self:getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM) then
        return 
      end
      if platform == nil then
        self.platformOverride = nil
      elseif type(platform) == 'string' then
        platform = platform:trim()
        if platform == '' then
          self.platformOverride = nil
        else
          self.platformOverride = platform
        end
      end
    end,
    getPath = function(self)
      return self.path
    end,
    setPath = function(self, path)
      if not (self:getPlatformID() == ENUMS.PLATFORM_IDS.CUSTOM) then
        return 
      end
      path = path:trim()
      if path == '' then
        return 
      end
      if (path:find('%s') == nil) then
        path = ('"%s"'):format(path)
      end
      self.path = path
    end,
    getProcess = function(self, skipOverride)
      if skipOverride == nil then
        skipOverride = false
      end
      if self.processOverride and skipOverride == false then
        return self.processOverride
      else
        return self.process
      end
    end,
    getProcessOverride = function(self)
      return self.processOverride
    end,
    setProcessOverride = function(self, process)
      if process == nil then
        self.processOverride = nil
      elseif type(process) == 'string' then
        process = process:trim()
        if process == '' then
          self.processOverride = nil
        else
          self.processOverride = process
        end
      end
    end,
    getBanner = function(self)
      return self.banner
    end,
    setBanner = function(self, path)
      if path == nil then
        self.banner = nil
      elseif type(path) == 'string' then
        path = path:trim()
        if path == '' then
          self.banner = nil
        else
          self.banner = path
        end
      end
    end,
    getExpectedBanner = function(self)
      return self.expectedBanner
    end,
    setExpectedBanner = function(self, str)
      if str == nil then
        return self.expectedBanner == nil
      elseif type(str) == 'string' then
        str = str:trim()
        if str == '' then
          self.expectedBanner = nil
        else
          self.expectedBanner = str
        end
      end
    end,
    getBannerURL = function(self)
      return self.bannerURL
    end,
    setBannerURL = function(self, url)
      if url == nil then
        self.bannerURL = nil
      elseif type(url) == 'string' then
        url = url:trim()
        if url == '' then
          self.bannerURL = nil
        else
          self.bannerURL = url
        end
      end
    end,
    isVisible = function(self)
      return self.hidden ~= true
    end,
    setVisible = function(self, state)
      if state == true then
        self.hidden = nil
      else
        self.hidden = true
      end
    end,
    toggleVisibility = function(self)
      if self.hidden == true then
        self.hidden = nil
      else
        self.hidden = true
      end
    end,
    isInstalled = function(self)
      return self.uninstalled ~= true
    end,
    setInstalled = function(self, state)
      assert(type(state) == 'boolean', 'main.game.Game.setInstalled')
      if state == true then
        self.uninstalled = nil
      else
        self.uninstalled = true
      end
    end,
    getLastPlayed = function(self)
      return self.lastPlayed or 0
    end,
    setLastPlayed = function(self, value)
      self.lastPlayed = value
    end,
    getHoursPlayed = function(self)
      return self.hoursPlayed or 0
    end,
    setHoursPlayed = function(self, value)
      if type(value) == 'number' and value >= 0 then
        self.hoursPlayed = value
      end
    end,
    incrementHoursPlayed = function(self, hours)
      if hours >= 0 then
        if self.hoursPlayed == nil then
          self.hoursPlayed = 0
        end
        self.hoursPlayed = self.hoursPlayed + hours
      end
    end,
    hasTags = function(self)
      if self.tags == nil then
        return false
      end
      for key, source in pairs(self.tags) do
        return true
      end
      return false
    end,
    getStartingBangs = function(self)
      return self.startingBangs or { }
    end,
    setStartingBangs = function(self, bangs)
      self.startingBangs = { }
      for _index_0 = 1, #bangs do
        local bang = bangs[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(self.startingBangs, bang)
        end
      end
      if #self.startingBangs == 0 then
        self.startingBangs = nil
      end
    end,
    getStoppingBangs = function(self)
      return self.stoppingBangs or { }
    end,
    setStoppingBangs = function(self, bangs)
      self.stoppingBangs = { }
      for _index_0 = 1, #bangs do
        local bang = bangs[_index_0]
        bang = bang:trim()
        if bang ~= '' then
          table.insert(self.stoppingBangs, bang)
        end
      end
      if #self.stoppingBangs == 0 then
        self.stoppingBangs = nil
      end
    end,
    getIgnoresOtherBangs = function(self)
      return self.ignoresOtherBangs or false
    end,
    toggleIgnoresOtherBangs = function(self)
      if self.ignoresOtherBangs == true then
        self.ignoresOtherBangs = nil
      else
        self.ignoresOtherBangs = true
      end
    end,
    getNotes = function(self)
      return self.notes
    end,
    setNotes = function(self, str)
      if str == nil then
        self.notes = nil
      elseif type(str) == 'string' then
        if str:trim() == '' then
          self.notes = nil
        else
          self.notes = str
        end
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args, tagsDictionary)
      local title = args.ti or args.title
      assert(type(title) == 'string' and title:trim() ~= '', 'main.game.Game')
      self.title = self:_moveThe(title)
      local path = args.pa or args.path
      assert(type(path) == 'string', 'main.game.Game')
      self.path = path
      local platformID = args.plID or args.platformID
      assert(type(platformID) == 'number' and platformID % 1 == 0, 'main.game.Game')
      self.platformID = platformID
      assert(self.platformID > 0 and self.platformID < ENUMS.PLATFORM_IDS.MAX, 'main.game.Game')
      self.platformOverride = args.plOv or args.platformOverride
      local banner = args.ba or args.banner
      local bannerURL = args.baURL or args.bannerURL
      if banner ~= nil and (io.fileExists(banner) or bannerURL ~= nil) then
        self.banner = banner
      end
      self.bannerURL = bannerURL
      assert(self.bannerURL == nil or (self.bannerURL ~= nil and self.banner ~= nil), 'main.game.Game')
      self.expectedBanner = args.exBa or args.expectedBanner
      self.process = args.pr or args.process or self:_parseProcess(self.path)
      self.uninstalled = args.un or args.uninstalled
      self.gameID = args.gaID or args.gameID
      self.processOverride = args.prOv or args.processOverride
      self.hidden = args.hi or args.hidden
      self.lastPlayed = args.laPl or args.lastPlayed
      self.hoursPlayed = args.hoPl or args.hoursPlayed
      self.startingBangs = args.staBa or args.startingBangs
      self.stoppingBangs = args.stoBa or args.stoppingBangs
      self.ignoresOtherBangs = args.igOtBa or args.ignoresOtherBangs
      self.notes = args.no or args.notes
      local tags = args.ta or args.tags or { }
      local platformTags = args.plTa or args.platformTags or { }
      if table.isArray(tags) then
        if #tags == 0 and #platformTags == 0 then
          self.tags = nil
        else
          self.tags = { }
          for i, tag in ipairs(tags) do
            local key = table.find(tagsDictionary, tag)
            if key == nil then
              local j = 1
              while true do
                key = tostring(j)
                if tagsDictionary[key] == nil then
                  tagsDictionary[key] = tag
                  break
                end
                j = j + 1
              end
            end
            self.tags[key] = ENUMS.TAG_SOURCES.SKIN
          end
          for i, tag in ipairs(platformTags) do
            local key = table.find(tagsDictionary, tag)
            if key == nil then
              local j = 1
              while true do
                key = tostring(j)
                if tagsDictionary[key] == nil then
                  tagsDictionary[key] = tag
                  break
                end
                j = j + 1
              end
            end
            self.tags[key] = ENUMS.TAG_SOURCES.PLATFORM
          end
        end
      else
        self.tags = tags
      end
      self.getTags = function(self)
        local n = 0
        local t = { }
        if self.tags ~= nil then
          for key, source in pairs(self.tags) do
            t[tagsDictionary[key]] = source
            n = n + 1
          end
        end
        return t, n
      end
      self.setTags = function(self, t)
        self.tags = { }
        local isEmpty = true
        for tag, source in pairs(t) do
          isEmpty = false
          local key = table.find(tagsDictionary, tag)
          if key == nil then
            local i = 1
            while true do
              key = tostring(i)
              if tagsDictionary[key] == nil then
                tagsDictionary[key] = tag
                break
              end
              i = i + 1
            end
          end
          self.tags[key] = source
        end
        if isEmpty then
          self.tags = nil
        end
      end
      self.hasTag = function(self, key)
        if self.tags == nil then
          return nil
        end
        if tonumber(key) == nil then
          key = table.find(tagsDictionary, key)
        end
        return self.tags[key]
      end
    end,
    __base = _base_0,
    __name = "Game"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Game = _class_0
end
if RUN_TESTS then
  local fullArgs = {
    title = 'The Game',
    path = 'C:\\Program Files\\The Game\\game.exe',
    platformID = ENUMS.PLATFORM_IDS.SHORTCUTS,
    platformOverride = 'SomePlatform',
    banner = 'Shortcuts\\SomePlatform\\The Game.jpg',
    process = 'game.exe',
    uninstalled = true,
    platformTags = {
      'Completed',
      'FPS'
    },
    lastPlayed = 123456789,
    hoursPlayed = 128.255
  }
  local oldArgs = {
    title = 'The Game',
    path = 'C:\\Program Files\\SomeDev\\The Game\\game.exe',
    platformID = ENUMS.PLATFORM_IDS.SHORTCUTS,
    banner = 'Shortcuts\\The Game.png',
    bannerURL = 'some_domain.com\\banners\\the_game.png',
    expectedBanner = 'The Game',
    process = 'game.exe',
    gameID = 7,
    processOverride = 'SomeOverlay.exe',
    hidden = true,
    lastPlayed = 102345678,
    hoursPlayed = 135.675,
    tags = {
      'Multiplayer'
    },
    startingBangs = {
      'Hide some skin ',
      'Show some other skin '
    },
    stoppingBangs = {
      'Show some skin',
      'Hide some other skin'
    },
    ignoresOtherBangs = true,
    notes = 'This is the game to end all games'
  }
  local game = Game(fullArgs)
  assert(game:getBanner() == nil, 'Game test failed!')
  assert(game:getBannerURL() == nil, 'Game test failed!')
  assert(game:getExpectedBanner() == nil, 'Game test failed!')
  assert(game:getGameID() == nil, 'Game test failed!')
  assert(game:getHoursPlayed() == fullArgs.hoursPlayed, 'Game test failed!')
  assert(game:getIgnoresOtherBangs() == false, 'Game test failed!')
  assert(game:getLastPlayed() == fullArgs.lastPlayed, 'Game test failed!')
  assert(game:getNotes() == nil, 'Game test failed!')
  assert(game:getPath() == fullArgs.path, 'Game test failed!')
  assert(game:getPlatformID() == fullArgs.platformID, 'Game test failed!')
  assert(game:getPlatformOverride() == fullArgs.platformOverride, 'Game test failed!')
  assert(game:getProcess() == fullArgs.process, 'Game test failed!')
  assert(game:getProcess(true) == fullArgs.process, 'Game test failed!')
  assert(game:getProcessOverride() == nil, 'Game test failed!')
  assert(#game:getStartingBangs() == 0, 'Game test failed!')
  assert(#game:getStoppingBangs() == 0, 'Game test failed!')
  assert(game:getTitle() == 'Game, The', 'Game test failed!')
  assert(#game:getTags() == 0, 'Game test failed!')
  assert(#game:getPlatformTags() == #fullArgs.platformTags, 'Game test failed!')
  local _list_0 = fullArgs.platformTags
  for _index_0 = 1, #_list_0 do
    local tag = _list_0[_index_0]
    assert(game:hasTag(tag) == true, 'Game test failed!')
  end
  assert(game:isInstalled() == false, 'Game test failed!')
  assert(game:isVisible() == true, 'Game test failed!')
  local oldGame = Game(oldArgs)
  assert(oldGame:getBanner() == oldArgs.banner, 'Game test failed!')
  assert(oldGame:getBannerURL() == oldArgs.bannerURL, 'Game test failed!')
  assert(oldGame:getExpectedBanner() == oldArgs.expectedBanner, 'Game test failed!')
  assert(oldGame:getGameID() == oldArgs.gameID, 'Game test failed!')
  assert(oldGame:getHoursPlayed() == oldArgs.hoursPlayed, 'Game test failed!')
  assert(oldGame:getIgnoresOtherBangs() == oldArgs.ignoresOtherBangs, 'Game test failed!')
  assert(oldGame:getLastPlayed() == oldArgs.lastPlayed, 'Game test failed!')
  assert(oldGame:getNotes() == oldArgs.notes, 'Game test failed!')
  assert(oldGame:getPath() == oldArgs.path, 'Game test failed!')
  assert(oldGame:getPlatformID() == oldArgs.platformID, 'Game test failed!')
  assert(oldGame:getPlatformOverride() == nil, 'Game test failed!')
  assert(oldGame:getProcess() == oldArgs.processOverride, 'Game test failed!')
  assert(oldGame:getProcess(true) == oldArgs.process, 'Game test failed!')
  assert(oldGame:getProcessOverride() == oldArgs.processOverride, 'Game test failed!')
  assert(#oldGame:getStartingBangs() == #oldArgs.startingBangs, 'Game test failed!')
  assert(#oldGame:getStoppingBangs() == #oldArgs.stoppingBangs, 'Game test failed!')
  assert(oldGame:getTitle() == 'Game, The', 'Game test failed!')
  assert(#oldGame:getTags() == #oldArgs.tags, 'Game test failed!')
  local _list_1 = oldArgs.tags
  for _index_0 = 1, #_list_1 do
    local tag = _list_1[_index_0]
    assert(oldGame:hasTag(tag) == true, 'Game test failed!')
  end
  assert(#oldGame:getPlatformTags() == 0, 'Game test failed!')
  assert(oldGame:isInstalled() == true, 'Game test failed!')
  assert(oldGame:isVisible() == false, 'Game test failed!')
  game:merge(oldGame)
  assert(game:getBanner() == nil, 'Game test failed!')
  assert(game:getBannerURL() == nil, 'Game test failed!')
  assert(game:getExpectedBanner() == nil, 'Game test failed!')
  assert(game:getGameID() == nil, 'Game test failed!')
  assert(game:getHoursPlayed() == oldArgs.hoursPlayed, 'Game test failed!')
  assert(game:getIgnoresOtherBangs() == oldArgs.ignoresOtherBangs, 'Game test failed!')
  assert(game:getLastPlayed() == fullArgs.lastPlayed, 'Game test failed!')
  assert(game:getNotes() == oldArgs.notes, 'Game test failed!')
  assert(game:getPath() == fullArgs.path, 'Game test failed!')
  assert(game:getPlatformID() == fullArgs.platformID, 'Game test failed!')
  assert(game:getPlatformOverride() == fullArgs.platformOverride, 'Game test failed!')
  assert(game:getProcess() == oldArgs.processOverride, 'Game test failed!')
  assert(game:getProcess(true) == fullArgs.process, 'Game test failed!')
  assert(game:getProcessOverride() == oldArgs.processOverride, 'Game test failed!')
  assert(#game:getStartingBangs() == #oldArgs.startingBangs, 'Game test failed!')
  assert(#game:getStoppingBangs() == #oldArgs.stoppingBangs, 'Game test failed!')
  assert(game:getTitle() == 'Game, The', 'Game test failed!')
  assert(#game:getTags() == #oldArgs.tags, 'Game test failed!')
  local _list_2 = oldArgs.tags
  for _index_0 = 1, #_list_2 do
    local tag = _list_2[_index_0]
    assert(game:hasTag(tag) == true, 'Game test failed!')
  end
  assert(#game:getPlatformTags() == #fullArgs.platformTags, 'Game test failed!')
  local _list_3 = fullArgs.platformTags
  for _index_0 = 1, #_list_3 do
    local tag = _list_3[_index_0]
    assert(game:hasTag(tag) == true, 'Game test failed!')
  end
  assert(game:isInstalled() == false, 'Game test failed!')
  assert(game:isVisible() == false, 'Game test failed!')
  assert(game:_moveThe('Game') == 'Game', 'Game test failed!')
  assert(game:_moveThe('Theatre of the Mind') == 'Theatre of the Mind', 'Game test failed!')
  assert(game:_moveThe('The Ides of March') == 'Ides of March, The', 'Game test failed!')
  assert(game:_parseProcess('C:\\Program Files\\SomeGame\\somegame.exe') == 'somegame.exe', 'Game test failed!')
  local process = 'SomeGame.exe'
  local defaultArgs = {
    title = 'Some game',
    path = ('C:\\Program Files\\SomeGame\\%s'):format(process),
    platformID = ENUMS.PLATFORM_IDS.SHORTCUTS
  }
  game = Game(defaultArgs)
  assert(game:getBanner() == nil, 'Game test failed!')
  assert(game:getBannerURL() == nil, 'Game test failed!')
  assert(game:getExpectedBanner() == nil, 'Game test failed!')
  assert(game:getGameID() == nil, 'Game test failed!')
  assert(game:getHoursPlayed() == 0, 'Game test failed!')
  assert(game:getIgnoresOtherBangs() == false, 'Game test failed!')
  assert(game:getLastPlayed() == 0, 'Game test failed!')
  assert(game:getNotes() == nil, 'Game test failed!')
  assert(game:getPath() == defaultArgs.path, 'Game test failed!')
  assert(game:getPlatformID() == defaultArgs.platformID, 'Game test failed!')
  assert(game:getPlatformOverride() == nil, 'Game test failed!')
  assert(game:getProcess() == process, 'Game test failed!')
  assert(game:getProcessOverride() == nil, 'Game test failed!')
  assert(type(game:getStartingBangs()) == 'table' and #game:getStartingBangs() == 0, 'Game test failed!')
  assert(type(game:getStoppingBangs()) == 'table' and #game:getStoppingBangs() == 0, 'Game test failed!')
  assert(game:getTitle() == defaultArgs.title, 'Game test failed!')
  assert(type(game:getTags()) == 'table' and #game:getTags() == 0, 'Game test failed!')
  assert(type(game:getPlatformTags()) == 'table' and #game:getPlatformTags() == 0, 'Game test failed!')
  assert(game:isInstalled() == true, 'Game test failed!')
  assert(game:isVisible() == true, 'Game test failed!')
  game:incrementHoursPlayed(127)
  assert(game:getHoursPlayed() == 127, 'Game test failed!')
  game:incrementHoursPlayed(128)
  assert(game:getHoursPlayed() == 255, 'Game test failed!')
  game:setBanner(nil)
  assert(game:getBanner() == nil, 'Game test failed!')
  game:setBanner(' ')
  assert(game:getBanner() == nil, 'Game test failed!')
  game:setBanner(' some image.jpg ')
  assert(game:getBanner() == 'some image.jpg', 'Game test failed!')
  game:setBannerURL(nil)
  assert(game:getBannerURL() == nil, 'Game test failed!')
  game:setBannerURL(' ')
  assert(game:getBannerURL() == nil, 'Game test failed!')
  game:setBannerURL(' some_domain.com\\banners\\some_image.jpg ')
  assert(game:getBannerURL() == 'some_domain.com\\banners\\some_image.jpg', 'Game test failed!')
  game:setExpectedBanner(nil)
  assert(game:getExpectedBanner() == nil, 'Game test failed!')
  game:setExpectedBanner(' ')
  assert(game:getExpectedBanner() == nil, 'Game test failed!')
  game:setExpectedBanner(' some banner.jpg ')
  assert(game:getExpectedBanner() == 'some banner.jpg', 'Game test failed!')
  local success, err = pcall(function()
    return game:setGameID(nil)
  end)
  assert(success == false, 'Game test failed!')
  game:setGameID(255)
  assert(game:getGameID() == 255, 'Game test failed!')
  game:setInstalled(false)
  local _ = assert(game:isInstalled() == false), 'Game test failed!'
  game:setInstalled(true)
  assert(game:isInstalled() == true, 'Game test failed!')
  game:setLastPlayed(987654321)
  assert(game:getLastPlayed(987654321), 'Game test failed!')
  game:setNotes(nil)
  assert(game:getNotes() == nil, 'Game test failed!')
  game:setNotes(' ')
  assert(game:getNotes() == nil, 'Game test failed!')
  game:setNotes('Some notes')
  assert(game:getNotes() == 'Some notes', 'Game test failed!')
  game:setProcessOverride(nil)
  assert(game:getProcess() == process, 'Game test failed!')
  assert(game:getProcess(true) == process, 'Game test failed!')
  assert(game:getProcessOverride() == nil, 'Game test failed!')
  game:setProcessOverride(' ')
  assert(game:getProcess() == process, 'Game test failed!')
  assert(game:getProcess(true) == process, 'Game test failed!')
  assert(game:getProcessOverride() == nil, 'Game test failed!')
  game:setProcessOverride(' SomeOverlay.exe ')
  assert(game:getProcess() == 'SomeOverlay.exe', 'Game test failed!')
  assert(game:getProcess(true) == process, 'Game test failed!')
  assert(game:getProcessOverride() == 'SomeOverlay.exe', 'Game test failed!')
  game:setStartingBangs({
    ' Hide some skin ',
    ' Show some other skin '
  })
  assert(#game:getStartingBangs() == 2, 'Game test failed!')
  game:setStoppingBangs({
    ' Show some skin ',
    ' Hide some other skin ',
    ' Terminate process '
  })
  assert(#game:getStoppingBangs() == 3, 'Game test failed!')
  game:setTags({
    ' Multiplayer ',
    ' '
  })
  assert(#game:getTags() == 1, 'Game test failed!')
  assert(game:hasTag('Multiplayer') == true, 'Game test failed!')
  assert(game:hasTag('FPS') == false, 'Game test failed!')
  game:setTags({ })
  assert(#game:getTags() == 0, 'Game test failed!')
  assert(game:hasTag('Multiplayer') == false, 'Game test failed!')
  game:setTags({
    ' ',
    ' FPS '
  })
  assert(#game:getTags() == 1, 'Game test failed!')
  assert(game:hasTag('FPS') == true, 'Game test failed!')
  assert(game:hasTag('Multiplayer') == false, 'Game test failed!')
  game:setVisible(false)
  assert(game:isVisible() == false, 'Game test failed!')
  game:setVisible(true)
  assert(game:isVisible() == true, 'Game test failed!')
  game:toggleIgnoresOtherBangs(true)
  assert(game:getIgnoresOtherBangs() == true, 'Game test failed!')
  game:toggleIgnoresOtherBangs(false)
  assert(game:getIgnoresOtherBangs() == false, 'Game test failed!')
  game:toggleVisibility()
  assert(game:isVisible() == false, 'Game test failed!')
  game:toggleVisibility()
  assert(game:isVisible() == true, 'Game test failed!')
end
return Game
