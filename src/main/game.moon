utility = require('shared.utility')

class Game
	new: (args) =>
		assert(type(args.title) == 'string' and args.title\trim() ~= '', 'main.game.Game')
		@title = @_moveThe(args.title)
		assert(type(args.path) == 'string', 'main.game.Game')
		@path = args.path
		assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, 'main.game.Game')
		@platformID = args.platformID
		assert(@platformID > 0 and @platformID < ENUMS.PLATFORM_IDS.MAX, 'main.game.Game')
		@platformOverride = args.platformOverride
		if args.banner ~= nil and (io.fileExists(args.banner) or args.bannerURL ~= nil)
			@banner = args.banner
		@bannerURL = args.bannerURL
		assert(@bannerURL == nil or (@bannerURL ~= nil and @banner ~= nil), 'main.game.Game')
		@expectedBanner = args.expectedBanner
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
		assert(old.__class == Game, 'main.game.Game.merge')
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
		assert(type(value) == 'number' and value % 1 == 0, 'main.game.Game.setGameID')
		@gameID = value

	getTitle: () => return @title

	getPlatformID: () => return @platformID

	getPlatformOverride: () => return @platformOverride

	getPath: () => return @path

	getProcess: (skipOverride = false) => return if @processOverride and skipOverride == false then @processOverride else @process

	getProcessOverride: () => return @processOverride

	setProcessOverride: (process) =>
		if process == nil
			@processOverride = nil
		elseif type(process) == 'string'
			process = process\trim()
			@processOverride = if process == '' then nil else process

	getBanner: () => return @banner

	setBanner: (path) =>
		if path == nil
			@banner = nil
		elseif type(path) == 'string'
			path = path\trim()
			@banner = if path == '' then nil else path

	getExpectedBanner: () => return @expectedBanner

	setExpectedBanner: (str) =>
		if str == nil
			@expectedBanner == nil
		elseif type(str) == 'string'
			str = str\trim()
			@expectedBanner = if str == '' then nil else str

	getBannerURL: () => return @bannerURL

	setBannerURL: (url) =>
		if url == nil
			@bannerURL = nil
		elseif type(url) == 'string'
			url = url\trim()
			@bannerURL = if url == '' then nil else url

	isVisible: () => return @hidden ~= true

	setVisible: (state) => @hidden = if state == true then nil else true

	toggleVisibility: () => @hidden = if @hidden == true then nil else true

	isInstalled: () => return @uninstalled ~= true

	setInstalled: (state) =>
		assert(type(state) == 'boolean', 'main.game.Game.setInstalled')
		@uninstalled = if state == true then nil else true

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
		if str == nil
			@notes = nil
		elseif type(str) == 'string'
			@notes = if str\trim() == '' then nil else str

