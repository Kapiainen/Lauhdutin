export HandshakeSearch = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%s)" "#ROOTCONFIG#\\Search"]')\format(tostring(STATE.STACK_NEXT_FILTER)))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Search = (str, stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Searching for:', str)
			games = if stack then STATE.GAMES else nil
			COMPONENTS.LIBRARY\filter(ENUMS.FILTER_TYPES.TITLE, {input: str, :games, :stack})
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success
