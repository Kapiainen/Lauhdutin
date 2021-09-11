RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
LOCALIZATION = nil
STATE = {
  PATHS = {
    GAMES = 'games.json'
  },
  GAME = nil,
  ALL_GAMES = nil,
  GAMES_VERSION = nil,
  CENTERED = false,
  ACTIVE_INPUT = false,
  PROGRESS = 1
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
    COMPONENTS.SETTINGS = require('shared.settings')()
    if COMPONENTS.SETTINGS:getLogging() == true then
      log = function(...)
        return print(...)
      end
    else
      log = function() end
    end
    log('Initializing NewGame config')
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    Game = require('main.game')
    local valueMeter = SKIN:GetMeter('Slot1Value')
    local maxValueStringLength = math.round(valueMeter:GetW() / valueMeter:GetOption('FontSize'))
    COMPONENTS.SLOT = Slot(1, maxValueStringLength)
    SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('newgame_window_title', 'New game')))
    SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_next', 'Next')))
    SKIN:Bang(('[!SetOption "CancelButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_cancel', 'Cancel')))
    SKIN:Bang('[!CommandMeasure "Script" "HandshakeNewGame()" "#ROOTCONFIG#"]')
    return COMPONENTS.STATUS:hide()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
local updateSlot
updateSlot = function()
  return COMPONENTS.SLOT:populate(STATE.PROPERTIES[STATE.PROGRESS])
end
local createProperties
createProperties = function()
  local properties = { }
  local titleValue
  titleValue = function()
    return STATE.ARGS.title or ''
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_title', 'Title'),
    value = titleValue(),
    update = titleValue,
    action = function(self)
      return StartEditingTitle()
    end
  }))
  local pathValue
  pathValue = function()
    return STATE.ARGS.path or ''
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_path', 'Path'),
    value = pathValue(),
    update = pathValue,
    action = function(self)
      return StartEditingPath()
    end
  }))
  local installedValue
  installedValue = function()
    if STATE.ARGS.uninstalled == false then
      return LOCALIZATION:get('button_label_yes', 'Yes')
    else
      return LOCALIZATION:get('button_label_no', 'No')
    end
  end
  table.insert(properties, Property({
    title = LOCALIZATION:get('game_installed', 'Installed'),
    value = installedValue(),
    update = installedValue,
    action = function(self)
      STATE.ARGS.uninstalled = not STATE.ARGS.uninstalled
      return updateSlot()
    end
  }))
  return properties
end
local centerConfig
centerConfig = function()
  if STATE.CENTERED == true then
    return 
  end
  STATE.CENTERED = true
  if not COMPONENTS.SETTINGS:getCenterOnMonitor() then
    return 
  end
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
  return SKIN:Bang(('[!Move "%d" "%d"]'):format(x, y))
