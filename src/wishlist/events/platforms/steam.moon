export OnSteamWishlistDownloaded = () ->
	success, err = pcall(
		() ->
			log('Successfully downloaded Steam wishlist')
			utility.stopDownloader()
			downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, 'wishlist.txt')
			cachedPath = io.joinPaths(STATE.PATHS.RESOURCES, STATE.PLATFORM_QUEUE[1]\getCachePath(), 'wishlist.txt')
			if io.fileExists(downloadedPath, false) and io.fileExists(cachedPath, false)
				os.remove(cachedPath)
				os.rename(downloadedPath, cachedPath)
			wishlist = ''
			if io.fileExists(cachedPath, false)
				wishlist = io.readFile(cachedPath, false)
			STATE.PLATFORM_QUEUE[1]\parseWishlist(wishlist)
			OnFinishedDownloadingWishlists()
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnSteamWishlistDownloadFailed = () ->
	success, err = pcall(
		() ->
			log('Failed to download Steam wishlist')
			utility.stopDownloader()
			OnFinishedDownloadingWishlists()
	)
	COMPONENTS.STATUS\show(err, true) unless success
