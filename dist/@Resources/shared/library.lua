local Game = require('main.game')
local json = require('lib.json')
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
  },
  {
    version = 2,
    func = function(games)
      for i, game in ipairs(games) do
        if game.tags ~= nil and #game.tags == 0 then
          game.tags = nil
        end
        if game.platformTags ~= nil and #game.platformTags == 0 then
          game.platformTags = nil
        end
        if game.startingBangs ~= nil and #game.startingBangs == 0 then
          game.startingBangs = nil
        end
        if game.stoppingBangs ~= nil and #game.stoppingBangs == 0 then
          game.stoppingBangs = nil
        end
        game.ba = game.banner
        game.baURL = game.bannerURL
        game.exBa = game.expectedBanner
        game.gaID = game.gameID
        game.hi = game.hidden
        game.hoPl = game.hoursPlayed
        game.igOtBa = game.ignoresOtherBangs
        game.laPl = game.lastPlayed
        game.no = game.notes
        game.pa = game.path
        game.plID = game.platformID
        game.plOv = game.platformOverride
        game.plTa = game.platformTags
        game.pr = game.process
        game.prOv = game.processOverride
        game.staBa = game.startingBangs
        game.stoBa = game.stoppingBangs
        game.ta = game.tags
        game.ti = game.title
        game.un = game.uninstalled
        game.banner = nil
        game.bannerURL = nil
        game.expectedBanner = nil
        game.gameID = nil
        game.hidden = nil
        game.hoursPlayed = nil
        game.ignoresOtherBangs = nil
        game.lastPlayed = nil
        game.notes = nil
        game.path = nil
        game.platformID = nil
        game.platformOverride = nil
        game.platformTags = nil
        game.process = nil
        game.processOverride = nil
        game.startingBangs = nil
        game.stoppingBangs = nil
        game.tags = nil
        game.title = nil
        game.uninstalled = nil
      end
    end
  }
}
local Library
do
  local _class_0
  local _base_0 = {
    getDetectGames = function(self)
      return self.detectGames
    end,
    getNextAvailableGameID = function(self)
      return self.currentGameID
    end,
    getOldGames = function(self)
      return self.oldGames
    end,
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
          for key, tag in pairs(games.tagsDictionary or { }) do
            self.tagsDictionary[key] = tag
          end
          if version > 0 then
            games = games.games
          end
          if type(games) ~= 'table' then
            games = { }
          end
          local migrated = self:migrate(games, version)
          do
            local _accum_0 = { }
            local _len_0 = 1
            for _index_1 = 1, #games do
              local args = games[_index_1]
              _accum_0[_len_0] = Game(args, self.tagsDictionary)
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
    cleanUp = function(self)
      local tagReferenceCounts
      do
        local _tbl_0 = { }
        for key, tag in pairs(self.tagsDictionary) do
          _tbl_0[key] = 0
        end
        tagReferenceCounts = _tbl_0
      end
      local _list_0 = self.gamesSortedByGameID
      for _index_0 = 1, #_list_0 do
        local _continue_0 = false
        repeat
          local game = _list_0[_index_0]
          if not (game:hasTags()) then
            _continue_0 = true
            break
          end
          for key, tag in pairs(self.tagsDictionary) do
            if game:hasTag(key) ~= nil then
              tagReferenceCounts[key] = tagReferenceCounts[key] + 1
            end
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      for key, refCount in pairs(tagReferenceCounts) do
        if refCount == 0 then
          self.tagsDictionary[key] = nil
        end
      end
    end,
    save = function(self, games)
      if games == nil then
        games = self.gamesSortedByGameID
      end
      local out = json.encode({
        version = self.version,
        tagsDictionary = self.tagsDictionary,
        games = games,
        updated = self.updatedTimestamp
      })
      out = out:gsub('"[^"]+":', {
        ['"banner":'] = '"ba":',
        ['"bannerURL":'] = '"baURL":',
        ['"expectedBanner":'] = '"exBa":',
        ['"gameID":'] = '"gaID":',
        ['"hidden":'] = '"hi":',
        ['"hoursPlayed":'] = '"hoPl":',
        ['"ignoresOtherBangs":'] = '"igOtBa":',
        ['"lastPlayed":'] = '"laPl":',
        ['"notes":'] = '"no":',
        ['"path":'] = '"pa":',
        ['"platformID":'] = '"plID":',
        ['"platformOverride":'] = '"plOv":',
        ['"platformTags":'] = '"plTa":',
        ['"process":'] = '"pr":',
        ['"processOverride":'] = '"prOv":',
        ['"startingBangs":'] = '"stBa":',
        ['"stoppingBangs":'] = '"stBa":',
        ['"tags":'] = '"ta":',
        ['"title":'] = '"ti":',
        ['"uninstalled":'] = '"un":'
      })
      return io.writeFile(self.path, out)
    end,
    migrate = function(self, games, version)
      assert(type(version) == 'number' and version % 1 == 0, 'Expected the games version number to be an integer.')
      assert(version <= self.version, ('Unsupported games version. Expected version %d or earlier.'):format(self.version))
      if version == self.version then
        return false
      end
      for _index_0 = 1, #migrators do
        local migrator = migrators[_index_0]
        if version < migrator.version then
          log("Migrating games.json from version " .. tostring(version) .. " to " .. tostring(migrator.version) .. ".")
          migrator.func(games, self.tagsDictionary)
        end
      end
      return true
    end,
    extend = function(self, games)
      if games == nil then
        return { }
      end
      assert(type(games) == 'table', 'shared.library.Library.extend')
      if #games == 0 then
        return { }
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #games do
          local args = games[_index_0]
          _accum_0[_len_0] = Game(args, self.tagsDictionary)
          _len_0 = _len_0 + 1
        end
        games = _accum_0
      end
      for _index_0 = 1, #games do
        local game = games[_index_0]
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
        table.insert(self.gamesSortedByGameID, game)
      end
      return games
    end,
    updateSortedList = function(self)
      return table.sort(self.gamesSortedByGameID, function(a, b)
        return a.gameID < b.gameID
      end)
    end,
    insert = function(self, game)
      assert(game.__class == Game, 'shared.library.Library.insert')
      local title = game:getTitle()
      local platformID = game:getPlatformID()
      local _list_0 = self.games
      for _index_0 = 1, #_list_0 do
        local oldGame = _list_0[_index_0]
        if oldGame:getPlatformID() == platformID and oldGame:getTitle() == title then
          return 
        end
      end
      game:setGameID(self.currentGameID)
      self.currentGameID = self.currentGameID + 1
      table.insert(self.games, game)
      table.insert(self.gamesSortedByGameID, game)
      self:updateSortedList()
      return self:save()
    end,
    finalize = function(self, platformEnabledStatus)
      assert(type(platformEnabledStatus) == 'table', 'shared.library.Library.finalize')
      self.platformEnabledStatus = platformEnabledStatus
      local _list_0 = self.oldGames
      for _index_0 = 1, #_list_0 do
        local game = _list_0[_index_0]
        if game:getPlatformID() ~= ENUMS.PLATFORM_IDS.CUSTOM then
          game:setInstalled(false)
        end
        game:setGameID(self.currentGameID)
        self.currentGameID = self.currentGameID + 1
        table.insert(self.games, game)
        table.insert(self.gamesSortedByGameID, game)
      end
      self.oldGames = nil
      if #self.gamesSortedByGameID ~= #self.games then
        self.gamesSortedByGameID = table.shallowCopy(self.games)
      end
      self:updateSortedList()
      if #self.gamesSortedByGameID > 0 then
        self.currentGameID = self.gamesSortedByGameID[#self.gamesSortedByGameID]:getGameID() + 1
      end
    end,
    add = function(self, gameID)
      assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID >= self.currentGameID, 'shared.library.Library.add')
      local games = io.readJSON(self.path)
      local args = games.games[gameID]
      local newGame
      if args ~= nil then
        newGame = Game(args, self.tagsDictionary)
      else
        newGame = nil
      end
      if newGame == nil or newGame:getGameID() ~= gameID then
        newGame = nil
        local _list_0 = games.games
        for _index_0 = 1, #_list_0 do
          local args = _list_0[_index_0]
          local game = Game(args, self.tagsDictionary)
          if game:getGameID() == gameID then
            newGame = game
            break
          end
        end
      end
      if newGame == nil then
        log('Failed to add game!')
        return false
      end
      self:insert(newGame)
      return true
    end,
    update = function(self, gameID)
      assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID < self.currentGameID, 'shared.library.Library.update')
      local games = io.readJSON(self.path)
      local tagsDictionary = games.tagsDictionary
      for key, tag in pairs(tagsDictionary) do
        if self.tagsDictionary[key] == nil then
          self.tagsDictionary[key] = tag
        end
      end
      local args = games.games[gameID]
      local updatedGame
      if args ~= nil then
        updatedGame = Game(args, self.tagsDictionary)
      else
        updatedGame = nil
      end
      if updatedGame == nil or updatedGame:getGameID() ~= gameID then
        updatedGame = nil
        local _list_0 = games.games
        for _index_0 = 1, #_list_0 do
          local args = _list_0[_index_0]
          local game = Game(args, self.tagsDictionary)
          if game:getGameID() == gameID then
            updatedGame = game
            break
          end
        end
      end
      if updatedGame == nil then
        log('Failed to find the updated game!')
        return false
      end
      local gameToUpdate = self.gamesSortedByGameID[gameID]
      if gameToUpdate == nil or gameToUpdate:getGameID() ~= gameID then
        gameToUpdate = nil
        local _list_0 = self.gamesSortedByGameID
        for _index_0 = 1, #_list_0 do
          local game = _list_0[_index_0]
          if game:getGameID() == gameID then
            gameToUpdate = game
            break
          end
        end
      end
      if gameToUpdate == nil then
        log('Failed to update the game!')
        return false
      end
      log('Updating game')
      gameToUpdate:merge(updatedGame, true)
      self:save()
      return true
    end,
    sort = function(self, sorting, games)
      if games == nil then
        games = self.games
      end
      assert(type(sorting) == 'number' and sorting % 1 == 0, 'shared.library.Library.sort')
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
      assert(type(comp) == 'function', 'shared.library.Library.sort')
      table.sort(games, comp)
      if games ~= self.games then
        return table.sort(self.games, comp)
      end
    end,
    fuzzySearch = function(self, str, pattern)
      assert(type(str) == 'string', 'shared.library.Library.fuzzySearch')
      assert(type(pattern) == 'string', 'shared.library.Library.fuzzySearch')
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
    filterGames = function(self, games, condition)
      local result = { }
      local i = 1
      while i <= #games do
        if condition(games[i]) == true then
          table.insert(result, table.remove(games, i))
        else
          i = i + 1
        end
      end
      return result
    end,
    filter = function(self, filter, args)
      if args == nil then
        args = { }
      end
      assert(type(filter) == 'number' and filter % 1 == 0, 'shared.library.Library.filter')
      local gamesToProcess = nil
      if args ~= nil and args.stack == true then
        assert(type(args.games) == 'table', 'shared.library.Library.filter')
        gamesToProcess = args.games
        args.games = nil
        table.insert(self.filterStack, {
          filter = filter,
          args = args
        })
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
              if not game:isInstalled() and self.searchHiddenGames == true then
                if not (self.searchUninstalledGames == true) then
                  _continue_0 = true
                  break
                end
              end
              if not (filter == ENUMS.FILTER_TYPES.HIDDEN or filter == ENUMS.FILTER_TYPES.TITLE and self.searchHiddenGames == true) then
                _continue_0 = true
                break
              end
            elseif not game:isInstalled() then
              if not (filter == ENUMS.FILTER_TYPES.UNINSTALLED or filter == ENUMS.FILTER_TYPES.TITLE and self.searchUninstalledGames == true) then
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
        if filter == ENUMS.FILTER_TYPES.NONE then
          self.filterStack = { }
        else
          self.filterStack = {
            {
              filter = filter,
              args = args
            }
          }
        end
      end
      local games = nil
      local _exp_0 = filter
      if ENUMS.FILTER_TYPES.NONE == _exp_0 then
        games = gamesToProcess
        self.filterStack = { }
      elseif ENUMS.FILTER_TYPES.TITLE == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.input) == 'string', 'shared.library.Library.filter')
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
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert((type(args.platformID) == 'number' and args.platformID % 1 == 0) or type(args.platformOverride) == 'string', 'shared.library.Library.filter')
        local platformID = args.platformID
        local platformOverride = args.platformOverride
        games = self:filterGames(gamesToProcess, function(game)
          if platformOverride == nil then
            return platformID == game:getPlatformID() and game:getPlatformOverride() == nil
          end
          return platformOverride == game:getPlatformOverride()
        end)
      elseif ENUMS.FILTER_TYPES.TAG == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.tag) == 'string', 'shared.library.Library.filter')
        local tag = args.tag
        local key = table.find(self.tagsDictionary, tag)
        games = self:filterGames(gamesToProcess, function(game)
          return game:hasTag(key) ~= nil
        end)
      elseif ENUMS.FILTER_TYPES.HIDDEN == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        local state = args.state
        games = self:filterGames(gamesToProcess, function(game)
          return game:isVisible() ~= state
        end)
      elseif ENUMS.FILTER_TYPES.UNINSTALLED == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        local state = args.state
        games = self:filterGames(gamesToProcess, function(game)
          return game:isInstalled() ~= state
        end)
      elseif ENUMS.FILTER_TYPES.NO_TAGS == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        if args.state then
          games = self:filterGames(gamesToProcess, function(game)
            return game:hasTags() == false
          end)
        else
          games = self:filterGames(gamesToProcess, function(game)
            return game:hasTags() == true
          end)
        end
      elseif ENUMS.FILTER_TYPES.RANDOM_GAME == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        games = {
          table.remove(gamesToProcess, math.random(1, #gamesToProcess))
        }
      elseif ENUMS.FILTER_TYPES.NEVER_PLAYED == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        games = self:filterGames(gamesToProcess, function(game)
          return game:getHoursPlayed() == 0
        end)
      elseif ENUMS.FILTER_TYPES.HAS_NOTES == _exp_0 then
        assert(type(args) == 'table', 'shared.library.Library.filter')
        assert(type(args.state) == 'boolean', 'shared.library.Library.filter')
        games = self:filterGames(gamesToProcess, function(game)
          return game:getNotes() ~= nil
        end)
      else
        assert(nil, 'shared.library.Library.filter')
      end
      if args.inverse == true then
        games = gamesToProcess
      end
      assert(type(games) == 'table', 'shared.library.Library.filter')
      self.processedGames = games
    end,
    getFilterStack = function(self)
      return self.filterStack
    end,
    get = function(self)
      if self.processedGames == nil then
        self:filter(ENUMS.FILTER_TYPES.NONE, nil)
      end
      local games = self.processedGames
      self.processedGames = nil
      return games
    end,
    getGameByID = function(self, gameID)
      assert(type(gameID) == 'number' and gameID % 1 == 0 and gameID < self.currentGameID, 'shared.library.Library.getGameByGameID')
      local game = self.gamesSortedByGameID[gameID]
      if game == nil or game:getGameID() ~= gameID then
        local _list_0 = self.gamesSortedByGameID
        for _index_0 = 1, #_list_0 do
          local game = _list_0[_index_0]
          if game:getGameID() == gameID then
            return game
          end
        end
        log('Failed to get game by gameID:', gameID)
        return nil
      end
      return game
    end,
    replace = function(self, old, new)
      assert(old ~= nil and old.__class == Game, 'shared.library.Library.replace')
      assert(new ~= nil and new.__class == Game, 'shared.library.Library.replace')
      return table.replace(self.games, old, new)
    end,
    remove = function(self, game)
      local i = table.find(self.games, game)
      table.remove(self.games, i)
      i = table.find(self.gamesSortedByGameID, game)
      table.remove(self.gamesSortedByGameID, i)
      return self:save()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, settings, regularMode)
      if regularMode == nil then
        regularMode = true
      end
      assert(type(settings) == 'table', 'shared.library.Library')
      assert(type(regularMode) == 'boolean', 'shared.library.Library')
      self.version = 2
      self.path = 'games.json'
      local games
      if io.fileExists(self.path) then
        games = io.readJSON(self.path)
      else
        games = { }
      end
      self.currentGameID = 1
      self.numBackups = settings:getNumberOfBackups()
      self.backupFilePattern = 'games_backup_%d.json'
      self.searchUninstalledGames = settings:getSearchUninstalledGamesEnabled()
      self.searchHiddenGames = settings:getSearchHiddenGamesEnabled()
      self.filterStack = { }
      self.processedGames = nil
      self.gamesSortedByGameID = { }
      self.detectGames = false
      if regularMode == true then
        self.updatedTimestamp = os.date('*t')
      else
        self.updatedTimestamp = games.updated
      end
      self.tagsDictionary = { }
      if regularMode then
        local _exp_0 = settings:getGameDetectionFrequency()
        if ENUMS.GAME_DETECTION_FREQUENCY.ALWAYS == _exp_0 then
          self.detectGames = true
        elseif ENUMS.GAME_DETECTION_FREQUENCY.ONCE_PER_DAY == _exp_0 then
          self.updatedTimestamp = os.date('*t')
          local updated = games.updated or { }
          if updated.year == self.updatedTimestamp.year and updated.month == self.updatedTimestamp.month and updated.day == self.updatedTimestamp.day then
            self.detectGames = false
          else
            self.detectGames = true
          end
        elseif ENUMS.GAME_DETECTION_FREQUENCY.NEVER == _exp_0 then
          if games.updated == nil then
            self.detectGames = true
          else
            self.detectGames = false
          end
        else
          self.detectGames = false
        end
        if self.detectGames == true then
          self.games = { }
          self.oldGames = self:load()
        else
          for key, tag in pairs(games.tagsDictionary or { }) do
            self.tagsDictionary[key] = tag
          end
          do
            local _accum_0 = { }
            local _len_0 = 1
            local _list_0 = games.games
            for _index_0 = 1, #_list_0 do
              local args = _list_0[_index_0]
              _accum_0[_len_0] = Game(args, self.tagsDictionary)
              _len_0 = _len_0 + 1
            end
            self.games = _accum_0
          end
          self.oldGames = { }
        end
      else
        for key, tag in pairs(games.tagsDictionary or { }) do
          self.tagsDictionary[key] = tag
        end
        do
          local _accum_0 = { }
          local _len_0 = 1
          local _list_0 = games.games
          for _index_0 = 1, #_list_0 do
            local args = _list_0[_index_0]
            _accum_0[_len_0] = Game(args, self.tagsDictionary)
            _len_0 = _len_0 + 1
          end
          self.games = _accum_0
        end
        self.oldGames = { }
      end
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
