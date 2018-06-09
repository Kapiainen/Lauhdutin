require('main.events.slots')

openStorePage = (game) -> COMPONENTS.PROCESS\getActiveProcesses(game\getGameID())

export OnLeftClickSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			log('OnLeftClickSlot', index)
			game = COMPONENTS.SLOTS\leftClick(index)
			return unless game
			action = switch STATE.LEFT_CLICK_ACTION
				when ENUMS.LEFT_CLICK_ACTIONS.OPEN_STORE_PAGE then openStorePage
				else
					assert(nil, 'wishlist.init.OnLeftClickSlot')
			return unless action
			--animationType = COMPONENTS.SETTINGS\getSlotsClickAnimation()
			--unless COMPONENTS.ANIMATIONS\pushSlotClick(index, animationType, action, game)
			--	action(game)
			action(game)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMiddleClickSlot = (index) ->
	return unless STATE.INITIALIZED
	return if STATE.SKIN_ANIMATION_PLAYING
	return if index < 1 or index > STATE.NUM_SLOTS
	success, err = pcall(
		() ->
			return
			--log('OnMiddleClickSlot', index)
			--game = COMPONENTS.SLOTS\middleClick(index)
			--return if game == nil
			--configName = ('%s\\Game')\format(STATE.ROOT_CONFIG)
			--config = utility.getConfig(configName)
			--if STATE.GAME_BEING_MODIFIED == game and config\isActive()
			--	STATE.GAME_BEING_MODIFIED = nil
			--	return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			--STATE.GAME_BEING_MODIFIED = game
			--if config == nil or not config\isActive()
			--	SKIN\Bang(('[!ActivateConfig "%s"]')\format(configName))
			--else
			--	HandshakeGame()
	)
	COMPONENTS.STATUS\show(err, true) unless success
