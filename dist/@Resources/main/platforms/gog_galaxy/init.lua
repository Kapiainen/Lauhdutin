local Platform = require('main.platforms.platform')
local json = require('lib.json')
local GOGGalaxy
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self)
      assert(io.fileExists(io.joinPaths(self.programDataPath, 'storage\\galaxy.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
      local sqlitePath = io.joinPaths(STATE.PATHS.RESOURCES, 'sqlite3.exe')
      assert(io.fileExists(sqlitePath, false) == true, ('SQLite3 CLI tool is missing. Expected the path to be "%s".'):format(sqlitePath))
      if self.clientPath ~= nil then
        self.clientPath = io.joinPaths(self.clientPath, 'GalaxyClient.exe')
        if self.indirectLaunch then
          assert(io.fileExists(self.clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
        end
      elseif self.indirectLaunch then
        assert(self.clientPath ~= nil, 'A path to the GOG Galaxy client has not been defined.')
      end
      if self.useCommunityProfile == true then
        assert(type(self.communityProfileName) == 'string' and #self.communityProfileName > 0, 'A GOG profile name has not been defined.')
        assert(io.fileExists(self.phantomjsPath, false) == true, ('PhantomJS is missing. Expected the path to be "%s".'):format(self.phantomjsPath))
        return assert(io.fileExists(self.communityProfileJavaScriptPath) == true, ('The JavaScript file for downloading and parsing the GOG community profile is missing. Expected the path to be "%s".'):format(self.communityProfileJavaScriptPath))
      end
    end,
    downloadCommunityProfile = function(self)
      if not (self.useCommunityProfile) then
        return nil
      end
      local parameter = ('""%s" "\\%s""'):format(self.phantomjsPath, self.communityProfileJavaScriptPath)
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\downloadProfile.bat" "%s"]'):format(self.communityProfileName))
      return self:getWaitCommand(), '', 'OnDownloadedGOGCommunityProfile'
    end,
    hasdownloadedCommunityProfile = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    hasDumpedDatabases = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    dumpDatabases = function(self)
      assert(self.programDataPath ~= nil, 'The path to GOG Galaxy\'s ProgramData path has not been defined.')
      local indexDBPath = io.joinPaths(self.programDataPath, 'storage\\index.db')
      local galaxyDBPath = io.joinPaths(self.programDataPath, 'storage\\galaxy.db')
      assert(io.fileExists(galaxyDBPath, false) == true, ('"%s" does not exist.'):format(galaxyDBPath))
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\gog_galaxy\\dumpDatabases.bat" "%s" "%s"]'):format(indexDBPath, galaxyDBPath))
      return self:getWaitCommand(), '', 'OnDumpedDBs'
    end,
    parseIndexDB = function(self, output)
      assert(type(output) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseIndexDB')
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
    parseProfile = function(self, output, productIDs)
      local hoursPlayed = { }
      if output == nil then
        return hoursPlayed
      end
      for id, hours in output:gmatch('(%d+)|([%d%.]+)') do
        if productIDs[id] == nil then
          productIDs[id] = false
        end
        hoursPlayed[id] = tonumber(hours)
      end
      return hoursPlayed
    end,
    parseGalaxyDB = function(self, productIDs, output)
      assert(type(productIDs) == 'table', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseGalaxyDB')
      assert(type(output) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseGalaxyDB')
      local lines = output:splitIntoLines()
      local titles = { }
      local bannerURLs = { }
      for _index_0 = 1, #lines do
        local _continue_0 = false
        repeat
          local line = lines[_index_0]
          local productID, title, images = line:match('^(%d+)|([^|]+)|([^|]+)|.+$')
          if productIDs[productID] == nil then
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
    parseInfo = function(self, dirPath, productID)
      assert(type(dirPath) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseInfo')
      assert(type(productID) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.parseInfo')
      local path = io.joinPaths(dirPath, ('goggame-%s.info'):format(productID))
      if not (io.fileExists(path, false)) then
        log('Skipping GOG Galaxy game', productID, 'because the .info file could not be found')
        return nil
      end
      local file = io.readFile(path, false)
      if file == '' or file:trim() == '' then
        log('Skipping GOG Galaxy game', productID, 'because the .info file is empty')
        return nil
      end
      return json.decode(file)
    end,
    getBanner = function(self, productID, bannerURLs)
      assert(type(productID) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
      local banner = self:getBannerPath(productID)
      if not (banner) then
        local bannerURL = bannerURLs[productID]
        if bannerURL then
          banner = io.joinPaths(self.cachePath, productID .. bannerURL:reverse():match('^([^%.]+%.)'):reverse())
          local expectedBanner = productID
          return banner, bannerURL, expectedBanner
        end
      end
      return banner, nil, nil
    end,
    getExePath = function(self, info)
      assert(type(info) == 'table', 'main.platforms.gog_galaxy.init.GOGGalaxy.getExePath')
      if type(info.playTasks) ~= 'table' then
        return nil, nil
      end
      local task = nil
      local _list_0 = info.playTasks
      for _index_0 = 1, #_list_0 do
        local t = _list_0[_index_0]
        if t.isPrimary == true then
          task = t
          break
        end
      end
      if task == nil then
        if type(info.playTasks[1]) ~= 'table' then
          return nil, nil
        end
        if type(info.playTasks[1].path) ~= 'string' then
          return nil, nil
        end
        task = info.playTasks[1]
      end
      local path = (task.path:gsub('//', '\\'))
      if task.arguments ~= nil then
        return path, task.arguments
      end
      return path, nil
    end,
    generateGames = function(self, indexOutput, galaxyOutput, profileOutput)
      assert(type(indexOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
      assert(type(galaxyOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
      local games = { }
      local productIDs, paths = self:parseIndexDB(indexOutput)
      local hoursPlayed = self:parseProfile(profileOutput, productIDs)
      local titles, bannerURLs = self:parseGalaxyDB(productIDs, galaxyOutput)
      for productID, installed in pairs(productIDs) do
        local _continue_0 = false
        repeat
          local banner, bannerURL, expectedBanner = self:getBanner(productID, bannerURLs)
          local path = ('"%s" "/command=runGame" "/gameId=%s"'):format(self.clientPath, productID)
          local process = nil
          if installed then
            local info = self:parseInfo(paths[productID], productID)
            if type(info) ~= 'table' then
              log('Skipping GOG Galaxy game', productID, 'because the info file could not be found')
              _continue_0 = true
              break
            end
            local exePath, arguments = self:getExePath(info)
            if type(exePath) ~= 'string' then
              log('Skipping GOG Galaxy game', productID, 'because the path to the executable could not be found')
              _continue_0 = true
              break
            end
            process = exePath:reverse():match('^([^\\]+)'):reverse()
            if not (self.indirectLaunch) then
              local fullPath = io.joinPaths(paths[productID], exePath)
              if not (io.fileExists(fullPath, false)) then
                path = nil
              else
                if arguments == nil then
                  path = ('"%s"'):format(fullPath)
                else
                  path = ('"%s" "%s"'):format(fullPath, arguments)
                end
              end
            end
          end
          local title = titles[productID]
          if title == nil then
            log('Skipping GOG Galaxy game', productID, 'because title could not be found')
            _continue_0 = true
            break
          elseif path == nil then
            log('Skipping GOG Galaxy game', productID, 'because path could not be found')
            _continue_0 = true
            break
          end
          table.insert(games, {
            banner = banner,
            bannerURL = bannerURL,
            expectedBanner = expectedBanner,
            title = title,
            path = path,
            uninstalled = not installed,
            platformID = self.platformID,
            process = process,
            hoursPlayed = hoursPlayed[productID]
          })
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      self.games = games
    end,
    getStorePageURL = function(self, game)
      assert(game ~= nil and game:getPlatformID() == self.platformID, 'main.platforms.gog_galaxy.init.getStorePageURL')
      local productID = game:getBanner():reverse():match('^[^%.]+%.([^\\]+)'):reverse()
      local galaxy = io.readFile(io.joinPaths(self.cachePath, 'galaxy.txt'))
      local url = nil
      local _list_0 = galaxy:splitIntoLines()
      for _index_0 = 1, #_list_0 do
        local line = _list_0[_index_0]
        if line:startsWith(productID) then
          local urls = line:match('^%d+|[^|]+|[^|]+|(.+)$')
          if urls ~= nil then
            urls = json.decode(urls:lower())
            if url == nil and urls.store ~= nil then
              if type(urls.store.href) == 'string' then
                url = urls.store.href
              elseif type(urls.store) == 'string' then
                url = urls.store
              end
            end
            if url == nil and urls.product_card ~= nil then
              if type(urls.product_card.href) == 'string' then
                url = urls.product_card.href
              elseif type(urls.product_card) == 'string' then
                url = urls.product_card
              end
            end
            if url == nil and urls.forum ~= nil then
              if type(urls.forum.href) == 'string' then
                url = urls.forum.href:gsub('forum', 'game')
              elseif type(urls.forum) == 'string' then
                url = urls.forum:gsub('forum', 'game')
              end
            end
          end
          break
        end
      end
      return url
    end,
    getBannerURL = function(self, game)
      assert(game ~= nil and game:getPlatformID() == self.platformID, 'main.platforms.gog_galaxy.init.getBannerURL')
      local productID = game:getBanner():reverse():match('^[^%.]+%.([^\\]+)'):reverse()
      local galaxy = io.readFile(io.joinPaths(self.cachePath, 'galaxy.txt'))
      local productIDs = { }
      productIDs[productID] = true
      local titles, bannerURLs = self:parseGalaxyDB(productIDs, galaxy)
      return bannerURLs[productID]
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
      self.indirectLaunch = settings:getGOGGalaxyIndirectLaunch()
      if self.indirectLaunch then
        self.platformProcess = 'GalaxyClient.exe'
      end
      self.clientPath = settings:getGOGGalaxyClientPath()
      self.useCommunityProfile = settings:getGOGGalaxyParseCommunityProfile()
      self.communityProfileName = settings:getGOGGalaxyProfileName()
      self.communityProfileJavaScriptPath = io.joinPaths('main', 'platforms', 'gog_galaxy', 'profile.js')
      self.phantomjsPath = io.joinPaths(STATE.PATHS.RESOURCES, 'phantomjs.exe')
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
if RUN_TESTS then
  local assertionMessage = 'GOG Galaxy test failed!'
  local settings = {
    getGOGGalaxyEnabled = function(self)
      return true
    end,
    getGOGGalaxyProgramDataPath = function(self)
      return ''
    end,
    getGOGGalaxyIndirectLaunch = function(self)
      return true
    end,
    getGOGGalaxyClientPath = function(self)
      return ''
    end,
    getGOGGalaxyParseCommunityProfile = function(self)
      return false
    end,
    getGOGGalaxyProfileName = function(self)
      return ''
    end
  }
  local galaxy = GOGGalaxy(settings)
  local indexOutput = '1207660094|D:\\Games\\GOG Galaxy\\Dust - An Elysian Tail\n1207659069|D:\\Games\\GOG Galaxy\\Torchlight\n1495134320|D:\\Games\\GOG Galaxy\\The Witcher 3 Wild Hunt GOTY\n1207660413|D:\\Games\\GOG Galaxy\\Shadowrun Returns\n1207658807|D:\\Games\\GOG Galaxy\\Psychonauts\n1207666193|D:\\Games\\GOG Galaxy\\Legend of Grimrock II'
  local productIDs, paths = galaxy:parseIndexDB(indexOutput)
  assert(type(productIDs) == 'table', assertionMessage)
  assert(type(paths) == 'table', assertionMessage)
  assert(productIDs['1207660094'] == true, assertionMessage)
  assert(productIDs['1207659069'] == true, assertionMessage)
  assert(productIDs['1495134320'] == true, assertionMessage)
  assert(productIDs['1207660413'] == true, assertionMessage)
  assert(productIDs['1207658807'] == true, assertionMessage)
  assert(productIDs['1207666193'] == true, assertionMessage)
  assert(paths['1207660094'] == 'D:\\Games\\GOG Galaxy\\Dust - An Elysian Tail', assertionMessage)
  assert(paths['1207659069'] == 'D:\\Games\\GOG Galaxy\\Torchlight', assertionMessage)
  assert(paths['1495134320'] == 'D:\\Games\\GOG Galaxy\\The Witcher 3 Wild Hunt GOTY', assertionMessage)
  assert(paths['1207660413'] == 'D:\\Games\\GOG Galaxy\\Shadowrun Returns', assertionMessage)
  assert(paths['1207658807'] == 'D:\\Games\\GOG Galaxy\\Psychonauts', assertionMessage)
  assert(paths['1207666193'] == 'D:\\Games\\GOG Galaxy\\Legend of Grimrock II', assertionMessage)
  local galaxyOutput = '1495134320|The Witcher 3: Wild Hunt - Game of the Year Edition|{"background":"https://images-2.gog.com/d942735a04269e01ab4799e55f5cd158c2c78e4265240b940b622578a002b08b.jpg","icon":"https://images-2.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1.png","logo":"https://images-3.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo.jpg","logo2x":"https://images-2.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo_2x.jpg","menuNotificationAv":"https://images-4.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av.png","menuNotificationAv2":"https://images-1.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av2.png","sidebarIcon":"https://images-1.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon.png","sidebarIcon2x":"https://images-4.gog.com/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon_2x.png"}|{  "forum" : "http://www.gog.com/forum/the_witcher_3_wild_hunt",  "product_card" : "http://www.gog.com/game/the_witcher_3_wild_hunt_game_of_the_year_edition_game",  "purchase_link" : "https://www.gog.com/checkout/manual/1495134320",  "support" : "https://www.gog.com/support/the_witcher_3_wild_hunt_game_of_the_year_edition_game"}\n1207659069|Torchlight|{"background":"https://images.gog.com/51a5d1be8c50b36655a0f057b12a0e13c9412de0c921a3b3f4aa753198bbd364.jpg","icon":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381.png","logo":"https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo.png","logo2x":"https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon.png","sidebarIcon2x":"https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/51a5d1be8c50b36655a0f057b12a0e13c9412de0c921a3b3f4aa753198bbd364.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/torchlight_series"  },  "icon" : {    "href" : "https://images.gog.com/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207659069?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/torchlight"  },  "support" : {    "href" : "https://www.gog.com/support/torchlight"  }}\n1207660413|Shadowrun Returns|{"background":"https://images.gog.com/a6ee88aed8f046df9993b96a6aec9d1d48e9bbada856c994700a8a4f28172e60.jpg","icon":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81.png","logo":"https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo.png","logo2x":"https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon.png","sidebarIcon2x":"https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/a6ee88aed8f046df9993b96a6aec9d1d48e9bbada856c994700a8a4f28172e60.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/shadowrun_series"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/c72867f15555a110b320a75fdf2db7d54c1d7fae8bc96f7db65a4accca710541.jpg"  },  "icon" : {    "href" : "https://images.gog.com/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81.png"  },  "isIncludedInGames" : [    {      "href" : "http://api.gog.com/v1/games/1791521599?locale=en-US"    },    {      "href" : "http://api.gog.com/v1/games/1983446193?locale=en-US"    }  ],  "isRequiredByGames" : [    {      "href" : "http://api.gog.com/v1/games/1207660843?locale=en-US"    }  ],  "self" : {    "href" : "http://api.gog.com/v1/games/1207660413?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/shadowrun_returns"  },  "support" : {    "href" : "https://www.gog.com/support/shadowrun_returns"  }}\n1207660094|Dust: An Elysian Tail|{"background":"https://images.gog.com/62b91190a44a7d38334b50e23ed5b1999e78a31122e6f4515b53aee2df1e360e.jpg","icon":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5.png","logo":"https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo.png","logo2x":"https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon.png","sidebarIcon2x":"https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/62b91190a44a7d38334b50e23ed5b1999e78a31122e6f4515b53aee2df1e360e.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/dust_an_elysian_tail"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/bd21391960c6087c8a760f5d858fc75d78654f065df45ccb08d66a149fd68634.jpg"  },  "icon" : {    "href" : "https://images.gog.com/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207660094?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/dust_an_elysian_tail"  },  "support" : {    "href" : "https://www.gog.com/support/dust_an_elysian_tail"  }}\n1207658807|Psychonauts|{"background":"https://images.gog.com/db4d0a4594d8d070ffb13d1feb1882f1a3fa6ab5325323e2b86cbd69a160c797.jpg","icon":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f.png","logo":"https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo.png","logo2x":"https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo_2x.png","sidebarIcon":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon.png","sidebarIcon2x":"https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon_2x.png"}|{  "backgroundImage" : {    "href" : "https://images.gog.com/db4d0a4594d8d070ffb13d1feb1882f1a3fa6ab5325323e2b86cbd69a160c797.jpg"  },  "forum" : {    "href" : "https://www.gog.com/forum/psychonauts"  },  "galaxyBackgroundImage" : {    "href" : "https://images.gog.com/09856119fff2f98b29b8b3f91edf0ea5bd12af19e9c95b1f33ea60b8f431912c.jpg"  },  "icon" : {    "href" : "https://images.gog.com/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f.png"  },  "self" : {    "href" : "http://api.gog.com/v1/games/1207658807?locale=en-US"  },  "store" : {    "href" : "https://www.gog.com/game/psychonauts"  },  "support" : {    "href" : "https://www.gog.com/support/psychonauts"  }}'
  local titles, bannerURLs = galaxy:parseGalaxyDB(productIDs, galaxyOutput)
  assert(type(titles) == 'table', assertionMessage)
  assert(type(bannerURLs) == 'table', assertionMessage)
  assert(titles['1495134320'] == 'The Witcher 3: Wild Hunt - Game of the Year Edition', assertionMessage)
  assert(titles['1207659069'] == 'Torchlight', assertionMessage)
  assert(titles['1207660413'] == 'Shadowrun Returns', assertionMessage)
  assert(titles['1207660094'] == 'Dust: An Elysian Tail', assertionMessage)
  assert(titles['1207658807'] == 'Psychonauts', assertionMessage)
  assert(bannerURLs['1495134320'] == 'https://images-3.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_392.jpg', assertionMessage)
  assert(bannerURLs['1207659069'] == 'https://images.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_392.png', assertionMessage)
  assert(bannerURLs['1207660413'] == 'https://images.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_392.png', assertionMessage)
  assert(bannerURLs['1207660094'] == 'https://images.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_392.png', assertionMessage)
  assert(bannerURLs['1207658807'] == 'https://images.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_392.png', assertionMessage)
  local infos = {
    ['1207660094'] = {
      playTasks = {
        {
          path = 'bin//a.exe'
        }
      }
    },
    ['1495134320'] = {
      playTasks = {
        {
          path = 'bin//x64//witcher3.exe'
        }
      }
    }
  }
  assert(galaxy:getExePath(infos['1207660094']) == 'bin\\a.exe', assertionMessage)
  assert(galaxy:getExePath(infos['1495134320']) == 'bin\\x64\\witcher3.exe', assertionMessage)
end
return GOGGalaxy
