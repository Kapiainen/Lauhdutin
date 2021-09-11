RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
local json = nil
LOCALIZATION = nil
STATE = {
  PATHS = {
    RESOURCES = nil
  },
  SCROLLBAR = {
    START = nil,
    MAX_HEIGHT = nil,
    HEIGHT = nil,
    STEP = nil
  },
  NUM_SLOTS = 5,
  LOGGING = false,
  STACK = false,
  SCROLL_INDEX = nil,
  PROPERTIES = nil,
  DEFAULT_PROPERTIES = nil,
  INVERSE_PROPERTIES = nil,
  FILTER_TYPE = nil,
  ARGUMENTS = { },
  NUM_GAMES_PATTERN = '',
  BACK_BUTTON_TITLE = ''
}
local COMPONENTS = {
  STATUS = nil,
  SETTINGS = nil,
  SLOTS = nil
}
local Property
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, args)
      self.title = args.title
      self.value = args.value
      self.enum = args.enum
      self.arguments = args.arguments
      self.properties = args.properties
      self.action = args.action
      self.update = args.update
    end,
    __base = _base_0,
    __name = "Property"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Property = _class_0
end
local Slot
do
  local _class_0
  local _base_0 = {
    populate = function(self, property)
      self.property = property
      return self:update()
    end,
    update = function(self)
      if self.property then
        if self.property.update ~= nil then
          self.property.value = self.property:update()
        end
        SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]'):format(self.index, utility.replaceUnsupportedChars(self.property.title)))
        SKIN:Bang(('[!SetOption "Slot%dValue" "Text" "%s"]'):format(self.index, utility.replaceUnsupportedChars(self.property.value)))
        return 
      end
      SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" " "]'):format(self.index))
      return SKIN:Bang(('[!SetOption "Slot%dValue" "Text" " "]'):format(self.index))
    end,
    hasAction = function(self)
      return self.property ~= nil
    end,
    action = function(self)
      if self.property.enum ~= nil then
        STATE.FILTER_TYPE = self.property.enum
      end
      if self.property.arguments ~= nil then
        for key, value in pairs(self.property.arguments) do
          STATE.ARGUMENTS[key] = value
        end
      end
      if self.property.properties ~= nil then
        STATE.PROPERTIES = self.property.properties
        return true
      end
      if self.property.action ~= nil then
        self.property:action()
        return true
      end
      local filter = STATE.FILTER_TYPE
      local arguments = json.encode(STATE.ARGUMENTS):gsub('"', '|')
      SKIN:Bang(('[!CommandMeasure "Script" "Filter(%d, %s, \'%s\')" "#ROOTCONFIG#"]'):format(filter, tostring(STATE.STACK), arguments))
      return false
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index)
      self.index = index
    end,
    __base = _base_0,
    __name = "Slot"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Slot = _class_0
end
local Game = nil
HideStatus = function()
  return COMPONENTS.STATUS:hide()
end
Initialize = function()
  SKIN:Bang('[!Hide]')
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.enums')
    utility = require('shared.utility')
    utility.createJSONHelpers()
    json = require('lib.json')
    COMPONENTS.SETTINGS = require('shared.settings')()
    if COMPONENTS.SETTINGS:getLogging() == true then
      log = function(...)
        return print(...)
      end
    else
      log = function() end
    end
    log('Initializing Filter config')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    STATE.NUM_GAMES_PATTERN = LOCALIZATION:get('game_number_of_games', '%d games')
    STATE.BACK_BUTTON_TITLE = LOCALIZATION:get('filter_back_button_title', 'Back')
    Game = require('main.game')
    STATE.SCROLL_INDEX = 1
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, STATE.NUM_SLOTS do
        _accum_0[_len_0] = Slot(i)
        _len_0 = _len_0 + 1
      end
      COMPONENTS.SLOTS = _accum_0
    end
    local scrollbar = SKIN:GetMeter('Scrollbar')
    STATE.SCROLLBAR.START = scrollbar:GetY()
    STATE.SCROLLBAR.MAX_HEIGHT = scrollbar:GetH()
    SKIN:Bang('[!CommandMeasure "Script" "HandshakeFilter()" "#ROOTCONFIG#"]')
    return COMPONENTS.STATUS:hide()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
