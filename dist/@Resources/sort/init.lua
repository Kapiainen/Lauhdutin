RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
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
  NUM_SLOTS = 5
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
      assert(type(args.title) == 'string', 'sort.init.Property')
      self.title = args.title
      assert(type(args.value) == 'string', 'sort.init.Property')
      self.value = args.value
      assert((type(args.enum) == 'number' and args.enum % 1 == 0) or type(args.action) == 'function', 'sort.init.Property')
      self.enum = args.enum
      self.action = args.action
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
      if self.property.action ~= nil then
        self.property:action()
        return true
      end
      SKIN:Bang(('[!CommandMeasure "Script" "Sort(%d)" "#ROOTCONFIG#"]'):format(self.property.enum))
      return false
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, index)
      assert(type(index) == 'number' and index % 1 == 0, 'sort.init.Slot')
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
    log('Initializing Sort config')
    require('shared.enums')
    utility = require('shared.utility')
    utility.createJSONHelpers()
    COMPONENTS.SETTINGS = require('shared.settings')()
    STATE.LOGGING = COMPONENTS.SETTINGS:getLogging()
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
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
    SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s"]'):format(LOCALIZATION:get('sort_window_title', 'Sort')))
    SKIN:Bang('[!CommandMeasure "Script" "HandshakeSort()" "#ROOTCONFIG#"]')
    return COMPONENTS.STATUS:hide()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
local createProperties
createProperties = function(game, platform)
  local properties = { }
  table.insert(properties, Property({
    title = LOCALIZATION:get('sort_alphabetically', 'Alphabetically'),
    value = ' ',
    enum = ENUMS.SORTING_TYPES.ALPHABETICALLY
  }))
  table.insert(properties, Property({
    title = LOCALIZATION:get('sort_last_played', 'Most recently played'),
    value = ' ',
    enum = ENUMS.SORTING_TYPES.LAST_PLAYED
  }))
  table.insert(properties, Property({
    title = LOCALIZATION:get('button_label_hours_played', 'Hours played'),
    value = ' ',
    enum = ENUMS.SORTING_TYPES.HOURS_PLAYED
  }))
  table.sort(properties, function(a, b)
    if a.title:lower() < b.title:lower() then
      return true
    end
    return false
  end)
  table.insert(properties, Property({
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
Handshake = function(currentSortingType)
  local success, err = pcall(function()
    log('Accepting Sort handshake', currentSortingType)
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
