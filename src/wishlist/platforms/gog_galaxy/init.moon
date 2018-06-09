Platform = require('wishlist.platforms.platform')

class GOGGalaxy extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.GOG_GALAXY
		@name = 'GOG Galaxy'
		@cachePath = 'cache\\gog_galaxy\\'
		@platformProcess = 'GalaxyClient.exe'
		@enabled = settings\getGOGGalaxyEnabled()
		@clientPath = settings\getGOGGalaxyClientPath()
		@communityProfileName = settings\getGOGGalaxyProfileName()
		@games = {}

	validate: () =>
		if @clientPath ~= nil
			@clientPath = io.joinPaths(@clientPath, 'GalaxyClient.exe')
			assert(io.fileExists(@clientPath, false) == true, 'The path to the GOG Galaxy client is not valid.')
		assert(type(@communityProfileName) == 'string' and #@communityProfileName > 0, 'A GOG profile name has not been defined.')

	getWishlistURL: () => return ('https://www.gog.com/u/%s/wishlist')\format(@communityProfileName), 'wishlist.txt', 'OnGOGWishlistDownloaded', 'OnGOGWishlistDownloadFailed'

	generateBannerURL: (url) => return ('https:%s_392.jpg')\format(url)

	getBanner: (productID, url) =>
		assert(type(productID) == 'string', 'wishlist.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
		assert(type(url) == 'string', 'wishlist.platforms.gog_galaxy.init.GOGGalaxy.getBanner')
		banner = @getBannerPath(productID)
		unless banner
			bannerURL = @generateBannerURL(url)
			banner = io.joinPaths(@cachePath, ('%s.jpg')\format(productID))
			expectedBanner = productID
			return banner, bannerURL, expectedBanner
		return banner, nil, nil

	generateStoreURL: (url) => return ('https://gog.com%s')\format(url)

	generateClientCommand: (id) => return ('\"%s\" \"/command=runGame\" \"/gameID=%d\"')\format(@clientPath, id)

	parseWishlist: (html) =>
		games = html\match('var gogData = {(.-)};')
		games = json.decode(('{%s}')\format(games)).products if games ~= nil
		return if games == nil
		for game in *games
			title = utility.adjustTitle(game.title)
			banner, bannerURL, expectedBanner = @getBanner(tostring(game.id), game.image)
			basePrice = tonumber(game.price.baseAmount) or 0
			finalPrice = tonumber(game.price.finalAmount) or 0
			discountPercentage = game.price.discountPercentage or 0
			isFree = if game.price.isFree == true then true else nil
			isPrerelease = if game.isComingSoon == true then true else nil
			table.insert(@games, {
				:title
				:banner
				:bannerURL
				:expectedBanner
				url: @generateStoreURL(game.url)
				clientCommand: @generateClientCommand(game.id)
				:basePrice
				:finalPrice
				:discountPercentage
				:isFree
				:isPrerelease
				platformID: @platformID
			})
		@games = [Game(args) for args in *@games]

return GOGGalaxy