if RUN_TESTS
	fullArgs = {
		title: 'The Game'
		path: 'C:\\Program Files\\The Game\\game.exe'
		platformID: ENUMS.PLATFORM_IDS.SHORTCUTS
		platformOverride: 'SomePlatform'
		banner: 'Shortcuts\\SomePlatform\\The Game.jpg'
		process: 'game.exe'
		uninstalled: true
		platformTags: {
			'Completed'
			'FPS'
		}
		lastPlayed: 123456789
		hoursPlayed: 128.255
	}
	oldArgs = {
		title: 'The Game'
		path: 'C:\\Program Files\\SomeDev\\The Game\\game.exe'
		platformID: ENUMS.PLATFORM_IDS.SHORTCUTS
		banner: 'Shortcuts\\The Game.png'
		bannerURL: 'some_domain.com\\banners\\the_game.png'
		expectedBanner: 'The Game'
		process: 'game.exe'
		gameID: 7
		processOverride: 'SomeOverlay.exe'
		hidden: true
		lastPlayed: 102345678
		hoursPlayed: 135.675
		tags: {
			'Multiplayer'
		}
		startingBangs: {
			'Hide some skin '
			'Show some other skin '
		}
		stoppingBangs: {
			'Show some skin'
			'Hide some other skin'
		}
		ignoresOtherBangs: true
		notes: 'This is the game to end all games'
	}
	game = Game(fullArgs)
	assert(game\getBanner() == nil, 'Game test failed!')
	assert(game\getBannerURL() == nil, 'Game test failed!')
	assert(game\getExpectedBanner() == nil, 'Game test failed!')
	assert(game\getGameID() == nil, 'Game test failed!')
	assert(game\getHoursPlayed() == fullArgs.hoursPlayed, 'Game test failed!')
	assert(game\getIgnoresOtherBangs() == false, 'Game test failed!')
	assert(game\getLastPlayed() == fullArgs.lastPlayed, 'Game test failed!')
	assert(game\getNotes() == nil, 'Game test failed!')
	assert(game\getPath() == fullArgs.path, 'Game test failed!')
	assert(game\getPlatformID() == fullArgs.platformID, 'Game test failed!')
	assert(game\getPlatformOverride() == fullArgs.platformOverride, 'Game test failed!')
	assert(game\getProcess() == fullArgs.process, 'Game test failed!')
	assert(game\getProcess(true) == fullArgs.process, 'Game test failed!')
	assert(game\getProcessOverride() == nil, 'Game test failed!')
	assert(#game\getStartingBangs() == 0, 'Game test failed!')
	assert(#game\getStoppingBangs() == 0, 'Game test failed!')
	assert(game\getTitle() == 'Game, The', 'Game test failed!')
	assert(#game\getTags() == 0, 'Game test failed!')
	assert(#game\getPlatformTags() == #fullArgs.platformTags, 'Game test failed!')
	for tag in *fullArgs.platformTags
		assert(game\hasTag(tag) == true, 'Game test failed!')
	assert(game\isInstalled() == false, 'Game test failed!')
	assert(game\isVisible() == true, 'Game test failed!')

	oldGame = Game(oldArgs)
	assert(oldGame\getBanner() == oldArgs.banner, 'Game test failed!')
	assert(oldGame\getBannerURL() == oldArgs.bannerURL, 'Game test failed!')
	assert(oldGame\getExpectedBanner() == oldArgs.expectedBanner, 'Game test failed!')
	assert(oldGame\getGameID() == oldArgs.gameID, 'Game test failed!')
	assert(oldGame\getHoursPlayed() == oldArgs.hoursPlayed, 'Game test failed!')
	assert(oldGame\getIgnoresOtherBangs() == oldArgs.ignoresOtherBangs, 'Game test failed!')
	assert(oldGame\getLastPlayed() == oldArgs.lastPlayed, 'Game test failed!')
	assert(oldGame\getNotes() == oldArgs.notes, 'Game test failed!')
	assert(oldGame\getPath() == oldArgs.path, 'Game test failed!')
	assert(oldGame\getPlatformID() == oldArgs.platformID, 'Game test failed!')
	assert(oldGame\getPlatformOverride() == nil, 'Game test failed!')
	assert(oldGame\getProcess() == oldArgs.processOverride, 'Game test failed!')
	assert(oldGame\getProcess(true) == oldArgs.process, 'Game test failed!')
	assert(oldGame\getProcessOverride() == oldArgs.processOverride, 'Game test failed!')
	assert(#oldGame\getStartingBangs() == #oldArgs.startingBangs, 'Game test failed!')
	assert(#oldGame\getStoppingBangs() == #oldArgs.stoppingBangs, 'Game test failed!')
	assert(oldGame\getTitle() == 'Game, The', 'Game test failed!')
	assert(#oldGame\getTags() == #oldArgs.tags, 'Game test failed!')
	for tag in *oldArgs.tags
		assert(oldGame\hasTag(tag) == true, 'Game test failed!')
	assert(#oldGame\getPlatformTags() == 0, 'Game test failed!')
	assert(oldGame\isInstalled() == true, 'Game test failed!')
	assert(oldGame\isVisible() == false, 'Game test failed!')

	game\merge(oldGame)
	assert(game\getBanner() == nil, 'Game test failed!')
	assert(game\getBannerURL() == nil, 'Game test failed!')
	assert(game\getExpectedBanner() == nil, 'Game test failed!')
	assert(game\getGameID() == nil, 'Game test failed!')
	assert(game\getHoursPlayed() == oldArgs.hoursPlayed, 'Game test failed!')
	assert(game\getIgnoresOtherBangs() == oldArgs.ignoresOtherBangs, 'Game test failed!')
	assert(game\getLastPlayed() == fullArgs.lastPlayed, 'Game test failed!')
	assert(game\getNotes() == oldArgs.notes, 'Game test failed!')
	assert(game\getPath() == fullArgs.path, 'Game test failed!')
	assert(game\getPlatformID() == fullArgs.platformID, 'Game test failed!')
	assert(game\getPlatformOverride() == fullArgs.platformOverride, 'Game test failed!')
	assert(game\getProcess() == oldArgs.processOverride, 'Game test failed!')
	assert(game\getProcess(true) == fullArgs.process, 'Game test failed!')
	assert(game\getProcessOverride() == oldArgs.processOverride, 'Game test failed!')
	assert(#game\getStartingBangs() == #oldArgs.startingBangs, 'Game test failed!')
	assert(#game\getStoppingBangs() == #oldArgs.stoppingBangs, 'Game test failed!')
	assert(game\getTitle() == 'Game, The', 'Game test failed!')
	assert(#game\getTags() == #oldArgs.tags, 'Game test failed!')
	for tag in *oldArgs.tags
		assert(game\hasTag(tag) == true, 'Game test failed!')
	assert(#game\getPlatformTags() == #fullArgs.platformTags, 'Game test failed!')
	for tag in *fullArgs.platformTags
		assert(game\hasTag(tag) == true, 'Game test failed!')
	assert(game\isInstalled() == false, 'Game test failed!')
	assert(game\isVisible() == false, 'Game test failed!')

	assert(game\_moveThe('Game') == 'Game', 'Game test failed!')
	assert(game\_moveThe('Theatre of the Mind') == 'Theatre of the Mind', 'Game test failed!')
	assert(game\_moveThe('The Ides of March') == 'Ides of March, The', 'Game test failed!')
	assert(game\_parseProcess('C:\\Program Files\\SomeGame\\somegame.exe') == 'somegame.exe', 'Game test failed!')

	process = 'SomeGame.exe'
	defaultArgs = {
		title: 'Some game'
		path: ('C:\\Program Files\\SomeGame\\%s')\format(process)
		platformID: ENUMS.PLATFORM_IDS.SHORTCUTS
	}
	game = Game(defaultArgs)
	assert(game\getBanner() == nil, 'Game test failed!')
	assert(game\getBannerURL() == nil, 'Game test failed!')
	assert(game\getExpectedBanner() == nil, 'Game test failed!')
	assert(game\getGameID() == nil, 'Game test failed!')
	assert(game\getHoursPlayed() == 0, 'Game test failed!')
	assert(game\getIgnoresOtherBangs() == false, 'Game test failed!')
	assert(game\getLastPlayed() == 0, 'Game test failed!')
	assert(game\getNotes() == nil, 'Game test failed!')
	assert(game\getPath() == defaultArgs.path, 'Game test failed!')
	assert(game\getPlatformID() == defaultArgs.platformID, 'Game test failed!')
	assert(game\getPlatformOverride() == nil, 'Game test failed!')
	assert(game\getProcess() == process, 'Game test failed!')
	assert(game\getProcessOverride() == nil, 'Game test failed!')
	assert(type(game\getStartingBangs()) == 'table' and #game\getStartingBangs() == 0, 'Game test failed!')
	assert(type(game\getStoppingBangs()) == 'table' and #game\getStoppingBangs() == 0, 'Game test failed!')
	assert(game\getTitle() == defaultArgs.title, 'Game test failed!')
	assert(type(game\getTags()) == 'table' and #game\getTags() == 0, 'Game test failed!')
	assert(type(game\getPlatformTags()) == 'table' and #game\getPlatformTags() == 0, 'Game test failed!')
	assert(game\isInstalled() == true, 'Game test failed!')
	assert(game\isVisible() == true, 'Game test failed!')

	game\incrementHoursPlayed(127)
	assert(game\getHoursPlayed() == 127, 'Game test failed!')
	game\incrementHoursPlayed(128)
	assert(game\getHoursPlayed() == 255, 'Game test failed!')
	
	game\setBanner(nil)
	assert(game\getBanner() == nil, 'Game test failed!')
	game\setBanner(' ')
	assert(game\getBanner() == nil, 'Game test failed!')
	game\setBanner(' some image.jpg ')
	assert(game\getBanner() == 'some image.jpg', 'Game test failed!')
	
	game\setBannerURL(nil)
	assert(game\getBannerURL() == nil, 'Game test failed!')
	game\setBannerURL(' ')
	assert(game\getBannerURL() == nil, 'Game test failed!')
	game\setBannerURL(' some_domain.com\\banners\\some_image.jpg ')
	assert(game\getBannerURL() == 'some_domain.com\\banners\\some_image.jpg', 'Game test failed!')
	
	game\setExpectedBanner(nil)
	assert(game\getExpectedBanner() == nil, 'Game test failed!')
	game\setExpectedBanner(' ')
	assert(game\getExpectedBanner() == nil, 'Game test failed!')
	game\setExpectedBanner(' some banner.jpg ')
	assert(game\getExpectedBanner() == 'some banner.jpg', 'Game test failed!')
	
	success, err = pcall(() ->
		game\setGameID(nil)
	)
	assert(success == false, 'Game test failed!')
	game\setGameID(255)
	assert(game\getGameID() == 255, 'Game test failed!')
	
	game\setInstalled(false)
	assert(game\isInstalled() == false), 'Game test failed!'	
	game\setInstalled(true)
	assert(game\isInstalled() == true, 'Game test failed!')
	
	game\setLastPlayed(987654321)
	assert(game\getLastPlayed(987654321), 'Game test failed!')
	
	game\setNotes(nil)
	assert(game\getNotes() == nil, 'Game test failed!')
	game\setNotes(' ')
	assert(game\getNotes() == nil, 'Game test failed!')
	game\setNotes('Some notes')
	assert(game\getNotes() == 'Some notes', 'Game test failed!')
	
	game\setProcessOverride(nil)
	assert(game\getProcess() == process, 'Game test failed!')
	assert(game\getProcess(true) == process, 'Game test failed!')
	assert(game\getProcessOverride() == nil, 'Game test failed!')
	game\setProcessOverride(' ')
	assert(game\getProcess() == process, 'Game test failed!')
	assert(game\getProcess(true) == process, 'Game test failed!')
	assert(game\getProcessOverride() == nil, 'Game test failed!')
	game\setProcessOverride(' SomeOverlay.exe ')
	assert(game\getProcess() == 'SomeOverlay.exe', 'Game test failed!')
	assert(game\getProcess(true) == process, 'Game test failed!')
	assert(game\getProcessOverride() == 'SomeOverlay.exe', 'Game test failed!')
	
	game\setStartingBangs({
			' Hide some skin '
			' Show some other skin '
	})
	assert(#game\getStartingBangs() == 2, 'Game test failed!')
	
	game\setStoppingBangs({
			' Show some skin '
			' Hide some other skin '
			' Terminate process '
	})
	assert(#game\getStoppingBangs() == 3, 'Game test failed!')

	game\setTags({
		' Multiplayer '
		' '
	})
	assert(#game\getTags() == 1, 'Game test failed!')
	assert(game\hasTag('Multiplayer') == true, 'Game test failed!')
	assert(game\hasTag('FPS') == false, 'Game test failed!')
	game\setTags({})
	assert(#game\getTags() == 0, 'Game test failed!')
	assert(game\hasTag('Multiplayer') == false, 'Game test failed!')
	game\setTags({
		' '
		' FPS '
	})
	assert(#game\getTags() == 1, 'Game test failed!')
	assert(game\hasTag('FPS') == true, 'Game test failed!')
	assert(game\hasTag('Multiplayer') == false, 'Game test failed!')
	
	game\setVisible(false)
	assert(game\isVisible() == false, 'Game test failed!')
	game\setVisible(true)
	assert(game\isVisible() == true, 'Game test failed!')

	game\toggleIgnoresOtherBangs(true)
	assert(game\getIgnoresOtherBangs() == true, 'Game test failed!')
	game\toggleIgnoresOtherBangs(false)
	assert(game\getIgnoresOtherBangs() == false, 'Game test failed!')

	game\toggleVisibility()
	assert(game\isVisible() == false, 'Game test failed!')
	game\toggleVisibility()
	assert(game\isVisible() == true, 'Game test failed!')

return Game
