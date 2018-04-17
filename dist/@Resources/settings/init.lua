RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
LOCALIZATION = nil
STATE = {
  INITIALIZED = false,
  PATHS = {
    RESOURCES = nil,
    RAINMETER = nil
  },
  CURRENT_CONFIG = nil,
  NUM_SLOTS = 4,
  PAGE_INDEX = 1,
  SCROLL_INDEX = 1,
  MAX_SCROLL_INDEX = 1
}
COMPONENTS = {
  SETTINGS = nil,
  SLOTS = nil,
  PAGES = nil
}
log = function(...)
  if STATE.LOGGING == true then
    return print(...)
  end
end
RebuildSettingsSlots = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local build = require('settings.build_settings_skin')
    io.writeFile('settings\\slots\\init.inc', build())
    return SKIN:Bang('[!Refresh]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
RebuildMainSlots = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local build = require('settings.build_main_skin')
    return io.writeFile('main\\slots\\init.inc', build(COMPONENTS.SETTINGS))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local updateTitle
updateTitle = function(title)
  assert(type(title) == 'string', 'settings.init.updateTitle')
  assert(title ~= '', 'settings.init.updateTitle')
  return SKIN:Bang(('[!SetOption "PageTitle" "Text" "%s (%d/%d)"]'):format(title, STATE.PAGE_INDEX, COMPONENTS.PAGES:getCount()))
end
local additionalEnums
additionalEnums = function()
  ENUMS.SETTING_TYPES = {
    ACTION = 1,
    BOOLEAN = 2,
    FOLDER_PATH = 3,
    SPINNER = 4,
    INTEGER = 5,
    FOLDER_PATH_SPINNER = 6,
    MAX = 7
  }
end
Initialize = function()
  STATE.PATHS.RESOURCES = SKIN:GetVariable('@')
  STATE.PATHS.RAINMETER = SKIN:GetVariable('PROGRAMPATH') .. 'Rainmeter.exe'
  STATE.CURRENT_CONFIG = SKIN:GetVariable('CURRENTCONFIG')
  dofile(('%s%s'):format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.enums')
    additionalEnums()
    utility = require('shared.utility')
    utility.createJSONHelpers()
    COMPONENTS.SETTINGS = require('shared.settings')()
    COMPONENTS.OLD_SETTINGS = require('shared.settings')()
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    COMPONENTS.STATUS:show(LOCALIZATION:get('status_initializing', 'Initializing'))
    COMPONENTS.SLOTS = require('settings.slots')()
    COMPONENTS.PAGES = require('settings.pages')()
    SKIN:Bang(('[!SetOption "SaveButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_save', 'Save')))
    SKIN:Bang(('[!SetOption "CloseButton" "Text" "%s"]'):format(LOCALIZATION:get('button_label_close', 'Close')))
    local title, settings = COMPONENTS.PAGES:loadPage(STATE.PAGE_INDEX)
    updateTitle(title)
    STATE.SCROLL_INDEX = 1
    STATE.MAX_SCROLL_INDEX = COMPONENTS.SLOTS:update(settings)
    os.remove(io.absolutePath('cache\\languages.txt'))
    SKIN:Bang('["#@#windowless.vbs" "#@#settings\\localization\\listLanguages.bat"]')
    return utility.runCommand(utility.waitCommand, '', 'OnLanguagesListed')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
  STATE.INITIALIZED = true
end
Update = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function() end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Unload = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function() end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Save = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    return COMPONENTS.SETTINGS:save()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
local requiresRebuilding
requiresRebuilding = function()
  if COMPONENTS.SETTINGS:getLayoutRows() ~= COMPONENTS.OLD_SETTINGS:getLayoutRows() then
    return true
  elseif COMPONENTS.SETTINGS:getLayoutColumns() ~= COMPONENTS.OLD_SETTINGS:getLayoutColumns() then
    return true
  elseif COMPONENTS.SETTINGS:getLayoutWidth() ~= COMPONENTS.OLD_SETTINGS:getLayoutWidth() then
    return true
  elseif COMPONENTS.SETTINGS:getLayoutHeight() ~= COMPONENTS.OLD_SETTINGS:getLayoutHeight() then
    return true
  elseif COMPONENTS.SETTINGS:getLayoutHorizontal() ~= COMPONENTS.OLD_SETTINGS:getLayoutHorizontal() then
    return true
  elseif COMPONENTS.SETTINGS:getSkinSlideAnimation() ~= COMPONENTS.OLD_SETTINGS:getSkinSlideAnimation() then
    return true
  elseif COMPONENTS.SETTINGS:getDoubleClickToLaunch() ~= COMPONENTS.OLD_SETTINGS:getDoubleClickToLaunch() then
    return true
  end
  return false
end
Close = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    if COMPONENTS.SETTINGS:hasChanged(COMPONENTS.OLD_SETTINGS:get()) then
      if requiresRebuilding() then
        RebuildMainSlots()
      end
      local mainConfig = utility.getConfig(SKIN:GetVariable('ROOTCONFIG'))
      if mainConfig ~= nil and mainConfig:isActive() then
        SKIN:Bang('[!Refresh "#ROOTCONFIG#]')
      end
    end
    return SKIN:Bang('[!DeactivateConfig "#CURRENTCONFIG#"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
CyclePage = function(direction)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    STATE.PAGE_INDEX = STATE.PAGE_INDEX + direction
    if STATE.PAGE_INDEX < 1 then
      STATE.PAGE_INDEX = COMPONENTS.PAGES:getCount()
    elseif STATE.PAGE_INDEX > COMPONENTS.PAGES:getCount() then
      STATE.PAGE_INDEX = 1
    end
    local title, settings = COMPONENTS.PAGES:loadPage(STATE.PAGE_INDEX)
    updateTitle(title)
    STATE.SCROLL_INDEX = 1
    STATE.MAX_SCROLL_INDEX = COMPONENTS.SLOTS:update(settings)
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ScrollSlots = function(direction)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    local index = STATE.SCROLL_INDEX + direction
    if index < 1 then
      return 
    elseif index > STATE.MAX_SCROLL_INDEX then
      return 
    end
    STATE.SCROLL_INDEX = index
    return COMPONENTS.SLOTS:scroll()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
PerformAction = function(index)
  return COMPONENTS.SLOTS:performAction(index)
end
ToggleBoolean = function(index)
  return COMPONENTS.SLOTS:toggleBoolean(index)
end
StartEditingFolderPath = function(index)
  local valueMeter = SKIN:GetMeter(('Slot%dFolderPathValue'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathInput" "DefaultValue" "%s"]'):format(valueMeter:GetOption('Text')))
  SKIN:Bang(('[!SetOption "FolderPathInput" "X" "([Slot%dFolderPathValue:X])"]'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathInput" "Y" "([Slot%dFolderPathValue:Y] + 18)"]'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathInput" "W" "([Slot%dFolderPathValue:W])"]'):format(index))
  SKIN:Bang('[!SetOption "FolderPathInput" "H" "32"]')
  SKIN:Bang(('[!SetOption "FolderPathInput" "SolidColor" "%s"]'):format(valueMeter:GetOption('SolidColor')))
  SKIN:Bang(('[!CommandMeasure "FolderPathInput" "ExecuteBatch %d"]'):format(index))
  return log('StartEditingFolderPath ' .. index)
end
StartBrowsingFolderPath = function(index)
  local parameter = COMPONENTS.SLOTS:startBrowsingFolderPath(index)
  return utility.runCommand(parameter, '', 'BrowseFolderPath', {
    ('%d'):format(index)
  }, 'Hide', 'ANSI')
end
BrowseFolderPath = function(index)
  local output = SKIN:GetMeasure('Command'):GetStringValue()
  local path = output:match('Path="([^"]*)"')
  return EditFolderPath(index, path)
end
EditFolderPath = function(index, path)
  if path:endsWith(';') then
    path = path:sub(1, -2)
  end
  return COMPONENTS.SLOTS:editFolderPath(index, path)
end
OnLanguagesListed = function()
  if not (io.fileExists('cache\\languages.txt')) then
    return utility.runLastCommand()
  end
  local setting = COMPONENTS.SLOTS:getSetting(COMPONENTS.SLOTS:getNumSettings() - 2)
  setting:setValues()
  COMPONENTS.SLOTS:scroll()
  return COMPONENTS.STATUS:hide()
end
OnSteamUsersListed = function()
  if not (io.fileExists('cache\\steam\\completed.txt')) then
    return utility.runLastCommand()
  end
  COMPONENTS.SLOTS:getSetting(3):setValues()
  return COMPONENTS.SLOTS:scroll()
end
CycleSpinner = function(index, direction)
  return COMPONENTS.SLOTS:cycleSpinner(index, direction)
end
IncrementInteger = function(index)
  return COMPONENTS.SLOTS:incrementInteger(index)
end
DecrementInteger = function(index)
  return COMPONENTS.SLOTS:decrementInteger(index)
end
StartEditingIntegerPath = function(index)
  local valueMeter = SKIN:GetMeter(('Slot%dIntegerValue'):format(index))
  SKIN:Bang(('[!SetOption "IntegerInput" "DefaultValue" "%s"]'):format(valueMeter:GetOption('Text')))
  SKIN:Bang(('[!SetOption "IntegerInput" "X" "([Slot%dIntegerValue:X])"]'):format(index))
  SKIN:Bang(('[!SetOption "IntegerInput" "Y" "([Slot%dIntegerValue:Y] + 18)"]'):format(index))
  SKIN:Bang(('[!SetOption "IntegerInput" "W" "([Slot%dIntegerValue:W])"]'):format(index))
  SKIN:Bang('[!SetOption "IntegerInput" "H" "32"]')
  SKIN:Bang(('[!SetOption "IntegerInput" "SolidColor" "%s"]'):format(valueMeter:GetOption('SolidColor')))
  SKIN:Bang(('[!CommandMeasure "IntegerInput" "ExecuteBatch %d"]'):format(index))
  return log('StartEditingInteger ' .. index)
end
EditInteger = function(index, value)
  value = tonumber(value)
  if type(value) ~= 'number' or value % 1 ~= 0 then
    return 
  end
  return COMPONENTS.SLOTS:setInteger(index, value)
end
OnEditedGlobalStartingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setGlobalStartingBangs(bangs:splitIntoLines())
end
OnEditedGlobalStoppingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setGlobalStoppingBangs(bangs:splitIntoLines())
end
OnEditedShortcutsStartingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setShortcutsStartingBangs(bangs:splitIntoLines())
end
OnEditedShortcutsStoppingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setShortcutsStoppingBangs(bangs:splitIntoLines())
end
OnEditedSteamStartingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setSteamStartingBangs(bangs:splitIntoLines())
end
OnEditedSteamStoppingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setSteamStoppingBangs(bangs:splitIntoLines())
end
OnEditedBattlenetStartingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setBattlenetStartingBangs(bangs:splitIntoLines())
end
OnEditedBattlenetStoppingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setBattlenetStoppingBangs(bangs:splitIntoLines())
end
OnEditedGOGGalaxyStartingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setGOGGalaxyStartingBangs(bangs:splitIntoLines())
end
OnEditedGOGGalaxyStoppingBangs = function()
  local bangs = io.readFile('cache\\bangs.txt')
  return COMPONENTS.SETTINGS:setGOGGalaxyStoppingBangs(bangs:splitIntoLines())
end
CycleFolderPathSpinner = function(index, direction)
  return COMPONENTS.SLOTS:cycleFolderPathSpinner(index, direction)
end
StartEditingFolderPathSpinner = function(index)
  local valueMeter = SKIN:GetMeter(('Slot%dFolderPathSpinnerValue'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathSpinnerInput" "DefaultValue" "%s"]'):format(valueMeter:GetOption('Text')))
  SKIN:Bang(('[!SetOption "FolderPathSpinnerInput" "X" "([Slot%dFolderPathSpinnerValue:X])"]'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathSpinnerInput" "Y" "([Slot%dFolderPathSpinnerValue:Y] + 18)"]'):format(index))
  SKIN:Bang(('[!SetOption "FolderPathSpinnerInput" "W" "([Slot%dFolderPathSpinnerValue:W])"]'):format(index))
  SKIN:Bang('[!SetOption "FolderPathSpinnerInput" "H" "32"]')
  SKIN:Bang(('[!SetOption "FolderPathSpinnerInput" "SolidColor" "%s"]'):format(valueMeter:GetOption('SolidColor')))
  SKIN:Bang(('[!CommandMeasure "FolderPathSpinnerInput" "ExecuteBatch %d"]'):format(index))
  return log('StartEditingFolderPath ' .. index)
end
StartBrowsingFolderPathSpinner = function(index)
  local parameter = COMPONENTS.SLOTS:startBrowsingFolderPathSpinner(index)
  return utility.runCommand(parameter, '', 'BrowseFolderPathSpinner', {
    ('%d'):format(index)
  }, 'Hide', 'ANSI')
end
BrowseFolderPathSpinner = function(index)
  local output = SKIN:GetMeasure('Command'):GetStringValue()
  local path = output:match('Path="([^"]*)"')
  return EditFolderPathSpinner(index, path)
end
EditFolderPathSpinner = function(index, path)
  if path:endsWith(';') then
    path = path:sub(1, -2)
  end
  return COMPONENTS.SLOTS:editFolderPathSpinner(index, path)
end
