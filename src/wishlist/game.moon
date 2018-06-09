class Game
	new: (args) =>
		assert(type(args.title) == 'string' and args.title\trim() ~= '', 'wishlist.game.Game')
		@title = utility.adjustTitle(args.title)
		assert(type(args.url) == 'string', 'wishlist.game.Game')
		@url = args.url
		@clientCommand = args.clientCommand
		assert(type(args.platformID) == 'number' and args.platformID % 1 == 0, 'wishlist.game.Game')
		@platformID = args.platformID
		assert(@platformID > 0 and @platformID < ENUMS.PLATFORM_IDS.MAX, 'wishlist.game.Game')
		@platformOverride = args.platformOverride
		if args.banner ~= nil and (io.fileExists(args.banner) or args.bannerURL ~= nil)
			@banner = args.banner
		@bannerURL = args.bannerURL
		assert(@bannerURL == nil or (@bannerURL ~= nil and @banner ~= nil), 'wishlist.game.Game')
		@expectedBanner = args.expectedBanner
		@gameID = args.gameID
		@isPrerelease = args.isPrerelease or false
		@isFree = args.isFree or false
		assert(type(args.basePrice) == 'number', 'wishlist.game.Game')
		assert(type(args.finalPrice) == 'number', 'wishlist.game.Game')
		assert(type(args.discountPercentage) == 'number', 'wishlist.game.Game')
		@basePrice = args.basePrice or 0
		@finalPrice = args.finalPrice or 0
		@discountPercentage = args.discountPercentage or 0

	merge: (other, newer = false) =>
		assert(other.__class == Game, 'main.game.Game.merge')
		log('Merging: ' .. other.title)
		if newer == true
			@banner = other.banner
			@bannerURL = other.bannerURL
			@expectedBanner = other.expectedBanner

	getBasePrice: () => return @basePrice

	getFinalPrice: () => return @finalPrice

	getDiscountPercentage: () => return @discountPercentage

	getFree: () => return @isFree

	getPrerelease: () => return @isPrerelease

	getURL: () => return @url

	getClientCommand: () => return @clientCommand

	getTitle: () => return @title

	getPlatformID: () => return @platformID

	getGameID: () => return @gameID

	setGameID: (value) => @gameID = value

	getPlatformOverride: () => return nil

	setPlatformOverride: () => return

	getPath: () => return nil

	setPath: () => return

	getProcess: () => return ''

	getProcessOverride: () => return @processOverride

	setProcessOverride: () => return

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

	isVisible: () => return true

	setVisible: () => return

	toggleVisibility: () => return

	isInstalled: () => return true

	setInstalled: () => return

	getLastPlayed: () => return 0

	setLastPlayed: () => return

	getHoursPlayed: () => return 0

	setHoursPlayed: () => return

	incrementHoursPlayed: () => return

	getTags: () => return {}

	setTags: () => return

	getPlatformTags: () => return {}

	hasTag: () => return false

	getStartingBangs: () => return {}

	setStartingBangs: () => return

	getStoppingBangs: () => return {}

	setStoppingBangs: () => return

	getIgnoresOtherBangs: () => return false

	toggleIgnoresOtherBangs: () => return

	getNotes: () => return nil

	setNotes: () => return

return Game