end
Handshake = function(gameID)
  local success, err = pcall(function()
    log('Accepting NewGame handshake', gameID)
    local games = io.readJSON(STATE.PATHS.GAMES)
    STATE.TAGS_DICTIONARY = games.tagsDictionary
    STATE.GAMES_VERSION = games.version
    STATE.GAMES_UPDATED_TIMESTAMP = games.updated or os.date('*t')
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = games.games
      for _index_0 = 1, #_list_0 do
        local args = _list_0[_index_0]
        _accum_0[_len_0] = Game(args, STATE.TAGS_DICTIONARY)
        _len_0 = _len_0 + 1
      end
      STATE.ALL_GAMES = _accum_0
    end
    STATE.ARGS = {
      title = '',
      path = '',
      uninstalled = false,
      platformID = ENUMS.PLATFORM_IDS.CUSTOM,
      gameID = gameID
    }
    STATE.PROPERTIES = createProperties()
    updateSlot()
    centerConfig()
    return SKIN:Bang('[!ZPos 1][!Show]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
MouseOver = function()
  return SKIN:Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonHighlightedColor#"]')
end
MouseLeave = function()
  return SKIN:Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonBaseColor#"]')
end
MouseLeftPress = function()
  return SKIN:Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonPressedColor#"]')
end
ButtonAction = function()
  SKIN:Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonHighlightedColor#"]')
  COMPONENTS.SLOT:action()
  return updateSlot()
end
Save = function()
  local success, err = pcall(function()
    if STATE.ACTIVE_INPUT == true then
      return 
    end
    if STATE.PROGRESS < #STATE.PROPERTIES then
      local _exp_0 = STATE.PROGRESS
      if 1 == _exp_0 then
        if STATE.ARGS.title:trim() == '' then
          COMPONENTS.STATUS:show(LOCALIZATION:get('newgame_missing_title', 'A title has not been defined!#CRLF##CRLF#Click to close.'))
          return 
        end
        local _list_0 = STATE.ALL_GAMES
        for _index_0 = 1, #_list_0 do
          local g = _list_0[_index_0]
          if g:getTitle() == STATE.ARGS.title and g:getPlatformID() == STATE.ARGS.platformID then
            COMPONENTS.STATUS:show(LOCALIZATION:get('newgame_game_with_same_title_exists', 'A game with that title already exists!#CRLF##CRLF#Click to close.'))
            return 
          end
        end
      elseif 2 == _exp_0 then
        if STATE.ARGS.path:trim() == '' then
          COMPONENTS.STATUS:show(LOCALIZATION:get('newgame_missing_path', 'A path has not been defined!#CRLF##CRLF#Click to close.'))
          return 
        end
      end
      STATE.PROGRESS = STATE.PROGRESS + 1
      updateSlot()
      if STATE.PROGRESS == #STATE.PROPERTIES then
        return SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save')))
      end
    else
      STATE.ARGS.expectedBanner = STATE.ARGS.title
      STATE.ARGS.path = (STATE.ARGS.path:gsub('/', '\\'))
      if (STATE.ARGS.path:find('%s')) ~= nil then
        STATE.ARGS.path = ('"%s"'):format(STATE.ARGS.path)
      end
      local game = Game(STATE.ARGS)
      table.insert(STATE.ALL_GAMES, game)
      io.writeJSON(STATE.PATHS.GAMES, {
        version = STATE.GAMES_VERSION,
        tagsDictionary = STATE.TAGS_DICTIONARY,
        games = STATE.ALL_GAMES,
        updated = STATE.GAMES_UPDATED_TIMESTAMP
      })
      SKIN:Bang(('[!CommandMeasure "Script" "OnAddGame(%d)" "#ROOTCONFIG#"]'):format(game:getGameID()))
      return SKIN:Bang('[!DeactivateConfig]')
    end
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Cancel = function()
  local success, err = pcall(function()
    if STATE.ACTIVE_INPUT == true then
      return 
    end
    return SKIN:Bang('[!DeactivateConfig]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnDismissedInput = function()
  local success, err = pcall(function()
    STATE.ACTIVE_INPUT = false
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local startEditing
startEditing = function(slotIndex, batchIndex, defaultValue)
  local meter = SKIN:GetMeter(('Slot%dValue'):format(slotIndex))
  SKIN:Bang(('[!SetOption "Input" "X" "%d"]'):format(meter:GetX() - 1))
  SKIN:Bang(('[!SetOption "Input" "Y" "%d"]'):format(meter:GetY() - 1))
  SKIN:Bang(('[!SetOption "Input" "W" "%d"]'):format(meter:GetW()))
  SKIN:Bang(('[!SetOption "Input" "H" "%d"]'):format(20))
  if defaultValue == nil then
    defaultValue = ''
  end
  SKIN:Bang(('[!SetOption "Input" "DefaultValue" "%s"]'):format(defaultValue))
  SKIN:Bang(('[!CommandMeasure "Input" "ExecuteBatch %d"]'):format(batchIndex))
  STATE.ACTIVE_INPUT = true
end
StartEditingTitle = function()
  local success, err = pcall(function()
    return startEditing(1, 1, STATE.ARGS.title)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedTitle = function(title)
  local success, err = pcall(function()
    STATE.ARGS.title = title:sub(1, -2)
    updateSlot()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
StartEditingPath = function()
  local success, err = pcall(function()
    return startEditing(1, 2, STATE.ARGS.path)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnEditedPath = function(path)
  local success, err = pcall(function()
    STATE.ARGS.path = path:sub(1, -2)
    updateSlot()
    return OnDismissedInput()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
