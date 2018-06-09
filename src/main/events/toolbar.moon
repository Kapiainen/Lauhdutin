export OnMouseOverToolbar = () ->
	return unless STATE.INITIALIZED
	return unless STATE.SKIN_VISIBLE
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			COMPONENTS.TOOLBAR\show()
			COMPONENTS.SLOTS\unfocus()
			COMPONENTS.SLOTS\leave()
			COMPONENTS.ANIMATIONS\resetSlots()
			COMPONENTS.ANIMATIONS\cancelAnimations()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnMouseLeaveToolbar = () ->
	return unless STATE.INITIALIZED
	return unless STATE.SKIN_VISIBLE
	return if STATE.SKIN_ANIMATION_PLAYING
	success, err = pcall(
		() ->
			COMPONENTS.TOOLBAR\hide()
			COMPONENTS.SLOTS\focus()
			COMPONENTS.SLOTS\hover()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarResetGames = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			STATE.GAMES = COMPONENTS.LIBRARY\get()
			STATE.SCROLL_INDEX = 1
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarSearch = (stack) ->
	return unless STATE.INITIALIZED
	STATE.STACK_NEXT_FILTER = stack
	log('OnToolbarSearch', stack)
	SKIN\Bang(('[!ActivateConfig "#ROOTCONFIG#\\Search" "%sSearch.ini"]')\format(STATE.VARIANT))

-- Sorting
export OnToolbarSort = (quick) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarSort')
			if quick
				sortingType = COMPONENTS.SETTINGS\getSorting() + 1
				sortingType = 1 if sortingType >= ENUMS.SORTING_TYPES.MAX
				return Sort(sortingType)
			configName = ('%s\\Sort')\format(STATE.ROOT_CONFIG)
			config = utility.getConfig(configName)
			if config ~= nil and config\isActive()
				return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			SKIN\Bang(('[!ActivateConfig "%s" "%sSort.ini"]')\format(configName, STATE.VARIANT))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarReverseOrder = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Reversing order of games')
			table.reverse(STATE.GAMES)
			updateSlots()
	)
	COMPONENTS.STATUS\show(err, true) unless success

-- Filtering
export OnToolbarFilter = (stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			STATE.STACK_NEXT_FILTER = stack
			configName = ('%s\\Filter')\format(STATE.ROOT_CONFIG)
			config = utility.getConfig(configName)
			if config ~= nil and config\isActive()
				return HandshakeFilter()
			SKIN\Bang(('[!ActivateConfig "%s" "%sFilter.ini"]')\format(configName, STATE.VARIANT))
	)
	COMPONENTS.STATUS\show(err, true) unless success
