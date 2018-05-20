RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
LOCALIZATION = nil
STATE = {
  PATHS = {
    GAMES = 'games.json',
    BANGS = 'cache\\bangs.txt',
    NOTES = 'cache\\notes.txt'
  },
  SCROLLBAR = {
    START = nil,
    MAX_HEIGHT = nil,
    HEIGHT = nil,
    STEP = nil
  },
  GAME = nil,
  ALL_GAMES = nil,
  GAMES_VERSION = nil,
  ALL_TAGS = nil,
  ALL_PLATFORMS = nil,
  HIGHLIGHTED_SLOT_INDEX = 0,
  CENTERED = false
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
      if self.property ~= nil then
        if self.property.update ~= nil then
          self.property.value = self.property:update()
        end
        SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]'):format(self.index, utility.replaceUnsupportedChars(self.property.title)))
        local value = utility.replaceUnsupportedChars(self.property.value)
        SKIN:Bang(('[!SetOption "Slot%dValue" "Text" "%s"]'):format(self.index, value))
        if value:len() > self.maxValueStringLength then
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipText" "%s"]'):format(self.index, value))
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "0"]'):format(self.index))
        else
          SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]'):format(self.index))
        end
        return 
      end
      SKIN:Bang(('[!SetOption "Slot%dTitle" "Text" " "]'):format(self.index))
      SKIN:Bang(('[!SetOption "Slot%dValue" "Text" " "]'):format(self.index))
      return SKIN:Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]'):format(self.index))
    end,
    hasAction = function(self)
      return self.property ~= nil and self.property.action ~= nil
    end,
    action = function(self)
      if self.property == nil or self.property.action == nil then
        return 
      end
      return self.property:action(self.index)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index, maxValueStringLength)
      self.index = index
      self.maxValueStringLength = maxValueStringLength
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
local additionalEnums
additionalEnums = function()
  ENUMS.TAG_STATES = {
    DISABLED = 1,
    ENABLED = 2,
    ENABLED_PLATFORM = 3,
    MAX = 4
  }
end
local getGamesAndTags
getGamesAndTags = function()
  local games = io.readJSON(STATE.PATHS.GAMES)
  STATE.GAMES_VERSION = games.version
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = games.games
    for _index_0 = 1, #_list_0 do
      local args = _list_0[_index_0]
      _accum_0[_len_0] = Game(args)
      _len_0 = _len_0 + 1
    end
    STATE.ALL_GAMES = _accum_0
  end
  if STATE.ALL_TAGS == nil then
    STATE.ALL_TAGS = { }
    local _list_0 = STATE.ALL_GAMES
    for _index_0 = 1, #_list_0 do
      local game = _list_0[_index_0]
      local _list_1 = game:getTags()
      for _index_1 = 1, #_list_1 do
        local tag = _list_1[_index_1]
        STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
      end
      local _list_2 = game:getPlatformTags()
      for _index_1 = 1, #_list_2 do
        local tag = _list_2[_index_1]
        STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
      end
    end
  end
end
Initialize = function()
  SKIN:Bang('[!Hide]')
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    log('Initializing Game config')
    require('shared.enums')
    additionalEnums()
    utility = require('shared.utility')
    utility.createJSONHelpers()
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    Game = require('main.game')
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = require('main.platforms')
      for _index_0 = 1, #_list_0 do
        local Platform = _list_0[_index_0]
        _accum_0[_len_0] = Platform(COMPONENTS.SETTINGS)
        _len_0 = _len_0 + 1
      end
      STATE.ALL_PLATFORMS = _accum_0
    end
    getGamesAndTags()
    STATE.NUM_SLOTS = 4
    STATE.SCROLL_INDEX = 1
    local valueMeter = SKIN:GetMeter('Slot1Value')
    local maxValueStringLength = math.round(valueMeter:GetW() / valueMeter:GetOption('FontSize'))
    do
      local _accum_0 = { }
      local _len_0 = 1
      for i = 1, STATE.NUM_SLOTS do
        _accum_0[_len_0] = Slot(i, maxValueStringLength)
        _len_0 = _len_0 + 1
      end
      COMPONENTS.SLOTS = _accum_0
    end
    local scrollbar = SKIN:GetMeter('Scrollbar')
    STATE.SCROLLBAR.START = scrollbar:GetY()
    STATE.SCROLLBAR.MAX_HEIGHT = scrollbar:GetH()
    STATE.SUPPORTED_BANNER_EXTENSIONS = table.concat(require('main.platforms.platform')(COMPONENTS.SETTINGS):getBannerExtensions(), '|'):gsub('%.', '')
    SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save')))
    SKIN:Bang(('[!SetOption "CancelButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_cancel', 'Cancel')))
    SKIN:Bang('[!CommandMeasure "Script" "HandshakeGame()" "#ROOTCONFIG#"]')
    return COMPONENTS.STATUS:hide()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
