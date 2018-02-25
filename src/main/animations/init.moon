Animation = require('main.animations.animation')
SlotHoverAnimation = require('main.animations.slot_hover_animation')
SlotClickAnimation = require('main.animations.slot_click_animation')
SkinSlideAnimation = require('main.animations.skin_slide_animation')

class AnimationQueue
	new: () =>
		@queue = {}

	push: (animation) =>
		if #@queue > 0
			unless @queue[1]\isMandatory()
				@queue[1]\cancel()
			i = 2
			while i <= #@queue
				unless @queue[i]\isMandatory()
					table.remove(@queue, i)
				else
					i += 1
		table.insert(@queue, animation)

	pushSlotHover: (index, animationType, banner) =>
		return if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX
		return if STATE.SKIN_ANIMATION_PLAYING
		return unless STATE.SKIN_VISIBLE
		@push(SlotHoverAnimation(index, animationType, banner))

	pushSlotClick: (index, animationType, action, game) =>
		return false if animationType <= ENUMS.SLOT_CLICK_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_CLICK_ANIMATIONS.MAX
		return if STATE.SKIN_ANIMATION_PLAYING
		return unless STATE.SKIN_VISIBLE
		banner = game\getBanner()
		return false if banner == nil
		@push(SlotClickAnimation(index, animationType, action, game, banner))
		return true

	pushSkinSlide: (animationType, reveal) =>
		return false if animationType <= ENUMS.SKIN_ANIMATIONS.NONE or animationType >= ENUMS.SKIN_ANIMATIONS.MAX
		if STATE.SKIN_ANIMATION_PLAYING
			return
		if reveal and STATE.SKIN_VISIBLE
			return
		if not reveal and not STATE.SKIN_VISIBLE
			return
		@push(SkinSlideAnimation(animationType, reveal))
		return true

	play: () =>
		return if #@queue < 1
		@queue[1]\play()
		if @queue[1] ~= nil and @queue[1]\hasFinished()
			table.remove(@queue, 1)

	updateSlot: (index) =>
		return if index < 1
		return if COMPONENTS.SETTINGS\getSlotsHoverAnimation() == ENUMS.SLOT_HOVER_ANIMATIONS.NONE
		game = COMPONENTS.SLOTS\getGame(index)
		return if game == nil
		banner = game\getBanner()
		return if banner == nil
		SKIN\Bang(('[!SetOption "SlotAnimation" "ImageName" "#@#%s"]')\format(banner))
		SKIN\Bang('[!UpdateMeter "SlotAnimation"]')

	resetSlots: () =>
		log('Animations.resetSlots')
		animationType = COMPONENTS.SETTINGS\getSlotsHoverAnimation()
		return if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX
		SKIN\Bang('[!SetOption "SlotsBackgroundCutout" "Shape2" "Rectangle 0,0,0,0 | StrokeWidth 0"]')
		SKIN\Bang('[!UpdateMeter "SlotsBackgroundCutout"][!ShowMeterGroup "Slots"]')

	cancelAnimations: () =>
		animationType = COMPONENTS.SETTINGS\getSlotsHoverAnimation()
		return if animationType <= ENUMS.SLOT_HOVER_ANIMATIONS.NONE or animationType >= ENUMS.SLOT_HOVER_ANIMATIONS.MAX
		i = 2
		while i <= #@queue
			unless @queue[i]\isMandatory()
				table.remove(@queue, i)
			else
				i += 1
		if @queue[1] ~= nil and not @queue[1]\isMandatory()
			@queue[1]\cancel()

return AnimationQueue
