local utility = require('shared.utility')
local bit = require('lib.bit.numberlua')
local digest = require('lib.digest.crc32')
local Platform = require('main.platforms.platform')
local Game = require('main.game')
local lookupTable
do
  local _accum_0 = { }
  local _len_0 = 1
  for i = 0, 56 do
    _accum_0[_len_0] = ('%.0f'):format(2 ^ i)
    _len_0 = _len_0 + 1
  end
  lookupTable = _accum_0
end
lookupTable[58] = '144115188075855872'
lookupTable[59] = '288230376151711744'
lookupTable[60] = '576460752303423488'
lookupTable[61] = '1152921504606846976'
lookupTable[62] = '2305843009213693952'
lookupTable[63] = '4611686018427387904'
lookupTable[64] = '9223372036854775808'
local Steam
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self)
      local clientPath = io.joinPaths(self.steamPath, 'steam.exe')
      assert(io.fileExists(clientPath, false), 'The Steam path is not valid.')
      assert(self.accountID ~= nil, 'A Steam account has not been chosen.')
      assert(tonumber(self.accountID) ~= nil, 'The Steam account is invalid.')
      if self.useCommunityProfile then
        assert(self.communityID ~= nil, 'A Steam ID has not been provided for downloading the community profile.')
        return assert(tonumber(self.communityID) ~= nil, 'The Steam ID is invalid.')
      end
    end,
    toBinaryString = function(self, value)
      local binary = { }
      for bit = 32, 1, -1 do
        binary[bit] = math.fmod(value, 2)
        value = math.floor((value - binary[bit]) / 2)
      end
      return table.concat(binary)
    end,
    adjustBinaryStringHash = function(self, binary)
      return binary .. '00000010000000000000000000000000'
    end,
    toDecimalString = function(self, binary)
      local bitValues = { }
      local i = #binary
      for char in binary:gmatch('.') do
        if char == '1' then
          table.insert(bitValues, lookupTable[i])
        end
        i = i - 1
      end
      local maxNumDigits = 24
      local digits
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, maxNumDigits do
          _accum_0[_len_0] = 0
          _len_0 = _len_0 + 1
        end
        digits = _accum_0
      end
      while #bitValues > 0 do
        i = 1
        local carry = 0
        local bitValue = table.remove(bitValues, 1)
        while i <= maxNumDigits do
          local temp = digits[i] + carry
          if bitValue[i] ~= nil then
            temp = temp + bitValue[i]
          end
          if temp > 9 then
            temp = temp % 10
            carry = 1
          else
            carry = 0
          end
          digits[i] = temp
          i = i + 1
        end
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #digits do
          local digit = digits[_index_0]
          _accum_0[_len_0] = tostring(digit)
          _len_0 = _len_0 + 1
        end
        digits = _accum_0
      end
      local decimalString = table.concat(digits):reverse()
      return decimalString:sub((decimalString:find('[^0]')))
    end,
    generateAppID = function(self, title, path)
      local value = path .. title
      local hash = digest.crc32(value)
      hash = bit.bor(hash, 0x80000000)
      local binaryHash = self:toBinaryString(hash)
      binaryHash = self:adjustBinaryStringHash(binaryHash)
      return self:toDecimalString(binaryHash)
    end,
    downloadCommunityProfile = function(self)
      if not (self.useCommunityProfile) then
        return nil
      end
      assert(type(self.communityID) == 'string', 'main.platforms.steam.init.downloadCommunityProfile')
      local url = ('http://steamcommunity.com/profiles/%s/games/?tab=all&xml=1'):format(self.communityID)
      return url, 'communityProfile.txt', 'OnCommunityProfileDownloaded', 'OnCommunityProfileDownloadFailed'
    end,
    getDownloadedCommunityProfilePath = function(self)
      return io.joinPaths(STATE.PATHS.DOWNLOADFILE, 'communityProfile.txt')
    end,
    getCachedCommunityProfilePath = function(self)
      return io.joinPaths(STATE.PATHS.RESOURCES, self.cachePath, 'communityProfile.txt')
    end,
    parseCommunityProfile = function(self, profile)
      local games = { }
      local num = 0
      for game in profile:gmatch('<game>(.-)</game>') do
        local _continue_0 = false
        repeat
          local appID = game:match('<appID>(%d+)</appID>')
          if games[appID] ~= nil then
            _continue_0 = true
            break
          end
          local title = game:match('<name><!%[CDATA%[(.-)%]%]></name>')
          if title == nil then
            log('Skipping Steam game', appID, 'because a title could not be parsed from the community profile')
            _continue_0 = true
            break
          end
          games[appID] = {
            title = title,
            hoursPlayed = tonumber(game:match('<hoursOnRecord>(%d+%.%d*)</hoursOnRecord>'))
          }
          num = num + 1
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      log('Games found in the Steam community profile:', num)
      self.communityProfileGames = games
    end,
    getLibraries = function(self)
      local libraries = {
        io.joinPaths(self.steamPath, 'steamapps\\')
      }
      local libraryFoldersPath = io.joinPaths(self.steamPath, 'steamapps\\libraryfolders.vdf')
      if io.fileExists(libraryFoldersPath, false) then
        local file = io.readFile(libraryFoldersPath, false)
        local lines = file:splitIntoLines()
        local vdf = utility.parseVDF(lines)
        for key, value in pairs(vdf.libraryfolders) do
          if tonumber(key) ~= nil then
            if value:endsWith('\\') then
              value = value .. '\\'
            end
            table.insert(libraries, io.joinPaths((value:gsub('\\\\', '\\')), 'steamapps\\'))
          end
        end
      else
        log('Could not find "\\Steam\\steamapps\\libraryfolders.vdf"')
      end
      self.libraries = libraries
    end,
    hasLibrariesToParse = function(self)
      return #self.libraries > 0
    end,
    hasGottenACFs = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    getACFs = function(self)
      io.writeFile(io.joinPaths(self.cachePath, 'output.txt'), '')
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\steam\\getACFs.bat" "%s"]'):format(self.libraries[1]))
      return self:getWaitCommand(), '', 'OnGotACFs'
    end,
    parseLocalConfig = function(self)
      local file = io.readFile(io.joinPaths(self.steamPath, 'userdata\\', self.accountID, 'config\\localconfig.vdf'), false)
      local lines = file:splitIntoLines()
      return utility.parseVDF(lines)
    end,
    parseSharedConfig = function(self)
      local file = io.readFile(io.joinPaths(self.steamPath, 'userdata\\', self.accountID, '\\7\\remote\\sharedconfig.vdf'), false)
      local lines = file:splitIntoLines()
      return utility.parseVDF(lines)
    end,
    getTags = function(self, appID, sharedConfig)
      local tags = nil
      local config = sharedConfig.userroamingconfigstore
      if config == nil then
        config = sharedConfig.userlocalconfigstore
      end
      if config == nil then
        log('Steam sharedConfig has an unsupported structure at the top-level')
        return tags
      end
      if config.software == nil then
        log('Steam sharedConfig.software is nil')
        return tags
      end
      if config.software.valve == nil then
        log('Steam sharedConfig.software.valve is nil')
        return tags
      end
      if config.software.valve.steam == nil then
        log('Steam sharedConfig.software.valve.steam is nil')
        return tags
      end
      if config.software.valve.steam.apps == nil then
        log('Steam sharedConfig.software.valve.steam.apps is nil')
        return tags
      end
      local app = config.software.valve.steam.apps[appID]
      if app == nil then
        log('Could not find the Steam game', appID, 'in sharedConfig')
        return tags
      end
      if app.tags == nil then
        log('Failed to get tags for Steam game', appID)
        return tags
      end
      if type(app.tags) ~= 'table' then
        return tags
      end
      tags = { }
      for index, tag in pairs(app.tags) do
        table.insert(tags, tag)
      end
      if #tags > 0 then
        return tags
      else
        return nil
      end
    end,
    getLastPlayed = function(self, appID, localConfig)
      local lastPlayed = nil
      local config = localConfig.userroamingconfigstore
      if config == nil then
        config = localConfig.userlocalconfigstore
      end
      if config == nil then
        log('Steam localConfig has an unsupported structure at the top-level')
        return lastPlayed
      end
      if config.software == nil then
        log('Steam localConfig.software is nil')
        return lastPlayed
      end
      if config.software.valve == nil then
        log('Steam localConfig.software.valve is nil')
        return lastPlayed
      end
      if config.software.valve.steam == nil then
        log('Steam localConfig.software.valve.steam is nil')
        return lastPlayed
      end
      if config.software.valve.steam.apps == nil then
        log('Steam localConfig.software.valve.steam.apps is nil')
        return lastPlayed
      end
      local app = config.software.valve.steam.apps[appID]
      if app == nil then
        log('Could not find the Steam game', appID, 'in localConfig')
        return lastPlayed
      end
      if app.lastplayed == nil then
        log('Failed to get last played timestamp for Steam game', appID)
        return lastPlayed
      end
      lastPlayed = tonumber(app.lastplayed)
      return lastPlayed
    end,
    getBanner = function(self, appID)
      local banner = self:getBannerPath(appID)
      if banner then
        return banner, nil
      end
      local _list_0 = self.bannerExtensions
      for _index_0 = 1, #_list_0 do
        local extension = _list_0[_index_0]
        local gridBannerPath = io.joinPaths(self.steamPath, 'userdata\\', self.accountID, 'config\\grid\\', appID .. extension)
        local cacheBannerPath = io.joinPaths(self.cachePath, appID .. extension)
        if io.fileExists(gridBannerPath, false) and not io.fileExists(cacheBannerPath) then
          io.copyFile(gridBannerPath, cacheBannerPath, false)
          return cacheBannerPath, nil
        end
      end
      banner = io.joinPaths(self.cachePath, appID .. '.jpg')
      local bannerURL = ('http://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg'):format(appID)
      return banner, bannerURL
    end,
    getPath = function(self, appID)
      return ('steam://rungameid/%s'):format(appID)
    end,
    getProcess = function(self)
      return 'GameOverlayUI.exe'
    end,
    generateShortcuts = function(self)
      local games = { }
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #lookupTable do
          local value = lookupTable[_index_0]
          do
            local _accum_1 = { }
            local _len_1 = 1
            for char in value:reverse():gmatch('.') do
              _accum_1[_len_1] = tonumber(char)
              _len_1 = _len_1 + 1
            end
            _accum_0[_len_0] = _accum_1
          end
          _len_0 = _len_0 + 1
        end
        lookupTable = _accum_0
      end
      local shortcutsPath = io.joinPaths(self.steamPath, 'userdata\\', self.accountID, '\\config\\shortcuts.vdf')
      if not (io.fileExists(shortcutsPath, false)) then
        return nil
      end
      local contents = io.readFile(shortcutsPath, false, 'rb')
      contents = contents:gsub('%c', '|')
      local shortcutsBannerPath = 'cache\\steam_shortcuts'
      for game in contents:reverse():gmatch('(.-)emaNppA') do
        local _continue_0 = false
        repeat
          game = game:reverse()
          local title = game:match('|(.-)|')
          if title == nil then
            log('Skipping Steam shortcut because the title could not be parsed')
            _continue_0 = true
            break
          end
          local path = ('"%s"'):format(game:match('"(.-)"'))
          if path == nil then
            log('Skipping Steam shortcut because the path could not be parsed')
            _continue_0 = true
            break
          end
          local appID = self:generateAppID(title, path)
          if appID == nil then
            log('Skipping Steam shortcut because the appID could not be generated')
            _continue_0 = true
            break
          end
          path = ('steam://rungameid/%s'):format(appID)
          local banner = self:getBannerPath(appID, shortcutsBannerPath)
          local expectedBanner = nil
          if not (banner) then
            local _list_0 = self.bannerExtensions
            for _index_0 = 1, #_list_0 do
              local extension = _list_0[_index_0]
              local gridBannerPath = io.joinPaths(self.steamPath, 'userdata\\', self.accountID, 'config\\grid\\', appID .. extension)
              local cacheBannerPath = io.joinPaths(shortcutsBannerPath, appID .. extension)
              if io.fileExists(gridBannerPath, false) and not io.fileExists(cacheBannerPath) then
                io.copyFile(gridBannerPath, cacheBannerPath, false)
                break
              end
            end
            banner = self:getBannerPath(appID)
          end
          if not (banner) then
            expectedBanner = appID
          end
          local process
          if game:match('AllowOverlay') then
            process = 'GameOverlayUI.exe'
          else
            process = nil
          end
          local tags = { }
          local tagsString = game:match('tags|(.+)')
          if tagsString then
            for tag in tagsString:gmatch('|%d|([^|]+)|') do
              table.insert(tags, tag)
            end
          end
          if #tags == 0 then
            tags = nil
          end
          table.insert(games, {
            title = title,
            path = path,
            process = process,
            banner = banner,
            expectedBanner = expectedBanner,
            platformOverride = self.name,
            platformTags = tags,
            platformID = self.platformID
          })
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      for _index_0 = 1, #games do
        local args = games[_index_0]
        table.insert(self.games, Game(args))
      end
    end,
    generateGames = function(self)
      if self.localConfig == nil then
        self.localConfig = self:parseLocalConfig()
      end
      if self.sharedConfig == nil then
        self.sharedConfig = self:parseSharedConfig()
      end
      local libraryPath = table.remove(self.libraries, 1)
      local games = { }
      local file = io.readFile(io.joinPaths(self.cachePath, 'output.txt'))
      local manifests = file:splitIntoLines()
      for _index_0 = 1, #manifests do
        local _continue_0 = false
        repeat
          local manifest = manifests[_index_0]
          local appID = manifest:match('appmanifest_(%d+)%.acf')
          if appID == nil then
            log('Skipping Steam game because the appID could not be parsed')
            _continue_0 = true
            break
          end
          assert(type(appID) == 'string', 'main.platforms.steam.init.generateGames')
          if games[appID] ~= nil then
            _continue_0 = true
            break
          end
          if self.communityProfileGames ~= nil and self.communityProfileGames[appID] == nil then
            _continue_0 = true
            break
          end
          file = io.readFile(io.joinPaths(libraryPath, manifest), false)
          local lines = file:splitIntoLines()
          local vdf = utility.parseVDF(lines)
          local title = nil
          if vdf.appstate ~= nil then
            title = vdf.appstate.name
          end
          if title == nil and vdf.userconfig ~= nil then
            title = vdf.userconfig.name
          end
          if title == nil and self.communityProfileGames ~= nil and self.communityProfileGames[appID] ~= nil then
            title = self.communityProfileGames[appID].title
          end
          if title == nil then
            log('Skipping Steam game', appID, 'because title could not be found')
            _continue_0 = true
            break
          end
          local banner, bannerURL = self:getBanner(appID)
          local expectedBanner
          if banner ~= nil then
            expectedBanner = nil
          else
            expectedBanner = appID
          end
          local hoursPlayed = nil
          if self.communityProfileGames ~= nil and self.communityProfileGames[appID] ~= nil then
            hoursPlayed = self.communityProfileGames[appID].hoursPlayed
            self.communityProfileGames[appID] = nil
          end
          games[appID] = {
            title = title,
            path = self:getPath(appID),
            platformID = self.platformID,
            banner = banner,
            bannerURL = bannerURL,
            expectedBanner = expectedBanner,
            hoursPlayed = hoursPlayed,
            lastPlayed = self:getLastPlayed(appID, self.localConfig),
            platformTags = self:getTags(appID, self.sharedConfig),
            process = self:getProcess()
          }
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      if self.communityProfileGames ~= nil and #self.libraries == 0 then
        log('Processing remaining Steam games found in the community profile')
        for appID, game in pairs(self.communityProfileGames) do
          local _continue_0 = false
          repeat
            if games[appID] ~= nil then
              _continue_0 = true
              break
            end
            local banner, bannerURL = self:getBanner(appID)
            local expectedBanner
            if banner ~= nil then
              expectedBanner = nil
            else
              expectedBanner = appID
            end
            games[appID] = {
              title = game.title,
              path = ('steam://rungameid/%s'):format(appID),
              platformID = self.platformID,
              banner = banner,
              bannerURL = bannerURL,
              expectedBanner = expectedBanner,
              hoursPlayed = game.hoursPlayed,
              lastPlayed = self:getLastPlayed(appID, self.localConfig),
              platformTags = self:getTags(appID, self.sharedConfig),
              process = self:getProcess(),
              uninstalled = true
            }
            self.communityProfileGames[appID] = nil
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      end
      for appID, args in pairs(games) do
        table.insert(self.games, Game(args))
      end
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      _class_0.__parent.__init(self, settings)
      self.name = "Steam"
      self.platform = 'steam'
      self.platformID = ENUMS.PLATFORM_IDS.STEAM
      self.platformProcess = 'Steam.exe'
      self.cachePath = 'cache\\steam\\'
      self.enabled = settings:getSteamEnabled()
      self.steamPath = settings:getSteamPath()
      self.accountID = settings:getSteamAccountID()
      self.communityID = settings:getSteamCommunityID()
      self.useCommunityProfile = settings:getSteamParseCommunityProfile()
      self.games = { }
      self.communityProfilePath = io.joinPaths(self.cachePath, 'communityProfile.txt')
      self.communityProfileGames = nil
      if self.enabled then
        return SKIN:Bang('["#@#windowless.vbs" "#@#main\\platforms\\steam\\deleteCachedCommunityProfile.bat"]')
      end
    end,
    __base = _base_0,
    __name = "Steam",
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
  Steam = _class_0
end
return Steam
