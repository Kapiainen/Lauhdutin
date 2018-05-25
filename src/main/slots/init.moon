Slot = require('main.slots.slot')
OverlaySlot = require('main.slots.overlay_slot')

class Slots
	new: (settings) =>
		assert(type(settings) == 'table', 'main.slots.init.Slots')
		@slots = [Slot(i) for i = 1, STATE.NUM_SLOTS]
		@overlaySlot = OverlaySlot(settings)
		@overlaySlot\hide()
		@hoveringSlot = 0
		@focused = true

	update: () =>
		log('Updating slots')
		SKIN\Bang('[!UpdateMeterGroup "Slots"]')

	populate: (games, startIndex = 1) =>
		log('Populating slots')
		for i = 1, #@slots
			@slots[i]\update(games[i + startIndex - 1])
		@hover(@hoveringSlot)
		return #games > 0

	hover: (index = @hoveringSlot) =>
		return false if index < 1
		@hoveringSlot = index
		return false unless @focused
		@overlaySlot\show(index, @slots[index]\getGame())
		animationType = COMPONENTS.SETTINGS\getSlotsHoverAnimation()
		if animationType ~= ENUMS.SLOT_HOVER_ANIMATIONS.NONE
			COMPONENTS.ANIMATIONS\resetSlots()
			game = @getGame(index)
			if game ~= nil
				banner = game\getBanner()
				if banner ~= nil
					COMPONENTS.ANIMATIONS\pushSlotHover(index, animationType, banner)
					return true
			COMPONENTS.ANIMATIONS\resetSlots()
			COMPONENTS.ANIMATIONS\cancelAnimations()
		return true

	getHoverIndex: () => return @hoveringSlot

	leave: (index) =>
		@overlaySlot\hide()
		return unless @focused
		@hoveringSlot = 0

	focus: () => @focused = true

	unfocus: () => @focused = false

	leftClick: (index) =>
		COMPONENTS.ANIMATIONS\resetSlots()
		return @slots[index]\getGame()

	middleClick: (index) => return @slots[index]\getGame()

	getGame: (index) => return @slots[index]\getGame()

return Slots
