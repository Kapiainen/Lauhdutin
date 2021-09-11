utility = require('shared.utility')
Page = require('settings.pages.page')
Settings = require('settings.types')

state = {
	languages: {}
}

-- Localization
updateLanguages = () ->
	path = 'cache\\languages.txt'
	state.languages = {}
	if io.fileExists(path)
		file = io.readFile(path)
		for line in *file\splitIntoLines()
			continue unless line\endsWith('%.txt')
			continue if line == 'languages.txt'
			language = line\match('([^%.]+)')
			table.insert(state.languages, {
				displayValue: language
			})

	englishListed = false
	for language in *state.languages
		if language.displayValue == 'English'
			englishListed = true
			break

	unless englishListed
		table.insert(state.languages, {
			displayValue: 'English'
		})
	table.sort(state.languages, (a, b) ->
		return true if a.displayValue\lower() < b.displayValue\lower()
		return false
	)

getLanguageIndex = () ->
	currentLanguage = COMPONENTS.SETTINGS\getLocalization()
	for i, language in ipairs(state.languages)
		if language.displayValue == currentLanguage
			return i
	return 1

-- Slot hover animations
state.slotHoverAnimations = {
	{displayValue: LOCALIZATION\get('setting_animation_label_none', 'None')}
	{displayValue: LOCALIZATION\get('setting_animation_label_zoom_in', 'Zoom in')}
	{displayValue: LOCALIZATION\get('setting_animation_label_jiggle', 'Jiggle')}
	{displayValue: LOCALIZATION\get('setting_animation_label_shake_left_right', 'Shake left and right')}
	{displayValue: LOCALIZATION\get('setting_animation_label_shake_up_down', 'Shake up and down')}
}
-- Slot click animations
state.slotClickAnimations = {
	{displayValue: LOCALIZATION\get('setting_animation_label_none', 'None')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_up', 'Slide upwards')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_right', 'Slide to the right')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_down', 'Slide downwards')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_left', 'Slide to the left')}
	{displayValue: LOCALIZATION\get('setting_animation_label_shrink', 'Shrink')}
}
-- Skin animations
state.skinAnimations = {
	{displayValue: LOCALIZATION\get('setting_animation_label_none', 'None')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_up', 'Slide upwards')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_right', 'Slide to the right')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_down', 'Slide downwards')}
	{displayValue: LOCALIZATION\get('setting_animation_label_slide_left', 'Slide to the left')}
}

-- Game detection frequencies
state.gameDetectionFrequencies = {
	{displayValue: LOCALIZATION\get('setting_game_detection_frequency_never', 'Never')}
	{displayValue: LOCALIZATION\get('setting_game_detection_frequency_always', 'Always')}
	{displayValue: LOCALIZATION\get('setting_game_detection_frequency_once_per_day', 'Once per day')}
}

-- Slot overlay text options
state.slotsOverlayTextOptions = {
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_none', 'Nothing')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_game_title', 'Title')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_game_platform', 'Platform')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_time_played_hours', 'Hours played')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_time_played_hours_and_minutes', 'Hours and minutes played')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_time_played_hours_or_minutes', 'Hours or minutes played')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_last_played_yyyymmdd', 'Last played (YYYY-MM-DD)')}
	{displayValue: LOCALIZATION\get('setting_slots_overlay_text_option_notes', 'Notes')}
}

