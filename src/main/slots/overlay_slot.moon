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
		@hoursPlayed = LOCALIZATION\get('overlay_hours_played', '%.0f hours played')
		@singleHourPlayed = LOCALIZATION\get('overlay_single_hour_played', '%.0f hour played')
		@installGame = LOCALIZATION\get('overlay_install', 'Install')
		@hideGame = LOCALIZATION\get('overlay_hide', 'Hide')
		@alreadyHidden = LOCALIZATION\get('overlay_already_hidden', 'Already hidden')
		@unhideGame = LOCALIZATION\get('overlay_unhide', 'Unhide')
		@alreadyVisible = LOCALIZATION\get('overlay_already_visible', 'Already visible')
		@removeGame = LOCALIZATION\get('overlay_remove', 'Remove')
		@uninstalledGame = LOCALIZATION\get('overlay_uninstalled', 'Uninstalled')

	show: (index, game) =>
		return unless @contextSensitive
		unless game
			@hide()
			return
		log(('Showing overlay for %s')\format(game\getTitle()))
		image = images.play
		info = ''
		platformID = game\getPlatformID()
		switch STATE.LEFT_CLICK_ACTION
			when ENUMS.LEFT_CLICK_ACTIONS.HIDE_GAME
				if game\isVisible() == false
					info = @alreadyHidden
				else
					info = @hideGame
				image = images.hide
			when ENUMS.LEFT_CLICK_ACTIONS.UNHIDE_GAME
				if game\isVisible() == true
					info = @alreadyVisible
				else
					info = @unhideGame
				image = images.unhide
			when ENUMS.LEFT_CLICK_ACTIONS.LAUNCH_GAME
				if STATE.PLATFORM_RUNNING_STATUS[platformID] == false
					info = @platformNotRunning\format(STATE.PLATFORM_NAMES[platformID])
					image = images.error
				elseif game\isInstalled() == false
					if (platformID == ENUMS.PLATFORM_IDS.STEAM or platformID == ENUMS.PLATFORM_IDS.BATTLENET)
						info = @installGame
						image = images.install
					else
						info = @uninstalledGame
						image = images.error
			when ENUMS.LEFT_CLICK_ACTIONS.REMOVE_GAME
				info = @removeGame
				image = images.error
			else
				assert(nil, 'main.slots.overlay_slot.show')
		if image
			SKIN\Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]')\format(image))
		else
			SKIN\Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
		if info == ''
			numHoursPlayed = math.round(game\getHoursPlayed())
			if numHoursPlayed == 1
				info = @singleHourPlayed\format(numHoursPlayed)
			else
				info = @hoursPlayed\format(numHoursPlayed)
		text = ('%s#CRLF##CRLF##CRLF##CRLF#%s')\format(utility.replaceUnsupportedChars(game\getTitle()), info)
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
