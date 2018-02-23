local utility = nil
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
  ARGUMENTS = { }
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
        local _list_0 = self.property.arguments
        for _index_0 = 1, #_list_0 do
          local arg = _list_0[_index_0]
          STATE.ARGUMENTS[arg[1]] = arg[2]
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
      local argument = ''
      for key, value in pairs(STATE.ARGUMENTS) do
        argument = argument .. ('|%s:%s'):format(key, tostring(value))
      end
      SKIN:Bang(('[!CommandMeasure "Script" "Filter(%d, %s, \'%s\')" "#ROOTCONFIG#"]'):format(STATE.FILTER_TYPE, tostring(STATE.STACK), argument))
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
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
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
local createProperties
createProperties = function()
  local properties = { }
  local backButtonTitle = LOCALIZATION:get('filter_back_button_title', 'Back')
  local numGamesPattern = LOCALIZATION:get('game_number_of_games', '%d games')
  local games = io.readJSON('games.json')
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
  local platformProperties = { }
  for _index_0 = 1, #platforms do
    local platform = platforms[_index_0]
    local numGames = 0
    local platformID = platform:getPlatformID()
    for _index_1 = 1, #games do
      local game = games[_index_1]
      if game:getPlatformID() == platformID and game:getPlatformOverride() == nil then
        numGames = numGames + 1
      end
    end
    numGames = numGamesPattern:format(numGames)
    table.insert(platformProperties, Property({
      title = platform:getName(),
      value = numGames,
      arguments = {
        {
          'platformID',
          platformID
        }
      }
    }))
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
    local numGames = numGamesPattern:format(params.numGames)
    table.insert(platformProperties, Property({
      title = platformOverride .. '*',
      value = numGames,
      arguments = {
        {
          'platformID',
          params.platformID
        },
        {
          'platformOverride',
          platformOverride
        }
      }
    }))
  end
  table.sort(platformProperties, sortPropertiesByTitle)
  table.insert(platformProperties, 1, Property({
    title = backButtonTitle,
    value = ' ',
    properties = properties
  }))
  local numGames = numGamesPattern:format(#games)
  table.insert(properties, Property({
    title = LOCALIZATION:get('filter_from_platform', 'Is on platform'),
    value = numGames,
    enum = ENUMS.FILTER_TYPES.PLATFORM,
    properties = platformProperties
  }))
  local tags = { }
  local gamesWithTags = 0
  local hiddenGames = 0
  local uninstalledGames = 0
  for _index_0 = 1, #games do
    local game = games[_index_0]
    if not (game:isVisible()) then
      hiddenGames = hiddenGames + 1
    end
    if not (game:isInstalled()) then
      uninstalledGames = uninstalledGames + 1
    end
    local skinTags = game:getTags()
    local platformTags = game:getPlatformTags()
    if #skinTags > 0 or #platformTags > 0 then
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
      if tags[tag] == nil then
        tags[tag] = 0
      end
      tags[tag] = tags[tag] + 1
    end
  end
  local tagProperties = { }
  for tag, numGames in pairs(tags) do
    numGames = numGamesPattern:format(numGames)
    table.insert(tagProperties, Property({
      title = tag,
      value = numGames,
      arguments = {
        {
          'tag',
          tag
        }
      }
    }))
  end
  table.sort(tagProperties, sortPropertiesByTitle)
  table.insert(tagProperties, 1, Property({
    title = backButtonTitle,
    value = ' ',
    properties = properties
  }))
  numGames = numGamesPattern:format(gamesWithTags)
  table.insert(properties, Property({
    title = LOCALIZATION:get('filter_has_tag', 'Has tag'),
    value = numGames,
    enum = ENUMS.FILTER_TYPES.TAG,
    properties = tagProperties
  }))
  numGames = numGamesPattern:format(hiddenGames)
  table.insert(properties, Property({
    title = LOCALIZATION:get('filter_is_hidden', 'Is hidden'),
    value = numGames,
    enum = ENUMS.FILTER_TYPES.HIDDEN
  }))
  numGames = numGamesPattern:format(uninstalledGames)
  table.insert(properties, Property({
    title = LOCALIZATION:get('filter_is_uninstalled', 'Is not installed'),
    value = numGames,
    enum = ENUMS.FILTER_TYPES.UNINSTALLED
  }))
  table.sort(properties, sortPropertiesByTitle)
  table.insert(properties, 1, Property({
    title = LOCALIZATION:get('filter_clear_filters', 'Clear filters'),
    value = ' ',
    enum = ENUMS.FILTER_TYPES.NONE
  }))
  table.insert(properties, 1, Property({
    title = LOCALIZATION:get('button_label_cancel', 'Cancel'),
    value = ' ',
    action = function(self)
      return SKIN:Bang('[!DeactivateConfig]')
    end
  }))
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
Handshake = function(stack)
  local success, err = pcall(function()
    if stack then
      SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('filter_window_current_title', 'Filter (current games)')))
    end
    log('Accepting Filter handshake', stack)
    STATE.STACK = stack
    STATE.PROPERTIES = createProperties()
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
end
MouseOver = function(index)
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
end
MouseLeave = function(index)
  if index < 1 then
    return 
  end
  if not (COMPONENTS.SLOTS) then
    return 
  end
  if not (COMPONENTS.SLOTS[index]:hasAction()) then
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
end
MouseLeftPress = function(index)
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
end
ButtonAction = function(index)
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
end
