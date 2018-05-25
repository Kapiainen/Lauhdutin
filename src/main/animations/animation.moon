class Animation
	new: (args) =>
		assert(type(args) == 'table', 'animations.animation.Animation')
		assert(type(args.frames) == 'table', 'animations.animation.Animation')
		assert(#args.frames > 0, 'animations.animation.Animation')
		assert(args.beginAction == nil or type(args.beginAction) == 'function', 'animations.animation.Animation')
		assert(args.resetAction == nil or type(args.resetAction) == 'function', 'animations.animation.Animation')
		assert(args.finishAction == nil or type(args.finishAction) == 'function', 'animations.animation.Animation')
		assert(args.mandatory == nil or type(args.mandatory) == 'boolean', 'animations.animation.Animation')
		@frames = args.frames
		@numFrames = #@frames
		@currentFrame = 0
		@beginAction = args.beginAction
		@resetAction = args.resetAction
		@finishAction = args.finishAction
		@mandatory = args.mandatory

	play: () =>
		@currentFrame += 1
		if @currentFrame <= @numFrames
			@beginAction() if @currentFrame == 1 and @beginAction ~= nil
			bangs = @frames[@currentFrame]
			for bang in *bangs
				SKIN\Bang(bang)
			if @currentFrame == @numFrames
				@finish()

	finish: () =>
		@resetAction() if @resetAction ~= nil
		@finishAction() if @finishAction ~= nil

	hasFinished: () => return @currentFrame >= @numFrames

	cancel: () =>
		return if @isMandatory()
		@currentFrame = @numFrames

	isMandatory: () => return @mandatory == true

return Animation