local updateTitle
updateTitle = function(game, maxStringLength)
  local title = utility.replaceUnsupportedChars(game:getTitle())
  SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(title))
  if title:len() > maxStringLength then
    SKIN:Bang(('[!SetOption "PageTitle" "ToolTipText" "%s"]'):format(title))
    return SKIN:Bang('[!SetOption "PageTitle" "ToolTipHidden" "0"]')
  else
    return SKIN:Bang('[!SetOption "PageTitle" "ToolTipHidden" "1"]')
  end
end
local updateBanner
updateBanner = function(game)
  local path = game:getBanner()
  if not (path) then
    SKIN:Bang('[!SetOption "Banner" "ImageName" "#@#game\\gfx\\blank.png"]')
    SKIN:Bang(('[!SetOption "BannerMissing" "Text" "%s"]'):format(LOCALIZATION:get('game_no_banner', 'No banner')))
    local expectedBanner = game:getExpectedBanner()
    if expectedBanner then
      local tooltip
      local _exp_0 = game:getPlatformID()
      if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
        local platformOverride = game:getPlatformOverride()
        if platformOverride ~= nil then
          tooltip = ('\\@Resources\\Shortcuts\\%s\\%s.%s'):format(platformOverride, expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
        else
          tooltip = ('\\@Resources\\Shortcuts\\%s.%s'):format(expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
        end
      elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
        if game:getPlatformOverride() then
          tooltip = ('\\@Resources\\cache\\steam_shortcuts\\%s.%s'):format(expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
        else
          tooltip = ('\\@Resources\\cache\\steam\\%s.%s'):format(expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
        end
      elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
        tooltip = ('\\@Resources\\cache\\battlenet\\%s.%s'):format(expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
      elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
        tooltip = ('\\@Resources\\cache\\gog_galaxy\\%s.%s'):format(expectedBanner, STATE.SUPPORTED_BANNER_EXTENSIONS)
      end
      SKIN:Bang(('[!SetOption "BannerMissing" "ToolTipText" "%s"]'):format(tooltip))
      SKIN:Bang('[!SetOption "BannerMissing" "ToolTipHidden" "0"]')
      return 
    end
  end
  SKIN:Bang(('[!SetOption "Banner" "ImageName" "#@#%s"]'):format(path))
  SKIN:Bang('[!SetOption "BannerMissing" "Text" ""]')
  return SKIN:Bang('[!SetOption "BannerMissing" "ToolTipHidden" "1"]')
end
local updateScrollbar
updateScrollbar = function()
  STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
  STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1))
  STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / (#STATE.PROPERTIES - STATE.NUM_SLOTS)
  SKIN:Bang(('[!SetOption "Scrollbar" "H" "%d"]'):format(STATE.SCROLLBAR.HEIGHT))
  local y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
  return SKIN:Bang(('[!SetOption "Scrollbar" "Y" "%d"]'):format(math.round(y)))
end
local updateSlots
updateSlots = function()
  for i, slot in ipairs(COMPONENTS.SLOTS) do
    slot:populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
    if i == STATE.HIGHLIGHTED_SLOT_INDEX then
      if slot:hasAction() then
        MouseOver(i)
      else
        MouseLeave(i)
      end
    end
  end
end
local sortPropertiesByTitle
sortPropertiesByTitle = function(a, b)
  if a.title:lower() < b.title:lower() then
    return true
  end
  return false
end
local createTagProperty
createTagProperty = function(tag, state)
  local f
  f = function()
    local _exp_0 = STATE.GAME_TAGS[tag]
    if ENUMS.TAG_STATES.DISABLED == _exp_0 then
      return LOCALIZATION:get('button_label_disabled', 'Disabled')
    elseif ENUMS.TAG_STATES.ENABLED == _exp_0 then
      return LOCALIZATION:get('button_label_enabled', 'Enabled')
    elseif ENUMS.TAG_STATES.ENABLED_PLATFORM == _exp_0 then
      return LOCALIZATION:get('button_label_enabled', 'Enabled') .. '*'
    end
  end
  if state == ENUMS.TAG_STATES.ENABLED_PLATFORM then
    return Property({
      title = tag,
      value = f(),
      update = f
    })
  else
    return Property({
      title = tag,
      value = f(),
      action = function(self, index)
        local _exp_0 = STATE.GAME_TAGS[tag]
        if ENUMS.TAG_STATES.DISABLED == _exp_0 then
          STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
        elseif ENUMS.TAG_STATES.ENABLED == _exp_0 then
          STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
        else
          STATE.GAME_TAGS[tag] = STATE.GAME_TAGS[tag]
        end
      end,
      update = f
    })
  end
end
local createTagProperties
createTagProperties = function()
  local properties = { }
  for tag, state in pairs(STATE.GAME_TAGS) do
    table.insert(properties, createTagProperty(tag, state))
  end
  table.sort(properties, sortPropertiesByTitle)
  table.insert(properties, 1, Property({
    title = LOCALIZATION:get('game_tag_create', 'Create a new tag'),
    value = '',
    action = function(self, index)
      return StartCreatingTag(index)
    end
  }))
  return properties
end
local createProperties
createProperties = function(game, platform)
  local properties = { }
  local platformOverride = game:getPlatformOverride()
  local platformName
  if platformOverride ~= nil then
    platformName = platformOverride .. '*'
  else
    platformName = platform:getName()
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_platform', 'Platform'),
    value = platformName
  }))
  table.insert(properties, Property({
    title = LOCALIZATION:get('button_label_hours_played', 'Hours played'),
    value = ('%.0f'):format(game:getHoursPlayed())
  }))
  local f
  f = function(self)
    local lastPlayed = game:getLastPlayed()
    if lastPlayed > 315532800 then
      local date = os.date('*t', lastPlayed)
      return ('%04.f-%02.f-%02.f %02.f:%02.f:%02.f'):format(date.year, date.month, date.day, date.hour, date.min, date.sec)
    end
    return LOCALIZATION:get('game_last_played_never', 'Never')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_last_played', 'Last played'),
    value = f()
  }))
  f = function(self)
    if game:isInstalled() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_installed', 'Installed'),
    value = f()
  }))
  f = function(self)
    if game:isVisible() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_visible', 'Visible'),
    value = f(),
    action = function(self, index)
      return STATE.GAME:toggleVisibility()
    end,
    update = f
  }))
  local path = game:getPath()
  local action = nil
  if path:startsWith('"') and path:endsWith('"') then
    path = path:sub(2, -2)
  end
  if io.fileExists(path, false) then
    local head, tail = io.splitPath(path)
    if head ~= nil then
      action = function(self, index)
        return SKIN:Bang(('["%s"]'):format(head))
      end
    end
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_path', 'Path'),
    value = ('""%s""'):format(game:getPath()),
    action = action
  }))
  action = nil
  path = nil
  f = function(self)
    local processOverride = game:getProcessOverride()
    if processOverride ~= nil and processOverride ~= '' then
      return processOverride .. '*'
    end
    local process = game:getProcess(true)
    if process ~= nil and process ~= '' then
      return process
    end
    return LOCALIZATION:get('game_process_none', 'None')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_process', 'Process'),
    value = f(),
    action = function(self, index)
      return StartEditingProcessOverride(index)
    end,
    update = f
  }))
  f = function(self)
    local notes = game:getNotes()
    if notes ~= nil and notes:len() > 0 then
      local lines = notes:splitIntoLines()
      local line = lines[1]
      if #lines > 1 then
        line = line .. '...'
      end
      return line
    end
    return LOCALIZATION:get('game_notes_none', 'None')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_notes', 'Notes'),
    value = f(),
    action = function(self, index)
      return StartEditingNotes()
    end,
    update = f
  }))
  f = function(self)
    local tags = { }
    local _list_0 = game:getTags()
    for _index_0 = 1, #_list_0 do
      local tag = _list_0[_index_0]
      tags[tag] = false
    end
    local _list_1 = game:getPlatformTags()
    for _index_0 = 1, #_list_1 do
      local tag = _list_1[_index_0]
      tags[tag] = true
    end
    if tags then
      do
        local _accum_0 = { }
        local _len_0 = 1
        for tag, fromPlatform in pairs(tags) do
          _accum_0[_len_0] = {
            tag = tag,
            fromPlatform = fromPlatform
          }
          _len_0 = _len_0 + 1
        end
        tags = _accum_0
      end
      table.sort(tags, function(a, b)
        return a.tag < b.tag
      end)
      local str = ''
      for _index_0 = 1, #tags do
        local entry = tags[_index_0]
        if entry.fromPlatform then
          str = str .. (' | %s*'):format(entry.tag)
        else
          str = str .. (' | %s'):format(entry.tag)
        end
      end
      str = str:sub(4)
      if str ~= '' then
        return str
      end
    end
    return LOCALIZATION:get('game_tags_none', 'None')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_tags', 'Tags'),
    value = f(),
    action = function(self, index)
      do
        local _tbl_0 = { }
        for tag, state in pairs(STATE.ALL_TAGS) do
          _tbl_0[tag] = state
        end
        STATE.GAME_TAGS = _tbl_0
      end
      local _list_0 = game:getTags()
      for _index_0 = 1, #_list_0 do
        local tag = _list_0[_index_0]
        STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
      end
      local _list_1 = game:getPlatformTags()
      for _index_0 = 1, #_list_1 do
        local tag = _list_1[_index_0]
        STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED_PLATFORM
      end
      SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_accept', 'Accept')))
      STATE.TAG_PROPERTIES = createTagProperties()
      STATE.PROPERTIES = STATE.TAG_PROPERTIES
      STATE.PREVIOUS_SCROLL_INDEX = STATE.SCROLL_INDEX
      STATE.SCROLL_INDEX = 1
      updateScrollbar()
      return updateSlots()
    end,
    update = f
  }))
  f = function(self)
    if game:getIgnoresOtherBangs() then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    end
    return LOCALIZATION:get('button_label_no', 'No')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_ignores_other_bangs', 'Ignores other bangs'),
    value = f(),
    action = function(self, index)
      return STATE.GAME:toggleIgnoresOtherBangs()
    end,
    update = f
  }))
  f = function(self)
    local bangs = game:getStartingBangs()
    if bangs and #bangs > 0 then
      bangs = table.concat(bangs, ' | ')
      if bangs ~= '' then
        return (bangs:gsub('\"', '\'\''))
      end
    end
    return LOCALIZATION:get('button_label_bangs_none', 'None')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('button_label_starting_bangs', 'Starting bangs'),
    value = f(),
    action = function(self, index)
      return StartEditingStartingBangs()
    end,
    update = f
  }))
  f = function(self)
    local bangs = game:getStoppingBangs()
    if bangs and #bangs > 0 then
      bangs = table.concat(bangs, ' | ')
      if bangs ~= '' then
        return (bangs:gsub('\"', '\'\''))
      end
    end
    return LOCALIZATION:get('button_label_bangs_none', 'None')
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('button_label_stopping_bangs', 'Stopping bangs'),
    value = f(),
    action = function(self, index)
      return StartEditingStoppingBangs()
    end,
    update = f
  }))
  return properties
