Animation = require('main.animations.animation')

slideFrame = (option, pos, mag, scale) ->
	return {
		('[!SetOption "SlotsBackground" "%s" "%d"]')\format(option, pos + mag * scale)
		'[!UpdateMeter "SlotsBackground"][!UpdateMeter "SlotsBackgroundCutout"][!UpdateMeterGroup "Slots"]'
	}

class SkinSlideAnimation extends Animation
	new: (typ, reveal) =>
		assert(type(typ) == 'number' and typ % 1 == 0, 'main.animations.skin_slide_animation.SkinSlideAnimation')
		assert(type(reveal) == 'boolean', 'main.animations.skin_slide_animation.SkinSlideAnimation')
		skin = SKIN\GetMeter('SlotsBackground')
		beginAction = nil
		finishAction = nil
		if reveal
			beginAction = () =>
				STATE.SKIN_ANIMATION_PLAYING = true
				SKIN\Bang('[!HideMeter "SkinEnabler"][!UpdateMeter "SkinEnabler"]')
			finishAction = () =>
				SKIN\Bang('[!ShowMeter "SlotAnimation"][!UpdateMeter "SlotAnimation"]')
				SKIN\Bang('[!ShowMeter "ToolbarEnabler"][!UpdateMeter "ToolbarEnabler"]')
				STATE.SKIN_VISIBLE = true
				STATE.SKIN_ANIMATION_PLAYING = false
		else
			beginAction = () =>
				STATE.SKIN_ANIMATION_PLAYING = true
				STATE.SKIN_VISIBLE = false
				SKIN\Bang('[!HideMeter "SlotAnimation"][!UpdateMeter "SlotAnimation"]')
				SKIN\Bang('[!HideMeter "ToolbarEnabler"][!UpdateMeter "ToolbarEnabler"]')
			finishAction = () =>
				setUpdateDivider(-1)
				SKIN\Bang('[!ShowMeter "SkinEnabler"][!UpdateMeter "SkinEnabler"]')
				STATE.REVEALING_DELAY = COMPONENTS.SETTINGS\getSkinRevealingDelay()
				STATE.SKIN_ANIMATION_PLAYING = false
		frames = {}
		switch typ
			when ENUMS.SKIN_ANIMATIONS.SLIDE_UP
				skinY = skin\GetY()
				skinH = skin\GetH()
				skinH = -skinH if reveal == false
				frames[1] = slideFrame('Y', skinY, skinH, 1 / 20.0)
				frames[2] = slideFrame('Y', skinY, skinH, 1 / 12.0)
				frames[3] = slideFrame('Y', skinY, skinH, 1 / 4.0)
				frames[4] = slideFrame('Y', skinY, skinH, 1 / 2.5)
				frames[5] = slideFrame('Y', skinY, skinH, 1 / 1.8)
				frames[6] = slideFrame('Y', skinY, skinH, 1)
			when ENUMS.SKIN_ANIMATIONS.SLIDE_RIGHT
				skinX = skin\GetX()
				skinW = skin\GetW()
				skinW = -skinW if reveal == true
				frames[1] = slideFrame('X', skinX, skinW, 1 / 20.0)
				frames[2] = slideFrame('X', skinX, skinW, 1 / 12.0)
				frames[3] = slideFrame('X', skinX, skinW, 1 / 4.0)
				frames[4] = slideFrame('X', skinX, skinW, 1 / 2.5)
				frames[5] = slideFrame('X', skinX, skinW, 1 / 1.8)
				frames[6] = slideFrame('X', skinX, skinW, 1)
			when ENUMS.SKIN_ANIMATIONS.SLIDE_DOWN
				skinY = skin\GetY()
				skinH = skin\GetH()
				skinH = -skinH if reveal == true
				frames[1] = slideFrame('Y', skinY, skinH, 1 / 20.0)
				frames[2] = slideFrame('Y', skinY, skinH, 1 / 12.0)
				frames[3] = slideFrame('Y', skinY, skinH, 1 / 4.0)
				frames[4] = slideFrame('Y', skinY, skinH, 1 / 2.5)
				frames[5] = slideFrame('Y', skinY, skinH, 1 / 1.8)
				frames[6] = slideFrame('Y', skinY, skinH, 1)
			when ENUMS.SKIN_ANIMATIONS.SLIDE_LEFT
				skinX = skin\GetX()
				skinW = skin\GetW()
				skinW = -skinW if reveal == false
				frames[1] = slideFrame('X', skinX, skinW, 1 / 20.0)
				frames[2] = slideFrame('X', skinX, skinW, 1 / 12.0)
				frames[3] = slideFrame('X', skinX, skinW, 1 / 4.0)
				frames[4] = slideFrame('X', skinX, skinW, 1 / 2.5)
				frames[5] = slideFrame('X', skinX, skinW, 1 / 1.8)
				frames[6] = slideFrame('X', skinX, skinW, 1)
			else
				assert(nil, 'main.animations.skin_slide_animation.SkinSlideAnimation')
		args = {
			:beginAction
			:finishAction
			:frames
			mandatory: true
			resetAction: nil
		}
		super(args)

return SkinSlideAnimation
