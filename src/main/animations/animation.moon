class Animation
	new: (args) =>
		assert(type(args) == 'table', '"Animation.new" expected a table.')
		assert(type(args.frames) == 'table', '"Animation.new" expected a table of frames.')
		assert(#args.frames > 0, '"Animation.new" expected a table of 1 or more frames.')
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
