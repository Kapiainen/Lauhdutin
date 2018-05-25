Animation = require('main.animations.animation')

slideFrame = (option, pos, dim, scale) ->
	return {
		('[!SetOption "SlotAnimation" "%s" "%d"]')\format(option, pos + dim * scale)
		'[!UpdateMeter "SlotAnimation"]'
	}

shrinkFrame = (x, y, w, h, scale) ->
	return {
		('[!SetOption "SlotAnimation" "X" "%d"]')\format(x + (w - w * scale) / 2)
		('[!SetOption "SlotAnimation" "Y" "%d"]')\format(y + (h - h * scale) / 2)
		('[!SetOption "SlotAnimation" "W" "%d"]')\format(w * scale)
		('[!SetOption "SlotAnimation" "H" "%d"]')\format(h * scale)
		'[!UpdateMeter "SlotAnimation"]'
	}

class SlotClickAnimation extends Animation
	new: (index, typ, action, game, banner) =>
		assert(type(index) == 'number' and index % 1 == 0, 'main.animations.slot_click_animation.SlotClickAnimation')
		assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.slot_click_animation.SlotClickAnimation')
		assert(type(action) == 'function', 'main.animations.slot_click_animation.SlotClickAnimation')
		assert(type(game) == 'table', 'main.animations.slot_click_animation.SlotClickAnimation')
		assert(type(banner) == 'string', 'main.animations.slot_click_animation.SlotClickAnimation')
		resetAction = () =>
			SKIN\Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
			SKIN\Bang(('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeter "Slot%dImage"]')\format(index))
		finishAction = () => action(game)
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
			when ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_UP
				frames[2] = slideFrame('Y', slotY, -slotH, 1 / 1.8)
				frames[3] = slideFrame('Y', slotY, -slotH, 1 / 2.5)
				frames[4] = slideFrame('Y', slotY, -slotH, 1 / 4.0)
				frames[5] = slideFrame('Y', slotY, -slotH, 1 / 12.0)
				frames[6] = slideFrame('Y', slotY, -slotH, 1 / 20.0)
			when ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_RIGHT
				frames[2] = slideFrame('X', slotX, slotW, 1 / 1.8)
				frames[3] = slideFrame('X', slotX, slotW, 1 / 2.5)
				frames[4] = slideFrame('X', slotX, slotW, 1 / 4.0)
				frames[5] = slideFrame('X', slotX, slotW, 1 / 12.0)
				frames[6] = slideFrame('X', slotX, slotW, 1 / 20.0)
			when ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_DOWN
				frames[2] = slideFrame('Y', slotY, slotH, 1 / 1.8)
				frames[3] = slideFrame('Y', slotY, slotH, 1 / 2.5)
				frames[4] = slideFrame('Y', slotY, slotH, 1 / 4.0)
				frames[5] = slideFrame('Y', slotY, slotH, 1 / 12.0)
				frames[6] = slideFrame('Y', slotY, slotH, 1 / 20.0)
			when ENUMS.SLOT_CLICK_ANIMATIONS.SLIDE_LEFT
				frames[2] = slideFrame('X', slotX, -slotW, 1 / 1.8)
				frames[3] = slideFrame('X', slotX, -slotW, 1 / 2.5)
				frames[4] = slideFrame('X', slotX, -slotW, 1 / 4.0)
				frames[5] = slideFrame('X', slotX, -slotW, 1 / 12.0)
				frames[6] = slideFrame('X', slotX, -slotW, 1 / 20.0)
			when ENUMS.SLOT_CLICK_ANIMATIONS.SHRINK
				frames[2] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 1.8)
				frames[3] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 2.5)
				frames[4] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 4.0)
				frames[5] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 12.0)
				frames[6] = shrinkFrame(slotX, slotY, slotW, slotH, 1 / 20.0)
			else
				assert(nil, 'main.animations.slot_click_animation.SlotClickAnimation')
		args = {
			:resetAction
			:finishAction
			:frames
			mandatory: true
		}
		super(args)

return SlotClickAnimation
