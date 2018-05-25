build = (settings) ->
	slotsWide = settings\getLayoutColumns()
	slotsTall = settings\getLayoutRows()
	numSlots = slotsWide * slotsTall
	slotWidth = settings\getLayoutWidth()
	slotHeight = settings\getLayoutHeight()
	horizontal = settings\getLayoutHorizontal()
	skinWidth = slotsWide * slotWidth
	skinHeight = slotsTall * slotHeight
	
	-- Variables
	contents = table.concat({
		'[Variables]'
		('SkinWidth=%d')\format(skinWidth)
		('SkinHeight=%d')\format(skinHeight)
		('SlotWidth=%d')\format(slotWidth)
		('SlotHeight=%d')\format(slotHeight)
		('SlotOverlayTextSize=%d')\format(math.round(12 * slotWidth / 320))
		'\n'
	}, '\n')

	-- Skin enabler (1)
	skinSlideAnimation = settings\getSkinSlideAnimation()
	if skinSlideAnimation ~= ENUMS.SKIN_ANIMATIONS.NONE
		enablerX = switch skinSlideAnimation
			when ENUMS.SKIN_ANIMATIONS.SLIDE_UP then 0
			when ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT then skinWidth - 1
			when ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN then 0
			when ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT then 0
			else
				assert(nil, 'settings.build_main_skin.build')
		enablerY = switch skinSlideAnimation
			when ENUMS.SKIN_ANIMATIONS.SLIDE_UP then 0
			when ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT then 0 
			when ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN then skinHeight - 1
			when ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT then 0
			else
				assert(nil, 'settings.build_main_skin.build')
		enablerWidth = switch skinSlideAnimation
			when ENUMS.SKIN_ANIMATIONS.SLIDE_UP then skinWidth
			when ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT then 1
			when ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN then skinWidth
			when ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT then 1
			else
				assert(nil, 'settings.build_main_skin.build')
		enablerHeight = switch skinSlideAnimation
			when ENUMS.SKIN_ANIMATIONS.SLIDE_UP then 1
			when ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT then skinHeight
			when ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN then 1
			when ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT then skinHeight
			else
				assert(nil, 'settings.build_main_skin.build')
		contents ..= table.concat({
			'[SkinEnabler]'
			'Meter=Image'
			'SolidColor=0,0,0,1'
			('X=%d')\format(enablerX)
			('Y=%d')\format(enablerY)
			('W=%d')\format(enablerWidth)
			('H=%d')\format(enablerHeight)
			'MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]'
			'MouseLeaveAction=[!CommandMeasure "Script" "OnMouseLeaveEnabler()"]'
			'\n'
		}, '\n')

	-- Background (1)
	contents ..= table.concat({
		'[SlotsBackground]'
		'Meter=Image'
		'SolidColor=#SlotBackgroundColor#'
		'X=0'
		'Y=0'
		'W=#SkinWidth#'
		'H=#SkinHeight#'
		'MouseScrollUpAction=[!CommandMeasure "Script" "OnScrollSlots(-1)"]'
		'MouseScrollDownAction=[!CommandMeasure "Script" "OnScrollSlots(1)"]'
		'MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]'
		'\n'
	}, '\n')

	-- Animation slot, mobile (1)
	contents ..= table.concat({
		'[SlotAnimation]'
		'Meter=Image'
		'ImageName='
		'SolidColor=0,0,0,1'
		'X=0'
		'Y=0'
		'W=0'
		'H=0'
		'PreserveAspectRatio=2'
		'\n'
	}, '\n')

	-- Background with cutout (1)
	contents ..= table.concat({
		'[SlotsBackgroundCutout]'
		'Meter=Shape'
		'X=([SlotsBackground:X])'
		'Y=([SlotsBackground:Y])'
		'Shape=Rectangle 0,0,#SkinWidth#,#SkinHeight# | Fill Color #SlotBackgroundColor# | StrokeWidth 0'
		'Shape2=Rectangle 0,0,0,0 | StrokeWidth 0'
		'Shape3=Combine Shape | XOR Shape2'
		'DynamicVariables=1'
		'\n'
	}, '\n')

	-- Regular slots, static (variable)
	index = 1
	leftMouseAction = switch settings\getDoubleClickToLaunch()
		when true then 'LeftMouseDoubleClickAction'
		else 'LeftMouseUpAction'
	gameSlot = (row, column) ->
		slot = {}
		--   String
		table.extend(slot, {
			('[Slot%dText]')\format(index)
			'Meter=String'
			'Text='
			'SolidColor=0,0,0,1'
			('X=([SlotsBackground:X] + %d)')\format((column - 1) * slotWidth + math.floor(slotWidth / 2))
			('Y=([SlotsBackground:Y] + %d)')\format((row - 1) * slotHeight + math.floor(slotHeight / 2))
			('W=%d')\format(slotWidth)
			('H=%d')\format(slotHeight)
			'FontSize=#SlotOverlayTextSize#'
			'FontColor=#SlotOverlayTextColor#'
			'StringAlign=CenterCenter'
			'StringEffect=Shadow'
			'StringStyle=Bold'
			'AntiAlias=1'
			'ClipString=1'
			'DynamicVariables=1'
			('%s=[!CommandMeasure "Script" "OnLeftClickSlot(%d)"]')\format(leftMouseAction, index)
			('MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(%d)"]')\format(index)
			('MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(%d)"]')\format(index)
			('MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(%d)"]')\format(index)
			('Group=Slots|Slot%d')\format(index)
		})
		table.insert(slot, '')
		--   Image
		table.extend(slot, {
			('[Slot%dImage]')\format(index)
			'Meter=Image'
			'ImageName='
			'SolidColor=0,0,0,1'
			('X=([SlotsBackground:X] + %d)')\format((column - 1) * slotWidth)
			('Y=([SlotsBackground:Y] + %d)')\format((row - 1) * slotHeight)
			('W=%d')\format(slotWidth)
			('H=%d')\format(slotHeight)
			'PreserveAspectRatio=2'
			'DynamicVariables=1'
			('Group=Slots|Slot%d')\format(index)
		})
		table.insert(slot, '\n')
		return slot

	if horizontal
		for row = 1, slotsTall
			for column = 1, slotsWide
				contents ..= table.concat(gameSlot(row, column), '\n')
				index += 1
	else
		for column = 1, slotsWide
			for row = 1, slotsTall
				contents ..= table.concat(gameSlot(row, column), '\n')
				index += 1
	-- Overlay slot, mobile (1)
	overlay = {}
	--   Image
	table.extend(overlay, {
		'[SlotOverlayImage]'
		'Meter=Image'
		'ImageName='
		'SolidColor=#SlotOverlayColor#'
		'X=0'
		'Y=0'
		('W=%d')\format(slotWidth)
		('H=%d')\format(slotHeight)
		'PreserveAspectRatio=2'
		'Group=SlotOverlay'
	})
	table.insert(overlay, '')
	--   String
	table.extend(overlay, {
		'[SlotOverlayText]'
		'Meter=String'
		'Text='
		('X=%dr')\format(math.floor(slotWidth / 2))
		('Y=%dr')\format(math.floor(slotHeight / 2))
		('W=%d')\format(slotWidth)
		('H=%d')\format(slotHeight)
		'FontSize=#SlotOverlayTextSize#'
		'FontColor=#SlotOverlayTextColor#'
		'StringAlign=CenterCenter'
		'StringEffect=Shadow'
		'StringStyle=Bold'
		'AntiAlias=1'
		'ClipString=1'
		'Group=SlotOverlay'
	})
	table.insert(overlay, '')
	contents ..= table.concat(overlay, '\n')
	return contents

return build
