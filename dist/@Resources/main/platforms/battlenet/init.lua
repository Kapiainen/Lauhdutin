local Platform = require('main.platforms.platform')
local Game = require('main.game')
local Battlenet
do
  local _class_0
  local _parent_0 = Platform
  local _base_0 = {
    hasUnprocessedPaths = function(self)
      return #self.battlenetPaths > 0
    end,
    hasProcessedPath = function(self)
      return io.fileExists(io.joinPaths(self.cachePath, 'completed.txt'))
    end,
    identifyFolders = function(self)
      SKIN:Bang(('["#@#windowless.vbs" "#@#main\\platforms\\battlenet\\identifyFolders.bat" "%s"]'):format(self.battlenetPaths[1]))
      return self:getWaitCommand(), '', 'OnIdentifiedBattlenetFolders'
    end,
    generateGames = function(self)
      local games = { }
      local output = io.readFile(io.joinPaths(self.cachePath, 'output.txt'))
      local basePath = table.remove(self.battlenetPaths, 1)
      local folders = output:lower():splitIntoLines()
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
              process = 'destiny2.exe'
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
              end)()
            }
          elseif 'hearthstone' == _exp_0 then
            args = {
              title = 'Hearthstone',
              path = 'battlenet://WTCG',
              process = 'Hearthstone.exe'
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
              end)()
            }
          elseif 'overwatch' == _exp_0 then
            args = {
              title = 'Overwatch',
              path = 'battlenet://Pro',
              process = 'Overwatch.exe'
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
              end)()
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
          args.banner = self:getBannerPath(args.title)
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
return Battlenet
