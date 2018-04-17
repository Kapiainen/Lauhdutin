export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil

export LOCALIZATION = nil

export STATE = {
	INITIALIZED: false
	PATHS: {
		RESOURCES: nil
		RAINMETER: nil
	}
	CURRENT_CONFIG: nil
	NUM_SLOTS: 4
	PAGE_INDEX: 1
	SCROLL_INDEX: 1
	MAX_SCROLL_INDEX: 1
}

export COMPONENTS = {
	SETTINGS: nil
	SLOTS: nil
	PAGES: nil
}

export log = (...) -> print(...) if STATE.LOGGING == true

export RebuildSettingsSlots = () -> -- For development only
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			build = require('settings.build_settings_skin')
			io.writeFile('settings\\slots\\init.inc', build())
			SKIN\Bang('[!Refresh]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export RebuildMainSlots = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			build = require('settings.build_main_skin')
			io.writeFile('main\\slots\\init.inc', build(COMPONENTS.SETTINGS))
	)
	COMPONENTS.STATUS\show(err, true) unless success

updateTitle = (title) ->
	assert(type(title) == 'string', 'settings.init.updateTitle')
	assert(title ~= '', 'settings.init.updateTitle')
	SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s (%d/%d)"]')\format(title, STATE.PAGE_INDEX, COMPONENTS.PAGES\getCount()))

additionalEnums = () ->
	ENUMS.SETTING_TYPES = {
		ACTION: 1
		BOOLEAN: 2
		FOLDER_PATH: 3
		SPINNER: 4
		INTEGER: 5
		FOLDER_PATH_SPINNER: 6
		MAX: 7
	}

export Initialize = () ->
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	STATE.PATHS.RAINMETER = SKIN\GetVariable('PROGRAMPATH') .. 'Rainmeter.exe'
	STATE.CURRENT_CONFIG = SKIN\GetVariable('CURRENTCONFIG')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			require('shared.enums')
			additionalEnums()
			utility = require('shared.utility')
			utility.createJSONHelpers()
			COMPONENTS.SETTINGS = require('shared.settings')()
			COMPONENTS.OLD_SETTINGS = require('shared.settings')()
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			COMPONENTS.STATUS\show(LOCALIZATION\get('status_initializing', 'Initializing'))
			COMPONENTS.SLOTS = require('settings.slots')()
			COMPONENTS.PAGES = require('settings.pages')()
			SKIN\Bang(('[!SetOption "SaveButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_save', 'Save')))
			SKIN\Bang(('[!SetOption "CloseButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_close', 'Close')))
			title, settings = COMPONENTS.PAGES\loadPage(STATE.PAGE_INDEX)
			updateTitle(title)
			STATE.SCROLL_INDEX = 1
			STATE.MAX_SCROLL_INDEX = COMPONENTS.SLOTS\update(settings)
			os.remove(io.absolutePath('cache\\languages.txt'))
			SKIN\Bang('["#@#windowless.vbs" "#@#settings\\localization\\listLanguages.bat"]')
			utility.runCommand(utility.waitCommand, '', 'OnLanguagesListed')
	)
	return COMPONENTS.STATUS\show(err, true) unless success
	STATE.INITIALIZED = true

export Update = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() -> return
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Unload = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			return
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Save = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.SETTINGS\save()
	)
	COMPONENTS.STATUS\show(err, true) unless success

requiresRebuilding = () ->
	if COMPONENTS.SETTINGS\getLayoutRows() ~= COMPONENTS.OLD_SETTINGS\getLayoutRows()
		return true
	elseif COMPONENTS.SETTINGS\getLayoutColumns() ~= COMPONENTS.OLD_SETTINGS\getLayoutColumns()
		return true
	elseif COMPONENTS.SETTINGS\getLayoutWidth() ~= COMPONENTS.OLD_SETTINGS\getLayoutWidth()
		return true
	elseif COMPONENTS.SETTINGS\getLayoutHeight() ~= COMPONENTS.OLD_SETTINGS\getLayoutHeight()
		return true
	elseif COMPONENTS.SETTINGS\getLayoutHorizontal() ~= COMPONENTS.OLD_SETTINGS\getLayoutHorizontal()
		return true
	elseif COMPONENTS.SETTINGS\getSkinSlideAnimation() ~= COMPONENTS.OLD_SETTINGS\getSkinSlideAnimation()
		return true
	elseif COMPONENTS.SETTINGS\getDoubleClickToLaunch() ~= COMPONENTS.OLD_SETTINGS\getDoubleClickToLaunch()
		return true
	return false

