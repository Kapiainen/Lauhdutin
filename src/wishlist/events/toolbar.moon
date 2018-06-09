require('main.events.toolbar')

export OnToolbarSort = (quick) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarSort')
			if quick
				sortingType = switch COMPONENTS.SETTINGS\getSorting()
					when ENUMS.SORTING_TYPES.ALPHABETICALLY then ENUMS.SORTING_TYPES.PRICE
					when ENUMS.SORTING_TYPES.PRICE then ENUMS.SORTING_TYPES.ALPHABETICALLY
					else ENUMS.SORTING_TYPES.ALPHABETICALLY
				sortingType = 1 if sortingType >= ENUMS.SORTING_TYPES.MAX
				return Sort(sortingType)
			configName = ('%s\\Sort')\format(STATE.ROOT_CONFIG)
			config = utility.getConfig(configName)
			if config ~= nil and config\isActive()
				return SKIN\Bang(('[!DeactivateConfig "%s"]')\format(configName))
			SKIN\Bang(('[!ActivateConfig "%s" "%sSort.ini"]')\format(configName, STATE.VARIANT))
	)
	COMPONENTS.STATUS\show(err, true) unless success
