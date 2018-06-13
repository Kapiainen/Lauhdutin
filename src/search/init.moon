export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

export LOCALIZATION = nil

STATE = {
	STACK: false
	CENTERED: false
}

COMPONENTS = {
	STATUS: nil
}

export log = (...) -> print(...) if STATE.LOGGING == true

export HideStatus = () -> COMPONENTS.STATUS\hide()

-- TODO: Have a look at the possibility of being able to use Lua patterns (square brackets seem to cause issues, but dot works just fine)
export Initialize = () ->
	SKIN\Bang('[!Hide]')
	dofile(('%s%s')\format(SKIN\GetVariable('@'), 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.string')
			json = require('lib.json')
			require('shared.io')(json)
			require('shared.rainmeter')
			require('shared.enums')
			COMPONENTS.SETTINGS = require('shared.settings')()
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			SKIN\Bang(('[!SetOption "WindowTitle" "Text" "%s"]')\format(LOCALIZATION\get('search_window_all_title', 'Search')))
			COMPONENTS.STATUS\hide()
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeSearch()" "#ROOTCONFIG#"]')
	)
	return COMPONENTS.STATUS\show(err, true) unless success

export Update = () ->
	return

centerConfig = () ->
	return if STATE.CENTERED == true
	STATE.CENTERED = true
	return if not COMPONENTS.SETTINGS\getCenterOnMonitor()
	meter = SKIN\GetMeter('WindowShadow')
	configWidth = meter\GetW()
	configHeight = meter\GetH()
	mainConfig = RAINMETER\GetConfig(SKIN\GetVariable('ROOTCONFIG'))
	monitorIndex = nil
	if mainConfig ~= nil
		monitorIndex = RAINMETER\GetConfigMonitor(mainConfig)
	else
		monitorIndex = 1
	RAINMETER\CenterOnMonitor(configWidth, configHeight, monitorIndex)

export Handshake = (stack) ->
	success, err = pcall(
		() ->
			if stack
				SKIN\Bang(('[!SetOption "WindowTitle" "Text" "%s"]')\format(LOCALIZATION\get('search_window_current_title', 'Search (current games)')))
			STATE.STACK = stack
			centerConfig()
			SKIN\Bang('[!Show]')
			SKIN\Bang('[!CommandMeasure "Input" "ExecuteBatch 1"]')
	)
	return COMPONENTS.STATUS\show(err, true) unless success

export SetInput = (str) ->
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Search(\'%s\', %s)" "#ROOTCONFIG#"]')\format(str\sub(1, -2), tostring(STATE.STACK)))
			SKIN\Bang('[!DeactivateConfig]')
	)
	return COMPONENTS.STATUS\show(err, true) unless success

export CancelInput = () ->
	success, err = pcall(
		() ->
			SKIN\Bang('[!DeactivateConfig]')
	)
	return COMPONENTS.STATUS\show(err, true) unless success