class Skin extends Page
	new: () =>
		super()
		@title = LOCALIZATION\get('setting_skin_title', 'Skin')
		updateLanguages()
		@settings = {
						Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_horizontal_orientation_title', 'Horizontal orientation')
				tooltip: LOCALIZATION\get('setting_slots_horizontal_orientation_description', 'If enabled, then slots are placed from left to right. If disabled, then slots are placed from the top to the bottom.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleLayoutHorizontal()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getLayoutHorizontal()
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_slots_rows_title', 'Number of rows')
				tooltip: LOCALIZATION\get('setting_slots_rows_description', 'The number of rows of slots.')
				defaultValue: COMPONENTS.SETTINGS\getLayoutRows()
				minValue: 1
				maxValue: 16
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setLayoutRows(value)
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_slots_columns_title', 'Number of columns')
				tooltip: LOCALIZATION\get('setting_slots_columns_description', 'The number of columns of slots.')
				defaultValue: COMPONENTS.SETTINGS\getLayoutColumns()
				minValue: 1
				maxValue: 16
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setLayoutColumns(value)
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_slots_width_title', 'Slot width')
				tooltip: LOCALIZATION\get('setting_slots_width_description', 'The width of each slot in pixels.')
				defaultValue: COMPONENTS.SETTINGS\getLayoutWidth()
				minValue: 144
				maxValue: 1280
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setLayoutWidth(value)
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_slots_height_title', 'Slot height')
				tooltip: LOCALIZATION\get('setting_slots_height_description', 'The height of each slot in pixels.')
				defaultValue: COMPONENTS.SETTINGS\getLayoutHeight()
				minValue: 48
				maxValue: 600
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setLayoutHeight(value)
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_overlay_enabled_title', 'Show overlays on slots')
				tooltip: LOCALIZATION\get('setting_slots_overlay_enabled_description', 'If enabled, then an overlay with contextual information is displayed when the mouse is on a slot.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSlotsOverlayEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSlotsOverlayEnabled()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_overlay_images_enabled_title', 'Show images on slot overlays')
				tooltip: LOCALIZATION\get('setting_slots_overlay_images_enabled_description', 'If enabled, then context-sensitive images are used in the slot overlays.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSlotsOverlayImagesEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSlotsOverlayImagesEnabled()
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_slots_overlay_upper_text_title', 'Slot overlay upper text')
				tooltip: LOCALIZATION\get('setting_slots_overlay_upper_text_description', 'The text that is shown on the upper half of the slot overlay.')
				index: COMPONENTS.SETTINGS\getSlotsOverlayUpperText()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setSlotsOverlayUpperText(index)
				getValues: () =>
					return state.slotsOverlayTextOptions
				setValues: () =>
					return
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_slots_overlay_lower_text_title', 'Slot overlay lower text')
				tooltip: LOCALIZATION\get('setting_slots_overlay_lower_text_description', 'The text that is shown on the lower half of the slot overlay.')
				index: COMPONENTS.SETTINGS\getSlotsOverlayLowerText()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setSlotsOverlayLowerText(index)
				getValues: () =>
					return state.slotsOverlayTextOptions
				setValues: () =>
					return
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_slots_hover_animation_title', 'Slot hover animation')
				tooltip: LOCALIZATION\get('setting_slots_hover_animation_description', 'The animation that plays when the mouse is on a slot.')
				index: COMPONENTS.SETTINGS\getSlotsHoverAnimation()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setSlotsHoverAnimation(index)
				getValues: () =>
					return state.slotHoverAnimations
				setValues: () =>
					return
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_slots_click_animation_title', 'Slot click animation')
				tooltip: LOCALIZATION\get('setting_slots_click_animation_description', 'The animation that plays when a slot is clicked.')
				index: COMPONENTS.SETTINGS\getSlotsClickAnimation()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setSlotsClickAnimation(index)
				getValues: () =>
					return state.slotClickAnimations
				setValues: () =>
					return
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_double_click_to_launch_title', 'Double-click to launch.')
				tooltip: LOCALIZATION\get('setting_slots_double_click_to_launch_description', 'If enabled, then a game has to be double-clicked to launched.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleDoubleClickToLaunch()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getDoubleClickToLaunch()
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_skin_animation_title', 'Skin animation')
				tooltip: LOCALIZATION\get('setting_skin_animation_description', 'The animation that is played when the mouse leaves the skin. The animation is played in reverse when the mouse enters the skin\'s enabler edge.')
				index: COMPONENTS.SETTINGS\getSkinSlideAnimation()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setSkinSlideAnimation(index)
				getValues: () =>
					return state.skinAnimations
				setValues: () =>
					return
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_skin_revealing_delay_title', 'Revealing delay')
				tooltip: LOCALIZATION\get('setting_skin_revealing_delay_description', 'The duration (in milliseconds) before the skin animation is played in order to reveal the skin.')
				defaultValue: COMPONENTS.SETTINGS\getSkinRevealingDelay()
				minValue: 0
				maxValue: 10000
				stepValue: 16
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setSkinRevealingDelay(value)
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_skin_scroll_step_title', 'Scroll step')
				tooltip: LOCALIZATION\get('setting_skin_scroll_step_description', 'The number of games that are scrolled at each scroll event.')
				defaultValue: COMPONENTS.SETTINGS\getScrollStep()
				minValue: 1
				maxValue: 100
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setScrollStep(value)
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_toolbar_at_top_title', 'Toolbar at the top')
				tooltip: LOCALIZATION\get('setting_slots_toolbar_at_top_description', 'If enabled, then the toolbar is at the top of the skin.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleLayoutToolbarAtTop()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getLayoutToolbarAtTop()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_slots_center_on_monitor_title', 'Center windows on the current monitor')
				tooltip: LOCALIZATION\get('setting_slots_center_on_monitor_description', 'If enabled, then some windows (e.g. sort, filter) are centered on the monitor that the main window of this skin is on.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleCenterOnMonitor()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getCenterOnMonitor()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_skin_hide_skin_title', 'Hide skin while playing')
				tooltip: LOCALIZATION\get('setting_skin_hide_skin_description', 'If enabled, then the skin is hidden while playing a game.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleHideSkin()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getHideSkin()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_skin_show_session_title', 'Show session skin')
				tooltip: LOCALIZATION\get('setting_skin_show_session_description', 'If enabled, then a small skin that shows the current system time and session duration in HH:MM format is loaded for the duration of the game.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleShowSession()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getShowSession()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_bangs_enabled_title', 'Execute bangs')
				tooltip: LOCALIZATION\get('setting_bangs_enabled_description', 'If enabled, then the specified Rainmeter bangs are executed when a game starts or terminates.')
				toggle: () =>
					COMPONENTS.SETTINGS\toggleBangsEnabled()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getBangsEnabled()
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_starting_bangs', 'Starting bangs')
				tooltip: LOCALIZATION\get('setting_bangs_starting_description', 'These Rainmeter bangs are executed just before any game launches.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getGlobalStartingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGlobalStartingBangs')
			})
			Settings.Action({
				title: LOCALIZATION\get('button_label_stopping_bangs', 'Stopping bangs')
				tooltip: LOCALIZATION\get('setting_bangs_stopping_description', 'These Rainmeter bangs are executed just after any game terminates.')
				label: LOCALIZATION\get('button_label_edit', 'Edit')
				perform:() =>
					path = 'cache\\bangs.txt'
					bangs = COMPONENTS.SETTINGS\getGlobalStoppingBangs()
					io.writeFile(path, table.concat(bangs, '\n'))
					utility.runCommand(('""%s""')\format(io.joinPaths(STATE.PATHS.RESOURCES, path)), '', 'OnEditedGlobalStoppingBangs')
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_search_uninstalled_games_enabled_title', 'Include uninstalled games in search results')
				tooltip: LOCALIZATION\get('setting_search_uninstalled_games_enabled_description', 'If enabled, then uninstalled games are included in the results when searching by name among all games.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSearchUninstalledGamesEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSearchUninstalledGamesEnabled()
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_search_hidden_games_enabled_title', 'Include hidden games in search results')
				tooltip: LOCALIZATION\get('setting_search_hidden_games_enabled_description', 'If enabled, then hidden games are included in the results when searching by name among all games.')
				toggle: () ->
					COMPONENTS.SETTINGS\toggleSearchHiddenGamesEnabled()
					return true
				getState: () ->
					return COMPONENTS.SETTINGS\getSearchHiddenGamesEnabled()
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_localization_language_title', 'Language')
				tooltip: LOCALIZATION\get('setting_localization_language_description', 'Select a language.')
				index: getLanguageIndex()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					language = @getValues()[@index]
					COMPONENTS.SETTINGS\setLocalization(language.displayValue)
				setValues: () =>
					updateLanguages()
					@setIndex(getLanguageIndex())
				getValues: () =>
					return state.languages
			})
			Settings.Integer({
				title: LOCALIZATION\get('setting_number_of_backups_title', 'Number of backups')
				tooltip: LOCALIZATION\get('setting_number_of_backups_description', 'The number of daily backups to keep of the list of games.')
				defaultValue: COMPONENTS.SETTINGS\getNumberOfBackups()
				minValue: 0
				maxValue: 100
				onValueChanged: (value) =>
					COMPONENTS.SETTINGS\setNumberOfBackups(value)
			})
			Settings.Spinner({
				title: LOCALIZATION\get('setting_game_detection_frequency_title', 'Game detection frequency')
				tooltip: LOCALIZATION\get('setting_game_detection_frequency_description', 'How often the skin should attempt to detect games when the skin is loaded. Game detection can also be triggered manually via the context menu.')
				index: COMPONENTS.SETTINGS\getGameDetectionFrequency()
				setIndex: (index) =>
					if index < 1
						index = #@getValues()
					elseif index > #@getValues()
						index = 1
					@index = index
					COMPONENTS.SETTINGS\setGameDetectionFrequency(index)
				getValues: () =>
					return state.gameDetectionFrequencies
				setValues: () =>
					return
			})
			Settings.Boolean({
				title: LOCALIZATION\get('setting_logging_title', 'Log')
				tooltip: LOCALIZATION\get('setting_logging_description', 'If enabled, then a bunch of messages are printed to the Rainmeter log. Useful when troubleshooting issues.')
				toggle: () =>
					COMPONENTS.SETTINGS\toggleLogging()
					return true
				getState: () =>
					return COMPONENTS.SETTINGS\getLogging()
			})
		}

return Skin