local sortPropertiesByTitle
sortPropertiesByTitle = function(a, b)
  return a.title:lower() < b.title:lower()
end
local createHiddenProperties
createHiddenProperties = function(default, inverse, numGames, numHiddenGames)
  if numHiddenGames > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_is_hidden', 'Is hidden'),
      value = STATE.NUM_GAMES_PATTERN:format(numHiddenGames),
      enum = ENUMS.FILTER_TYPES.HIDDEN,
      arguments = {
        state = true
      }
    }))
  end
  if numGames > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_is_hidden_inverse', 'Is not hidden'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.HIDDEN,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createUninstalledProperties
createUninstalledProperties = function(default, inverse, numGames, numUninstalledGames)
  if numUninstalledGames > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_is_uninstalled', 'Is not installed'),
      value = STATE.NUM_GAMES_PATTERN:format(numUninstalledGames),
      enum = ENUMS.FILTER_TYPES.UNINSTALLED,
      arguments = {
        state = true
      }
    }))
  end
  if numGames > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_is_uninstalled_inverse', 'Is installed'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.UNINSTALLED,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createPlatformProperties
createPlatformProperties = function(default, inverse, numGames, platforms, platformGameCounts, backDefault, backInverse)
  local platformsDefault = { }
  local platformsInverse = { }
  local platformNames
  do
    local _tbl_0 = { }
    for _index_0 = 1, #platforms do
      local platform = platforms[_index_0]
      _tbl_0[platform:getPlatformID()] = platform:getName()
    end
    platformNames = _tbl_0
  end
  for platform, i in pairs(platformGameCounts) do
    local _continue_0 = false
    repeat
      if i <= 0 then
        _continue_0 = true
        break
      end
      if type(platform) == 'number' then
        table.insert(platformsDefault, Property({
          title = platformNames[platform],
          value = STATE.NUM_GAMES_PATTERN:format(i),
          arguments = {
            platformID = platform
          }
        }))
        table.insert(platformsInverse, Property({
          title = platformNames[platform],
          value = STATE.NUM_GAMES_PATTERN:format(numGames - i),
          arguments = {
            platformID = platform,
            inverse = true
          }
        }))
      else
        local title = platform .. '*'
        table.insert(platformsDefault, Property({
          title = title,
          value = STATE.NUM_GAMES_PATTERN:format(i),
          arguments = {
            platformOverride = platform
          }
        }))
        table.insert(platformsInverse, Property({
          title = title,
          value = STATE.NUM_GAMES_PATTERN:format(numGames - i),
          arguments = {
            platformOverride = platform,
            inverse = true
          }
        }))
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  table.sort(platformsDefault, sortPropertiesByTitle)
  table.sort(platformsInverse, sortPropertiesByTitle)
  if numGames < 1 then
    platformsDefault = nil
  else
    platformsDefault = Property({
      title = LOCALIZATION:get('filter_from_platform', 'Is on platform X'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.PLATFORM,
      properties = platformsDefault
    })
  end
  if numGames < 1 then
    platformsInverse = nil
  else
    platformsInverse = Property({
      title = LOCALIZATION:get('filter_from_platform_inverse', 'Is not on platform X'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.PLATFORM,
      properties = platformsInverse
    })
  end
  if platformsDefault then
    table.insert(platformsDefault.properties, 1, backDefault)
    table.insert(default, platformsDefault)
  end
  if platformsInverse then
    table.insert(platformsInverse.properties, 1, backInverse)
    return table.insert(inverse, platformsInverse)
  end
end
local createTagProperties
createTagProperties = function(default, inverse, numGames, numGamesWithTags, tagsGameCounts, backDefault, backInverse)
  local tagsDefault = { }
  local tagsInverse = { }
  for tag, i in pairs(tagsGameCounts) do
    if i > 0 then
      table.insert(tagsDefault, Property({
        title = tag,
        value = STATE.NUM_GAMES_PATTERN:format(i),
        arguments = {
          tag = tag
        }
      }))
      table.insert(tagsInverse, Property({
        title = tag,
        value = STATE.NUM_GAMES_PATTERN:format(numGames - i),
        arguments = {
          tag = tag,
          inverse = true
        }
      }))
    end
  end
  table.sort(tagsDefault, sortPropertiesByTitle)
  table.sort(tagsInverse, sortPropertiesByTitle)
  if #tagsDefault < 1 then
    tagsDefault = nil
  else
    tagsDefault = Property({
      title = LOCALIZATION:get('filter_has_tag', 'Has tag X'),
      value = STATE.NUM_GAMES_PATTERN:format(numGamesWithTags),
      enum = ENUMS.FILTER_TYPES.TAG,
      properties = tagsDefault
    })
  end
  if #tagsInverse < 1 then
    tagsInverse = nil
  else
    tagsInverse = Property({
      title = LOCALIZATION:get('filter_has_tag_inverse', 'Does not have tag X'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.TAG,
      properties = tagsInverse
    })
  end
  if tagsDefault then
    table.insert(tagsDefault.properties, 1, backDefault)
    table.insert(default, tagsDefault)
  end
  if tagsInverse then
    table.insert(tagsInverse.properties, 1, backInverse)
    return table.insert(inverse, tagsInverse)
  end
end
local createNoTagProperties
createNoTagProperties = function(default, inverse, numGames, numGamesWithTags)
  if (numGames - numGamesWithTags) > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_has_no_tags', 'Has no tags'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames - numGamesWithTags),
      enum = ENUMS.FILTER_TYPES.NO_TAGS,
      arguments = {
        state = true
      }
    }))
  end
  if numGamesWithTags > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_has_no_tags_inverse', 'Has one or more tags'),
      value = STATE.NUM_GAMES_PATTERN:format(numGamesWithTags),
      enum = ENUMS.FILTER_TYPES.NO_TAGS,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createRandomProperties
