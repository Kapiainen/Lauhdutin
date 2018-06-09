export OnFinishedDownloadingWishlists = () ->
	success, err = pcall(
		() ->
			log('Finished downloading wishlists')
			platform = table.remove(STATE.PLATFORM_QUEUE, 1)
			games = platform\getGames()
			log(('Found %d %s games')\format(#games, platform\getName()))
			COMPONENTS.LIBRARY\extend(games)
			for game in *games
				if game\getBannerURL() ~= nil
					if game\getBanner() == nil
						game\setBannerURL(nil)
					else
						table.insert(STATE.BANNER_QUEUE, game)
			if #STATE.PLATFORM_QUEUE > 0
				return startDetectingPlatformGames()
			STATE.PLATFORM_QUEUE = nil
			log(('%d banners to download')\format(#STATE.BANNER_QUEUE))
			if #STATE.BANNER_QUEUE > 0
				return startDownloadingBanner()
			onInitialized()
	)
	COMPONENTS.STATUS\show(err, true) unless success

require('wishlist.events.platforms.gog_galaxy')
require('wishlist.events.platforms.steam')
