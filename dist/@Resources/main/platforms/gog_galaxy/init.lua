local Platform = require('main.platforms.platform')
local Game = require('main.game')
local json = require('lib.json')
local GOGGalaxy
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self)
      assert(io.fileExists(io.joinPaths(self.programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
      assert(io.fileExists(io.joinPaths(self.programDataPath, 'storage\\index.db'), false), 'The path to GOG Galaxy\'s ProgramData directory is not valid.')
      if self.clientPath ~= nil then
        self.clientPath = io.joinPaths(self.clientPath, 'GalaxyClient.exe')
        if self.indirectLaunch then
          return assert(io.fileExists(self.clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
        end
      elseif self.indirectLaunch then
        return assert(self.clientPath ~= nil, 'A path to the GOG Galaxy client has not been defined.')
      end
    end,
    getCachePath = function(self)
      return self.cachePath
    end,
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
        return nil
      end
      if type(info.playTasks[1]) ~= 'table' then
        return nil
      end
      if type(info.playTasks[1].path) ~= 'string' then
        return nil
      end
      return (info.playTasks[1].path:gsub('//', '\\'))
    end,
    generateGames = function(self, indexOutput, galaxyOutput)
      assert(type(indexOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
      assert(type(galaxyOutput) == 'string', 'main.platforms.gog_galaxy.init.GOGGalaxy.generateGames')
      local games = { }
      local productIDs, paths = self:parseIndexDB(indexOutput)
      local titles, bannerURLs = self:parseGalaxyDB(productIDs, galaxyOutput)
      for productID, _ in pairs(productIDs) do
        local _continue_0 = false
        repeat
          local banner, bannerURL, expectedBanner = self:getBanner(productID, bannerURLs)
          local info = self:parseInfo(paths[productID], productID)
          if type(info) ~= 'table' then
            log('Skipping GOG Galaxy game', productID, 'because the info file could not be found')
            _continue_0 = true
            break
          end
          local exePath = self:getExePath(info)
          if type(exePath) ~= 'string' then
            log('Skipping GOG Galaxy game', productID, 'because the path to the executable could not be found')
            _continue_0 = true
            break
          end
          local path
          local _exp_0 = self.indirectLaunch
          if true == _exp_0 then
            path = ('"%s" "/command=runGame" "/gameId=%s"'):format(self.clientPath, productID)
          else
            local fullPath = io.joinPaths(paths[productID], exePath)
            if not (io.fileExists(fullPath, false)) then
              path = nil
            else
              path = ('"%s"'):format(fullPath)
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
            platformID = self.platformID,
            process = exePath:reverse():match('^([^\\]+)'):reverse()
          })
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
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
      self.indirectLaunch = settings:getGOGGalaxyIndirectLaunch()
      if self.indirectLaunch then
        self.platformProcess = 'GalaxyClient.exe'
      end
      self.clientPath = settings:getGOGGalaxyClientPath()
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
  local galaxyOutput = '1495134320|The Witcher 3: Wild Hunt - Game of the Year Edition|{"background":"https:\/\/images-2.gog.com\/d942735a04269e01ab4799e55f5cd158c2c78e4265240b940b622578a002b08b.jpg","icon":"https:\/\/images-2.gog.com\/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1.png","logo":"https:\/\/images-3.gog.com\/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo.jpg","logo2x":"https:\/\/images-2.gog.com\/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_glx_logo_2x.jpg","menuNotificationAv":"https:\/\/images-4.gog.com\/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av.png","menuNotificationAv2":"https:\/\/images-1.gog.com\/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_menu_notification_av2.png","sidebarIcon":"https:\/\/images-1.gog.com\/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon.png","sidebarIcon2x":"https:\/\/images-4.gog.com\/0313f1d9b3378ec94f4a5ed59781ce72b0201433060de449c986eb5c9804c3b1_sbicon_2x.png"}\n1207659069|Torchlight|{"background":"https:\/\/images-1.gog.com\/51a5d1be8c50b36655a0f057b12a0e13c9412de0c921a3b3f4aa753198bbd364.jpg","icon":"https:\/\/images-4.gog.com\/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381.png","logo":"https:\/\/images-1.gog.com\/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo.jpg","logo2x":"https:\/\/images-3.gog.com\/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_glx_logo_2x.jpg","menuNotificationAv":"https:\/\/images-1.gog.com\/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_menu_notification_av.png","menuNotificationAv2":"https:\/\/images-1.gog.com\/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_menu_notification_av2.png","sidebarIcon":"https:\/\/images-4.gog.com\/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon.png","sidebarIcon2x":"https:\/\/images-4.gog.com\/278f280547e01300fd89f0b36d71144ce8800a4104631c18f93fafd3ddf78381_sbicon_2x.png"}\n1207660413|Shadowrun Returns|{"background":"https:\/\/images-1.gog.com\/a6ee88aed8f046df9993b96a6aec9d1d48e9bbada856c994700a8a4f28172e60.jpg","icon":"https:\/\/images-2.gog.com\/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81.png","logo":"https:\/\/images-1.gog.com\/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo.jpg","logo2x":"https:\/\/images-1.gog.com\/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_glx_logo_2x.jpg","menuNotificationAv":"https:\/\/images-3.gog.com\/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_menu_notification_av.png","menuNotificationAv2":"https:\/\/images-3.gog.com\/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_menu_notification_av2.png","sidebarIcon":"https:\/\/images-2.gog.com\/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon.png","sidebarIcon2x":"https:\/\/images-4.gog.com\/3bb987dc1e408b3b156ee09432c63a97d31fefc8f6af2cb2cd2c747d745c3f81_sbicon_2x.png"}\n1207660094|Dust: An Elysian Tail|{"background":"https:\/\/images-1.gog.com\/62b91190a44a7d38334b50e23ed5b1999e78a31122e6f4515b53aee2df1e360e.jpg","icon":"https:\/\/images-3.gog.com\/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5.png","logo":"https:\/\/images-1.gog.com\/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo.jpg","logo2x":"https:\/\/images-1.gog.com\/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_glx_logo_2x.jpg","menuNotificationAv":"https:\/\/images-2.gog.com\/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_menu_notification_av.png","menuNotificationAv2":"https:\/\/images-4.gog.com\/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_menu_notification_av2.png","sidebarIcon":"https:\/\/images-1.gog.com\/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon.png","sidebarIcon2x":"https:\/\/images-2.gog.com\/635347fd22849e12a0e5287127602b84a693f718a1f3b3f74d45e9808e280cb5_sbicon_2x.png"}\n1207658807|Psychonauts|{"background":"https:\/\/images-4.gog.com\/db4d0a4594d8d070ffb13d1feb1882f1a3fa6ab5325323e2b86cbd69a160c797.jpg","icon":"https:\/\/images-1.gog.com\/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f.png","logo":"https:\/\/images-4.gog.com\/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo.jpg","logo2x":"https:\/\/images-3.gog.com\/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_glx_logo_2x.jpg","menuNotificationAv":"https:\/\/images-2.gog.com\/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_menu_notification_av.png","menuNotificationAv2":"https:\/\/images-3.gog.com\/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_menu_notification_av2.png","sidebarIcon":"https:\/\/images-3.gog.com\/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon.png","sidebarIcon2x":"https:\/\/images-4.gog.com\/9114a81e297f335a784c56af16a79bf9307a369bc7023f0dec5c6427f9c7652f_sbicon_2x.png"}'
  local titles, bannerURLs = galaxy:parseGalaxyDB(productIDs, galaxyOutput)
  assert(type(titles) == 'table', assertionMessage)
  assert(type(bannerURLs) == 'table', assertionMessage)
  assert(titles['1495134320'] == 'The Witcher 3: Wild Hunt - Game of the Year Edition', assertionMessage)
  assert(titles['1207659069'] == 'Torchlight', assertionMessage)
  assert(titles['1207660413'] == 'Shadowrun Returns', assertionMessage)
  assert(titles['1207660094'] == 'Dust: An Elysian Tail', assertionMessage)
  assert(titles['1207658807'] == 'Psychonauts', assertionMessage)
  assert(bannerURLs['1495134320'] == 'https://images-3.gog.com/7b5017a1e70bde6e4129aeb6770e77bc9798bc2f239cde2432812d0dbdae9fe1_392.jpg', assertionMessage)
  assert(bannerURLs['1207659069'] == 'https://images-1.gog.com/395336bf671bf508dbc0adcf7ae55e1f6cb7763bb1aba000074a1193ae293f82_392.jpg', assertionMessage)
  assert(bannerURLs['1207660413'] == 'https://images-1.gog.com/6c35ecb988f57725cc0f385acf860241082da16eda9fab66115f4da883dae3d1_392.jpg', assertionMessage)
  assert(bannerURLs['1207660094'] == 'https://images-1.gog.com/0d679a5b5e297d129221362d41370871c433f9573ad857fbd53a0b9bc09d2303_392.jpg', assertionMessage)
  assert(bannerURLs['1207658807'] == 'https://images-4.gog.com/9cda8695e107d9ae7d12d91c1c338aa6dd70229627fc60a9625e2883f3d88190_392.jpg', assertionMessage)
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