end
Handshake = function(gameID)
  local success, err = pcall(function()
    log('Accepting Game handshake', gameID)
    getGamesAndTags()
    local game = STATE.ALL_GAMES[gameID]
    if game == nil or game.gameID ~= gameID then
      game = nil
      local _list_0 = STATE.ALL_GAMES
      for _index_0 = 1, #_list_0 do
        local candidate = _list_0[_index_0]
        if candidate:getGameID() == gameID then
          game = candidate
          break
        end
      end
    end
    assert(game ~= nil, ('Could not find a game with the gameID: %d'):format(gameID))
    STATE.GAME = game
    local valueMeter = SKIN:GetMeter('PageTitle')
    local maxStringLength = math.round(valueMeter:GetW() / valueMeter:GetOption('FontSize'))
    updateTitle(game, maxStringLength)
    updateBanner(game)
    local platform = nil
    local _list_0 = STATE.ALL_PLATFORMS
    for _index_0 = 1, #_list_0 do
      local p = _list_0[_index_0]
      if p:getPlatformID() == game:getPlatformID() then
        platform = p
        break
      end
    end
    assert(platform ~= nil, 'Could not find the game\'s platform.')
    STATE.DEFAULT_PROPERTIES = createProperties(game, platform)
    STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
    updateScrollbar()
    updateSlots()
    if STATE.CENTERED == false then
      STATE.CENTERED = true
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
    end
    return SKIN:Bang('[!Show]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Scroll = function(direction)
  if not (COMPONENTS.SLOTS ~= nil) then
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
  if not (COMPONENTS.SLOTS ~= nil) then
    return 
  end
  STATE.HIGHLIGHTED_SLOT_INDEX = index
  if not (COMPONENTS.SLOTS[index] ~= nil and COMPONENTS.SLOTS[index]:hasAction()) then
    return 
  end
  return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
end
MouseLeave = function(index)
  if not (COMPONENTS.SLOTS ~= nil) then
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
  if not (COMPONENTS.SLOTS ~= nil and COMPONENTS.SLOTS[index] ~= nil and COMPONENTS.SLOTS[index]:hasAction()) then
    return 
  end
  return SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]'):format(index))
end
ButtonAction = function(index)
  if not (COMPONENTS.SLOTS ~= nil and COMPONENTS.SLOTS[index] ~= nil and COMPONENTS.SLOTS[index]:hasAction()) then
    return 
  end
  SKIN:Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]'):format(index))
  COMPONENTS.SLOTS[index]:action()
  return updateSlots()
