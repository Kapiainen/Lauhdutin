HandshakeGame = function()
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('HandshakeGame')
    local gameID = STATE.GAME_BEING_MODIFIED:getGameID()
    assert(gameID ~= nil, 'main.init.HandshakeGame')
    return SKIN:Bang(('[!CommandMeasure "Script" "Handshake(%d)" "#ROOTCONFIG#\\Game"]'):format(gameID))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
UpdateGame = function(gameID)
  if not (STATE.INITIALIZED) then
    return 
  end
  local success, err = pcall(function()
    log('UpdateGame', gameID)
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.UpdateGame')
    COMPONENTS.LIBRARY:update(game)
    STATE.SCROLL_INDEX_UPDATED = false
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OpenStorePage = function(gameID)
  local success, err = pcall(function()
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OpenStorePage')
    local platform = getPlatformByGame(game)
    assert(platform ~= nil, 'main.init.OpenStorePage')
    local url = platform:getStorePageURL(game)
    if url == nil then
      log("Failed to get URL for opening the store page", gameID)
      return 
    end
    return SKIN:Bang(('[%s]'):format(url))
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
ReacquireBanner = function(gameID)
  local success, err = pcall(function()
    log('ReacquireBanner', gameID)
    local game = getGameByID(gameID)
    assert(game ~= nil, 'main.init.OnReacquireBanner')
    log('Reacquiring a banner for', game:getTitle())
    local platform = getPlatformByGame(game)
    assert(platform ~= nil, 'main.init.ReacquireBanner')
    local url = platform:getBannerURL(game)
    if url == nil then
      log("Failed to get URL for banner reacquisition", gameID)
      return 
    end
    STATE.BANNER_QUEUE = {
      game
    }
    local bannerPath = game:getBanner():reverse():match('^([^%.]+%.[^\\]+)'):reverse()
    return utility.downloadFile(url, bannerPath, 'OnBannerReacquisitionFinished', 'OnBannerReacquisitionError')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnBannerReacquisitionFinished = function()
  local success, err = pcall(function()
    log('Successfully reacquired a banner')
    local game = STATE.BANNER_QUEUE[1]
    STATE.BANNER_QUEUE = nil
    local downloadedPath = io.joinPaths(STATE.PATHS.DOWNLOADFILE, SKIN:GetMeasure('Downloader'):GetOption('DownloadFile'))
    local bannerPath = io.joinPaths(STATE.PATHS.RESOURCES, game:getBanner())
    os.remove(bannerPath)
    os.rename(downloadedPath, bannerPath)
    utility.stopDownloader()
    STATE.SCROLL_INDEX_UPDATED = false
    SKIN:Bang('[!UpdateMeasure "Script"]')
    return SKIN:Bang('[!CommandMeasure "Script" "OnReacquiredBanner()" "#ROOTCONFIG#\\Game"]')
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
OnBannerReacquisitionError = function()
  local success, err = pcall(function()
    log('Failed to reacquire a banner')
    STATE.BANNER_QUEUE = nil
    return utility.stopDownloader()
  end)
  if not (success) then
    return COMPONENTS.STATUS:show(err, true)
  end
end
