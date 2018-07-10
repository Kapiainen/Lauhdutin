export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil

export LOCALIZATION = nil

export STATE = {
	PATHS: {
		GAMES: 'games.json'
	}
	GAME: nil
	ALL_GAMES: nil
	GAMES_VERSION: nil
	CENTERED: false
	ACTIVE_INPUT: false
	PROGRESS: 1
}

COMPONENTS = {
	STATUS: nil
	SETTINGS: nil
	SLOTS: nil
}

class Property
	new: (args) =>
		@title = args.title
		@value = args.value
		@action = args.action
		@update = args.update

class Slot
	new: (index, maxValueStringLength) =>
		@index = index
		@maxValueStringLength = maxValueStringLength

	populate: (property) =>
		@property = property
		@update()

	update: () =>
		if @property ~= nil
			@property.value = @property\update() if @property.update ~= nil
			SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index, utility.replaceUnsupportedChars(@property.title)))
			value = utility.replaceUnsupportedChars(@property.value)
			SKIN\Bang(('[!SetOption "Slot%dValue" "Text" "%s"]')\format(@index, value))
			if value\len() > @maxValueStringLength
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipText" "%s"]')\format(@index, value))
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "0"]')\format(@index))
			else
				SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]')\format(@index))
			return
		SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "ToolTipHidden" "1"]')\format(@index))

	hasAction: () => return @property ~= nil and @property.action ~= nil

	action: () =>
		return if @property == nil or @property.action == nil
		@property\action(@index)

Game = nil

export HideStatus = () -> COMPONENTS.STATUS\hide()

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
			export log = if COMPONENTS.SETTINGS\getLogging() == true then (...) -> print(...) else () -> return
			log('Initializing NewGame config')
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			Game = require('main.game')
			valueMeter = SKIN\GetMeter('Slot1Value')
			maxValueStringLength = math.round(valueMeter\GetW() / valueMeter\GetOption('FontSize'))
			COMPONENTS.SLOT = Slot(1, maxValueStringLength)
			SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(LOCALIZATION\get('newgame_window_title', 'New game')))
			SKIN\Bang(('[!SetOption "SaveButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_next', 'Next')))
			SKIN\Bang(('[!SetOption "CancelButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_cancel', 'Cancel')))
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeNewGame()" "#ROOTCONFIG#"]')
			COMPONENTS.STATUS\hide()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () -> return

updateSlot = () -> COMPONENTS.SLOT\populate(STATE.PROPERTIES[STATE.PROGRESS])

createProperties = () ->
	properties = {}
	titleValue = () -> return STATE.ARGS.title or ''
	table.insert(properties, Property({
		title: LOCALIZATION\get('game_title', 'Title')
		value: titleValue()
		update: titleValue
		action: () => StartEditingTitle()
	}))
	pathValue = () -> return STATE.ARGS.path or ''
	table.insert(properties, Property({
		title: LOCALIZATION\get('game_path', 'Path')
		value: pathValue()
		update: pathValue
		action: () => StartEditingPath()
	}))
	installedValue = () -> return if STATE.ARGS.uninstalled == false then LOCALIZATION\get('button_label_yes', 'Yes') else return LOCALIZATION\get('button_label_no', 'No')
	table.insert(properties, Property({
		title: LOCALIZATION\get('game_installed', 'Installed')
		value: installedValue()
		update: installedValue
		action: () =>
			STATE.ARGS.uninstalled = not STATE.ARGS.uninstalled
			updateSlot()
	}))
	return properties

centerConfig = () ->
	return if STATE.CENTERED == true
	STATE.CENTERED = true
	return if not COMPONENTS.SETTINGS\getCenterOnMonitor()
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

