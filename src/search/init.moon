export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil

export LOCALIZATION = nil

STATE = {
	PATHS: {
		RESOURCES: nil
	}
	STACK: false
}

COMPONENTS = {
	STATUS: nil
}

export log = (...) -> print(...) if STATE.LOGGING == true

-- TODO: Have a look at the possibility of being able to use Lua patterns (square brackets seem to cause issues, but dot works just fine)
export Initialize = () ->
	SKIN\Bang('[!Hide]')
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.enums')
			utility = require('shared.utility')
			utility.createJSONHelpers()
			COMPONENTS.SETTINGS = require('shared.settings')()
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			SKIN\Bang(('[!SetOption "WindowTitle" "Text" "%s"]')\format(LOCALIZATION\get('search_window_all_title', 'Search')))
			COMPONENTS.STATUS\hide()
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeSearch()" "#ROOTCONFIG#"]')
	)
	return COMPONENTS.STATUS\show(err, true) unless success

export Update = () ->
	return

export Handshake = (stack) ->
	success, err = pcall(
		() ->
			if stack
				SKIN\Bang(('[!SetOption "WindowTitle" "Text" "%s"]')\format(LOCALIZATION\get('search_window_current_title', 'Search (current games)')))
			STATE.STACK = stack
			meter = SKIN\GetMeter('WindowShadow')
			skinWidth = meter\GetW()
			skinHeight = meter\GetH()
			mainConfig = utility.getConfig(SKIN\GetVariable('ROOTCONFIG'))
			monitorIndex = nil
			if mainConfig ~= nil
				monitorIndex = utility.getConfigMonitor(mainConfig) or 1
			else
				monitorIndex = 1
			x, y = utility.centerOnMonitor(skinWidth, skinHeight, monitorIndex)
			SKIN\Bang(('[!Move "%d" "%d"]')\format(x, y))
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
