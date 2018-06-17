local Platform = require('main.platforms.platform')
local Game = require('main.game')
local Battlenet
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    validate = function(self) end,
    hasUnprocessedPaths = function(self)
      return #self.battlenetPaths > 0
    end,
    hasProcessedPath = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    getCachePath = function(self)
      return self.cachePath
    end,
    identifyFolders = function(self)
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\battlenet\\identifyFolders.bat" "%s"]'):format(self.battlenetPaths[1]))
      return self:getWaitCommand(), '', 'OnIdentifiedBattlenetFolders'
    end,
    getBanner = function(self, title, bannerURL)
      local banner = self:getBannerPath(title)
      if not (banner) then
        if bannerURL then
          banner = io.joinPaths(self.cachePath, title .. bannerURL:reverse():match('^([^%.]+%.)'):reverse())
        end
      end
      return banner
    end,
    generateGames = function(self, output)
      assert(type(output) == 'string')
      table.remove(self.battlenetPaths, 1)
      local games = { }
      local folders = output:lower():splitIntoLines()
      assert(folders[1]:startsWith('bits:'))
      local bits = table.remove(folders, 1)
      if (bits:find('64')) ~= nil then
        bits = 64
      else
        bits = 32
      end
      for _index_0 = 1, #folders do
        local _continue_0 = false
        repeat
          local folder = folders[_index_0]
          local args = nil
          local _exp_0 = folder
          if 'destiny 2' == _exp_0 then
            args = {
              title = 'Destiny 2',
              path = 'battlenet://DST2',
              process = 'destiny2.exe',
              bannerURL = 'https://images.launchbox-app.com/34b4f780-34a2-42f0-a4ea-fa78933dd5e8.jpg'
            }
          elseif 'diablo iii' == _exp_0 then
            args = {
              title = 'Diablo III',
              path = 'battlenet://D3',
              process = (function()
                if bits == 64 then
                  return 'Diablo III64.exe'
                else
                  return 'Diablo III.exe'
                end
              end)(),
              bannerURL = 'https://images.launchbox-app.com/9c1d2d30-8845-4b8a-89e6-632abab530c5.png'
            }
          elseif 'hearthstone' == _exp_0 then
            args = {
              title = 'Hearthstone',
              path = 'battlenet://WTCG',
              process = 'Hearthstone.exe',
              bannerURL = 'https://images.launchbox-app.com/5aa3fd48-4edd-4d8a-a302-9eed46f3e471.png'
            }
          elseif 'heroes of the storm' == _exp_0 then
            args = {
              title = 'Heroes of the Storm',
              path = 'battlenet://Hero',
              process = (function()
                if bits == 64 then
                  return 'HeroesOfTheStorm_x64.exe'
                else
                  return 'HeroesOfTheStorm.exe'
                end
              end)(),
              bannerURL = 'https://images.launchbox-app.com/cb0aba61-915e-40e3-b2e1-187158819711.jpg'
            }
          elseif 'overwatch' == _exp_0 then
            args = {
              title = 'Overwatch',
              path = 'battlenet://Pro',
              process = 'Overwatch.exe',
              bannerURL = 'https://images.launchbox-app.com/09b1d6e3-316d-44d8-beca-90b87eb18c35.jpg'
            }
          elseif 'starcraft' == _exp_0 then
            args = {
              title = 'StarCraft',
              path = 'battlenet://S1',
              process = 'StarCraft.exe'
            }
          elseif 'starcraft ii' == _exp_0 then
            args = {
              title = 'StarCraft II',
              path = 'battlenet://S2',
              process = (function()
                if bits == 64 then
                  return 'SC2_x64.exe'
                else
                  return 'SC2.exe'
                end
              end)()
            }
          elseif 'world of warcraft' == _exp_0 then
            args = {
              title = 'World of Warcraft',
              path = 'battlenet://WoW',
              process = (function()
                if bits == 64 then
                  return 'Wow-64.exe'
                else
                  return 'Wow.exe'
                end
              end)(),
              bannerURL = 'https://images.launchbox-app.com/09a032b5-b86e-435a-b75a-264fcaa8a05d.png'
            }
          else
            _continue_0 = true
            break
          end
          if args.title == nil then
            log('Skipping Blizzard Battle.net game because the title is missing')
            _continue_0 = true
            break
          elseif args.path == nil then
            log('Skipping Blizzard Battle.net game because the path is missing')
            _continue_0 = true
            break
          end
          args.banner = self:getBanner(args.title, args.bannerURL)
          if not (args.banner) then
            args.expectedBanner = args.title
          end
          args.platformID = self.platformID
          table.insert(games, args)
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
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, settings)
      _class_0.__parent.__init(self, settings)
      self.platformID = ENUMS.PLATFORM_IDS.BATTLENET
      self.platformProcess = 'Battle.net.exe'
      self.name = 'Blizzard Battle.net'
      self.cachePath = 'cache\\battlenet\\'
      self.battlenetPaths = (function()
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = settings:getBattlenetPaths()
        for _index_0 = 1, #_list_0 do
          local path = _list_0[_index_0]
          _accum_0[_len_0] = path
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)() or { }
      self.enabled = settings:getBattlenetEnabled()
      self.games = { }
    end,
    __base = _base_0,
    __name = "Battlenet",
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
  Battlenet = _class_0
end
if RUN_TESTS then
  local assertionMessage = 'Blizzard Battle.net test failed!'
  local settings = {
    getBattlenetPaths = function(self)
      return {
        'Y:\\Blizzard games',
        'Z:\\Games\\Battle.net'
      }
    end,
    getBattlenetEnabled = function(self)
      return true
    end
  }
  local battlenet = Battlenet(settings)
  local output = 'BITS:AMD64\nDiablo III\nStarCraft\nOverwatch\nSome random game\nHearthstone\n'
  battlenet:generateGames(output)
  local games = battlenet.games
  assert(#games == 4, assertionMessage)
  output = 'BITS:x86\nHeroes of the Storm\nStarCraft II\nStarCraft\nAnother random game\nWorld of Warcraft\nDestiny 2\n'
  battlenet:generateGames(output)
  games = battlenet.games
  assert(#games == 9, assertionMessage)
  local expectedGames = {
    {
      title = 'Diablo III',
      path = 'battlenet://D3',
      process = 'Diablo III64.exe'
    },
    {
      title = 'StarCraft',
      path = 'battlenet://S1',
      process = 'StarCraft.exe'
    },
    {
      title = 'Overwatch',
      path = 'battlenet://Pro',
      process = 'Overwatch.exe'
    },
    {
      title = 'Hearthstone',
      path = 'battlenet://WTCG',
      process = 'Hearthstone.exe'
    },
    {
      title = 'Heroes of the Storm',
      path = 'battlenet://Hero',
      process = 'HeroesOfTheStorm.exe'
    },
    {
      title = 'StarCraft II',
      path = 'battlenet://S2',
      process = 'SC2.exe'
    },
    {
      title = 'StarCraft',
      path = 'battlenet://S1',
      process = 'StarCraft.exe'
    },
    {
      title = 'World of Warcraft',
      path = 'battlenet://WoW',
      process = 'Wow.exe'
    },
    {
      title = 'Destiny 2',
      path = 'battlenet://DST2',
      process = 'destiny2.exe'
    }
  }
  for i, game in ipairs(games) do
    assert(game:getTitle() == expectedGames[i].title, assertionMessage)
    assert(game:getPath() == expectedGames[i].path, assertionMessage)
    assert(game:getProcess() == expectedGames[i].process, assertionMessage)
  end
end
return Battlenet