createRandomProperties = function(default, inverse, numGames)
  if numGames > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_random', 'Pick a random game'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.RANDOM_GAME,
      arguments = {
        state = true
      }
    }))
  end
  if numGames > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_random_inverse', 'Remove a random game'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames),
      enum = ENUMS.FILTER_TYPES.RANDOM_GAME,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createNeverPlayerProperties
createNeverPlayerProperties = function(default, inverse, numGames, numGamesNeverPlayed)
  if numGamesNeverPlayed > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_never_played', 'Has never been played'),
      value = STATE.NUM_GAMES_PATTERN:format(numGamesNeverPlayed),
      enum = ENUMS.FILTER_TYPES.NEVER_PLAYED,
      arguments = {
        state = true
      }
    }))
  end
  if (numGames - numGamesNeverPlayed) > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_never_played_inverse', 'Has been played'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames - numGamesNeverPlayed),
      enum = ENUMS.FILTER_TYPES.NEVER_PLAYED,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createNotesProperties
createNotesProperties = function(default, inverse, numGames, numGamesWithNotes)
  if numGamesWithNotes > 0 then
    table.insert(default, Property({
      title = LOCALIZATION:get('filter_has_notes', 'Has notes'),
      value = STATE.NUM_GAMES_PATTERN:format(numGamesWithNotes),
      enum = ENUMS.FILTER_TYPES.HAS_NOTES,
      arguments = {
        state = true
      }
    }))
  end
  if (numGames - numGamesWithNotes) > 0 then
    return table.insert(inverse, Property({
      title = LOCALIZATION:get('filter_has_notes_inverse', 'Does not have notes'),
      value = STATE.NUM_GAMES_PATTERN:format(numGames - numGamesWithNotes),
      enum = ENUMS.FILTER_TYPES.HAS_NOTES,
      arguments = {
        state = true,
        inverse = true
      }
    }))
  end
end
local createInvertProperties
createInvertProperties = function(default, inverse)
  local invertFilters = Property({
    title = LOCALIZATION:get('filter_invert_filters', 'Invert filters'),
    value = ' ',
    action = function(self)
      if STATE.PROPERTIES == STATE.DEFAULT_PROPERTIES then
        STATE.PROPERTIES = STATE.INVERSE_PROPERTIES
      else
        STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
      end
    end
  })
  table.insert(default, 1, invertFilters)
  return table.insert(inverse, 1, invertFilters)
