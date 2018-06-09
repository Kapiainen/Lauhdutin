export HandshakeGame = () ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('HandshakeGame')
			gameID = STATE.GAME_BEING_MODIFIED\getGameID()
			assert(gameID ~= nil, 'main.init.HandshakeGame')
			SKIN\Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Game"]')\format(gameID))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export UpdateGame = (gameID) ->
	return unless STATE.INITIALIZED
	success, err = pcall(
		() ->
			log('UpdateGame', gameID)
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.UpdateGame')
			COMPONENTS.LIBRARY\update(game)
			STATE.SCROLL_INDEX_UPDATED = false
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OpenStorePage = (gameID) ->
	success, err = pcall(
		() ->
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.OpenStorePage')
			platform = getPlatformByGame(game)
			assert(platform ~= nil, 'main.init.OpenStorePage')
			url = platform\getStorePageURL(game)
			if url == nil
				log("Failed to get URL for opening the store page", gameID)
				return
			SKIN\Bang(('[%s]')\format(url))
	)
	COMPONENTS.STATUS\show(err, true) unless success

export ReacquireBanner = (gameID) ->
	success, err = pcall(
		() ->
			log('ReacquireBanner', gameID)
			game = getGameByID(gameID)
			assert(game ~= nil, 'main.init.OnReacquireBanner')
			log('Reacquiring a banner for', game\getTitle())
			platform = getPlatformByGame(game)
			assert(platform ~= nil, 'main.init.ReacquireBanner')
			url = platform\getBannerURL(game)
			if url == nil
				log("Failed to get URL for banner reacquisition", gameID)
				return
			STATE.BANNER_QUEUE = {game}
			bannerPath = game\getBanner()\reverse()\match('^([^%.]+%.[^\\]+)')\reverse()
			utility.downloadFile(url, bannerPath, 'OnBannerReacquisitionFinished', 'OnBannerReacquisitionError')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnBannerReacquisitionFinished = () ->
	success, err = pcall(
		() ->
			log('Successfully reacquired a banner')
			game = STATE.BANNER_QUEUE[1]
			STATE.BANNER_QUEUE = nil
			downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, SKIN\GetMeasure('Downloader')\GetOption('DownloadFile'))
			bannerPath = io.joinPaths(STATE.PATHS.RESOURCES, game\getBanner())
			os.remove(bannerPath)
			os.rename(downloadedPath, bannerPath)
			utility.stopDownloader()
			STATE.SCROLL_INDEX_UPDATED = false
			SKIN\Bang('[!UpdateMeasure "Script"]')
			SKIN\Bang('[!CommandMeasure "Script" "OnReacquiredBanner()" "#ROOTCONFIG#\\Game"]')
	)
	COMPONENTS.STATUS\show(err, true) unless success

export OnBannerReacquisitionError = () ->
	success, err = pcall(
		() ->
			log('Failed to reacquire a banner')
			STATE.BANNER_QUEUE = nil
			utility.stopDownloader()
	)
	COMPONENTS.STATUS\show(err, true) unless success