end
local showDefaultProperties
showDefaultProperties = function()
  SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save')))
  SKIN:Bang(('[!SetOption "CancelButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_cancel', 'Cancel')))
  STATE.PROPERTIES = STATE.DEFAULT_PROPERTIES
  STATE.SCROLL_INDEX = STATE.PREVIOUS_SCROLL_INDEX
  STATE.PREVIOUS_SCROLL_INDEX = 1
  updateScrollbar()
  return updateSlots()
end
Save = function()
  local success, err = pcall(function()
    local _exp_0 = STATE.PROPERTIES
    if STATE.DEFAULT_PROPERTIES == _exp_0 then
      io.writeJSON(STATE.PATHS.GAMES, {
        version = STATE.GAMES_VERSION,
        games = STATE.ALL_GAMES
      })
      local gameID = STATE.GAME:getGameID()
      return SKIN:Bang(('[!CommandMeasure "Script" "UpdateGame(%d)" "#ROOTCONFIG#"][!DeactivateConfig]'):format(gameID))
    elseif STATE.TAG_PROPERTIES == _exp_0 then
      STATE.GAME:setTags((function()
        local _accum_0 = { }
        local _len_0 = 1
        for tag, state in pairs(STATE.GAME_TAGS) do
          if state == ENUMS.TAG_STATES.ENABLED then
            _accum_0[_len_0] = tag
            _len_0 = _len_0 + 1
          end
        end
        return _accum_0
      end)())
      return showDefaultProperties()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Cancel = function()
  local success, err = pcall(function()
    local _exp_0 = STATE.PROPERTIES
    if STATE.DEFAULT_PROPERTIES == _exp_0 then
      return SKIN:Bang('[!CommandMeasure "Script" "UpdateGame()" "#ROOTCONFIG#"][!DeactivateConfig]')
    elseif STATE.TAG_PROPERTIES == _exp_0 then
      return showDefaultProperties()
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OpenBanner = function()
  local success, err = pcall(function()
    local path = SKIN:GetMeter('Banner'):GetOption('ImageName')
    if path ~= nil and path ~= '' and path:match('@Resources\\game\\gfx\\') == nil then
      return SKIN:Bang(('"%s"'):format(path))
    else
      local game = STATE.GAME
      local _exp_0 = game:getPlatformID()
      if ENUMS.PLATFORM_IDS.SHORTCUTS == _exp_0 then
        local platformOverride = game:getPlatformOverride()
        if platformOverride ~= nil then
          path = ('Shortcuts\\%s\\'):format(platformOverride)
        else
          path = 'Shortcuts\\'
        end
      elseif ENUMS.PLATFORM_IDS.STEAM == _exp_0 then
        if game:getPlatformOverride() then
          path = 'cache\\steam_shortcuts\\'
        else
          path = 'cache\\steam\\'
        end
      elseif ENUMS.PLATFORM_IDS.BATTLENET == _exp_0 then
        path = 'cache\\battlenet\\'
      elseif ENUMS.PLATFORM_IDS.GOG_GALAXY == _exp_0 then
        path = 'cache\\gog_galaxy\\'
      end
      return SKIN:Bang(('"#@#%s"'):format(path))
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingProcessOverride = function(index)
  local success, err = pcall(function()
    local meter = SKIN:GetMeter(('Slot%dValue'):format(index))
    SKIN:Bang(('[!SetOption "Input" "X" "%d"]'):format(meter:GetX() - 1))
    SKIN:Bang(('[!SetOption "Input" "Y" "%d"]'):format(meter:GetY() - 1))
    SKIN:Bang(('[!SetOption "Input" "W" "%d"]'):format(meter:GetW()))
    SKIN:Bang(('[!SetOption "Input" "H" "%d"]'):format(20))
    return SKIN:Bang('[!CommandMeasure "Input" "ExecuteBatch 1"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedProcessOverride = function(process)
  local success, err = pcall(function()
    STATE.GAME:setProcessOverride(process:sub(1, -2))
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartCreatingTag = function(index)
  local success, err = pcall(function()
    local meter = SKIN:GetMeter(('Slot%dValue'):format(index))
    SKIN:Bang(('[!SetOption "Input" "X" "%d"]'):format(meter:GetX() - 1))
    SKIN:Bang(('[!SetOption "Input" "Y" "%d"]'):format(meter:GetY() - 1))
    SKIN:Bang(('[!SetOption "Input" "W" "%d"]'):format(meter:GetW()))
    SKIN:Bang(('[!SetOption "Input" "H" "%d"]'):format(20))
    return SKIN:Bang('[!CommandMeasure "Input" "ExecuteBatch 2"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnCreatedTag = function(tag)
  local success, err = pcall(function()
    tag = tag:sub(1, -2)
    if STATE.ALL_TAGS[tag] ~= nil then
      return 
    end
    STATE.ALL_TAGS[tag] = ENUMS.TAG_STATES.DISABLED
    STATE.GAME_TAGS[tag] = ENUMS.TAG_STATES.ENABLED
    local createProperty = table.remove(STATE.TAG_PROPERTIES, 1)
    table.insert(STATE.TAG_PROPERTIES, createTagProperty(tag, STATE.GAME_TAGS[tag]))
    table.sort(STATE.TAG_PROPERTIES, sortPropertiesByTitle)
    table.insert(STATE.TAG_PROPERTIES, 1, createProperty)
    updateScrollbar()
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingStartingBangs = function()
  local success, err = pcall(function()
    local bangs = STATE.GAME:getStartingBangs()
    io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
    return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, STATE.PATHS.BANGS)), '', 'OnEditedStartingBangs')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedStartingBangs = function()
  local success, err = pcall(function()
    local bangs = io.readFile(STATE.PATHS.BANGS)
    STATE.GAME:setStartingBangs(bangs:splitIntoLines())
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingStoppingBangs = function()
  local success, err = pcall(function()
    local bangs = STATE.GAME:getStoppingBangs()
    io.writeFile(STATE.PATHS.BANGS, table.concat(bangs, '\n'))
    return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, STATE.PATHS.BANGS)), '', 'OnEditedStoppingBangs')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedStoppingBangs = function()
  local success, err = pcall(function()
    local bangs = io.readFile(STATE.PATHS.BANGS)
    STATE.GAME:setStoppingBangs(bangs:splitIntoLines())
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ToggleIgnoresOtherBangs = function()
  local success, err = pcall(function()
    STATE.GAME:toggleIgnoresOtherBangs()
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingNotes = function()
  local success, err = pcall(function()
    local notes = STATE.GAME:getNotes()
    if notes == nil then
      notes = ''
    end
    io.writeFile(STATE.PATHS.NOTES, notes)
    return utility.runCommand(('""%s""'):format(io.joinPaths(STATE.PATHS.RESOURCES, STATE.PATHS.NOTES)), '', 'OnEditedNotes')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedNotes = function()
  local success, err = pcall(function()
    local notes = io.readFile(STATE.PATHS.NOTES)
    STATE.GAME:setNotes(notes)
    return updateSlots()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
