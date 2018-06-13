class Toolbar
	new: (settings) =>
		assert(type(settings) == 'table', 'main.toolbar.init.Toolbar')
		unless settings\getLayoutToolbarAtTop()
			SKIN\Bang('[!SetOption "ToolbarBackground" "Y" "(#SkinHeight# - #ToolbarHeight#)]')
			SKIN\Bang('[!SetOption "ToolbarEnabler" "Y" "(#SkinHeight# - 1)]')
			SKIN\Bang('[!UpdateMeterGroup "Toolbar"]')

	hide: () => SKIN\Bang('[!HideMeterGroup "Toolbar"]')

	show: () => SKIN\Bang('[!ShowMeterGroup "Toolbar"]')

export OnToolbarMouseOver = () ->
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

export OnToolbarMouseLeave = () ->
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

export OnToolbarSearch = (stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarSearch', stack)
			COMPONENTS.SIGNAL\emit(SIGNALS.OPEN_SEARCH_MENU, stack)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarResetGames = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Resetting list of games')
			COMPONENTS.SIGNAL\emit(SIGNALS.UPDATE_GAMES, COMPONENTS.LIBRARY\get())
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarSort = (quick) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarSort', quick)
			COMPONENTS.SIGNAL\emit(SIGNALS.OPEN_SORTING_MENU, quick)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarReverseOrder = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('Reversing order of games')
			COMPONENTS.SIGNAL\emit(SIGNALS.REVERSE_GAMES)
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnToolbarFilter = (stack) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('OnToolbarFilter', stack)
			COMPONENTS.SIGNAL\emit(SIGNALS.OPEN_FILTERING_MENU, stack)
	)
	COMPONENTS.STATUS\show(err, true) unless success

return Toolbar
