Slot = require('settings.slots.slot')

class Slots
	new: () =>
		@slots = [Slot(i) for i = 1, STATE.NUM_SLOTS]
		assert(#@slots == STATE.NUM_SLOTS, 'settings.slots.init.Slots')
		@settings = {}
		scrollBar = SKIN\GetMeter('ScrollBar')
		assert(scrollBar ~= nil, 'settings.slots.init.Slots')
		@scrollBarStart = if scrollBar then scrollBar\GetY() else 0
		@scrollBarMaxHeight = if scrollBar then scrollBar\GetH() else 0
		@scrollBarHeight = @scrollBarMaxHeight
		@scrollBarStep = 0

	updateScrollBar: (numSettings) =>
		if numSettings > STATE.NUM_SLOTS
			@scrollBarHeight = math.round(@scrollBarMaxHeight / (numSettings - STATE.NUM_SLOTS + 1))
			@scrollBarStep = (@scrollBarMaxHeight - @scrollBarHeight) / (numSettings - STATE.NUM_SLOTS)
		else
			@scrollBarHeight = @scrollBarMaxHeight
			@scrollBarStep = 0
		SKIN\Bang(('[!SetOption "ScrollBar" "H" "%d"]')\format(@scrollBarHeight))

	update: (settings) =>
		@settings = settings
		@updateScrollBar(#settings)
		@scroll()
		return #settings - STATE.NUM_SLOTS + 1

	getNumSettings: () => return #@settings

	getSetting: (index) => return @settings[index + STATE.SCROLL_INDEX - 1]
	
	updateSlot: (index) =>
		@slots[index]\update(@getSetting(index))

	scroll: () =>
		yPos = @scrollBarStart + (STATE.SCROLL_INDEX - 1) * @scrollBarStep
		SKIN\Bang(('[!SetOption "ScrollBar" "Y" "%d"]')\format(yPos))
		@updateSlot(index) for index = 1, STATE.NUM_SLOTS

	performAction: (index) => @getSetting(index)\perform()

	toggleBoolean: (index) =>
		@getSetting(index)\toggle()
		@updateSlot(index)

	startBrowsingFolderPath: (index) =>
		@getSetting(index)\startBrowsing()

	editFolderPath: (index, path) =>
		@getSetting(index)\setValue(path)
		@updateSlot(index)

	cycleSpinner: (index, direction) =>
		setting = @getSetting(index)
		setting\setIndex(setting\getIndex() + direction)
		@updateSlot(index)

	incrementInteger: (index) =>
		@getSetting(index)\incrementValue()
		@updateSlot(index)

	decrementInteger: (index) =>
		@getSetting(index)\decrementValue()
		@updateSlot(index)

	setInteger: (index, value) =>
		@getSetting(index)\setValue(value)
		@updateSlot(index)

	cycleFolderPathSpinner: (index, direction) =>
		setting = @getSetting(index)
		setting\setIndex(setting\getIndex() + direction)
		@updateSlot(index)

	startBrowsingFolderPathSpinner: (index) =>
		@getSetting(index)\startBrowsing()

	editFolderPathSpinner: (index, path) =>
		setting = @getSetting(index)
		setting\setPath(setting.index, path)
		@updateSlot(index)

	editString: (index, value) =>
		@getSetting(index)\setValue(value)
		@updateSlot(index)

return Slots
