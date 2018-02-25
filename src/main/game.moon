utility = require('shared.utility')

class Game
	new: (args) =>
		assert(type(args.title) == 'string', '"Game" expected "args.title" to be a string.')
		@title = @_moveThe(args.title)
		assert(type(args.path) == 'string', '"Game" expected "args.path" to be a string.')
		@path = args.path
		assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, '"Game" expected "args.platformID" to be an integer.')
		@platformID = args.platformID
		@platformOverride = args.platformOverride
		if args.banner ~= nil and io.fileExists(args.banner)
			@banner = args.banner
		@expectedBanner = args.expectedBanner
		@bannerURL = args.bannerURL
		@process = args.process or @_parseProcess(@path)
		@uninstalled = args.uninstalled
		@gameID = args.gameID
		@platformTags = args.platformTags
		-- User-generated information, which needs to be used in the 'merge' method.
		@processOverride = args.processOverride
		@hidden = args.hidden
		@lastPlayed = args.lastPlayed
		@hoursPlayed = args.hoursPlayed
		@tags = args.tags
		@startingBangs = args.startingBangs
		@stoppingBangs = args.stoppingBangs
		@ignoresOtherBangs = args.ignoresOtherBangs
		@notes = args.notes

	merge: (old) =>
		assert(old.__class == Game, '"merge" expected "old" to be an instance of "Game".') -- TODO: Should 'Game' actually just be a table directly parsed from 'games.json'? Unnecessary allocations could be avoided.
		log('Merging: ' .. old.title)
		@processOverride = old.processOverride
		@hidden = old.hidden
		if @lastPlayed ~= nil
			if old.lastPlayed ~= nil and old.lastPlayed > @lastPlayed
				@lastPlayed = old.lastPlayed
		else
			@lastPlayed = old.lastPlayed
		if @hoursPlayed ~= nil
			if old.hoursPlayed ~= nil and old.hoursPlayed > @hoursPlayed
				@hoursPlayed = old.hoursPlayed
		else
			@hoursPlayed = old.hoursPlayed
		@tags = old.tags
		@startingBangs = old.startingBangs
		@stoppingBangs = old.stoppingBangs
		@ignoresOtherBangs = old.ignoresOtherBangs
		@notes = old.notes

	-- Move the substring 'the ' to the end of the title to ensure that searching for anything containing
	-- the substring 'the' does not lead to a bunch of unrelated games beginning with 'the ' to show up.
	-- Also helps when alphabetically sorting games.
	_moveThe: (title) =>
		if title\lower()\startsWith('the ')
			title = ('%s, %s')\format(title\sub(5), title\sub(1, 3))
		return title

	_parseProcess: (path) =>
		-- If no process is specified, then try to fall back on using the name of the game executable.
		path = path\gsub("\\", "/")\gsub("//", "/")\reverse()
		process = path\match("(exe%p[^\\/:%*?<>|]+)/")
		if process ~= nil
			return process\reverse() 
		return nil

	-- @gameID is only valid during a single session of using the skin.
	-- It is stored in games.json, but might not have the same value
	-- the next time that the skin is loaded.
	getGameID: () => return @gameID

	setGameID: (value) =>
		assert(type(value) == 'number' and value % 1 == 0, '"Game.setGameID" expected "value" to be an integer.')
		@gameID = value

	getTitle: () => return @title

	getPlatformID: () => return @platformID

	getPlatformOverride: () => return @platformOverride

	getPath: () => return @path

	getProcess: (skipOverride = false) => return if @processOverride and skipOverride == false then @processOverride else @process

	getProcessOverride: () => return @processOverride

	setProcessOverride: (process) =>
		process = process\trim()
		@processOverride = if process == '' then nil else process

	getBanner: () => return @banner

	setBanner: (path) =>
		if path == nil
			@banner = nil
		else
			path = path\trim()
			@banner = if path == '' the nil else path

	getExpectedBanner: () => return @expectedBanner

	setExpectedBanner: (str) => @expectedBanner = str

	getBannerURL: () => return @bannerURL

	setBannerURL: (url) =>
		if url == nil
			@bannerURL = nil
		else
			url = url\trim()
			@bannerURL = if url == '' then nil else url

	isVisible: () => return @hidden ~= true

	setVisible: (state) => @hidden = if state == true then nil else true

	toggleVisibility: () => @hidden = if @hidden == true then nil else true

	isInstalled: () => return @uninstalled ~= true

	setInstalled: (state) => @uninstalled = if state == true then nil else true

	getLastPlayed: () => return @lastPlayed or 0

	setLastPlayed: (value) => @lastPlayed = value

	getHoursPlayed: () => return @hoursPlayed or 0

	incrementHoursPlayed: (hours) =>
		if hours >= 0
			@hoursPlayed = 0 if @hoursPlayed == nil
			@hoursPlayed += hours

	getTags: () => return @tags or {}

	setTags: (tags) =>
		@tags = {}
		for tag in *tags
			tag = tag\trim()
			table.insert(@tags, tag) if tag ~= ''

	getPlatformTags: () => return @platformTags or {}

	hasTag: (tag) =>
		if @tags ~= nil
			for t in *@tags
				return true if t == tag
		if @platformTags ~= nil
			for t in *@platformTags
				return true if t == tag
		return false

	getStartingBangs: () => return @startingBangs or {}

	setStartingBangs: (bangs) =>
		@startingBangs = {}
		for bang in *bangs
			bang = bang\trim()
			table.insert(@startingBangs, bang) if bang ~= ''

	getStoppingBangs: () => return @stoppingBangs or {}

	setStoppingBangs: (bangs) =>
		@stoppingBangs = {}
		for bang in *bangs
			bang = bang\trim()
			table.insert(@stoppingBangs, bang) if bang ~= ''

	getIgnoresOtherBangs: () => return @ignoresOtherBangs or false

	toggleIgnoresOtherBangs: () => @ignoresOtherBangs = if @ignoresOtherBangs == true then nil else true

	getNotes: () => return @notes

	setNotes: (str) =>
		@notes = if str\trim() == '' then nil else str

return Game
