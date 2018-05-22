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
      assert(type(value) == 'number')
      local binary = { }
      for bit = 32, 1, -1 do
        binary[bit] = math.fmod(value, 2)
        value = math.floor((value - binary[bit]) / 2)
      end
      return table.concat(binary)
    end,
    adjustBinaryStringHash = function(self, binary)
      assert(type(binary) == 'string')
      return binary .. '00000010000000000000000000000000'
    end,
    toDecimalString = function(self, binary)
      assert(type(binary) == 'string')
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
      SKIN:Bang('["#@#windowless.vbs" "#@#main\\platforms\\steam\\deleteCachedCommunityProfile.bat"]')
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
            title = title:trim(),
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
      log('Getting Steam libraries from libraryfolders.vdf')
      local libraries = {
        io.joinPaths(self.steamPath, 'steamapps\\')
      }
      local libraryFoldersPath = io.joinPaths(self.steamPath, 'steamapps\\libraryfolders.vdf')
      if io.fileExists(libraryFoldersPath, false) then
        local file = io.readFile(libraryFoldersPath, false)
        local lines = file:splitIntoLines()
        local vdf = utility.parseVDF(lines)
        if type(vdf.libraryfolders) == 'table' then
          for key, value in pairs(vdf.libraryfolders) do
            if tonumber(key) ~= nil then
              if value:endsWith('\\') then
                value = value .. '\\'
              end
              table.insert(libraries, io.joinPaths((value:gsub('\\\\', '\\')), 'steamapps\\'))
            end
          end
        else
          log('\\Steam\\steamapps\\libraryfolders.vdf does not contain a table called "libraryfolders".')
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
      log('Parsing localconfig.vdf')
      local file = io.readFile(io.joinPaths(self.steamPath, 'userdata\\', self.accountID, 'config\\localconfig.vdf'), false)
      local lines = file:splitIntoLines()
      return utility.parseVDF(lines)
    end,
    parseSharedConfig = function(self)
      log('Parsing sharedconfig.vdf')
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
          log('Processing Steam game:', manifest)
          local appID = manifest:match('appmanifest_(%d+)%.acf')
          if appID == nil then
            log('Skipping Steam game because the appID could not be parsed')
            _continue_0 = true
            break
          end
          assert(type(appID) == 'string', 'main.platforms.steam.init.generateGames')
          if games[appID] ~= nil then
            log('Skipping Steam game', appID, 'because it has already been processed')
            _continue_0 = true
            break
          end
          if self.communityProfileGames ~= nil and self.communityProfileGames[appID] == nil then
            log('Skipping Steam game', appID, 'because it does not appear in the community profile')
            _continue_0 = true
            break
          end
          file = io.readFile(io.joinPaths(libraryPath, manifest), false)
          local lines = file:splitIntoLines()
          local success, vdf = pcall(utility.parseVDF, lines)
          if not (success) then
            log(('Failed to parse "%s": %s'):format(manifest, vdf))
            _continue_0 = true
            break
          end
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
if RUN_TESTS then
  local assertionMessage = 'Steam test failed!'
  local settings = {
    getSteamEnabled = function(self)
      return true
    end,
    getSteamPath = function(self)
      return 'Y:\\Program Files (32)\\Steam'
    end,
    getSteamAccountID = function(self)
      return '1234567890'
    end,
    getSteamCommunityID = function(self)
      return '987654321'
    end,
    getSteamParseCommunityProfile = function(self)
      return true
    end
  }
  local steam = Steam(settings)
  assert(steam:toBinaryString(136) == '00000000000000000000000010001000', assertionMessage)
  assert(steam:toBinaryString(5895412582) == '01011111011001001101101101100110', assertionMessage)
  assert(steam:adjustBinaryStringHash('') == '00000010000000000000000000000000', assertionMessage)
  assert(steam:adjustBinaryStringHash('0101') == '010100000010000000000000000000000000', assertionMessage)
  assert(steam:toDecimalString('1111') == '15', assertionMessage)
  assert(steam:toDecimalString('01001000100011100100111000010000') == '1217285648', assertionMessage)
  assert(steam:generateAppID('Whatevs', '"Y:\\Program Files (32)\\SomeGame\\game.exe"') == '17882896429207257088', assertionMessage)
  assert(steam:generateAppID('Spelunky Classic', '"D:\\Games\\GOG\\Spelunky Classic\\Spelunky.exe"') == '15292025676400427008', assertionMessage)
  local profile = 'Some kind of header or other junk that we are not interested in...\n<game>\n	<appID>40400</appID>\n	<name><![CDATA[ AI War: Fleet Command ]]></name>\n	<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/40400/91c4cd7c72ae83b354e9380f9e69849c34e163c3.jpg]]></logo>\n	<storeLink><![CDATA[ http://steamcommunity.com/app/40400 ]]></storeLink>\n	<hoursOnRecord>73.0</hoursOnRecord>\n	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AIWar/achievements/]]></globalStatsLink>\n</game>\n<game>\n	<appID>108710</appID>\n	<name><![CDATA[ Alan Wake ]]></name>\n	<logo>\n	<![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/108710/0f9b6613ac50bf42639ed6a2e16e9b78e846ef0a.jpg]]></logo>\n	<storeLink><![CDATA[ http://steamcommunity.com/app/108710 ]]></storeLink>\n	<hoursOnRecord>26.7</hoursOnRecord>\n	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AlanWake/achievements/]]></globalStatsLink>\n</game>\n<game>\n	<appID>630</appID>\n	<name><![CDATA[ Alien Swarm ]]></name>\n	<logo><![CDATA[http://cdn.edgecast.steamstatic.com/steamcommunity/public/images/apps/630/de3320a2c29b55b6f21d142dee26d9b044a29e97.jpg]]></logo>\n	<storeLink><![CDATA[ http://steamcommunity.com/app/630 ]]></storeLink>\n	<globalStatsLink><![CDATA[http://steamcommunity.com/stats/AlienSwarm/achievements/]]></globalStatsLink>\n</game>\nMore games, etc.'
  steam:parseCommunityProfile(profile)
  local numGames = 0
  local games = steam.communityProfileGames
  for appID, info in pairs(steam.communityProfileGames) do
    local _exp_0 = appID
    if '40400' == _exp_0 then
      assert(info.title == 'AI War: Fleet Command', assertionMessage)
      assert(info.hoursPlayed == 73.0, assertionMessage)
    elseif '108710' == _exp_0 then
      assert(info.title == 'Alan Wake', assertionMessage)
      assert(info.hoursPlayed == 26.7, assertionMessage)
    elseif '630' == _exp_0 then
      assert(info.title == 'Alien Swarm', assertionMessage)
      assert(info.hoursPlayed == nil, assertionMessage)
    else
      assert(nil, assertionMessage)
    end
    numGames = numGames + 1
  end
  assert(numGames == 3, assertionMessage)
  local sharedConfig = {
    userroamingconfigstore = {
      software = {
        valve = {
          steam = {
            apps = {
              ['654035'] = {
                tags = {
                  'FPS',
                  'Multiplayer'
                }
              }
            }
          }
        }
      }
    }
  }
  assert(steam:getTags('654020', sharedConfig) == nil, assertionMessage)
  assert(#steam:getTags('654035', sharedConfig) == 2, assertionMessage)
  local localConfig = {
    userlocalconfigstore = {
      software = {
        valve = {
          steam = {
            apps = {
              ['654020'] = {
                lastplayed = '123456789'
              }
            }
          }
        }
      }
    }
  }
  assert(steam:getLastPlayed('654020', localConfig) == 123456789, assertionMessage)
  assert(steam:getLastPlayed('654035', localConfig) == nil, assertionMessage)
  assert(steam:getPath('84065421351') == 'steam://rungameid/84065421351', assertionMessage)
end
return Steam
