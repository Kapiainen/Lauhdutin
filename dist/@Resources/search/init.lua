RUN_TESTS = false
if RUN_TESTS then
  print('Running tests')
end
local utility = nil
LOCALIZATION = nil
local STATE = {
  STACK = false,
  CENTERED = false
}
local COMPONENTS = {
  STATUS = nil
}
log = function(...)
  if STATE.LOGGING == true then
    return print(...)
  end
end
HideStatus = function()
  return COMPONENTS.STATUS:hide()
end
Initialize = function()
  SKIN:Bang('[!Hide]')
  dofile(('%s%s'):format(SKIN:GetVariable('@'), 'lib\\rainmeter_helpers.lua'))
  COMPONENTS.STATUS = require('shared.status')()
  local success, err = pcall(function()
    require('shared.string')
    local json = require('lib.json')
    require('shared.io')(json)
    require('shared.rainmeter')
    require('shared.enums')
    utility = require('shared.utility')
    COMPONENTS.SETTINGS = require('shared.settings')()
    LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
    SKIN:Bang(('[!SetOption "WindowTitle" "Text" "%s"]'):format(LOCALIZATION:get('search_window_all_title', 'Search')))
    COMPONENTS.STATUS:hide()
    return SKIN:Bang('[!CommandMeasure "Script" "HandshakeSearch()" "#ROOTCONFIG#"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
Update = function() end
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
  local configWidth = meter:GetW()
  local configHeight = meter:GetH()
  local mainConfig = RAINMETER:GetConfig(SKIN:GetVariable('ROOTCONFIG'))
  local monitorIndex = nil
  if mainConfig ~= nil then
    monitorIndex = RAINMETER:GetConfigMonitor(mainConfig)
  else
    monitorIndex = 1
  end
  return RAINMETER:CenterOnMonitor(configWidth, configHeight, monitorIndex)
end
Handshake = function(stack)
  local success, err = pcall(function()
    if stack then
      SKIN:Bang(('[!SetOption "WindowTitle" "Text" "%s"]'):format(LOCALIZATION:get('search_window_current_title', 'Search (current games)')))
    end
    STATE.STACK = stack
    centerConfig()
    SKIN:Bang('[!Show]')
    return SKIN:Bang('[!CommandMeasure "Input" "ExecuteBatch 1"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
SetInput = function(str)
  local success, err = pcall(function()
    SKIN:Bang(('[!CommandMeasure "Script" "Search(\'%s\', %s)" "#ROOTCONFIG#"]'):format(str:sub(1, -2), tostring(STATE.STACK)))
    return SKIN:Bang('[!DeactivateConfig]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
CancelInput = function()
  local success, err = pcall(function()
    return SKIN:Bang('[!DeactivateConfig]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
