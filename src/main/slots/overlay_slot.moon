utility = require('shared.utility')

images = {
	play: 'overlay_slot_play.png'
	error: 'overlay_slot_error.png'
	hide: 'overlay_slot_hide.png'
	unhide: 'overlay_slot_unhide.png'
	install: 'overlay_slot_install.png'
	uninstall: 'overlay_slot_uninstall.png'
}

class OverlaySlot
	new: (settings) =>
		assert(type(settings) == 'table', 'main.slots.overlay_slot.OverlaySlot')
		@contextSensitive = settings\getSlotsOverlayEnabled()
		@platformNotRunning = LOCALIZATION\get('overlay_platform_not_running', '%s is not running')
		@multipleHoursPlayed = LOCALIZATION\get('overlay_hours_played', '%.0f hours played')
		@singleHourPlayed = LOCALIZATION\get('overlay_single_hour_played', '%.0f hour played')
		@singleHourSingleMinutePlayed = LOCALIZATION\get('overlay_single_hour_single_minute_played', '%.0f hour %.0f minute played')
		@singleHourMultipleMinutesPlayed = LOCALIZATION\get('overlay_single_hour_multiple_minute_played', '%.0f hour %.0f minutes played')
		@multipleHoursSingleMinutePlayed = LOCALIZATION\get('overlay_multiple_hour_single_minute_played', '%.0f hours %.0f minute played')
		@multipleHoursMultipleMinutesPlayed = LOCALIZATION\get('overlay_multiple_hour_multiple_minute_played', '%.0f hours %.0f minutes played')
		@singleMinutePlayed = LOCALIZATION\get('overlay_single_minute_played', '%.0f minute played')
		@multipleMinutesPlayed = LOCALIZATION\get('overlay_multiple_minutes_played', '%.0f minutes played')
		@installGame = LOCALIZATION\get('overlay_install', 'Install')
		@hideGame = LOCALIZATION\get('overlay_hide', 'Hide')
		@alreadyHidden = LOCALIZATION\get('overlay_already_hidden', 'Already hidden')
		@unhideGame = LOCALIZATION\get('overlay_unhide', 'Unhide')
		@alreadyVisible = LOCALIZATION\get('overlay_already_visible', 'Already visible')
		@removeGame = LOCALIZATION\get('overlay_remove', 'Remove')
		@uninstalledGame = LOCALIZATION\get('overlay_uninstalled', 'Uninstalled')
		textOptions = {}
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.GAME_TITLE] = (game) =>
			return game\getTitle()
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.GAME_PLATFORM] = (game) =>
			return STATE.PLATFORM_NAMES[game\getPlatformID()]
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS] = (game) =>
			numHoursPlayed = math.round(game\getHoursPlayed())
			if numHoursPlayed == 1
				return @singleHourPlayed\format(numHoursPlayed)
			return @multipleHoursPlayed\format(numHoursPlayed)
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS_AND_MINUTES] = (game) =>
			hoursPlayed = game\getHoursPlayed()
			numHoursPlayed = math.floor(hoursPlayed)
			numMinutesPlayed = math.round((hoursPlayed - numHoursPlayed) * 60.0)
			if numHoursPlayed == 1
				if numMinutesPlayed == 1
					return @singleHourSingleMinutePlayed\format(numHoursPlayed, numMinutesPlayed)
				return @singleHourMultipleMinutesPlayed\format(numHoursPlayed, numMinutesPlayed)
			if numMinutesPlayed == 1
				return @multipleHoursSingleMinutePlayed\format(numHoursPlayed, numMinutesPlayed)
			return @multipleHoursMultipleMinutesPlayed\format(numHoursPlayed, numMinutesPlayed)
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.TIME_PLAYED_HOURS_OR_MINUTES] = (game) =>
			hoursPlayed = game\getHoursPlayed()
			if hoursPlayed >= 1.0 and hoursPlayed < 1.5
				return @singleHourPlayed\format(math.floor(hoursPlayed))
			elseif hoursPlayed >= 1.5
				return @multipleHoursPlayed\format(math.round(hoursPlayed))
			numMinutesPlayed = math.round((hoursPlayed - math.floor(hoursPlayed)) * 60.0)
			if numMinutesPlayed == 1
				return @singleMinutePlayed\format(numMinutesPlayed)
			return @multipleMinutesPlayed\format(numMinutesPlayed)
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.LAST_PLAYED_YYYYMMDD] = (game) =>
			lastPlayed = game\getLastPlayed()
			if lastPlayed > 315532800
				date = os.date('*t', lastPlayed)
				return ('%04.f-%02.f-%02.f')\format(date.year, date.month, date.day)
			return ''
		textOptions[ENUMS.OVERLAY_SLOT_TEXT.NOTES] = (game) =>
			notes = game\getNotes()
			if notes == nil
				return ''
			return notes
		@getUpperText = textOptions[settings\getSlotsOverlayUpperText()]
		@getLowerText = textOptions[settings\getSlotsOverlayLowerText()]
		if settings\getSlotsOverlayImagesEnabled() ~= true
			images = {}

	show: (index, game) =>
		return unless @contextSensitive
		unless game
			@hide()
			return
		log(('Showing overlay for %s')\format(game\getTitle()))
		image = images.play
		upperText = ''
		lowerText = ''
		platformID = game\getPlatformID()
		switch STATE.LEFT_CLICK_ACTION
			when ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
				upperText = game\getTitle()
				if game\isVisible() == false
					lowerText = @alreadyHidden
				else
					lowerText = @hideGame
				image = images.hide
			when ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
				upperText = game\getTitle()
				if game\isVisible() == true
					lowerText = @alreadyVisible
				else
					lowerText = @unhideGame
				image = images.unhide
			when ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
				if STATE.PLATFORM_RUNNING_STATUS[platformID] == false
					upperText = game\getTitle()
					lowerText = @platformNotRunning\format(STATE.PLATFORM_NAMES[platformID])
					image = images.error
				elseif game\isInstalled() == false
					upperText = game\getTitle()
					if platformID == ENUMS.PLATFORM_IDS.STEAM and game\getPlatformOverride() == nil
						lowerText = @installGame
						image = images.install
					else
						lowerText = @uninstalledGame
						image = images.error
				else
					upperText = @getUpperText(game) if @getUpperText ~= nil
					lowerText = @getLowerText(game) if @getLowerText ~= nil
			when ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
				upperText = game\getTitle()
				lowerText = @removeGame
				image = images.error
			else
				assert(nil, 'main.slots.overlay_slot.show')
		if image
			SKIN\Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]')\format(image))
		else
			SKIN\Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
		text = ('%s#CRLF##CRLF##CRLF##CRLF#%s')\format(utility.replaceUnsupportedChars(upperText), utility.replaceUnsupportedChars(lowerText))
		SKIN\Bang(('[!SetOption "SlotOverlayText" "Text" "%s"]')\format(text))
		slot = SKIN\GetMeter(('Slot%dImage')\format(index))
		SKIN\Bang(('[!SetOption "SlotOverlayImage" "X" "%d"]')\format(slot\GetX()))
		SKIN\Bang(('[!SetOption "SlotOverlayImage" "Y" "%d"]')\format(slot\GetY()))
		SKIN\Bang('[!ShowMeterGroup "SlotOverlay"]')
		SKIN\Bang('[!UpdateMeterGroup "SlotOverlay"]')

	hide: () =>
		SKIN\Bang('[!HideMeterGroup "SlotOverlay"]')
		SKIN\Bang('[!UpdateMeterGroup "SlotOverlay"]')

return OverlaySlot
