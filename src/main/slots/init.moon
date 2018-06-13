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

export OnSlotHover = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(() -> COMPONENTS.SLOTS\hover(index))
	COMPONENTS.STATUS\show(err, true) unless success

export OnSlotsScroll = (direction) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			index = STATE.SCROLL_INDEX + direction * STATE.SCROLL_STEP
			if index < 1
				return
			elseif index > #STATE.GAMES - STATE.NUM_SLOTS + 1
				return
			STATE.SCROLL_INDEX = index
			log(('Scroll index is now %d')\format(STATE.SCROLL_INDEX))
			STATE.SCROLL_INDEX_UPDATED = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnSlotLeftClick = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			game = COMPONENTS.SLOTS\leftClick(index)
			return unless game
			action = switch STATE.LEFT_CLICK_ACTION
				when ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
					result = nil
					if game\isInstalled() == true
						result = launchGame
					else
						platformID = game\getPlatformID()
						if platformID == ENUMS.PLATFORM_IDS.STEAM and game\getPlatformOverride() == nil
							result = installGame
					result
				when ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME then hideGame
				when ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME then unhideGame
				when ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME then removeGame
				else
					assert(nil, 'main.init.OnLeftClickSlot')
			return unless action
			animationType = COMPONENTS.SETTINGS\getSlotsClickAnimation()
			unless COMPONENTS.ANIMATIONS\pushSlotClick(index, animationType, action, game)
				action(game)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnSlotMiddleClick = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			log('OnMiddleClickSlot', index)
			game = COMPONENTS.SLOTS\middleClick(index)
			return if game == nil
			configName = ('%s\\Game')\format(STATE.ROOT_CONFIG)
			config = RAINMETER\GetConfig(configName)
			if STATE.GAME_BEING_MODIFIED == game and config\isActive()
				STATE.GAME_BEING_MODIFIED = nil
				return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			STATE.GAME_BEING_MODIFIED = game
			if config == nil or not config\isActive()
				SKIN\Bang(('[!ActivateConfig "%s"]')\format(configName))
			else
				HandshakeGame()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnSlotLeave = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(() -> COMPONENTS.SLOTS\leave(index))
	COMPONENTS.STATUS\show(err, true) unless success

return Slots
