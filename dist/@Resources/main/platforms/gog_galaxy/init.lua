local Platform = require('main.platforms.platform')
local Game = require('main.game')
local json = require('lib.json')
local GOGGalaxy
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    hasDumpedDatabases = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    dumpDatabases = function(self)
      assert(self.programDataPath ~= nil, 'The path to GOG Galaxy\'s ProgramData path has not been defined.')
      local indexDBPath = io.joinPaths(self.programDataPath, 'storage\\index.db')
      local galaxyDBPath = io.joinPaths(self.programDataPath, 'storage\\galaxy.db')
      assert(io.fileExists(indexDBPath, false) == true, ('"%s" does not exist.'):format(indexDBPath))
      assert(io.fileExists(galaxyDBPath, false) == true, ('"%s" does not exist.'):format(galaxyDBPath))
      local sqlitePath = io.joinPaths(STATE.PATHS.RESOURCES, 'sqlite3.exe')
      assert(io.fileExists(sqlitePath, false) == true, ('SQLite3 CLI tool is missing. Expected the path to be "%s".'):format(sqlitePath))
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\dumpDatabases.bat" "%s" "%s"]'):format(indexDBPath, galaxyDBPath))
      return self:getWaitCommand(), '', 'OnDumpedDBs'
    end,
    parseIndexDB = function(self)
      local output = io.readFile(io.joinPaths(self.cachePath, 'index.txt'))
      local lines = output:splitIntoLines()
      local productIDs = { }
      local paths = { }
      for _index_0 = 1, #lines do
        local line = lines[_index_0]
        local productID, path = line:match('^(%d+)|(.+)$')
        productIDs[productID] = true
        paths[productID] = path
      end
      return productIDs, paths
    end,
    parseGalaxyDB = function(self, productIDs)
      local output = io.readFile(io.joinPaths(self.cachePath, 'galaxy.txt'))
      local lines = output:splitIntoLines()
      local titles = { }
      local bannerURLs = { }
      for _index_0 = 1, #lines do
        local _continue_0 = false
        repeat
          local line = lines[_index_0]
          local productID, title, images = line:match('^(%d+)|([^|]+)|(.+)$')
          if not (productIDs[productID] == true) then
            _continue_0 = true
            break
          end
          titles[productID] = title
          images = json.decode(images:lower())
          bannerURLs[productID] = images.logo:gsub('_glx_logo', '_392')
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      return titles, bannerURLs
    end,
    generateGames = function(self)
      local games = { }
      local productIDs, paths = self:parseIndexDB()
      local titles, bannerURLs = self:parseGalaxyDB(productIDs)
      for productID, _ in pairs(productIDs) do
        local info = io.readFile(io.joinPaths(paths[productID], ('goggame-%s.info'):format(productID)), false)
        info = json.decode(info)
        local exePath = (info.playTasks[1].path:gsub('//', '\\'))
        local banner = self:getBannerPath(productID)
        local bannerURL = nil
        local expectedBanner = nil
        if not (banner) then
          bannerURL = bannerURLs[productID]
          banner = io.joinPaths(self.cachePath, productID .. bannerURL:reverse():match('^([^%.]+%.)'):reverse())
          expectedBanner = productID
        end
        local path = nil
        if self.indirectLaunch then
          path = ('"%s" "/command=runGame" "/gameId=%s"'):format(self.clientPath, productID)
        else
          path = ('"%s"'):format(io.joinPaths(paths[productID], exePath))
        end
        table.insert(games, {
          banner = banner,
          bannerURL = bannerURL,
          expectedBanner = expectedBanner,
          title = titles[productID],
          path = path,
          platformID = self.platformID,
          process = exePath:reverse():match('^([^\\]+)'):reverse()
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
      self.platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
      self.name = 'GOG Galaxy'
      self.cachePath = 'cache\\gog_galaxy\\'
      self.enabled = settings:getGOGGalaxyEnabled()
      self.programDataPath = settings:getGOGGalaxyProgramDataPath()
      if self.enabled then
        assert(io.fileExists(io.joinPaths(self.programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
        assert(io.fileExists(io.joinPaths(self.programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
      end
      self.indirectLaunch = settings:getGOGGalaxyIndirectLaunch()
      if self.indirectLaunch then
        self.platformProcess = 'GalaxyClient.exe'
      end
      self.clientPath = settings:getGOGGalaxyClientPath()
      if self.clientPath ~= nil then
        self.clientPath = io.joinPaths(self.clientPath, 'GalaxyClient.exe')
        if self.indirectLaunch then
          assert(io.fileExists(self.clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
        end
      elseif self.indirectLaunch then
        assert(self.clientPath ~= nil, 'A path to the GOG Galaxy client has not been defined.')
      end
      self.games = { }
    end,
    __base = _base_0,
    __name = "GOGGalaxy",
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
  GOGGalaxy = _class_0
end
return GOGGalaxy
