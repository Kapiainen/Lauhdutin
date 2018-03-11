Animation = require('main.animations.animation')

zoomInFrame = (x, y, w, h, scale) ->
	return {
		('[!SetOption "SlotAnimation" "X" "%d"]')\format(x - w * (scale - 1) / 2)
		('[!SetOption "SlotAnimation" "Y" "%d"]')\format(y - h * (scale - 1) / 2)
		('[!SetOption "SlotAnimation" "W" "%d"]')\format(w * scale)
		('[!SetOption "SlotAnimation" "H" "%d"]')\format(h * scale)
		'[!UpdateMeter "SlotAnimation"]'
	}

jiggleFrame = (mag) ->
	return {
		('[!SetOption "SlotAnimation" "ImageRotate" "%d"]')\format(mag)
		'[!UpdateMeter "SlotAnimation"]'
	}

shakeFrame = (option, pos, mag) ->
	return {
		('[!SetOption "SlotAnimation" "%s" "%d"]')\format(option, pos - mag)
		'[!UpdateMeter "SlotAnimation"]'
	}

class SlotHoverAnimation extends Animation
	new: (index, typ, banner) =>
		assert(type(index) == 'number' and index % 1 == 0, 'main.animations.slot_hover_animation.SlotHoverAnimation')
		assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.slot_hover_animation.SlotHoverAnimation')
		assert(type(banner) == 'string', 'main.animations.slot_hover_animation.SlotHoverAnimation')
		resetAction = () =>
			SKIN\Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
			SKIN\Bang(('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeter "Slot%dImage"]')\format(index))
		frames = {}
		slot = SKIN\GetMeter(('Slot%dImage')\format(index))
		slotX = slot\GetX()
		slotY = slot\GetY()
		slotW = slot\GetW()
		slotH = slot\GetH()
		frames[1] = {
			'[!ShowMeterGroup "Slots"]'
			('[!SetOption "SlotAnimation" "ImageName" "#@#%s"]')\format(banner)
			('[!SetOption "SlotAnimation" "X" "%d"]')\format(slotX)
			('[!SetOption "SlotAnimation" "Y" "%d"]')\format(slotY)
			('[!SetOption "SlotAnimation" "W" "%d"]')\format(slotW)
			('[!SetOption "SlotAnimation" "H" "%d"]')\format(slotH)
			('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle %d,%d,%d,%d | StrokeWidth 0"]')\format(slotX, slotY, slotW, slotH)
			'[!UpdateMeter "SlotAnimation"][!UpdateMeter "SlotsBackgroundCutout"]'
			('[!HideMeter "Slot%dImage"][!UpdateMeter "Slot%dImage"]')\format(index, index)
		}
		switch typ
			when ENUMS.SLOT_HOVER_ANIMATIONS.ZOOM_IN
				resetAction = nil
				frames[2] = zoomInFrame(slotX, slotY, slotW, slotH, 1.05)
				frames[3] = zoomInFrame(slotX, slotY, slotW, slotH, 1.10)
				frames[4] = zoomInFrame(slotX, slotY, slotW, slotH, 1.15)
			when ENUMS.SLOT_HOVER_ANIMATIONS.JIGGLE
				frames[2] = jiggleFrame(2)
				frames[3] = jiggleFrame(0)
				frames[4] = jiggleFrame(-2)
				frames[5] = jiggleFrame(0)
			when ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_LEFT_RIGHT
				frames[2] = shakeFrame('X', slotX, -5)
				frames[3] = shakeFrame('X', slotX, 0)
				frames[4] = shakeFrame('X', slotX, 5)
				frames[5] = shakeFrame('X', slotX, 0)
			when ENUMS.SLOT_HOVER_ANIMATIONS.SHAKE_UP_DOWN
				frames[2] = shakeFrame('Y', slotY, -5)
				frames[3] = shakeFrame('Y', slotY, 0)
				frames[4] = shakeFrame('Y', slotY, 5)
				frames[5] = shakeFrame('Y', slotY, 0)
			else
				assert(nil, 'main.animations.slot_hover_animation.SlotHoverAnimation')
		args = {
			:resetAction
			:frames
			mandatory: false
			finishAction: nil
		}
		super(args)

return SlotHoverAnimation
