class OverlaySlot
	new: (settings) =>
		assert(type(settings) == 'table', 'wishlist.slots.overlay_slot.OverlaySlot')
		@contextSensitive = settings\getSlotsOverlayEnabled()
		@free = LOCALIZATION\get('overlay_free', 'Free')
		@comingSoon = LOCALIZATION\get('overlay_coming_soon', 'Coming soon')

	show: (index, game) =>
		return unless @contextSensitive
		unless game
			@hide()
			return
		log(('Showing overlay for %s')\format(game\getTitle()))
		image = nil
		upperText = ''
		lowerText = ''
		platformID = game\getPlatformID()
		switch STATE.LEFT_CLICK_ACTION
			when ENUMS.LEFT_CLICK_ACTIONS.OPEN_STORE_PAGE
				upperText = game\getTitle()
				lowerText = STATE.PLATFORM_NAMES[platformID]
			else
				assert(nil, 'wishlist.slots.overlay_slot.show')
		if image
			SKIN\Bang(('[!SetOption "SlotOverlayImage" "ImageName" "#@#main\\gfx\\%s"]')\format(image))
		else
			SKIN\Bang('[!SetOption "SlotOverlayImage" "ImageName" ""]')
		price = ''
		basePrice = game\getBasePrice()
		finalPrice = game\getFinalPrice()
		discount = game\getDiscountPercentage()
		isFree = game\getFree()
		isPrerelease = game\getPrerelease()
		if isPrerelease
			price = @comingSoon
		elseif isFree
			price = @free
		elseif discount > 0
			price = ('%s (-%d%%)')\format(finalPrice, discount)
			-- TODO: Decimal separator (. or ,)
		else
			price = finalPrice
			-- TODO: Decimal separator (. or ,)
		text = ('%s#CRLF##CRLF#%s#CRLF##CRLF#%s')\format(utility.replaceUnsupportedChars(upperText), price, utility.replaceUnsupportedChars(lowerText))
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