end
local createClearProperties
createClearProperties = function(default, inverse)
  local clear = Property({
    title = LOCALIZATION:get('filter_clear_filters', 'Clear filters'),
    value = ' ',
    enum = ENUMS.FILTER_TYPES.NONE
  })
  table.insert(default, clear)
  return table.insert(inverse, clear)
end
local createCancelProperties
createCancelProperties = function(default, inverse)
  local cancel = Property({
    title = LOCALIZATION:get('button_label_cancel', 'Cancel'),
    value = ' ',
    action = function(self)
      return SKIN:Bang('[!DeactivateConfig]')
    end
  })
  table.insert(default, cancel)
  return table.insert(inverse, cancel)
end
local createProperties
createProperties = function(games, hiddenGames, uninstalledGames, platforms, stack, filterStack)
  local defaultProperties = { }
  local inverseProperties = { }
  local numGames = #games
  local numHiddenGames = #hiddenGames
  createHiddenProperties(defaultProperties, inverseProperties, numGames, numHiddenGames)
  local numUninstalledGames = #uninstalledGames
  createUninstalledProperties(defaultProperties, inverseProperties, numGames, numUninstalledGames)
  if numGames > 0 then
    local skipPlatforms = false
    local skipTags = false
    local skipNoTags = false
    local skipRandom = false
    local skipNeverPlayed = false
    local skipHasNotes = false
    for _index_0 = 1, #filterStack do
      local f = filterStack[_index_0]
      local _exp_0 = f.filter
      if ENUMS.FILTER_TYPES.PLATFORM == _exp_0 then
        skipPlatforms = true
      elseif ENUMS.FILTER_TYPES.NO_TAGS == _exp_0 then
        skipTags = true
      elseif ENUMS.FILTER_TYPES.TAG == _exp_0 then
        skipNoTags = true
      elseif ENUMS.FILTER_TYPES.RANDOM_GAME == _exp_0 then
        if numGames < 2 then
          skipRandom = true
        end
      elseif ENUMS.FILTER_TYPES.NEVER_PLAYED == _exp_0 then
        skipNeverPlayed = true
      elseif ENUMS.FILTER_TYPES.HAS_NOTES == _exp_0 then
        skipHasNotes = true
      end
    end
    local backDefault = Property({
      title = STATE.BACK_BUTTON_TITLE,
      value = ' ',
      properties = defaultProperties
    })
    local backInverse = Property({
      title = STATE.BACK_BUTTON_TITLE,
      value = ' ',
      properties = inverseProperties
    })
    local platformGameCounts = { }
    local tagsGameCounts = { }
    local numGamesWithTags = 0
    local numGamesNeverPlayed = 0
    local numGamesWithNotes = 0
    if not (skipPlatforms) then
      for _index_0 = 1, #platforms do
        local platform = platforms[_index_0]
        local platformGames = 0
        local platformID = platform:getPlatformID()
        platformGameCounts[platformID] = 0
      end
    end
    for _index_0 = 1, #games do
      local game = games[_index_0]
      if not (skipPlatforms) then
        local platformID = game:getPlatformID()
        local platformOverride = game:getPlatformOverride()
        if platformOverride == nil then
          platformGameCounts[platformID] = platformGameCounts[platformID] + 1
        else
          if platformGameCounts[platformOverride] == nil then
            platformGameCounts[platformOverride] = 0
          end
          platformGameCounts[platformOverride] = platformGameCounts[platformOverride] + 1
        end
      end
      if not (skipTags) then
        local gameTags, n = game:getTags()
        if n > 0 then
          for tag, source in pairs(gameTags) do
            local _continue_0 = false
            repeat
              local skip = false
              for _index_1 = 1, #filterStack do
                local f = filterStack[_index_1]
                if f.filter == ENUMS.FILTER_TYPES.TAG and f.args.tag == tag then
                  skip = true
                  break
                end
              end
              if skip then
                _continue_0 = true
                break
              end
              if tagsGameCounts[tag] == nil then
                tagsGameCounts[tag] = 0
              end
              tagsGameCounts[tag] = tagsGameCounts[tag] + 1
              _continue_0 = true
            until true
            if not _continue_0 then
              break
            end
          end
          numGamesWithTags = numGamesWithTags + 1
        end
      end
      if not (skipNeverPlayed) then
        if game:getHoursPlayed() == 0 then
          numGamesNeverPlayed = numGamesNeverPlayed + 1
        end
      end
      if not (skipHasNotes) then
        if game:getNotes() ~= nil then
          numGamesWithNotes = numGamesWithNotes + 1
        end
      end
    end
    if not (skipPlatforms) then
      createPlatformProperties(defaultProperties, inverseProperties, numGames, platforms, platformGameCounts, backDefault, backInverse)
    end
    if not (skipTags) then
      createTagProperties(defaultProperties, inverseProperties, numGames, numGamesWithTags, tagsGameCounts, backDefault, backInverse)
    end
    if not (skipNoTags) then
      createNoTagProperties(defaultProperties, inverseProperties, numGames, numGamesWithTags)
    end
    if not skipRandom and numGames > 1 then
      createRandomProperties(defaultProperties, inverseProperties, numGames)
    end
    if not (skipNeverPlayed) then
      createNeverPlayerProperties(defaultProperties, inverseProperties, numGames, numGamesNeverPlayed)
    end
    if not (skipHasNotes) then
      createNotesProperties(defaultProperties, inverseProperties, numGames, numGamesWithNotes)
    end
  end
  table.sort(defaultProperties, sortPropertiesByTitle)
  table.sort(inverseProperties, sortPropertiesByTitle)
  createInvertProperties(defaultProperties, inverseProperties)
  if not (stack) then
    createClearProperties(defaultProperties, inverseProperties)
  end
  createCancelProperties(defaultProperties, inverseProperties)
  return defaultProperties, inverseProperties
