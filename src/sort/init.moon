export RUN_TESTS = false
if RUN_TESTS
	print('Running tests')

utility = nil

export LOCALIZATION = nil

export STATE = {
	PATHS: {
		RESOURCES: nil
	}
	SCROLLBAR: {
		START: nil
		MAX_HEIGHT: nil
		HEIGHT: nil
		STEP: nil
	}
	NUM_SLOTS: 5
}

COMPONENTS = {
	STATUS: nil
	SETTINGS: nil
	SLOTS: nil
}

class Property
	new: (args) =>
		assert(type(args.title) == 'string', 'sort.init.Property')
		@title = args.title
		assert(type(args.value) == 'string', 'sort.init.Property')
		@value = args.value
		assert((type(args.enum) == 'number' and args.enum % 1 == 0) or type(args.action) == 'function', 'sort.init.Property')
		@enum = args.enum
		@action = args.action

class Slot
	new: (index) =>
		assert(type(index) == 'number' and index % 1 == 0, 'sort.init.Slot')
		@index = index

	populate: (property) =>
		@property = property
		@update()

	update: () =>
		if @property
			@property.value = @property\update() if @property.update ~= nil
			SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" "%s"]')\format(@index, utility.replaceUnsupportedChars(@property.title)))
			SKIN\Bang(('[!SetOption "Slot%dValue" "Text" "%s"]')\format(@index, utility.replaceUnsupportedChars(@property.value)))
			return
		SKIN\Bang(('[!SetOption "Slot%dTitle" "Text" " "]')\format(@index))
		SKIN\Bang(('[!SetOption "Slot%dValue" "Text" " "]')\format(@index))

	hasAction: () => return @property ~= nil

	action: () =>
		if @property.action ~= nil
			@property\action()
			return true
		SKIN\Bang(('[!CommandMeasure "Script" "Sort(%d)" "#ROOTCONFIG#"]')\format(@property.enum))
		return false

export log = (...) -> print(...) if STATE.LOGGING == true

export Initialize = () ->
	SKIN\Bang('[!Hide]')
	STATE.PATHS.RESOURCES = SKIN\GetVariable('@')
	dofile(('%s%s')\format(STATE.PATHS.RESOURCES, 'lib\\rainmeter_helpers.lua'))
	COMPONENTS.STATUS = require('shared.status')()
	success, err = pcall(
		() ->
			log('Initializing Sort config')
			require('shared.enums')
			utility = require('shared.utility')
			utility.createJSONHelpers()
			COMPONENTS.SETTINGS = require('shared.settings')()
			STATE.LOGGING = COMPONENTS.SETTINGS\getLogging()
			export LOCALIZATION = require('shared.localization')(COMPONENTS.SETTINGS)
			STATE.SCROLL_INDEX = 1
			COMPONENTS.SLOTS = [Slot(i) for i = 1, STATE.NUM_SLOTS]
			scrollbar = SKIN\GetMeter('Scrollbar')
			STATE.SCROLLBAR.START = scrollbar\GetY()
			STATE.SCROLLBAR.MAX_HEIGHT = scrollbar\GetH()
			SKIN\Bang(('[!SetOption "PageTitle" "Text" "%s"]')\format(LOCALIZATION\get('sort_window_title', 'Sort')))
			SKIN\Bang('[!CommandMeasure "Script" "HandshakeSort()" "#ROOTCONFIG#"]')
			COMPONENTS.STATUS\hide()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Update = () ->
	return

createProperties = (game, platform) ->
	properties = {}
	table.insert(properties,
		Property({
			title: LOCALIZATION\get('sort_alphabetically', 'Alphabetically')
			value: ' '
			enum: ENUMS.SORTING_TYPES.ALPHABETICALLY
		})
	)
	table.insert(properties,
		Property({
			title: LOCALIZATION\get('sort_last_played', 'Most recently played')
			value: ' '
			enum: ENUMS.SORTING_TYPES.LAST_PLAYED
		})
	)
	table.insert(properties,
		Property({
			title: LOCALIZATION\get('button_label_hours_played', 'Hours played')
			value: ' '
			enum: ENUMS.SORTING_TYPES.HOURS_PLAYED
		})
	)
	table.sort(properties, (a, b) ->
		if a.title\lower() < b.title\lower()
			return true
		return false
	)
	table.insert(properties,
		Property({
			title: LOCALIZATION\get('button_label_cancel', 'Cancel')
			value: ' '
			action: () =>
				SKIN\Bang('[!DeactivateConfig]')
		})
	)
	return properties

updateScrollbar = () ->
	STATE.MAX_SCROLL_INDEX = #STATE.PROPERTIES - STATE.NUM_SLOTS + 1
	if #STATE.PROPERTIES > STATE.NUM_SLOTS
		STATE.SCROLLBAR.HEIGHT = math.round(STATE.SCROLLBAR.MAX_HEIGHT / (#STATE.PROPERTIES - STATE.NUM_SLOTS + 1))
		STATE.SCROLLBAR.STEP = (STATE.SCROLLBAR.MAX_HEIGHT - STATE.SCROLLBAR.HEIGHT) / (#STATE.PROPERTIES - STATE.NUM_SLOTS)
	else
		STATE.SCROLLBAR.HEIGHT = STATE.SCROLLBAR.MAX_HEIGHT
		STATE.SCROLLBAR.STEP = 0
	SKIN\Bang(('[!SetOption "Scrollbar" "H" "%d"]')\format(STATE.SCROLLBAR.HEIGHT))
	y = STATE.SCROLLBAR.START + (STATE.SCROLL_INDEX - 1) * STATE.SCROLLBAR.STEP
	SKIN\Bang(('[!SetOption "Scrollbar" "Y" "%d"]')\format(math.round(y)))

updateSlots = () ->
	for i, slot in ipairs(COMPONENTS.SLOTS)
		slot\populate(STATE.PROPERTIES[i + STATE.SCROLL_INDEX - 1])
		if i == STATE.HIGHLIGHTED_SLOT_INDEX
			MouseOver(i)

export Handshake = (currentSortingType) ->
	success, err = pcall(
		() ->
			log('Accepting Sort handshake', currentSortingType)
			STATE.PROPERTIES = createProperties()
			updateScrollbar()
			updateSlots()
			if COMPONENTS.SETTINGS\getCenterOnMonitor()
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
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Scroll = (direction) ->
	success, err = pcall(
		() ->
			return unless COMPONENTS.SLOTS
			index = STATE.SCROLL_INDEX + direction
			if index < 1
				return
			elseif index > STATE.MAX_SCROLL_INDEX
				return
			STATE.SCROLL_INDEX = index
			updateScrollbar()
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseOver = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			STATE.HIGHLIGHTED_SLOT_INDEX = index
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseLeave = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			if index == 0
				STATE.HIGHLIGHTED_SLOT_INDEX = 0
				for i = index, STATE.NUM_SLOTS
					SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(i))
			else
				SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonBaseColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export MouseLeftPress = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonPressedColor#"]')\format(index))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ButtonAction = (index) ->
	success, err = pcall(
		() ->
			return if index < 1
			return unless COMPONENTS.SLOTS
			return unless COMPONENTS.SLOTS[index]\hasAction()
			SKIN\Bang(('[!SetOption "Slot%dButton" "SolidColor" "#ButtonHighlightedColor#"]')\format(index))
			if COMPONENTS.SLOTS[index]\action()
				STATE.SCROLL_INDEX = 1
				updateScrollbar()
				updateSlots()
			else
				SKIN\Bang('[!DeactivateConfig]')
	)
	COMPONENTS.STATUS\show(err, true) unless success
