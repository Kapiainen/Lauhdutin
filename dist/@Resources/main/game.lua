local utility = require('shared.utility')
local Game
do
  local _class_0
  local _base_0 = {
    merge = function(self, old)
      assert(old.__class == Game, '"merge" expected "old" to be an instance of "Game".')
      log('Merging: ' .. old.title)
      self.processOverride = old.processOverride
      self.hidden = old.hidden
      if self.lastPlayed ~= nil then
        if old.lastPlayed ~= nil and old.lastPlayed > self.lastPlayed then
          self.lastPlayed = old.lastPlayed
        end
      else
        self.lastPlayed = old.lastPlayed
      end
      if self.hoursPlayed ~= nil then
        if old.hoursPlayed ~= nil and old.hoursPlayed > self.hoursPlayed then
          self.hoursPlayed = old.hoursPlayed
        end
      else
        self.hoursPlayed = old.hoursPlayed
      end
      self.tags = old.tags
      self.startingBangs = old.startingBangs
      self.stoppingBangs = old.stoppingBangs
      self.ignoresOtherBangs = old.ignoresOtherBangs
      self.notes = old.notes
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
      assert(type(value) == 'number' and value % 1 == 0, '"Game.setGameID" expected "value" to be an integer.')
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
    getPath = function(self)
      return self.path
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
      process = process:trim()
      if process == '' then
        self.processOverride = nil
      else
        self.processOverride = process
      end
    end,
    getBanner = function(self)
      return self.banner
    end,
    setBanner = function(self, path)
      if path == nil then
        self.banner = nil
      else
        path = path:trim()
        if path == '' then
          self.banner = the(nil)
        else
          self.banner = path
        end
      end
    end,
    getExpectedBanner = function(self)
      return self.expectedBanner
    end,
    setExpectedBanner = function(self, str)
      self.expectedBanner = str
    end,
    getBannerURL = function(self)
      return self.bannerURL
    end,
    setBannerURL = function(self, url)
      if url == nil then
        self.bannerURL = nil
      else
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
    incrementHoursPlayed = function(self, hours)
      if hours >= 0 then
        if self.hoursPlayed == nil then
          self.hoursPlayed = 0
        end
        self.hoursPlayed = self.hoursPlayed + hours
      end
    end,
    getTags = function(self)
      return self.tags or { }
    end,
    setTags = function(self, tags)
      self.tags = { }
      for _index_0 = 1, #tags do
        local tag = tags[_index_0]
        tag = tag:trim()
        if tag ~= '' then
          table.insert(self.tags, tag)
        end
      end
    end,
    getPlatformTags = function(self)
      return self.platformTags or { }
    end,
    hasTag = function(self, tag)
      if self.tags ~= nil then
        local _list_0 = self.tags
        for _index_0 = 1, #_list_0 do
          local t = _list_0[_index_0]
          if t == tag then
            return true
          end
        end
      end
      if self.platformTags ~= nil then
        local _list_0 = self.platformTags
        for _index_0 = 1, #_list_0 do
          local t = _list_0[_index_0]
          if t == tag then
            return true
          end
        end
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
      if str:trim() == '' then
        self.notes = nil
      else
        self.notes = str
      end
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      assert(type(args.title) == 'string', '"Game" expected "args.title" to be a string.')
      self.title = self:_moveThe(args.title)
      assert(type(args.path) == 'string', '"Game" expected "args.path" to be a string.')
      self.path = args.path
      assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, '"Game" expected "args.platformID" to be an integer.')
      self.platformID = args.platformID
      self.platformOverride = args.platformOverride
      if args.banner ~= nil and io.fileExists(args.banner) then
        self.banner = args.banner
      end
      self.expectedBanner = args.expectedBanner
      self.bannerURL = args.bannerURL
      self.process = args.process or self:_parseProcess(self.path)
      self.uninstalled = args.uninstalled
      self.gameID = args.gameID
      self.platformTags = args.platformTags
      self.processOverride = args.processOverride
      self.hidden = args.hidden
      self.lastPlayed = args.lastPlayed
      self.hoursPlayed = args.hoursPlayed
      self.tags = args.tags
      self.startingBangs = args.startingBangs
      self.stoppingBangs = args.stoppingBangs
      self.ignoresOtherBangs = args.ignoresOtherBangs
      self.notes = args.notes
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
return Game
