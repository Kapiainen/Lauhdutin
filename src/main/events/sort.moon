export HandshakeSort = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%d, \'%s\')" "#ROOTCONFIG#\\Sort"]')\format(COMPONENTS.SETTINGS\getSorting(), STATE.VARIANT))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Sort = (sortingType) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			COMPONENTS.SETTINGS\setSorting(sortingType)
			COMPONENTS.LIBRARY\sort(sortingType, STATE.GAMES)
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success
