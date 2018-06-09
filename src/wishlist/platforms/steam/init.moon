Platform = require('wishlist.platforms.platform')

class Steam extends Platform
	new: (settings) =>
		super(settings)
		@platformID = ENUMS.PLATFORM_IDS.STEAM
		@name = "Steam"
		@cachePath = 'cache\\steam\\'
		@platformProcess = 'Steam.exe'
		@enabled = settings\getSteamEnabled()
		@steamPath = settings\getSteamPath()
		@communityID = settings\getSteamCommunityID()
		@games = {}

	validate: () =>
		clientPath = io.joinPaths(@steamPath, 'steam.exe')
		assert(io.fileExists(clientPath, false), 'The Steam path is not valid.')
		assert(@communityID ~= nil, 'A Steam ID has not been provided for downloading the community profile.')
		assert(tonumber(@communityID) ~= nil, 'The Steam ID is invalid.')

	getWishlistURL: () => return ('https://store.steampowered.com/wishlist/profiles/%s')\format(@communityID), 'wishlist.txt', 'OnSteamWishlistDownloaded', 'OnSteamWishlistDownloadFailed'

	generateStoreURL: (appID) => return ('https://store.steampowered.com/app/%s')\format(appID)

	generateClientCommand: (appID) => return ('steam://store/%s')\format(appID)

	generateBannerURL: (appID) => return ('http://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg')\format(appID)

	getBanner: (appID) =>
		assert(type(appID) == 'string', 'wishlist.platforms.steam.init.Steam.getBanner')
		banner = @getBannerPath(appID)
		unless banner
			banner = io.joinPaths(@cachePath, appID .. '.jpg')
			bannerURL = @generateBannerURL(appID)
			expectedBanner = appID
			return banner, bannerURL, expectedBanner
		return banner, nil, nil

	getPricesDiscountCurrency: (subs) =>
		base = nil
		final = nil
		discount = nil
		for sub in *subs
			b = sub.discount_block\match('original_price\">(%d+[,%.]%d+)')
			f = sub.discount_block\match('final_price\">(%d+[,%.]%d+)')
			if f ~= nil
				f = tonumber((f\gsub(',', '.')))
			if b ~= nil
				b = tonumber((b\gsub(',', '.')))
			else
				b = f
			if final == nil or (f ~= nil and f < final)
				base, final, discount = b, f, sub.discount_pct
		return base, final, discount

	parseWishlist: (html) =>
		games = html\match('var g_rgAppInfo = {(.-)};')
		games = json.decode(('{%s}')\format(games)) if games ~= nil
		return if games == nil
		for appID, game in pairs(games)
			title = utility.adjustTitle(game.name)
			banner, bannerURL, expectedBanner = @getBanner(appID)
			basePrice, finalPrice, discountPercentage = @getPricesDiscountCurrency(game.subs)
			isFree = if game.free ~= nil then game.free == 1 else nil
			isPrerelease = if game.prerelease ~= nil then game.prerelease == 1 else nil
			table.insert(@games, {
				:title
				:banner
				:bannerURL
				:expectedBanner
				url: @generateStoreURL(appID)
				clientCommand: @generateClientCommand(appID)
				basePrice: basePrice or 0
				finalPrice: finalPrice or 0
				discountPercentage: discountPercentage or 0
				:isFree
				:isPrerelease
				platformID: @platformID
			}) 
		@games = [Game(args) for args in *@games]

return Steam