end
local updateScrollbar
updateScrollbar = function()
  STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
  if #STATE.PROPERTIES > STATE.NUM_SLOTS then
    local div = (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1)
    if div < 1 then
      div = 1
    end
    STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / div)
    div = (#STATE.PROPERTIES - STATE.NUM_SLOTS)
    if div < 1 then
      div = 1
    end
    STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / div
  else
    STATE.SCROLLBAR.HEIGHT = STATE.SCROLLBAR.MAX_HEIGHT
    STATE.SCROLLBAR.STEP = 0
  end
  SKIN:Bang(('[!SetOption "Scrollbar" "H" "%d"]'):format(STATE.SCROLLBAR.HEIGHT))
  local y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
  return SKIN:Bang(('[!SetOption "Scrollbar" "Y" "%d"]'):format(math.round(y)))
end
local updateSlots
updateSlots = function()
  for i, slot in ipairs(COMPONENTS.SLOTS) do
    slot:populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
    if i == STATE.HIGHLIGHTED_SLOT_INDEX then
      MouseOver(i)
    end
  end
end
Handshake = function(stack, appliedFilters)
  local success, err = pcall(function()
    log('Accepting Filter handshake', stack)
    STATE.SCROLL_INDEX = 1
    STATE.STACK = stack
    local platforms
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = require('main.platforms')
      for _index_0 = 1, #_list_0 do
        local Platform = _list_0[_index_0]
        _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
        _len_0 = _len_0 + 1
      end
      platforms = _accum_0
    end
    local games = nil
    local hiddenGames = { }
    local uninstalledGames = { }
    appliedFilters = appliedFilters:gsub('|', '"')
    local filterStack = json.decode(appliedFilters)
    if stack then
      SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('filter_window_current_title', 'Filter (current games)')))
      local library = require('shared.library')(COMPONENTS.SETTINGS, false)
      local platformsEnabledStatus = { }
      local temp = { }
      for _index_0 = 1, #platforms do
        local platform = platforms[_index_0]
        local enabled = platform:isEnabled()
        platformsEnabledStatus[platform:getPlatformID()] = enabled
        if enabled then
          table.insert(temp, platform)
        end
      end
      platforms = temp
      temp = nil
      library:finalize(platformsEnabledStatus)
      games = library:get()
      local showHiddenGames = false
      local showUninstalledGames = false
      for _index_0 = 1, #filterStack do
        local f = filterStack[_index_0]
        if f.filter == ENUMS.FILTER_TYPES.HIDDEN and f.args.state == true then
          showHiddenGames = true
        elseif f.filter == ENUMS.FILTER_TYPES.UNINSTALLED and f.args.state == true then
          showUninstalledGames = true
        end
        f.args.games = games
        library:filter(f.filter, f.args)
        games = library:get()
      end
      for i = #games, 1, -1 do
        if not games[i]:isVisible() and not showHiddenGames then
          table.insert(hiddenGames, table.remove(games, i))
        elseif not games[i]:isInstalled() and not (showUninstalledGames or showHiddenGames) then
          table.insert(uninstalledGames, table.remove(games, i))
        end
      end
    else
      SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('filter_window_all_title', 'Filter')))
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #platforms do
          local platform = platforms[_index_0]
          if platform:isEnabled() then
            _accum_0[_len_0] = platform
            _len_0 = _len_0 + 1
          end
        end
        platforms = _accum_0
      end
      games = io.readJSON('games.json')
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = games.games
        for _index_0 = 1, #_list_0 do
          local args = _list_0[_index_0]
          _accum_0[_len_0] = Game(args, games.tagsDictionary)
          _len_0 = _len_0 + 1
        end
        games = _accum_0
      end
      for i = #games, 1, -1 do
        if not games[i]:isVisible() then
          table.insert(hiddenGames, table.remove(games, i))
        elseif not games[i]:isInstalled() then
          table.insert(uninstalledGames, table.remove(games, i))
        end
      end
    end
    STATE.DEFAULT_PROPERTIES, STATE.INVERSE_PROPERTIES = createProperties(games, hiddenGames, uninstalledGames, platforms, stack, filterStack)
    STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
    updateScrollbar()
    updateSlots()
    if COMPONENTS.SETTINGS:getCenterOnMonitor() then
      local meter = SKIN:GetMeter('WindowShadow')
      local skinWidth = meter:GetW()
      local skinHeight = meter:GetH()
      local mainConfig = utility.getConfig(SKIN:GetVariable('ROOTCONFIG'))
      local monitorIndex = nil
      if mainConfig ~= nil then
        monitorIndex = utility.getConfigMonitor(mainConfig) or 1
      else
        monitorIndex = 1
      end
      local x, y = utility.centerOnMonitor(skinWidth, skinHeight, monitorIndex)
      SKIN:Bang(('[!Move "%d" "%d"]'):format(x, y))
    end
    return SKIN:Bang('[!ZPos 1][!Show]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Scroll = function(direction)
  local success, err = pcall(function()
    if not (COMPONENTS.SLOTS) then
      return 
    end
    local index = STATE.SCROLL_INDEX + direction
    if index < 1 then
      return 
    elseif index > STATE.MAX_SCROLL_INDEX then
      return 
    end
    STATE.SCROLL_INDEX = index
    updateScrollbar()
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
MouseOver = function(index)
  local success, err = pcall(function()
    if index < 1 then
      return 
    end
    if not (COMPONENTS.SLOTS) then
      return 
    end
    if not (COMPONENTS.SLOTS[index]:hasAction()) then
      return 
    end
    STATE.HIGHLIGHTED_SLOT_INDEX = index
    return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
MouseLeave = function(index)
  local success, err = pcall(function()
    if index < 1 then
      return 
    end
    if not (COMPONENTS.SLOTS) then
      return 
    end
    if index == 0 then
      STATE.HIGHLIGHTED_SLOT_INDEX = 0
      for i = index, STATE.NUM_SLOTS do
        SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]'):format(i))
      end
    else
      return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]'):format(index))
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
MouseLeftPress = function(index)
  local success, err = pcall(function()
    if index < 1 then
      return 
    end
    if not (COMPONENTS.SLOTS) then
      return 
    end
    if not (COMPONENTS.SLOTS[index]:hasAction()) then
      return 
    end
    return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]'):format(index))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ButtonAction = function(index)
  local success, err = pcall(function()
    if index < 1 then
      return 
    end
    if not (COMPONENTS.SLOTS) then
      return 
    end
    if not (COMPONENTS.SLOTS[index]:hasAction()) then
      return 
    end
    SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
    if COMPONENTS.SLOTS[index]:action() then
      STATE.SCROLL_INDEX = 1
      updateScrollbar()
      return updateSlots()
    else
      return SKIN:Bang('[!DeactivateConfig]')
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
