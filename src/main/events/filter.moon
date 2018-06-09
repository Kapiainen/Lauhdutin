export HandshakeFilter = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			stack = tostring(STATE.STACK_NEXT_FILTER)
			appliedFilters = '[]'
			if STATE.STACK_NEXT_FILTER
				appliedFilters = json.encode(COMPONENTS.LIBRARY\getFilterStack())\gsub('"', '|')
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%s, \'%s\', \'%s\')" "#ROOTCONFIG#\\Filter"]')\format(stack, appliedFilters, STATE.VARIANT))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export Filter = (filterType, stack, arguments) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Filter', filterType, type(filterType), stack, type(stack), arguments)
			arguments = arguments\gsub('|', '"')
			arguments = json.decode(arguments)
			arguments.games = if stack then STATE.GAMES else nil
			arguments.stack = stack
			COMPONENTS.LIBRARY\filter(filterType, arguments)
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success
