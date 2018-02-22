local Game = require('main.game')
local migrators = {
  {
    version = 1,
    func = function(games)
      local gamesToRemove = { }
      for i, game in ipairs(games) do
        local remove = false
        if type(game.title) ~= 'string' or game.title:trim() == '' then
          remove = true
        end
        if type(game.path) ~= 'string' or game.path:trim() == '' then
          remove = true
        end
        if type(game.platform) ~= 'number' or game.platform < 0 or game.platform > 5 then
          remove = true
        end
        if remove then
          table.insert(gamesToRemove, game)
        else
          local _exp_0 = game.platform
          if 0 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.STEAM
          elseif 1 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.STEAM
          elseif 2 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
          elseif 3 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.SHORTCUTS
          elseif 4 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.SHORTCUTS
          elseif 5 == _exp_0 then
            game.platformID = ENUMS.PLATFORM_IDS.BATTLENET
          end
          game.platformOverride = game.platformoverride
          game.platformoverride = nil
          game.hoursPlayed = game.hourstotal
          game.hourstotal = nil
          game.lastPlayed = tonumber(game.lastplayed)
          game.lastplayed = nil
          game.uninstalled = game.notinstalled
          game.notinstalled = nil
          game.processOverride = game.processoverride
          game.processoverride = nil
          if game.tags ~= nil then
            local tags = { }
            for key, tag in pairs(game.tags) do
              table.insert(tags, tag)
            end
            game.tags = tags
          end
          game.banner = nil
          game.bannererror = nil
          game.bannerurl = nil
          game.error = nil
          game.hourslast2weeks = nil
          game.ignoresbangs = nil
          game.invalidpatherror = nil
        end
      end
      for _index_0 = 1, #gamesToRemove do
        local game = gamesToRemove[_index_0]
        local i = table.find(games, game)
        table.remove(games, i)
      end
    end
  }
}
local Library
do
  local _class_0
  local _base_0 = {
    createBackup = function(self, path)
      local games = io.readJSON(path)
      local date = os.date('*t')
      games.backup = {
        year = date.year,
        month = date.month,
        day = date.day
      }
      local latestBackupPath = self.backupFilePattern:format(1)
      if io.fileExists(latestBackupPath) then
        local latestBackup = io.readJSON(latestBackupPath)
        if latestBackup.backup.year == date.year and latestBackup.backup.month == date.month and latestBackup.backup.day == date.day then
          return 
        end
        for i = self.numBackups, 1, -1 do
          local backupPath = self.backupFilePattern:format(i)
          if io.fileExists(backupPath) then
            if i == self.numBackups then
              os.remove(io.absolutePath(backupPath))
            else
              backupPath = io.absolutePath(backupPath)
              local target = io.absolutePath(self.backupFilePattern:format(i + 1))
              os.rename(backupPath, target)
            end
          end
        end
      end
      return io.writeJSON(latestBackupPath, games)
    end,
    load = function(self)
      local paths
      do
        local _accum_0 = { }
        local _len_0 = 1
        for i = 1, self.numBackups do
          _accum_0[_len_0] = self.backupFilePattern:format(i)
          _len_0 = _len_0 + 1
        end
        paths = _accum_0
      end
      table.insert(paths, 1, self.path)
      for _index_0 = 1, #paths do
        local path = paths[_index_0]
        if io.fileExists(path) then
          self:createBackup(path)
          local games = io.readJSON(path)
          local version = games.version or 0
          if version > 0 then
            games = games.games
          end
          local migrated = self:migrate(games, version)
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_1 = 1, #games do
              local args = games[_index_1]
              _accum_0[_len_0] = Game(args)
              _len_0 = _len_0 + 1
            end
            games = _accum_0
          end
          if migrated then
            self:save(games)
          end
          return games
        end
      end
      return { }
    end,
    save = function(self, games)
      if games == nil then
        games = self.games
      end
      return io.writeJSON(self.path, {
        version = self.version,
        games = games
      })
    end,
    migrate = function(self, games, version)
      assert(type(version) == 'number' and version % 1 == 0, '"Library.migrate" expected "version" to be an integer.')
      assert(version <= self.version, ('"Library.migrate" expected "version" to be less than or equal to %d.'):format(self.version))
      if version == self.version then
        return false
      end
      for _index_0 = 1, #migrators do
        local migrator = migrators[_index_0]
        if version < migrator.version then
          log("Migrating games.json from version " .. tostring(version) .. " to " .. tostring(migrator.version) .. ".")
          migrator.func(games)
        end
      end
      return true
    end,
    add = function(self, games)
      if games == nil then
        return false
      end
      assert(type(games) == 'table', '"Library.add" expected "games" to be a table.')
      if #games == 0 then
        return false
      end
      for _index_0 = 1, #games do
        local game = games[_index_0]
        assert(game.__class == Game, '"Library.add" expected each entry in "games" to be an instance of "Game".')
        for i, oldGame in ipairs(self.oldGames) do
          if game:getPlatformID() == oldGame:getPlatformID() and game:getTitle() == oldGame:getTitle() then
            game:merge(oldGame)
            table.remove(self.oldGames, i)
            break
          end
        end
        game:setGameID(self.currentGameID)
        self.currentGameID = self.currentGameID + 1
        table.insert(self.games, game)
      end
      return true
    end,
    finalize = function(self, platformEnabledStatus)
      assert(type(platformEnabledStatus) == 'table', '"Library.finalize" expected "platformEnabledStatus" to be a table.')
      self.platformEnabledStatus = platformEnabledStatus
      local _list_0 = self.oldGames
      for _index_0 = 1, #_list_0 do
        local game = _list_0[_index_0]
        game:setInstalled(false)
        game:setGameID(self.currentGameID)
        self.currentGameID = self.currentGameID + 1
        table.insert(self.games, game)
      end
      self.oldGames = nil
    end,
    update = function(self, updatedGame)
      local gameID = updatedGame:getGameID()
      local _list_0 = self.games
      for _index_0 = 1, #_list_0 do
        local game = _list_0[_index_0]
        if game:getGameID() == gameID then
          game:merge(updatedGame)
          return true
        end
      end
      return false
    end,
    sort = function(self, sorting, games)
      if games == nil then
        games = self.games
      end
      assert(type(sorting) == 'number' and sorting % 1 == 0, '"Library.sort" expected "sorting" to be an integer.')
      local comp = nil
      local _exp_0 = sorting
      if ENUMS.SORTING_TYPES.ALPHABETICALLY == _exp_0 then
        comp = function(a, b)
          return a:getTitle():lower() < b:getTitle():lower()
        end
      elseif ENUMS.SORTING_TYPES.LAST_PLAYED == _exp_0 then
        comp = function(a, b)
          return a:getLastPlayed() > b:getLastPlayed()
        end
      elseif ENUMS.SORTING_TYPES.HOURS_PLAYED == _exp_0 then
        comp = function(a, b)
          return a:getHoursPlayed() > b:getHoursPlayed()
        end
      else
        assert(nil, 'Unknown sorting type.')
      end
      assert(type(comp) == 'function', '"Library.sort" expected "comp" to be a function.')
      table.sort(games, comp)
      if games ~= self.games then
        return table.sort(self.games, comp)
      end
    end,
    fuzzySearch = function(self, str, pattern)
      assert(type(str) == 'string', '"Library.fuzzySearch" expected "str" to be a string.')
      assert(type(pattern) == 'string', '"Library.fuzzySearch" expected "pattern" to be a string.')
      local score = 0
      if str == '' or pattern == '' then
        return score
      end
      local bonusPerfectMatch = 50
      local bonusFirstMatch = 25
      local bonusMatch = 10
      local bonusMatchDistance = 10
      local bonusConsecutiveMatches = 10
      local bonusFirstWordMatch = 20
      local penaltyNotMatch = -5
      pattern = pattern:lower()
      str = str:lower()
      if str == pattern then
        score = score + bonusPerfectMatch
      end
      local patternChars = pattern:splitIntoChars()
      local strWords = str:splitIntoWords()
      local matchString
      matchString = function(_str, _patternChars)
        local matchIndex = _str:find(_patternChars[1])
        if matchIndex ~= nil then
          score = score + (bonusFirstMatch / matchIndex)
          local matchIndices = { }
          table.insert(matchIndices, matchIndex)
          local consecutiveMatches = 0
          for i, char in ipairs(_patternChars) do
            if i > 1 and matchIndices[i - 1] ~= nil then
              matchIndex = _str:find(char, matchIndices[i - 1] + 1)
              if matchIndex ~= nil then
                table.insert(matchIndices, matchIndex)
                score = score + bonusMatch
                local distance = matchIndex - matchIndices[i - 1]
                if distance == 1 then
                  consecutiveMatches = consecutiveMatches + 1
                else
                  score = score + (consecutiveMatches * bonusConsecutiveMatches)
                  consecutiveMatches = 0
                end
                score = score + (bonusMatchDistance / distance)
              else
                score = score + (consecutiveMatches * bonusConsecutiveMatches)
                score = score + penaltyNotMatch
                consecutiveMatches = 0
              end
            end
          end
          if consecutiveMatches > 0 then
            score = score + (consecutiveMatches * bonusConsecutiveMatches)
          end
          return true
        end
        return false
      end
      if not (matchString(str, patternChars)) then
        local min = 1
        while not matchString(str, table.slice(patternChars, min)) and min < #patternChars do
          min = min + 1
        end
      end
      if #strWords > 0 then
        local j = 1
        for i, char in ipairs(patternChars) do
          if j <= #strWords and strWords[j]:find(char) == 1 then
            score = score + bonusFirstWordMatch
            j = j + 1
          end
        end
        for _index_0 = 1, #strWords do
          local word = strWords[_index_0]
          matchString(word, patternChars)
        end
      end
      if score >= 0 then
        return score
      else
        return 0
      end
    end,
    filter = function(self, filter, args)
      assert(type(filter) == 'number' and filter % 1 == 0, '"Library.filter" expected "filter" to be an integer.')
      local gamesToProcess = nil
      if args ~= nil and args.stack == true then
        assert(type(args.games) == 'table', '"Library.filter" expected "args.games" to be a table.')
        gamesToProcess = args.games
      else
        gamesToProcess = { }
        local _list_0 = self.games
        for _index_0 = 1, #_list_0 do
          local _continue_0 = false
          repeat
            local game = _list_0[_index_0]
            if not (self.platformEnabledStatus[game:getPlatformID()] == true) then
              _continue_0 = true
              break
            end
            if not game:isVisible() then
              if not (filter == ENUMS.FILTER_TYPES.HIDDEN) then
                _continue_0 = true
                break
              end
            elseif not game:isInstalled() then
              if not (filter == ENUMS.FILTER_TYPES.UNINSTALLED) then
                _continue_0 = true
                break
              end
            end
            table.insert(gamesToProcess, game)
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
      end
      local games = nil
      local _exp_0 = filter
      if ENUMS.FILTER_TYPES.NONE == _exp_0 then
        games = gamesToProcess
      elseif ENUMS.FILTER_TYPES.TITLE == _exp_0 then
        assert(type(args) == 'table', '"Library.filter" expected "args" to be a table.')
        assert(type(args.input) == 'string', '"Library.filter" expected "args.input" to be a string.')
        if args.input == '' then
          games = gamesToProcess
        else
          local temp = { }
          for _index_0 = 1, #gamesToProcess do
            local game = gamesToProcess[_index_0]
            table.insert(temp, {
              game = game,
              score = self:fuzzySearch(game:getTitle(), args.input)
            })
          end
          table.sort(temp, function(a, b)
            return a.score > b.score
          end)
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #temp do
              local entry = temp[_index_0]
              _accum_0[_len_0] = entry.game
              _len_0 = _len_0 + 1
            end
            games = _accum_0
          end
        end
      elseif ENUMS.FILTER_TYPES.PLATFORM == _exp_0 then
        assert(type(args) == 'table', '"Library.filter" expected "args" to be a table.')
        assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, '"Library.filter" expected "args.platformID" to be an integer.')
        local platformID = args.platformID
        local platformOverride = args.platformOverride
        if platformOverride ~= nil then
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #gamesToProcess do
              local game = gamesToProcess[_index_0]
              if game:getPlatformID() == platformID and game:getPlatformOverride() == platformOverride then
                _accum_0[_len_0] = game
                _len_0 = _len_0 + 1
              end
            end
            games = _accum_0
          end
        else
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_0 = 1, #gamesToProcess do
              local game = gamesToProcess[_index_0]
              if game:getPlatformID() == platformID and game:getPlatformOverride() == nil then
                _accum_0[_len_0] = game
                _len_0 = _len_0 + 1
              end
            end
            games = _accum_0
          end
        end
      elseif ENUMS.FILTER_TYPES.TAG == _exp_0 then
        assert(type(args) == 'table', '"Library.filter" expected "args" to be a table.')
        assert(type(args.tag) == 'string', '"Library.filter" expected "args.tag" to be a string.')
        local tag = args.tag
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #gamesToProcess do
            local game = gamesToProcess[_index_0]
            if game:hasTag(tag) == true then
              _accum_0[_len_0] = game
              _len_0 = _len_0 + 1
            end
          end
          games = _accum_0
        end
      elseif ENUMS.FILTER_TYPES.HIDDEN == _exp_0 then
        assert(type(args) == 'table', '"Library.filter" expected "args" to be a table.')
        assert(type(args.state) == 'boolean', '"Library.filter" expected "args.state" to be a boolean.')
        local state = args.state
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #gamesToProcess do
            local game = gamesToProcess[_index_0]
            if game:isVisible() ~= state then
              _accum_0[_len_0] = game
              _len_0 = _len_0 + 1
            end
          end
          games = _accum_0
        end
      elseif ENUMS.FILTER_TYPES.UNINSTALLED == _exp_0 then
        assert(type(args) == 'table', '"Library.filter" expected "args" to be a table.')
        assert(type(args.state) == 'boolean', '"Library.filter" expected "args.state" to be a boolean.')
        local state = args.state
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #gamesToProcess do
            local game = gamesToProcess[_index_0]
            if game:isInstalled() ~= state then
              _accum_0[_len_0] = game
              _len_0 = _len_0 + 1
            end
          end
          games = _accum_0
        end
      else
        assert(nil, 'Unknown filter type.')
      end
      assert(type(games) == 'table', '"Library.filter" expected "games" to be a table.')
      self.processedGames = games
    end,
    get = function(self)
      if self.processedGames == nil then
        self:filter(ENUMS.FILTER_TYPES.NONE, nil)
      end
      local games = self.processedGames
      self.processedGames = nil
      return games
    end,
    replace = function(self, old, new)
      assert(old ~= nil and old.__class == Game, '"Library.replace" expected the first argument to be an instance of "Game".')
      assert(new ~= nil and new.__class == Game, '"Library.replace" expected the second argument to be an instance of "Game".')
      return table.replace(self.games, old, new)
    end,
    remove = function(self, game)
      local i = table.find(self.games, game)
      table.remove(self.games, i)
      return self:save()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings)
      self.version = 1
      self.numBackups = settings:getNumberOfBackups()
      self.path = 'games.json'
      self.backupFilePattern = 'games_backup_%d.json'
      self.games = { }
      self.oldGames = self:load()
      self.currentGameID = 0
      self.processedGames = nil
    end,
    __base = _base_0,
    __name = "Library"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Library = _class_0
end
return Library
