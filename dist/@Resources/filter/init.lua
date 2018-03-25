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
      local stack = tostring(STATE.STACK)
      local arguments = json.encode(STATE.ARGUMENTS):gsub('"', '|')
      SKIN:Bang(('[!CommandMeasure "Script" "Filter(%d, %s, \'%s\')" "#ROOTCONFIG#"]'):format(filter, stack, arguments))
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
log = function(...)
  if STATE.LOGGING == true then
    return print(...)
  end
end
Initialize = function()
  SKIN:Bang('[!Hide]')
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    log('Initializing Filter config')
    require('shared.enums')
    utility = require('shared.utility')
    utility.createJSONHelpers()
    json = require('lib.json')
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
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
    SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('filter_window_all_title', 'Filter')))
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
  if a.title:lower() < b.title:lower() then
    return true
  end
  return false
end
local createPlatformProperties
createPlatformProperties = function(games, platforms)
  local platformProperties = { }
  for _index_0 = 1, #platforms do
    local platform = platforms[_index_0]
    local platformGames = 0
    local platformID = platform:getPlatformID()
    for _index_1 = 1, #games do
      local game = games[_index_1]
      if game:getPlatformID() == platformID and game:getPlatformOverride() == nil then
        platformGames = platformGames + 1
      end
    end
    if platformGames > 0 then
      table.insert(platformProperties, Property({
        title = platform:getName(),
        value = STATE.NUM_GAMES_PATTERN:format(platformGames),
        arguments = {
          platformID = platformID
        }
      }))
    end
  end
  local platformOverrides = { }
  for _index_0 = 1, #games do
    local game = games[_index_0]
    local platformOverride = game:getPlatformOverride()
    if platformOverride ~= nil then
      if platformOverrides[platformOverride] == nil then
        platformOverrides[platformOverride] = {
          platformID = game:getPlatformID(),
          numGames = 1
        }
      else
        platformOverrides[platformOverride].numGames = platformOverrides[platformOverride].numGames + 1
      end
    end
  end
  for platformOverride, params in pairs(platformOverrides) do
    if params.numGames > 0 then
      table.insert(platformProperties, Property({
        title = platformOverride .. '*',
        value = STATE.NUM_GAMES_PATTERN:format(params.numGames),
        arguments = {
          platformID = params.platformID,
          platformOverride = platformOverride
        }
      }))
    end
  end
  table.sort(platformProperties, sortPropertiesByTitle)
  return Property({
    title = LOCALIZATION:get('filter_from_platform', 'Is on platform'),
    value = STATE.NUM_GAMES_PATTERN:format(#games),
    enum = ENUMS.FILTER_TYPES.PLATFORM,
    properties = platformProperties
  })
end
local createTagProperties
createTagProperties = function(games, filterStack)
  local tags = { }
  local gamesWithTags = 0
  for _index_0 = 1, #games do
    local game = games[_index_0]
    local skinTags = game:getTags()
    local platformTags = game:getPlatformTags()
    if (#skinTags > 0 or #platformTags > 0) then
      gamesWithTags = gamesWithTags + 1
    end
    local combinedTags = { }
    for _index_1 = 1, #skinTags do
      local tag = skinTags[_index_1]
      combinedTags[tag] = true
    end
    for _index_1 = 1, #platformTags do
      local tag = platformTags[_index_1]
      combinedTags[tag] = true
    end
    for tag, _ in pairs(combinedTags) do
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
        if tags[tag] == nil then
          tags[tag] = 0
        end
        tags[tag] = tags[tag] + 1
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  if gamesWithTags < 1 then
    return nil, gamesWithTags
  end
  local tagProperties = { }
  for tag, numGames in pairs(tags) do
    if numGames > 0 then
      table.insert(tagProperties, Property({
        title = tag,
        value = STATE.NUM_GAMES_PATTERN:format(numGames),
        arguments = {
          tag = tag
        }
      }))
    end
  end
  if #tagProperties < 1 then
    return nil, gamesWithTags
  end
  table.sort(tagProperties, sortPropertiesByTitle)
  return Property({
    title = LOCALIZATION:get('filter_has_tag', 'Has tag'),
    value = STATE.NUM_GAMES_PATTERN:format(gamesWithTags),
    enum = ENUMS.FILTER_TYPES.TAG,
    properties = tagProperties
  }), gamesWithTags
end
local createHasNoTagsProperty
createHasNoTagsProperty = function(numGames)
  return Property({
    title = LOCALIZATION:get('filter_has_no_tags', 'Has no tags'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.NO_TAGS,
    arguments = {
      state = true
    }
  })
end
local createHiddenProperty
createHiddenProperty = function(numGames)
  return Property({
    title = LOCALIZATION:get('filter_is_hidden', 'Is hidden'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.HIDDEN,
    arguments = {
      state = true
    }
  })
end
local createRandomProperty
createRandomProperty = function(numGames)
  return Property({
    title = LOCALIZATION:get('filter_random', 'Random game'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.RANDOM_GAME,
    arguments = {
      state = true
    }
  })
end
local createNeverPlayedProperty
createNeverPlayedProperty = function(games)
  local numGames = 0
  for _index_0 = 1, #games do
    local game = games[_index_0]
    if game:getHoursPlayed() == 0 then
      numGames = numGames + 1
    end
  end
  if numGames < 1 then
    return nil
  end
  return Property({
    title = LOCALIZATION:get('filter_never_played', 'Has never been played'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.NEVER_PLAYED,
    arguments = {
      state = true
    }
  })
end
local createHasNotesProperty
createHasNotesProperty = function(games)
  local numGames = 0
  for _index_0 = 1, #games do
    local game = games[_index_0]
    if game:getNotes() ~= nil then
      numGames = numGames + 1
    end
  end
  if numGames < 1 then
    return nil
  end
  return Property({
    title = LOCALIZATION:get('filter_has_notes', 'Has notes'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.HAS_NOTES,
    arguments = {
      state = true
    }
  })
end
local createUninstalledProperty
createUninstalledProperty = function(numGames)
  return Property({
    title = LOCALIZATION:get('filter_is_uninstalled', 'Is not installed'),
    value = STATE.NUM_GAMES_PATTERN:format(numGames),
    enum = ENUMS.FILTER_TYPES.UNINSTALLED,
    arguments = {
      state = true
    }
  })
end
local createClearProperty
createClearProperty = function()
  return Property({
    title = LOCALIZATION:get('filter_clear_filters', 'Clear filters'),
    value = ' ',
    enum = ENUMS.FILTER_TYPES.NONE
  })
end
local createCancelProperty
createCancelProperty = function()
  return Property({
    title = LOCALIZATION:get('button_label_cancel', 'Cancel'),
    value = ' ',
    action = function(self)
      return SKIN:Bang('[!DeactivateConfig]')
    end
  })
end
local createProperties
createProperties = function(games, hiddenGames, uninstalledGames, platforms, stack, filterStack)
  local properties = { }
  if #hiddenGames > 0 then
    table.insert(properties, createHiddenProperty(#hiddenGames))
  end
  if #uninstalledGames > 0 then
    table.insert(properties, createUninstalledProperty(#uninstalledGames))
  end
  if #games > 0 then
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
        skipRandom = true
      elseif ENUMS.FILTER_TYPES.NEVER_PLAYED == _exp_0 then
        skipNeverPlayed = true
      elseif ENUMS.FILTER_TYPES.HAS_NOTES == _exp_0 then
        skipHasNotes = true
      end
    end
    if not (skipPlatforms) then
      local platformsProperty = createPlatformProperties(games, platforms)
      if platformsProperty then
        table.insert(platformsProperty.properties, Property({
          title = STATE.BACK_BUTTON_TITLE,
          value = ' ',
          properties = properties
        }))
        table.insert(properties, platformsProperty)
      end
    end
    local gamesWithTags = 0
    if not (skipTags) then
      local tagsProperty
      tagsProperty, gamesWithTags = createTagProperties(games, filterStack)
      if tagsProperty then
        table.insert(tagsProperty.properties, Property({
          title = STATE.BACK_BUTTON_TITLE,
          value = ' ',
          properties = properties
        }))
        table.insert(properties, tagsProperty)
      end
    end
    if not (skipNoTags) then
      local numGamesWithoutTags = #games - gamesWithTags
      if numGamesWithoutTags > 0 then
        table.insert(properties, createHasNoTagsProperty(numGamesWithoutTags))
      end
    end
    if not skipRandom and #games > 1 then
      table.insert(properties, createRandomProperty(#games))
    end
    if not (skipNeverPlayed) then
      local neverPlayedProperty = createNeverPlayedProperty(games)
      if neverPlayedProperty then
        table.insert(properties, neverPlayedProperty)
      end
    end
    if not (skipHasNotes) then
      local hasNotesProperty = createHasNotesProperty(games)
      if hasNotesProperty then
        table.insert(properties, hasNotesProperty)
      end
    end
  end
  table.sort(properties, sortPropertiesByTitle)
  if not (stack) then
    table.insert(properties, createClearProperty())
  end
  table.insert(properties, createCancelProperty())
  return properties
end
local updateScrollbar
updateScrollbar = function()
  STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
  if #STATE.PROPERTIES > STATE.NUM_SLOTS then
    STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1))
    STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / (#STATE.PROPERTIES - STATE.NUM_SLOTS)
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
          _accum_0[_len_0] = Game(args)
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
    STATE.PROPERTIES = createProperties(games, hiddenGames, uninstalledGames, platforms, stack, filterStack)
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
    return SKIN:Bang('[!Show]')
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