export Handshake = (gameID) ->
	success, err = pcall(
		() ->
			log('Accepting NewGame handshake', gameID)
			games = io.readJSON(STATE.PATHS.GAMES)
			STATE.TAGS_DICTIONARY = games.tagsDictionary
			STATE.GAMES_VERSION = games.version
			STATE.GAMES_UPDATED_TIMESTAMP = games.updated or os.date('*t')
			STATE.ALL_GAMES = [Game(args, STATE.TAGS_DICTIONARY) for args in *games.games]
			STATE.ARGS = {
				title: ''
				path: ''
				uninstalled: false
				platformID: ENUMS.PLATFORM_IDS.CUSTOM
				gameID: gameID
			}
			STATE.PROPERTIES = createProperties()
			updateSlot()
			centerConfig()
			SKIN\Bang('[!ZPos 1][!Show]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseOver = () -> SKIN\Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonHighlightedColor#"]')

export MouseLeave = () -> SKIN\Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonBaseColor#"]')

export MouseLeftPress = () -> SKIN\Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonPressedColor#"]')

export ButtonAction = () ->
	SKIN\Bang('[!SetOption "Slot1Button" "SolidColor" "#ButtonHighlightedColor#"]')
	COMPONENTS.SLOT\action()
	updateSlot()

export Save = () ->
	success, err = pcall(
		() ->
			return if STATE.ACTIVE_INPUT == true
			if STATE.PROGRESS < #STATE.PROPERTIES -- Next
				switch STATE.PROGRESS
					when 1
						if STATE.ARGS.title\trim() == ''
							COMPONENTS.STATUS\show(LOCALIZATION\get('newgame_missing_title', 'A title has not been defined!#CRLF##CRLF#Click to close.'))
							return
						for g in *STATE.ALL_GAMES
							if g\getTitle() == STATE.ARGS.title and g\getPlatformID() == STATE.ARGS.platformID
								COMPONENTS.STATUS\show(LOCALIZATION\get('newgame_game_with_same_title_exists', 'A game with that title already exists!#CRLF##CRLF#Click to close.'))
								return
					when 2
						if STATE.ARGS.path\trim() == ''
							COMPONENTS.STATUS\show(LOCALIZATION\get('newgame_missing_path', 'A path has not been defined!#CRLF##CRLF#Click to close.'))
							return
				STATE.PROGRESS += 1
				updateSlot()
				if STATE.PROGRESS == #STATE.PROPERTIES
					SKIN\Bang(('[!SetOption "SaveButton" "Text" "%s"]')\format(LOCALIZATION\get('button_label_save', 'Save')))
			else -- Save
				STATE.ARGS.expectedBanner = STATE.ARGS.title
				STATE.ARGS.path = (STATE.ARGS.path\gsub('/', '\\'))
				if (STATE.ARGS.path\find('%s')) ~= nil
					STATE.ARGS.path = ('"%s"')\format(STATE.ARGS.path)
				game = Game(STATE.ARGS)
				table.insert(STATE.ALL_GAMES, game)
				io.writeJSON(STATE.PATHS.GAMES, {
					version: STATE.GAMES_VERSION
					tagsDictionary: STATE.TAGS_DICTIONARY
					games: STATE.ALL_GAMES
					updated: STATE.GAMES_UPDATED_TIMESTAMP
				})
				SKIN\Bang(('[!CommandMeasure "Script" "OnAddGame(%d)" "#ROOTCONFIG#"]')\format(game\getGameID()))
				SKIN\Bang('[!DeactivateConfig]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Cancel = () ->
	success, err = pcall(
		() ->
			return if STATE.ACTIVE_INPUT == true
			SKIN\Bang('[!DeactivateConfig]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnDismissedInput = () ->
	success, err = pcall(
		() ->
			STATE.ACTIVE_INPUT = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

startEditing = (slotIndex, batchIndex, defaultValue) ->
	meter = SKIN\GetMeter(('Slot%dValue')\format(slotIndex))
	SKIN\Bang(('[!SetOption "Input" "X" "%d"]')\format(meter\GetX() - 1))
	SKIN\Bang(('[!SetOption "Input" "Y" "%d"]')\format(meter\GetY() - 1))
	SKIN\Bang(('[!SetOption "Input" "W" "%d"]')\format(meter\GetW()))
	SKIN\Bang(('[!SetOption "Input" "H" "%d"]')\format(20))
	defaultValue = '' if defaultValue == nil
	SKIN\Bang(('[!SetOption "Input" "DefaultValue" "%s"]')\format(defaultValue))
	SKIN\Bang(('[!CommandMeasure "Input" "ExecuteBatch %d"]')\format(batchIndex))
	STATE.ACTIVE_INPUT = true

export StartEditingTitle = () ->
	success, err = pcall(
		() ->
			startEditing(1, 1, STATE.ARGS.title)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedTitle = (title) ->
	success, err = pcall(
		() ->
			STATE.ARGS.title = title\sub(1, -2)
			updateSlot()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export StartEditingPath = () ->
	success, err = pcall(
		() ->
			startEditing(1, 2, STATE.ARGS.path)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnEditedPath = (path) ->
	success, err = pcall(
		() ->
			STATE.ARGS.path = path\sub(1, -2)
			updateSlot()
			OnDismissedInput()
	)
	COMPONENTS.STATUS\show(err, true) unless success