export Close = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			if COMPONENTS.SETTINGS\hasChanged(COMPONENTS.OLD_SETTINGS\get())
				if requiresRebuilding()
					RebuildMainSlots()
				mainConfig = utility.getConfig(SKIN\GetVariable('ROOTCONFIG'))
				if mainConfig ~= nil and mainConfig\isActive()
					SKIN\Bang('[!Refresh "#ROOTCONFIG#]')
			SKIN\Bang('[!DeactivateConfig "#CURRENTCONFIG#"]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export CyclePage = (direction) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
		STATE.PAGE_INDEX += direction
		if STATE.PAGE_INDEX < 1
			STATE.PAGE_INDEX = COMPONENTS.PAGES\getCount()
		elseif STATE.PAGE_INDEX > COMPONENTS.PAGES\getCount()
			STATE.PAGE_INDEX = 1
		title, settings = COMPONENTS.PAGES\loadPage(STATE.PAGE_INDEX)
		updateTitle(title)
		STATE.SCROLL_INDEX = 1
		STATE.MAX_SCROLL_INDEX = COMPONENTS.SLOTS\update(settings)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ScrollSlots = (direction) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
		index = STATE.SCROLL_INDEX + direction
		if index < 1
			return
		elseif index > STATE.MAX_SCROLL_INDEX
			return
		STATE.SCROLL_INDEX = index
		COMPONENTS.SLOTS\scroll()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export PerformAction = (index) -> COMPONENTS.SLOTS\performAction(index)

export ToggleBoolean = (index) -> COMPONENTS.SLOTS\toggleBoolean(index)

export StartEditingFolderPath = (index) ->
	valueMeter = SKIN\GetMeter(('Slot%dFolderPathValue')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathInput" "DefaultValue" "%s"]')\format(valueMeter\GetOption('Text')))
	SKIN\Bang(('[!SetOption "FolderPathInput" "X" "([Slot%dFolderPathValue:X])"]')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathInput" "Y" "([Slot%dFolderPathValue:Y] + 18)"]')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathInput" "W" "([Slot%dFolderPathValue:W])"]')\format(index))
	SKIN\Bang('[!SetOption "FolderPathInput" "H" "32"]')
	SKIN\Bang(('[!SetOption "FolderPathInput" "SolidColor" "%s"]')\format(valueMeter\GetOption('SolidColor')))
	SKIN\Bang(('[!CommandMeasure "FolderPathInput" "ExecuteBatch %d"]')\format(index))
	return log('StartEditingFolderPath ' .. index)

export StartBrowsingFolderPath = (index) ->
	parameter = COMPONENTS.SLOTS\startBrowsingFolderPath(index)
	utility.runCommand(parameter, '', 'BrowseFolderPath', {('%d')\format(index)}, 'Hide', 'ANSI')

export BrowseFolderPath = (index) ->
	output = SKIN\GetMeasure('Command')\GetStringValue()
	path = output\match('Path="([^"]*)"')
	EditFolderPath(index, path)

export EditFolderPath = (index, path) ->
	path = path\sub(1, -2) if path\endsWith(';')
	COMPONENTS.SLOTS\editFolderPath(index, path)

export OnLanguagesListed = () ->
	unless io.fileExists('cache\\languages.txt')
		return utility.runLastCommand()
	setting = COMPONENTS.SLOTS\getSetting(COMPONENTS.SLOTS\getNumSettings() - 2)
	setting\setValues()
	COMPONENTS.SLOTS\scroll()
	COMPONENTS.STATUS\hide()

export OnSteamUsersListed = () ->
	unless io.fileExists('cache\\steam\\completed.txt')
		return utility.runLastCommand()
	COMPONENTS.SLOTS\getSetting(3)\setValues()
	COMPONENTS.SLOTS\scroll()

export CycleSpinner = (index, direction) -> COMPONENTS.SLOTS\cycleSpinner(index, direction)

export IncrementInteger = (index) -> COMPONENTS.SLOTS\incrementInteger(index)

export DecrementInteger = (index) -> COMPONENTS.SLOTS\decrementInteger(index)

export StartEditingIntegerPath = (index) ->
	valueMeter = SKIN\GetMeter(('Slot%dIntegerValue')\format(index))
	SKIN\Bang(('[!SetOption "IntegerInput" "DefaultValue" "%s"]')\format(valueMeter\GetOption('Text')))
	SKIN\Bang(('[!SetOption "IntegerInput" "X" "([Slot%dIntegerValue:X])"]')\format(index))
	SKIN\Bang(('[!SetOption "IntegerInput" "Y" "([Slot%dIntegerValue:Y] + 18)"]')\format(index))
	SKIN\Bang(('[!SetOption "IntegerInput" "W" "([Slot%dIntegerValue:W])"]')\format(index))
	SKIN\Bang('[!SetOption "IntegerInput" "H" "32"]')
	SKIN\Bang(('[!SetOption "IntegerInput" "SolidColor" "%s"]')\format(valueMeter\GetOption('SolidColor')))
	SKIN\Bang(('[!CommandMeasure "IntegerInput" "ExecuteBatch %d"]')\format(index))
	return log('StartEditingInteger ' .. index)

export EditInteger = (index, value) ->
	value = tonumber(value)
	return if type(value) ~= 'number' or value % 1 ~= 0
	COMPONENTS.SLOTS\setInteger(index, value)

export OnEditedGlobalStartingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setGlobalStartingBangs(bangs\splitIntoLines())

export OnEditedGlobalStoppingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setGlobalStoppingBangs(bangs\splitIntoLines())

export OnEditedShortcutsStartingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setShortcutsStartingBangs(bangs\splitIntoLines())

export OnEditedShortcutsStoppingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setShortcutsStoppingBangs(bangs\splitIntoLines())

export OnEditedSteamStartingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setSteamStartingBangs(bangs\splitIntoLines())

export OnEditedSteamStoppingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setSteamStoppingBangs(bangs\splitIntoLines())

export OnEditedBattlenetStartingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setBattlenetStartingBangs(bangs\splitIntoLines())

export OnEditedBattlenetStoppingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setBattlenetStoppingBangs(bangs\splitIntoLines())

export OnEditedGOGGalaxyStartingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setGOGGalaxyStartingBangs(bangs\splitIntoLines())

export OnEditedGOGGalaxyStoppingBangs = () ->
	bangs = io.readFile('cache\\bangs.txt')
	COMPONENTS.SETTINGS\setGOGGalaxyStoppingBangs(bangs\splitIntoLines())

export CycleFolderPathSpinner = (index, direction) -> COMPONENTS.SLOTS\cycleFolderPathSpinner(index, direction)

export StartEditingFolderPathSpinner = (index) ->
	valueMeter = SKIN\GetMeter(('Slot%dFolderPathSpinnerValue')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathSpinnerInput" "DefaultValue" "%s"]')\format(valueMeter\GetOption('Text')))
	SKIN\Bang(('[!SetOption "FolderPathSpinnerInput" "X" "([Slot%dFolderPathSpinnerValue:X])"]')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathSpinnerInput" "Y" "([Slot%dFolderPathSpinnerValue:Y] + 18)"]')\format(index))
	SKIN\Bang(('[!SetOption "FolderPathSpinnerInput" "W" "([Slot%dFolderPathSpinnerValue:W])"]')\format(index))
	SKIN\Bang('[!SetOption "FolderPathSpinnerInput" "H" "32"]')
	SKIN\Bang(('[!SetOption "FolderPathSpinnerInput" "SolidColor" "%s"]')\format(valueMeter\GetOption('SolidColor')))
	SKIN\Bang(('[!CommandMeasure "FolderPathSpinnerInput" "ExecuteBatch %d"]')\format(index))
	return log('StartEditingFolderPath ' .. index)

export StartBrowsingFolderPathSpinner = (index) ->
	parameter = COMPONENTS.SLOTS\startBrowsingFolderPathSpinner(index)
	utility.runCommand(parameter, '', 'BrowseFolderPathSpinner', {('%d')\format(index)}, 'Hide', 'ANSI')

export BrowseFolderPathSpinner = (index) ->
	output = SKIN\GetMeasure('Command')\GetStringValue()
	path = output\match('Path="([^"]*)"')
	EditFolderPathSpinner(index, path)

export EditFolderPathSpinner = (index, path) ->
	path = path\sub(1, -2) if path\endsWith(';')
	COMPONENTS.SLOTS\editFolderPathSpinner(index, path)
